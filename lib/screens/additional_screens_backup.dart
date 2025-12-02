import 'package:flutter/material.dart';
import '../constants/vanelux_colors.dart';
import '../services/vanelux_api_service.dart';
import '../services/google_maps_service.dart';
import '../main.dart';

// Booking Screen
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  bool _isLoading = false;
  
  // Para autocompletado
  List<dynamic> _pickupSuggestions = [];
  List<dynamic> _dropoffSuggestions = [];
  bool _showPickupSuggestions = false;
  bool _showDropoffSuggestions = false;
  
  // Coordenadas seleccionadas
  double? _pickupLat;
  double? _pickupLng;
  String? _pickupPlaceId;
  double? _dropoffLat;
  double? _dropoffLng;
  String? _dropoffPlaceId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchPickupPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _pickupSuggestions = [];
        _showPickupSuggestions = false;
      });
      return;
    }

    try {
      final results = await GoogleMapsService.searchPlaces(query);
      setState(() {
        _pickupSuggestions = results;
        _showPickupSuggestions = results.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error searching pickup places: $e');
    }
  }
    if (query.isEmpty) {
      setState(() {
        _pickupSuggestions = [];
        _showPickupSuggestions = false;
      });
      return;
    }

    try {
      final results = await GoogleMapsService.searchPlaces(query);
      setState(() {
        _pickupSuggestions = results;
        _showPickupSuggestions = results.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error searching pickup places: $e');
    }
  }

  Future<void> _searchDropoffPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _dropoffSuggestions = [];
        _showDropoffSuggestions = false;
      });
      return;
    }

    try {
      final results = await GoogleMapsService.searchPlaces(query);
      setState(() {
        _dropoffSuggestions = results;
        _showDropoffSuggestions = results.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error searching dropoff places: $e');
    }
  }

  Future<void> _selectPickupPlace(dynamic suggestion) async {
    final placeId = suggestion['place_id'];
    final description = suggestion['description'] ?? '';
    
    setState(() {
      _pickupController.text = description;
      _showPickupSuggestions = false;
      _pickupPlaceId = placeId;
    });

    try {
      final details = await GoogleMapsService.getPlaceDetails(placeId);
      if (details != null && details['geometry'] != null) {
        final location = details['geometry']['location'];
        setState(() {
          _pickupLat = location['lat'] as double;
          _pickupLng = location['lng'] as double;
        });
      }
    } catch (e) {
      debugPrint('Error getting pickup place details: $e');
    }
  }

  Future<void> _selectDropoffPlace(dynamic suggestion) async {
    final placeId = suggestion['place_id'];
    final description = suggestion['description'] ?? '';
    
    setState(() {
      _dropoffController.text = description;
      _showDropoffSuggestions = false;
      _dropoffPlaceId = placeId;
    });

    try {
      final details = await GoogleMapsService.getPlaceDetails(placeId);
      if (details != null && details['geometry'] != null) {
        final location = details['geometry']['location'];
        setState(() {
          _dropoffLat = location['lat'] as double;
          _dropoffLng = location['lng'] as double;
        });
      }
    } catch (e) {
      debugPrint('Error getting dropoff place details: $e');
    }
  }

  _loadVehicles() async {
    try {
      final vehicles = await VaneLuxApiService.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        if (vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.first['name'] ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _bookRide() async {
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa las ubicaciones')),
      );
      return;
    }

    if (_pickupLat == null || _pickupLng == null || _dropoffLat == null || _dropoffLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona ubicaciones válidas de las sugerencias')),
      );
      return;
    }

    // Navegar a la pantalla de detalles del viaje
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(
          pickupAddress: _pickupController.text,
          dropoffAddress: _dropoffController.text,
          pickupLat: _pickupLat!,
          pickupLng: _pickupLng!,
          dropoffLat: _dropoffLat!,
          dropoffLng: _dropoffLng!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride', style: TextStyle(color: VaneLuxColors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: IconThemeData(color: VaneLuxColors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: VaneLuxColors.gold))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Location
                  Text('Pickup Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Column(
                    children: [
                      TextField(
                        controller: _pickupController,
                        decoration: InputDecoration(
                          hintText: 'Enter pickup address',
                          prefixIcon: Icon(Icons.location_on, color: VaneLuxColors.success),
                          suffixIcon: _pickupPlaceId != null
                              ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          _pickupPlaceId = null;
                          _pickupLat = null;
                          _pickupLng = null;
                          _searchPickupPlaces(value);
                        },
                      ),
                      if (_showPickupSuggestions && _pickupSuggestions.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: _pickupSuggestions.length,
                            separatorBuilder: (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _pickupSuggestions[index];
                              final description = suggestion['description'] ?? '';
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.location_on, color: VaneLuxColors.success, size: 20),
                                title: Text(description, style: TextStyle(fontSize: 14)),
                                onTap: () => _selectPickupPlace(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Dropoff Location
                  Text('Dropoff Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Column(
                    children: [
                      TextField(
                        controller: _dropoffController,
                        decoration: InputDecoration(
                          hintText: 'Enter destination address',
                          prefixIcon: Icon(Icons.flag, color: VaneLuxColors.error),
                          suffixIcon: _dropoffPlaceId != null
                              ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          _dropoffPlaceId = null;
                          _dropoffLat = null;
                          _dropoffLng = null;
                          _searchDropoffPlaces(value);
                        },
                      ),
                      if (_showDropoffSuggestions && _dropoffSuggestions.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: _dropoffSuggestions.length,
                            separatorBuilder: (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _dropoffSuggestions[index];
                              final description = suggestion['description'] ?? '';
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.flag, color: VaneLuxColors.error, size: 20),
                                title: Text(description, style: TextStyle(fontSize: 14)),
                                onTap: () => _selectDropoffPlace(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _bookRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaneLuxColors.gold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: VaneLuxColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// Trip Details Screen - Segunda pantalla para confirmar detalles del viaje
class TripDetailsScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const TripDetailsScreen({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _isLoading = true;
  String? _distance;
  String? _duration;
  double? _distanceMiles;
  List<Map<String, dynamic>> _vehicles = [];
  String _selectedVehicle = '';
  double _estimatedPrice = 0.0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    try {
      // Cargar vehículos
      final vehicles = await VaneLuxApiService.getVehicles();
      
      // Calcular distancia usando Google Maps
      final distanceData = await GoogleMapsService.getDistanceMatrix(
        '${widget.pickupLat},${widget.pickupLng}',
        '${widget.dropoffLat},${widget.dropoffLng}',
      );

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          if (vehicles.isNotEmpty) {
            _selectedVehicle = vehicles.first['name'] ?? '';
          }
          
          // Extraer distancia y duración
          if (distanceData['distance'] != null) {
            final distanceMeters = distanceData['distance']['value'] as int;
            _distanceMiles = distanceMeters * 0.000621371; // metros a millas
            _distance = '${_distanceMiles!.toStringAsFixed(2)} mi';
          }
          
          if (distanceData['duration'] != null) {
            final durationSeconds = distanceData['duration']['value'] as int;
            final minutes = (durationSeconds / 60).round();
            _duration = '$minutes min';
          }
          
          _isLoading = false;
          _calculatePrice();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculando distancia: $e'),
            backgroundColor: VaneLuxColors.error,
          ),
        );
      }
    }
  }

  void _calculatePrice() {
    if (_distanceMiles == null) return;
    
    // Tarifas base por milla según tipo de vehículo
    final rates = {
      'Sedan': 2.50,
      'SUV': 3.50,
      'Luxury': 5.00,
    };
    
    final rate = rates[_selectedVehicle] ?? 2.50;
    final baseFare = 5.0; // Tarifa base
    
    setState(() {
      _estimatedPrice = baseFare + (_distanceMiles! * rate);
    });
  }

  Future<void> _confirmBooking() async {
    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await VaneLuxApiService.createBooking(
        pickupLocation: widget.pickupAddress,
        dropoffLocation: widget.dropoffAddress,
        vehicleType: _selectedVehicle,
        scheduledTime: scheduledDateTime.toIso8601String(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reserva creada exitosamente!'),
            backgroundColor: VaneLuxColors.success,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reservar: $e'),
            backgroundColor: VaneLuxColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Viaje', style: TextStyle(color: VaneLuxColors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: IconThemeData(color: VaneLuxColors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: VaneLuxColors.gold))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de ubicaciones
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: VaneLuxColors.success),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.pickupAddress,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.flag, color: VaneLuxColors.error),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.dropoffAddress,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Distancia y Duración
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.straighten, color: VaneLuxColors.primaryBlue, size: 30),
                              SizedBox(height: 8),
                              Text(
                                _distance ?? '-- mi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: VaneLuxColors.primaryBlue,
                                ),
                              ),
                              Text('Distancia', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VaneLuxColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.access_time, color: VaneLuxColors.gold, size: 30),
                              SizedBox(height: 8),
                              Text(
                                _duration ?? '-- min',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: VaneLuxColors.gold,
                                ),
                              ),
                              Text('Duración', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Selección de Vehículo
                  Text(
                    'Selecciona tu Vehículo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  
                  ..._vehicles.map((vehicle) {
                    final isSelected = vehicle['name'] == _selectedVehicle;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = vehicle['name'] ?? '';
                          _calculatePrice();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? VaneLuxColors.gold.withOpacity(0.1) : Colors.white,
                          border: Border.all(
                            color: isSelected ? VaneLuxColors.gold : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: isSelected ? VaneLuxColors.gold : Colors.grey,
                              size: 30,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    vehicle['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: VaneLuxColors.gold),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 30),
                  
                  // Precio Estimado
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [VaneLuxColors.primaryBlue, VaneLuxColors.primaryBlue.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precio Estimado',
                          style: TextStyle(
                            color: VaneLuxColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_estimatedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: VaneLuxColors.gold,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Fecha y Hora
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: VaneLuxColors.gold),
                                    SizedBox(width: 8),
                                    Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hora', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime,
                                );
                                if (time != null) {
                                  setState(() => _selectedTime = time);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, color: VaneLuxColors.gold),
                                    SizedBox(width: 8),
                                    Text(_selectedTime.format(context)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Botón Confirmar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaneLuxColors.gold,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirmar Reserva',
                        style: TextStyle(
                          color: VaneLuxColors.primaryBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
// Trips Screen
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  _loadBookings() async {
    try {
      final bookings = await VaneLuxApiService.getUserBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips', style: TextStyle(color: VaneLuxColors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: const IconThemeData(color: VaneLuxColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: VaneLuxColors.gold))
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: VaneLuxColors.textGray),
                      SizedBox(height: 20),
                      Text(
                        'No trips yet',
                        style: TextStyle(fontSize: 18, color: VaneLuxColors.textGray),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: VaneLuxColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['vehicleType'] ?? 'Luxury Vehicle',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: VaneLuxColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('From: ${booking['pickupLocation'] ?? 'N/A'}'),
                          Text('To: ${booking['dropoffLocation'] ?? 'N/A'}'),
                          Text('Date: ${booking['scheduledTime'] ?? 'N/A'}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: VaneLuxColors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: IconThemeData(color: VaneLuxColors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: VaneLuxColors.gold,
              child: Icon(Icons.person, size: 50, color: VaneLuxColors.white),
            ),
            SizedBox(height: 20),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'john.doe@email.com',
              style: TextStyle(fontSize: 16, color: VaneLuxColors.textGray),
            ),
            SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.payment, color: VaneLuxColors.gold),
              title: Text('Payment Methods'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history, color: VaneLuxColors.gold),
              title: Text('Trip History'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TripsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: VaneLuxColors.gold),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await VaneLuxApiService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaneLuxColors.error,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: VaneLuxColors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}