import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'payment_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
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
  final String serviceType; // "to-airport", "from-airport", etc.

  const BookingDetailsScreen({
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
    this.serviceType = 'point-to-point',
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _flightNumberController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  bool _meetAndGreet = false;
  bool _childSafetySeat = false;
  bool _extraStop = false;
  User? _currentUser;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _setupMap() {
    // Crear marcadores
    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(widget.pickupLat, widget.pickupLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(widget.destinationLat, widget.destinationLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    // Crear polyline
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(widget.pickupLat, widget.pickupLng),
        LatLng(widget.destinationLat, widget.destinationLng),
      ],
      color: Colors.blue,
      width: 4,
    );

    setState(() {
      _markers = {pickupMarker, destinationMarker};
      _polylines = {polyline};
    });
  }

  bool _isAirportService() {
    return widget.serviceType == 'to-airport' ||
        widget.serviceType == 'from-airport';
  }

  void _proceedToPayment() {
    // Validar número de vuelo si es servicio de aeropuerto
    if (_isAirportService() && _flightNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flight number is required for airport pickups'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navegar al paso 5 (Payment)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          pickupAddress: widget.pickupAddress,
          destinationAddress: widget.destinationAddress,
          pickupLat: widget.pickupLat,
          pickupLng: widget.pickupLng,
          destinationLat: widget.destinationLat,
          destinationLng: widget.destinationLng,
          selectedDateTime: widget.selectedDateTime,
          vehicleName: widget.vehicleName,
          totalPrice: widget.totalPrice,
          distanceMiles: widget.distanceMiles,
          duration: widget.duration,
          flightNumber: _flightNumberController.text.trim().isNotEmpty
              ? _flightNumberController.text.trim()
              : null,
          extraServices: {
            'meetAndGreet': _meetAndGreet,
            'childSafetySeat': _childSafetySeat,
            'extraStop': _extraStop,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // BARRA DE NAVEGACIÓN SUPERIOR (solo desktop)
          if (!isMobile) _buildTopNavBar(),

          // INDICADOR DE PASOS
          _buildStepIndicator(),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: EdgeInsets.all(isMobile ? 20 : 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 4 OF 5',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B3254),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // INDICADOR CON CHECKMARKS
                    _buildProgressIndicator(),

                    const SizedBox(height: 40),

                    // INFORMACIÓN DEL VIAJE
                    _buildTripInfo(),

                    const SizedBox(height: 40),

                    // Layout responsivo
                    isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En móvil: todo en columna
                            _buildExtraServices(),
                            const SizedBox(height: 24),
                            _buildSpecialRequests(),
                            const SizedBox(height: 24),
                            _buildBookingSummary(),
                            const SizedBox(height: 24),
                            _buildMap(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // COLUMNA IZQUIERDA - Extra Services
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildExtraServices(),
                                  const SizedBox(height: 32),
                                  _buildSpecialRequests(),
                                ],
                              ),
                            ),

                            const SizedBox(width: 40),

                            // COLUMNA DERECHA - Booking Summary + Map
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildBookingSummary(),
                                  const SizedBox(height: 24),
                                  _buildMap(),
                                ],
                              ),
                            ),
                          ],
                        ),

                    const SizedBox(height: 40),

                    // BOTONES
                    isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _proceedToPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4169E1),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Proceed to Payment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _proceedToPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4169E1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Proceed to Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
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
          const SizedBox(width: 24),
          const Text(
            'CITIES WE SERVE',
            style: TextStyle(fontSize: 14, color: Color(0xFF0B3254)),
          ),
          const SizedBox(width: 32),
          // Mostrar botones de LOGIN/SIGNUP solo si NO hay usuario autenticado
          if (_currentUser == null) ...[
            TextButton(
              onPressed: () {},
              child: const Text(
                'LOGIN',
                style: TextStyle(color: Color(0xFF0B3254)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37)),
              ),
              child: const Text(
                'SIGNUP',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
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
          _buildStepLine(true),
          _buildStep(3, 'Login', true),
          _buildStepLine(true),
          _buildStep(4, 'Details', true),
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

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildCheckItem('Ride Information', true),
        const SizedBox(width: 32),
        _buildCheckItem('Vehicle Class', true),
        const SizedBox(width: 32),
        _buildCheckItem('Login', true),
        const SizedBox(width: 32),
        _buildCheckItem('Booking Details', false, isActive: true),
        const SizedBox(width: 32),
        _buildCheckItem('Payment', false),
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
                    isActive ? '4' : '5',
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pickupAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.destinationAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Color(0xFF4169E1),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Date & Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(widget.selectedDateTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraServices() {
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
            'Extra Services & Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 24),

          // Flight Number - SOLO SI ES SERVICIO DE AEROPUERTO
          if (_isAirportService()) ...[
            const Text(
              'Flight Number (Required for Airport Pickups)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B3254),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _flightNumberController,
              decoration: InputDecoration(
                hintText: 'e.g., UA123, AA456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Required for airport pickups and drop-offs so we can track your flight and adjust pickup time accordingly.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
          ],

          const Text(
            'Additional Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 16),

          _buildServiceCheckbox(
            'Meet & Greet Service (+\$25)',
            'Driver will meet you inside the terminal with a name sign.',
            _meetAndGreet,
            (value) => setState(() => _meetAndGreet = value),
          ),
          const SizedBox(height: 16),
          _buildServiceCheckbox(
            'Child Safety Seat (+\$15)',
            'We provide and install a child safety seat.',
            _childSafetySeat,
            (value) => setState(() => _childSafetySeat = value),
          ),
          const SizedBox(height: 16),
          _buildServiceCheckbox(
            'Add Extra Stop (+\$20)',
            'Add one additional stop on your route.',
            _extraStop,
            (value) => setState(() => _extraStop = value),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCheckbox(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? const Color(0xFF4169E1) : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: value
            ? const Color(0xFF4169E1).withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: const Color(0xFF4169E1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequests() {
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
            'Special Requests (optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _specialRequestsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Any special instructions for your driver',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
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
          const Text(
            'Passenger Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guest user',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSummaryRow('Vehicle', widget.vehicleName),
          const SizedBox(height: 12),
          _buildSummaryRow('Service Type', widget.serviceType),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Base Fare',
            '\$${widget.totalPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${widget.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4169E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF4169E1), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: Tax will be calculated on the payment page',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4169E1)),
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
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: GoogleMap(
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
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$weekday, $month ${dateTime.day}, ${dateTime.year}, $hour:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }
}
