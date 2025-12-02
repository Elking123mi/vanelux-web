import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/types.dart';
import '../../services/trip_service.dart';
import '../../widgets/places_autocomplete_field.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.sedan;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  double _estimatedPrice = 0.0;
  bool _isLoadingPrice = false;
  bool _isBooking = false;

  // Coordenadas de las ubicaciones seleccionadas
  double? _pickupLat;
  double? _pickupLng;
  String? _pickupPlaceId;

  double? _destinationLat;
  double? _destinationLng;
  String? _destinationPlaceId;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'type': VehicleType.sedan,
      'name': 'Sedán Premium',
      'description': 'Cómodo para 4 pasajeros',
      'icon': FontAwesomeIcons.car,
      'basePrice': 15.0,
      'color': const Color(0xFF4A90E2),
    },
    {
      'type': VehicleType.suv,
      'name': 'SUV Ejecutivo',
      'description': 'Espacioso para 6 pasajeros',
      'icon': FontAwesomeIcons.truck,
      'basePrice': 25.0,
      'color': const Color(0xFF50C878),
    },
    {
      'type': VehicleType.luxury,
      'name': 'Vehículo de Lujo',
      'description': 'Máximo confort y exclusividad',
      'icon': FontAwesomeIcons.gem,
      'basePrice': 45.0,
      'color': const Color(0xFFFFD700),
    },
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _calculateEstimatedPrice() {
    // Solo calcular si tenemos ambas coordenadas
    if (_pickupLat != null &&
        _pickupLng != null &&
        _destinationLat != null &&
        _destinationLng != null) {
      setState(() {
        _isLoadingPrice = true;
      });

      final selectedVehicle = _vehicleTypes.firstWhere(
        (vehicle) => vehicle['type'] == _selectedVehicleType,
      );

      // Calcular distancia usando la fórmula de Haversine
      final distance = _calculateDistance(
        _pickupLat!,
        _pickupLng!,
        _destinationLat!,
        _destinationLng!,
      );
      final pricePerKm = selectedVehicle['basePrice'] as double;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _estimatedPrice = distance * pricePerKm;
            _isLoadingPrice = false;
          });
        }
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = pi / 180; // Usar pi de dart:math
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _bookTrip() async {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor selecciona ubicaciones válidas de las sugerencias',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final pickupLocation = Location(
        latitude: _pickupLat!,
        longitude: _pickupLng!,
        address: _pickupController.text,
      );

      final destinationLocation = Location(
        latitude: _destinationLat!,
        longitude: _destinationLng!,
        address: _destinationController.text,
      );

      final trip = await TripService.requestTrip(
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        vehicleType: _selectedVehicleType,
        paymentMethod: _selectedPaymentMethod,
      );

      if (mounted) {
        _showBookingSuccessDialog(trip.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar viaje: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  void _showBookingSuccessDialog(String tripId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('¡Viaje Solicitado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tu viaje ha sido solicitado exitosamente.'),
            const SizedBox(height: 10),
            Text('ID del viaje: $tripId'),
            const SizedBox(height: 10),
            const Text('Un conductor se asignará en breve.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a home
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Solicitar Viaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ubicaciones
            const Text(
              'Ubicaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Origen con autocompletado
            PlacesAutocompleteField(
              controller: _pickupController,
              hintText: 'Punto de recogida',
              prefixIcon: Icons.my_location,
              iconColor: const Color(0xFF4A90E2),
              onPlaceSelected: (placeId, description, lat, lng) {
                setState(() {
                  _pickupPlaceId = placeId;
                  _pickupLat = lat;
                  _pickupLng = lng;
                });
                _calculateEstimatedPrice();
              },
              onChanged: () {
                setState(() {
                  _pickupPlaceId = null;
                  _pickupLat = null;
                  _pickupLng = null;
                  _estimatedPrice = 0.0;
                });
              },
            ),

            const SizedBox(height: 16),

            // Campo Destino con autocompletado
            PlacesAutocompleteField(
              controller: _destinationController,
              hintText: 'Destino',
              prefixIcon: Icons.location_on,
              iconColor: const Color(0xFFFF6B6B),
              onPlaceSelected: (placeId, description, lat, lng) {
                setState(() {
                  _destinationPlaceId = placeId;
                  _destinationLat = lat;
                  _destinationLng = lng;
                });
                _calculateEstimatedPrice();
              },
              onChanged: () {
                setState(() {
                  _destinationPlaceId = null;
                  _destinationLat = null;
                  _destinationLng = null;
                  _estimatedPrice = 0.0;
                });
              },
            ),

            const SizedBox(height: 30),

            // Tipo de Vehículo
            const Text(
              'Tipo de Vehículo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            ..._vehicleTypes.map((vehicle) => _buildVehicleCard(vehicle)),

            const SizedBox(height: 30),

            // Método de Pago
            const Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: PaymentMethod.values.map((method) {
                  IconData icon;
                  String name;

                  switch (method) {
                    case PaymentMethod.cash:
                      icon = Icons.money;
                      name = 'Efectivo';
                      break;
                    case PaymentMethod.card:
                      icon = Icons.credit_card;
                      name = 'Tarjeta de Crédito';
                      break;
                    case PaymentMethod.digitalWallet:
                      icon = Icons.account_balance_wallet;
                      name = 'Billetera Digital';
                      break;
                    case PaymentMethod.corporate:
                      icon = Icons.business;
                      name = 'Corporativo';
                      break;
                    case PaymentMethod.creditCard:
                      icon = Icons.credit_card;
                      name = 'Tarjeta de Crédito';
                      break;
                    case PaymentMethod.debitCard:
                      icon = Icons.credit_card;
                      name = 'Tarjeta de Débito';
                      break;
                    case PaymentMethod.paypal:
                      icon = Icons.payment;
                      name = 'PayPal';
                      break;
                    case PaymentMethod.applePay:
                      icon = Icons.phone_iphone;
                      name = 'Apple Pay';
                      break;
                    case PaymentMethod.googlePay:
                      icon = Icons.phone_android;
                      name = 'Google Pay';
                      break;
                  }

                  return RadioListTile<PaymentMethod>(
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (PaymentMethod? value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF1A1A2E)),
                        const SizedBox(width: 12),
                        Text(name),
                      ],
                    ),
                    activeColor: const Color(0xFFFFD700),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Precio Estimado
            if (_estimatedPrice > 0 || _isLoadingPrice)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio Estimado:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isLoadingPrice)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                        ),
                      )
                    else
                      Text(
                        '\$${_estimatedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // Botón Solicitar
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isBooking ? null : _bookTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Color(0xFF1A1A2E))
                    : const Text(
                        'Solicitar Viaje',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final isSelected = _selectedVehicleType == vehicle['type'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = vehicle['type'];
        });
        _calculateEstimatedPrice();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (vehicle['color'] as Color).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(vehicle['icon'], color: vehicle['color'], size: 25),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    vehicle['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '\$${vehicle['basePrice']}/km',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
