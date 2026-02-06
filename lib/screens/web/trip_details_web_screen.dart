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
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
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
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'BMW 7 Series',
      description: 'Premium comfort with advanced technology',
      passengers: 3,
      luggage: 3,
      imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'Audi A8',
      description: 'Sophisticated design meets cutting-edge performance',
      passengers: 3,
      luggage: 3,
      imageUrl: 'https://images.unsplash.com/photo-1610768764270-790fbec18178?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'Cadillac Escalade ESV',
      description: 'Black exterior, premium interior, entertainment system',
      passengers: 6,
      luggage: 6,
      imageUrl: 'https://images.unsplash.com/photo-1571422789648-ef357f10d838?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'Suburban',
      description: 'Comfortable group transportation',
      passengers: 7,
      luggage: 7,
      imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'Suburban RTS',
      description: 'Extended SUV for special events',
      passengers: 7,
      luggage: 7,
      imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
    ),
    _VehicleOption(
      name: 'Mercedes Sprinter',
      description: 'Luxury van for group transportation',
      passengers: 14,
      luggage: 14,
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=400&q=80',
      basePrice: 0.50,
      perMileRate: 0.50,
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
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;
    final double horizontalPadding = isMobile ? 16 : 80;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // BARRA DE NAVEGACIÓN SUPERIOR
          _buildTopNavBar(isMobile, horizontalPadding),
          
          // INDICADOR DE PASOS
          _buildStepIndicator(isMobile, horizontalPadding),
          
          // INFORMACIÓN DE UBICACIONES Y FECHA
          _buildTripInfo(isMobile, horizontalPadding),
          
          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // MAPA
                  _buildMapSection(isMobile, horizontalPadding),
                  
                  const SizedBox(height: 40),
                  
                  // TÍTULO "Select Your Vehicle"
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(
                      'Select Your Vehicle',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B3254),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // INFO DE RUTA
                  if (_distanceMiles != null && _duration != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Route: ${_distanceMiles!.toStringAsFixed(0)} mi • $_duration',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // LISTA DE VEHÍCULOS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: _vehicles.map((vehicle) => 
                        _buildVehicleCard(vehicle, isMobile)
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

  Widget _buildTopNavBar(bool isMobile, double horizontalPadding) {
    if (isMobile) {
      return Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254),
              ),
            ),
            const Spacer(),
            if (_currentUser == null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login to continue')),
                  );
                },
                child: const Text('LOGIN', style: TextStyle(color: Color(0xFF0B3254), fontSize: 14)),
              )
            else
              PopupMenuButton<String>(
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  radius: 18,
                  child: Text(
                    _currentUser!.name.isNotEmpty 
                      ? _currentUser!.name[0].toUpperCase() 
                      : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                itemBuilder: (context) => [
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
        ),
      );
    }
    
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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

  Widget _buildStepIndicator(bool isMobile, double horizontalPadding) {
    if (isMobile) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(1, 'Information', true, isMobile),
            _buildStepLine(true, isMobile),
            _buildStep(2, 'Vehicle', true, isMobile),
            _buildStepLine(false, isMobile),
            _buildStep(3, 'Login', false, isMobile),
          ],
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Information', true, isMobile),
          _buildStepLine(true, isMobile),
          _buildStep(2, 'Vehicle', true, isMobile),
          _buildStepLine(false, isMobile),
          _buildStep(3, 'Login', false, isMobile),
          _buildStepLine(false, isMobile),
          _buildStep(4, 'Details', false, isMobile),
          _buildStepLine(false, isMobile),
          _buildStep(5, 'Payment', false, isMobile),
        ],
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
      margin: EdgeInsets.only(bottom: isMobile ? 24 : 28),
      color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
    );
  }

  Widget _buildTripInfo(bool isMobile, double horizontalPadding) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF0B3254), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        widget.pickupAddress,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF0B3254), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        widget.destinationAddress,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF0B3254), size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatDateTime(widget.selectedDateTime),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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

  Widget _buildMapSection(bool isMobile, double horizontalPadding) {
    return Container(
      height: isMobile ? 250 : 400,
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 16 : 32),
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
                  // Map controller created
                },
              ),
      ),
    );
  }

  Widget _buildVehicleCard(_VehicleOption vehicle, bool isMobile) {
    final totalPrice = _calculateTotalPrice(vehicle);
    final isSelected = _selectedVehicleName == vehicle.name;
    
    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN DEL VEHÍCULO
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                vehicle.imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[100],
                    child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // NOMBRE Y DESCRIPCIÓN
            Text(
              vehicle.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CARACTERÍSTICAS
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildFeature(Icons.person, '${vehicle.passengers} pax'),
                _buildFeature(Icons.luggage, '${vehicle.luggage} bags'),
                _buildFeature(Icons.wifi, 'WiFi'),
                _buildFeature(Icons.access_time, '90 min wait'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // PRECIO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Base: \$${vehicle.basePrice.toStringAsFixed(2)} • ${_distanceMiles?.toStringAsFixed(0) ?? "0"} mi',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Fees & taxes included',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // BOTÓN
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedVehicleName = vehicle.name;
                  });
                  
                  // Calcular precio total
                  final totalPrice = _calculateTotalPrice(vehicle);
                  
                  // Determinar tipo de servicio
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
                  backgroundColor: const Color(0xFF0B3254),
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
      );
    }
    
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
