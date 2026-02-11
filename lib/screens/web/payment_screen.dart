import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import '../../models/types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Conditional imports
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'dart:js_util' as js if (dart.library.io) 'dart:io';

// Formatter para número de tarjeta (xxxx xxxx xxxx xxxx)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formatter para fecha de expiración (MM/YY)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime? selectedDateTime;
  final String vehicleName;
  final double totalPrice;
  final double distanceMiles;
  final String duration;
  final String? flightNumber;
  final Map<String, bool> extraServices;
  final String? guestEmail;
  final String? guestName;
  final String? guestPhone;

  const PaymentScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    this.selectedDateTime,
    required this.vehicleName,
    required this.totalPrice,
    required this.distanceMiles,
    required this.duration,
    this.flightNumber,
    required this.extraServices,
    this.guestEmail,
    this.guestName,
    this.guestPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameController = TextEditingController();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
  List<LatLng> _routePoints = [];

  bool _isStripeInitialized = false;
  String? _clientSecret;
  String? _paymentIntentId;
  int? _bookingId;

  @override
  void initState() {
    super.initState();
    _loadDetailedRoute();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      // Inicializar Stripe con tu publishable key de PRODUCCIÓN (dinero real)
      final publishableKey =
          'pk_live_51RCrU0LcVFDlHSTpysEqLwQMCoqkSyky9pVxXeSV7J7xzmUQ0hDxEEhT74SbkrRiLY58bXBPUh3iJ85w95P8UHME00K8iOIvZd';

      final result = js.callMethod(html.window, 'initStripe', [publishableKey]);

      setState(() {
        _isStripeInitialized = result as bool;
      });

      print('✅ Stripe inicializado: $_isStripeInitialized');
    } catch (e) {
      print('❌ Error inicializando Stripe: $e');
    }
  }

  Future<void> _loadDetailedRoute() async {
    try {
      // Por ahora usamos línea recta
      // TODO: Implementar Directions API para ruta detallada
      setState(() {
        _routePoints = [
          LatLng(widget.pickupLat, widget.pickupLng),
          LatLng(widget.destinationLat, widget.destinationLng),
        ];

        // Crear marcadores
        _markers = {
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(widget.pickupLat, widget.pickupLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: 'Pickup',
              snippet: widget.pickupAddress,
            ),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(widget.destinationLat, widget.destinationLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: widget.destinationAddress,
            ),
          ),
        };

        // Crear polyline con la ruta
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            color: const Color(0xFF4169E1),
            width: 5,
          ),
        };

        _isLoadingRoute = false;
      });
    } catch (e) {
      print('Error loading route: $e');
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _createBookingAndIntent() async {
    try {
      // Validar nombre
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingrese su nombre completo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = await AuthService.getCurrentUser();
      final userId = user?.id;

      // Determine vehicle type
      VehicleType vehicleType = VehicleType.sedan;
      if (widget.vehicleName.toLowerCase().contains('suv')) {
        vehicleType = VehicleType.suv;
      } else if (widget.vehicleName.toLowerCase().contains('van')) {
        vehicleType = VehicleType.van;
      } else if (widget.vehicleName.toLowerCase().contains('luxury') ||
          widget.vehicleName.toLowerCase().contains('executive') ||
          widget.vehicleName.toLowerCase().contains('escalade') ||
          widget.vehicleName.toLowerCase().contains('cadillac')) {
        vehicleType = VehicleType.luxury;
      }

      // Create booking
      final bookingPayload = {
        'user_id': userId,
        'pickup_address': widget.pickupAddress,
        'pickup_lat': widget.pickupLat,
        'pickup_lng': widget.pickupLng,
        'destination_address': widget.destinationAddress,
        'destination_lat': widget.destinationLat,
        'destination_lng': widget.destinationLng,
        'pickup_time': (widget.selectedDateTime ?? DateTime.now())
            .toIso8601String(),
        'vehicle_name': widget.vehicleName,
        'passengers': 1,
        'price': widget.totalPrice,
        'distance_miles': widget.distanceMiles,
        'distance_text': '${widget.distanceMiles.toStringAsFixed(1)} mi',
        'duration_text': widget.duration,
        'service_type': vehicleType.toString().split('.').last,
        'is_scheduled': widget.selectedDateTime != null ? 1 : 0,
        'status': 'pending',
        'customer_email': widget.guestEmail ?? user?.email,
        'customer_name':
            widget.guestName ?? user?.name ?? _nameController.text.trim(),
      };

      final result = await BookingService.createBooking(bookingPayload);
      final bookingId = result['id'] ?? result['booking']?['id'];

      if (bookingId == null) {
        throw Exception('No se recibió ID de reserva');
      }

      setState(() {
        _bookingId = bookingId;
      });

      // Crear Payment Intent
      final intentResponse = await http.post(
        Uri.parse(
          'https://web-production-700fe.up.railway.app/api/v1/vlx/payments/stripe/create-intent',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': widget.totalPrice,
          'currency': 'usd',
          'customer_email': widget.guestEmail ?? user?.email,
        }),
      );

      if (intentResponse.statusCode != 200) {
        throw Exception('Error creando payment intent: ${intentResponse.body}');
      }

      final intentData = jsonDecode(intentResponse.body);

      setState(() {
        _clientSecret = intentData['client_secret'] as String;
        _paymentIntentId = intentData['payment_intent_id'] as String;
      });

      print('✅ Payment Intent creado: $_paymentIntentId');
      print('✅ Client Secret: $_clientSecret');

      // Montar el Stripe Card Element
      js.callMethod(html.window, 'createStripeCardElement', ['card-element']);

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Listo para pagar. Ingrese los datos de su tarjeta.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processPayment() async {
    try {
      // Validar nombre
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingrese su nombre completo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = await AuthService.getCurrentUser();
      final userId = user?.id;

      // Determine vehicle type
      VehicleType vehicleType = VehicleType.sedan;
      if (widget.vehicleName.toLowerCase().contains('suv')) {
        vehicleType = VehicleType.suv;
      } else if (widget.vehicleName.toLowerCase().contains('van')) {
        vehicleType = VehicleType.van;
      } else if (widget.vehicleName.toLowerCase().contains('luxury') ||
          widget.vehicleName.toLowerCase().contains('executive') ||
          widget.vehicleName.toLowerCase().contains('escalade') ||
          widget.vehicleName.toLowerCase().contains('cadillac')) {
        vehicleType = VehicleType.luxury;
      }

      // Crear booking
      final bookingPayload = {
        'user_id': userId,
        'pickup_address': widget.pickupAddress,
        'pickup_lat': widget.pickupLat,
        'pickup_lng': widget.pickupLng,
        'destination_address': widget.destinationAddress,
        'destination_lat': widget.destinationLat,
        'destination_lng': widget.destinationLng,
        'pickup_time': (widget.selectedDateTime ?? DateTime.now())
            .toIso8601String(),
        'vehicle_name': widget.vehicleName,
        'passengers': 1,
        'price': widget.totalPrice,
        'distance_miles': widget.distanceMiles,
        'distance_text': '${widget.distanceMiles.toStringAsFixed(1)} mi',
        'duration_text': widget.duration,
        'service_type': vehicleType.toString().split('.').last,
        'is_scheduled': widget.selectedDateTime != null ? 1 : 0,
        'status': 'pending',
        'customer_email': widget.guestEmail ?? user?.email,
        'customer_name':
            widget.guestName ?? user?.name ?? _nameController.text.trim(),
        // Guest booking fields for email confirmation
        'guest_email': widget.guestEmail ?? user?.email,
        'guest_first_name': (widget.guestName ?? user?.name ?? '')
            .split(' ')
            .first,
        'guest_last_name': (widget.guestName ?? user?.name ?? '')
            .split(' ')
            .skip(1)
            .join(' '),
        'guest_phone': widget.guestPhone ?? user?.phone ?? '',
      };

      print('📤 Creando booking con payload: ${jsonEncode(bookingPayload)}');

      // Validar precio antes de enviar
      final price = bookingPayload['price'];
      if (price == null ||
          price is! num ||
          (price as num).isNaN ||
          (price as num).isInfinite ||
          price < 0) {
        throw Exception('Invalid price value: $price. Cannot create booking.');
      }
      print('💵 Price validation passed: \$$price');

      // DEBUG: Verificar que los campos de guest estén presentes
      print('🔍 DEBUG - guest_email: ${bookingPayload['guest_email']}');
      print(
        '🔍 DEBUG - guest_first_name: ${bookingPayload['guest_first_name']}',
      );
      print('🔍 DEBUG - guest_last_name: ${bookingPayload['guest_last_name']}');
      print('🔍 DEBUG - guest_phone: ${bookingPayload['guest_phone']}');

      // Para guests, llamar directamente al endpoint guest
      Map<String, dynamic>? result;
      if (widget.guestEmail != null) {
        print('📤 Creando guest booking...');

        // Reintentar hasta 3 veces si falla
        int attempts = 0;
        const maxAttempts = 3;
        Exception? lastError;

        while (attempts < maxAttempts) {
          attempts++;
          print('🔄 Intento $attempts de $maxAttempts...');

          try {
            final url = Uri.parse(
              'https://web-production-700fe.up.railway.app/api/v1/vlx/bookings/guest',
            );
            print('🎯 Target URL: $url');

            final response = await http
                .post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                  },
                  body: jsonEncode(bookingPayload),
                )
                .timeout(
                  const Duration(seconds: 30),
                  onTimeout: () {
                    throw Exception('Request timeout after 30 seconds');
                  },
                );

            print('📥 Response status: ${response.statusCode}');
            print('📥 Response headers: ${response.headers}');
            print('📥 Response body: ${response.body}');

            if (response.statusCode == 201) {
              result = jsonDecode(response.body);
              print('✅ Guest booking creado exitosamente: ${result['id']}');
              break; // Éxito, salir del loop
            } else if (response.statusCode >= 500) {
              // Error de servidor, reintentar
              lastError = Exception(
                'Server error ${response.statusCode}: ${response.body}',
              );
              if (attempts < maxAttempts) {
                print('⚠️ Server error, reintentando en 2 segundos...');
                await Future.delayed(const Duration(seconds: 2));
                continue;
              }
            } else {
              // Error de cliente (4xx), no reintentar
              throw Exception('Error ${response.statusCode}: ${response.body}');
            }
          } on http.ClientException catch (e) {
            lastError = Exception(
              'Network/CORS error: ${e.message}. '
              'Verificar (1) Backend está corriendo en Railway, '
              '(2) CORS habilitado para https://vane-lux.com, '
              '(3) Endpoint /api/v1/vlx/bookings/guest existe.',
            );
            print('❌ ClientException: ${e.message}');
            print('❌ URI: ${e.uri}');

            if (attempts < maxAttempts) {
              print('🔄 Reintentando en 2 segundos...');
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }
          } on Exception catch (e) {
            lastError = e;
            print('❌ Exception: $e');

            if (attempts < maxAttempts && e.toString().contains('timeout')) {
              print('⏱️ Timeout, reintentando...');
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }
            break; // No reintentar otros errores
          }
        }

        // Si llegamos aquí sin resultado, lanzar el último error
        if (result == null || !result.containsKey('id')) {
          throw lastError ??
              Exception(
                'Failed to create guest booking after $maxAttempts attempts',
              );
        }
      } else {
        result = await BookingService.createBooking(bookingPayload);
      }

      print('📥 Resultado del booking: $result');

      final bookingId = result['id'] ?? result['booking']?['id'];

      if (bookingId == null) {
        throw Exception('No se recibió ID de reserva del servidor');
      }

      print('✅ Booking creado exitosamente: $bookingId');

      // Crear Checkout Session de Stripe
      print('📤 Creando Stripe Checkout Session...');

      final checkoutResponse = await http.post(
        Uri.parse(
          'https://web-production-700fe.up.railway.app/api/v1/vlx/payments/stripe/create-checkout-session',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId.toString(),
          'amount': widget.totalPrice,
          'currency': 'usd',
          'customer_email': widget.guestEmail ?? user?.email,
          'success_url':
              'https://vane-lux.com/?payment=success&booking_id=$bookingId',
          'cancel_url': 'https://vane-lux.com/?payment=cancelled',
        }),
      );

      print('📥 Checkout Response Status: ${checkoutResponse.statusCode}');
      print('📥 Checkout Response Body: ${checkoutResponse.body}');

      if (checkoutResponse.statusCode != 200) {
        throw Exception(
          'Error creando checkout (${checkoutResponse.statusCode}): ${checkoutResponse.body}',
        );
      }

      final checkoutData = jsonDecode(checkoutResponse.body);
      final checkoutUrl = checkoutData['url'] as String?;

      if (checkoutUrl == null) {
        throw Exception('No se recibió URL de checkout de Stripe');
      }

      print('✅ Stripe Checkout URL: $checkoutUrl');

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      // Redirigir a Stripe Checkout para procesar el pago
      html.window.location.href = checkoutUrl;
    } catch (e) {
      print('❌ Error procesando pago: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (!isMobile) _buildTopNavBar(),
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: EdgeInsets.all(isMobile ? 20 : 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 5 OF 5',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B3254),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildProgressIndicator(),

                    const SizedBox(height: 40),

                    _buildTripInfo(),

                    const SizedBox(height: 40),

                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRouteMap(),
                              const SizedBox(height: 24),
                              _buildBookingSummary(),
                              const SizedBox(height: 24),
                              _buildPaymentForm(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildRouteMap(),
                                    const SizedBox(height: 24),
                                    _buildBookingSummary(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(flex: 2, child: _buildPaymentForm()),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'VANELUX',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const Spacer(),
          _buildNavLink('HOME'),
          _buildNavLink('SERVICES'),
          _buildNavLink('FLEET'),
          _buildNavLink('ABOUT'),
          _buildNavLink('CONTACT'),
          const SizedBox(width: 32),
          const Text(
            '+1 917 599-5522',
            style: TextStyle(fontSize: 14, color: Color(0xFF0B3254)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {
          // Navigate to main screen and scroll to section
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF0B3254),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 16 : 32,
        horizontal: isMobile ? 8 : 80,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(1, 'Information', true, isMobile),
            _buildStepLine(true, isMobile),
            _buildStep(2, 'Vehicle', true, isMobile),
            _buildStepLine(true, isMobile),
            _buildStep(3, 'Login', true, isMobile),
            _buildStepLine(true, isMobile),
            _buildStep(4, 'Details', true, isMobile),
            _buildStepLine(true, isMobile),
            _buildStep(5, 'Payment', true, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isMobile) {
    return Column(
      children: [
        Container(
          width: isMobile ? 32 : 40,
          height: isMobile ? 32 : 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: isActive ? const Color(0xFF0B3254) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive, bool isMobile) {
    return Container(
      width: isMobile ? 40 : 80,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildCheckItem('Ride Information', true),
        const SizedBox(width: 32),
        _buildCheckItem('Vehicle Class', true),
        const SizedBox(width: 32),
        _buildCheckItem('Login', true),
        const SizedBox(width: 32),
        _buildCheckItem('Booking Details', true),
        const SizedBox(width: 32),
        _buildCheckItem('Payment', false, isActive: true),
      ],
    );
  }

  Widget _buildCheckItem(
    String label,
    bool isCompleted, {
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : (isActive ? const Color(0xFF4169E1) : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Center(
                  child: Text(
                    '5',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isCompleted || isActive
                ? const Color(0xFF0B3254)
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfo() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.pickupAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Destination',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.destinationAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(widget.selectedDateTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.pickupAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.destinationAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(widget.selectedDateTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildRouteMap() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.pickupLat + widget.destinationLat) / 2,
                (widget.pickupLng + widget.destinationLng) / 2,
              ),
              zoom: 11,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          if (_isLoadingRoute)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Distance: ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${widget.distanceMiles.toStringAsFixed(1)} mi',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Est. Time: ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            widget.duration,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'From: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Expanded(
                        child: Text(
                          widget.pickupAddress.split(',').first,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'To: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Expanded(
                        child: Text(
                          widget.destinationAddress.split(',').first,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Vehicle:', widget.vehicleName),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total fare:',
            '\$${widget.totalPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$${widget.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 24),

          // Nombre del titular
          const Text(
            'Cardholder name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Full name on card',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mensaje simple - el pago usa Stripe directamente
          const Text(
            'Card details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment will be processed securely through Stripe',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4169E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pay \$${widget.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.lock, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Secure Payment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your payment is processed securely. Your data is protected with bank-level encryption and we never store complete card details on our servers.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not specified';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$weekday, $month ${dateTime.day}, ${dateTime.year}, $hour:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }
}
