import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_maps_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'login_screen.dart';
import 'booking_details_screen.dart';

class TripDetailsWebScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime? selectedDateTime;
  final String serviceType;

  const TripDetailsWebScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    this.selectedDateTime,
    this.serviceType = 'Point to Point',
  });

  @override
  State<TripDetailsWebScreen> createState() => _TripDetailsWebScreenState();
}

class _VehicleOption {
  final String name;
  final String description;
  final int passengers;
  final int luggage;
  final String imageUrl;
  final double basePrice;
  final double perMileRate;

  const _VehicleOption({
    required this.name,
    required this.description,
    required this.passengers,
    required this.luggage,
    required this.imageUrl,
    required this.basePrice,
    required this.perMileRate,
  });
}

class _TripDetailsWebScreenState extends State<TripDetailsWebScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
  String? _errorMessage;
  User? _currentUser;
  
  double? _distanceMiles;
  String? _duration;
  String? _selectedVehicleName;
  
  final List<_VehicleOption> _vehicles = const [
    _VehicleOption(
      name: 'Mercedes-Maybach S 680',
      description: 'Black exterior, premium interior, enhanced features, entertainment system',
      passengers: 4,
      luggage: 3,
      imageUrl: 'https://images.unsplash.com/photo-1617450365226-a9994d16ff2a?auto=format&fit=crop&w=400&q=80',
      basePrice: 3908.54,
      perMileRate: 3.5,
    ),
    _VehicleOption(
      name: 'Cadillac Escalade ESV',
      description: 'Black exterior, premium interior, entertainment system',
      passengers: 6,
      luggage: 6,
      imageUrl: 'https://images.unsplash.com/photo-1571422789648-ef357f10d838?auto=format&fit=crop&w=400&q=80',
      basePrice: 2812.96,
      perMileRate: 2.5,
    ),
    _VehicleOption(
      name: 'Range Rover Autobiography',
      description: 'Black exterior, premium sound system, WiFi, executive comfort',
      passengers: 4,
      luggage: 4,
      imageUrl: 'https://images.unsplash.com/photo-1617813486164-1f910f7cc8e9?auto=format&fit=crop&w=400&q=80',
      basePrice: 3500.00,
      perMileRate: 3.2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRouteData();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadRouteData() async {
    try {
      print('🚗 Starting _loadRouteData...');
      print('Pickup: ${widget.pickupLat},${widget.pickupLng}');
      print('Destination: ${widget.destinationLat},${widget.destinationLng}');
      
      // Obtener distancia y duración
      final distanceData = await GoogleMapsService.getDistanceMatrix(
        '${widget.pickupLat},${widget.pickupLng}',
        '${widget.destinationLat},${widget.destinationLng}',
      );

      print('📦 Distance Matrix Response: $distanceData');

      // El JS bridge ya devuelve los datos procesados directamente
      // Formato: {distance: "9.1 mi", distance_value: 14616, duration: "19 mins", duration_value: 1130}
      if (distanceData.containsKey('distance_value') && distanceData.containsKey('duration_value')) {
        final distanceMeters = distanceData['distance_value'] as int;
        final durationSeconds = distanceData['duration_value'] as int;

        print('📏 Distance meters: $distanceMeters');
        print('⏱️ Duration seconds: $durationSeconds');

        setState(() {
          _distanceMiles = distanceMeters * 0.000621371;
          final hours = durationSeconds ~/ 3600;
          final minutes = (durationSeconds % 3600) ~/ 60;
          _duration = hours > 0 ? '$hours hours $minutes mins' : '$minutes mins';
          print('✅ Distance set to: $_distanceMiles miles, Duration: $_duration');
        });
      } else {
        print('❌ distance_value or duration_value not found in response!');
      }

      // Crear marcadores
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(widget.pickupLat, widget.pickupLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(widget.destinationLat, widget.destinationLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
        
        // Dibujar línea entre puntos
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(widget.pickupLat, widget.pickupLng),
              LatLng(widget.destinationLat, widget.destinationLng),
            ],
            color: Colors.blue,
            width: 4,
          ),
        };
        
        _isLoadingRoute = false;
        print('🎉 State updated successfully!');
      });
    } catch (e, stackTrace) {
      print('❌ ERROR in _loadRouteData: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Error loading trip data: $e';
        _isLoadingRoute = false;
      });
    }
  }

  double _calculateTotalPrice(_VehicleOption vehicle) {
    if (_distanceMiles == null) return 0.0;
    return vehicle.basePrice + (_distanceMiles! * vehicle.perMileRate);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not specified';
    return '${_getWeekday(dateTime)}, ${_getMonth(dateTime)} ${dateTime.day}, ${dateTime.year}, ${_formatTime(dateTime)}';
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // BARRA DE NAVEGACIÓN SUPERIOR
          _buildTopNavBar(),
          
          // INDICADOR DE PASOS
          _buildStepIndicator(),
          
          // INFORMACIÓN DE UBICACIONES Y FECHA
          _buildTripInfo(),
          
          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // MAPA
                  _buildMapSection(),
                  
                  const SizedBox(height: 40),
                  
                  // TÍTULO "Select Your Vehicle"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: const Text(
                      'Select Your Vehicle',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B3254),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // INFO DE RUTA
                  if (_distanceMiles != null && _duration != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Route: ${_distanceMiles!.toStringAsFixed(0)} mi • $_duration',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // LISTA DE VEHÍCULOS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Column(
                      children: _vehicles.map((vehicle) => 
                        _buildVehicleCard(vehicle)
                      ).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                ],
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
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(width: 24),
          const Text(
            'CITIES WE SERVE',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(width: 32),
          // Mostrar botones de LOGIN/SIGNUP solo si NO hay usuario autenticado
          if (_currentUser == null) ...[
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login to continue')),
                );
              },
              child: const Text('LOGIN', style: TextStyle(color: Color(0xFF0B3254))),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please signup to continue')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37)),
              ),
              child: const Text('SIGNUP', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ] else ...[
            // Mostrar información del usuario cuando está autenticado
            PopupMenuButton<String>(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFD4AF37),
                    child: Text(
                      _currentUser!.name.isNotEmpty 
                        ? _currentUser!.name[0].toUpperCase() 
                        : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentUser!.name,
                    style: const TextStyle(
                      color: Color(0xFF0B3254),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF0B3254)),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: const Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('My Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'bookings',
                  child: const Row(
                    children: [
                      Icon(Icons.history, size: 20),
                      SizedBox(width: 8),
                      Text('My Bookings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'logout') {
                  await AuthService.logout();
                  setState(() {
                    _currentUser = null;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Information', true),
          _buildStepLine(true),
          _buildStep(2, 'Vehicle', true),
          _buildStepLine(false),
          _buildStep(3, 'Login', false),
          _buildStepLine(false),
          _buildStep(4, 'Details', false),
          _buildStepLine(false),
          _buildStep(5, 'Payment', false),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
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
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF0B3254) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 80,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF0B3254)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pickup Location',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.pickupAddress,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          const Icon(Icons.location_on, color: Color(0xFF0B3254)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destination',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.destinationAddress,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          const Icon(Icons.calendar_today, color: Color(0xFF0B3254)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date & Time',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _formatDateTime(widget.selectedDateTime),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isLoadingRoute
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (widget.pickupLat + widget.destinationLat) / 2,
                    (widget.pickupLng + widget.destinationLng) / 2,
                  ),
                  zoom: 10,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
      ),
    );
  }

  Widget _buildVehicleCard(_VehicleOption vehicle) {
    final totalPrice = _calculateTotalPrice(vehicle);
    final isSelected = _selectedVehicleName == vehicle.name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGEN DEL VEHÍCULO
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              vehicle.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.directions_car, size: 64, color: Colors.grey);
              },
            ),
          ),
          
          const SizedBox(width: 32),
          
          // INFORMACIÓN DEL VEHÍCULO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vehicle.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeature(Icons.person, '${vehicle.passengers} passengers'),
                    const SizedBox(width: 24),
                    _buildFeature(Icons.luggage, '${vehicle.luggage} luggage'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeature(Icons.wifi, 'Free WiFi'),
                    const SizedBox(width: 24),
                    _buildFeature(Icons.access_time, '90 min wait time'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeature(Icons.lock, 'Secure payment'),
                    const SizedBox(width: 24),
                    _buildFeature(Icons.check_circle, 'Free cancellation'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 32),
          
          // PRECIO Y BOTÓN
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total price',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3254),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Base service (${_distanceMiles?.toStringAsFixed(0) ?? "0"} mi): \$${vehicle.basePrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Credit card fee (4%): \$${(totalPrice * 0.04).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'STC charge (14%): \$${(totalPrice * 0.14).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Admin fee: \$15.00',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3254),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVehicleName = vehicle.name;
                    });
                    
                    // Calcular precio total
                    final totalPrice = _calculateTotalPrice(vehicle);
                    
                    // Determinar tipo de servicio para validación de número de vuelo
                    String serviceType = 'point-to-point';
                    if (widget.serviceType == 'To Airport') {
                      serviceType = 'to-airport';
                    } else if (widget.serviceType == 'From Airport') {
                      serviceType = 'from-airport';
                    }
                    
                    // Si el usuario YA está autenticado, ir directamente a BookingDetailsScreen
                    if (_currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsScreen(
                            pickupAddress: widget.pickupAddress,
                            destinationAddress: widget.destinationAddress,
                            pickupLat: widget.pickupLat,
                            pickupLng: widget.pickupLng,
                            destinationLat: widget.destinationLat,
                            destinationLng: widget.destinationLng,
                            selectedDateTime: widget.selectedDateTime,
                            vehicleName: vehicle.name,
                            totalPrice: totalPrice,
                            distanceMiles: _distanceMiles ?? 0,
                            duration: _duration ?? '',
                            serviceType: serviceType,
                          ),
                        ),
                      );
                    } else {
                      // Si NO está autenticado, ir a LoginWebScreen (paso 3)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginWebScreen(
                            pickupAddress: widget.pickupAddress,
                            destinationAddress: widget.destinationAddress,
                            pickupLat: widget.pickupLat,
                            pickupLng: widget.pickupLng,
                            destinationLat: widget.destinationLat,
                            destinationLng: widget.destinationLng,
                            selectedDateTime: widget.selectedDateTime,
                            vehicleName: vehicle.name,
                            totalPrice: totalPrice,
                            distanceMiles: _distanceMiles ?? 0,
                            duration: _duration ?? '',
                            serviceType: serviceType,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4169E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Select Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
