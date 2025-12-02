import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/vanelux_colors.dart';
import '../../services/google_maps_service.dart';

// PASO 1: Selección de ubicaciones y tipo de servicio
class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  List<dynamic> _pickupSuggestions = [];
  List<dynamic> _dropoffSuggestions = [];
  bool _showPickupSuggestions = false;
  bool _showDropoffSuggestions = false;

  double? _pickupLat;
  double? _pickupLng;
  String? _pickupPlaceId;
  double? _dropoffLat;
  double? _dropoffLng;
  String? _dropoffPlaceId;

  String _selectedServiceType = 'Point to Point';
  final List<String> _serviceTypes = [
    'Point to Point',
    'To Airport',
    'From Airport',
    'Hourly Service',
  ];

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

  void _continueToVehicleSelection() {
    if (_pickupPlaceId == null || _dropoffPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and dropoff locations'),
          backgroundColor: VaneLuxColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileVehicleSelectionScreen(
          pickupAddress: _pickupController.text,
          dropoffAddress: _dropoffController.text,
          pickupLat: _pickupLat!,
          pickupLng: _pickupLng!,
          dropoffLat: _dropoffLat!,
          dropoffLng: _dropoffLng!,
          serviceType: _selectedServiceType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [VaneLuxColors.primaryBlue, Color(0xFF154a74)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'VANELUX',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: VaneLuxColors.gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'LUXURY TRANSPORTATION',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Booking Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Your Ride',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: VaneLuxColors.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Service Type Selection
                      const Text(
                        'Service Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VaneLuxColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: VaneLuxColors.gold,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedServiceType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          items: _serviceTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedServiceType = newValue);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pickup Location
                      const Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VaneLuxColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextField(
                            controller: _pickupController,
                            decoration: InputDecoration(
                              hintText: 'Enter pickup address',
                              prefixIcon: const Icon(
                                Icons.location_on,
                                color: VaneLuxColors.success,
                              ),
                              suffixIcon: _pickupPlaceId != null
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: VaneLuxColors.gold,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: VaneLuxColors.gold.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: VaneLuxColors.gold,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _pickupPlaceId = null;
                                _pickupLat = null;
                                _pickupLng = null;
                              });
                              _searchPickupPlaces(value);
                            },
                          ),
                          if (_showPickupSuggestions &&
                              _pickupSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: _pickupSuggestions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final suggestion = _pickupSuggestions[index];
                                  final description =
                                      suggestion['description'] ?? '';
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: VaneLuxColors.success,
                                      size: 20,
                                    ),
                                    title: Text(
                                      description,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => _selectPickupPlace(suggestion),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Dropoff Location
                      const Text(
                        'Dropoff Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VaneLuxColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextField(
                            controller: _dropoffController,
                            decoration: InputDecoration(
                              hintText: 'Enter destination address',
                              prefixIcon: const Icon(
                                Icons.flag,
                                color: VaneLuxColors.error,
                              ),
                              suffixIcon: _dropoffPlaceId != null
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: VaneLuxColors.gold,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: VaneLuxColors.gold.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: VaneLuxColors.gold,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _dropoffPlaceId = null;
                                _dropoffLat = null;
                                _dropoffLng = null;
                              });
                              _searchDropoffPlaces(value);
                            },
                          ),
                          if (_showDropoffSuggestions &&
                              _dropoffSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: _dropoffSuggestions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final suggestion = _dropoffSuggestions[index];
                                  final description =
                                      suggestion['description'] ?? '';
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.flag,
                                      color: VaneLuxColors.error,
                                      size: 20,
                                    ),
                                    title: Text(
                                      description,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () =>
                                        _selectDropoffPlace(suggestion),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _continueToVehicleSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VaneLuxColors.gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// PASO 2: Selección de vehículo con precios
class MobileVehicleSelectionScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String serviceType;

  const MobileVehicleSelectionScreen({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.serviceType,
  });

  @override
  State<MobileVehicleSelectionScreen> createState() =>
      _MobileVehicleSelectionScreenState();
}

class _MobileVehicleSelectionScreenState
    extends State<MobileVehicleSelectionScreen> {
  bool _isLoadingDistance = true;
  double? _distanceMiles;
  String? _duration;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'name': 'Mercedes-Benz S-Class',
      'passengers': '3',
      'luggage': '3',
      'baseRate': 2.50,
      'image': 'assets/sedan.png',
    },
    {
      'name': 'Cadillac Escalade ESV',
      'passengers': '6',
      'luggage': '6',
      'baseRate': 3.50,
      'image': 'assets/suv.png',
    },
    {
      'name': 'Mercedes-Benz Sprinter',
      'passengers': '14',
      'luggage': '10',
      'baseRate': 5.00,
      'image': 'assets/van.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    try {
      final distanceData = await GoogleMapsService.getDistanceMatrix(
        '${widget.pickupLat},${widget.pickupLng}',
        '${widget.dropoffLat},${widget.dropoffLng}',
      );

      if (distanceData != null) {
        final distanceMeters = distanceData['distance_value'] as int;
        final durationSeconds = distanceData['duration_value'] as int;

        final miles = distanceMeters * 0.000621371;
        final minutes = (durationSeconds / 60).round();

        setState(() {
          _distanceMiles = miles;
          _duration = '$minutes mins';
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading route data: $e');
      setState(() => _isLoadingDistance = false);
    }
  }

  double _calculatePrice(double baseRate) {
    if (_distanceMiles == null) return 0;
    final baseFare = 10.0;
    return baseFare + (_distanceMiles! * baseRate);
  }

  void _selectVehicle(String vehicleName, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileLoginScreen(
          pickupAddress: widget.pickupAddress,
          dropoffAddress: widget.dropoffAddress,
          pickupLat: widget.pickupLat,
          pickupLng: widget.pickupLng,
          dropoffLat: widget.dropoffLat,
          dropoffLng: widget.dropoffLng,
          vehicleName: vehicleName,
          totalPrice: price,
          distanceMiles: _distanceMiles ?? 0,
          duration: _duration ?? '',
          serviceType: widget.serviceType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Vehicle',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoadingDistance
          ? const Center(
              child: CircularProgressIndicator(color: VaneLuxColors.gold),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Route Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [VaneLuxColors.primaryBlue, Color(0xFF154a74)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard(
                              icon: Icons.straighten,
                              label: 'Distance',
                              value:
                                  '${_distanceMiles?.toStringAsFixed(1) ?? '0'} mi',
                            ),
                            _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Duration',
                              value: _duration ?? 'N/A',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: VaneLuxColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.pickupAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flag,
                                color: VaneLuxColors.error,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.dropoffAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vehicle Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _vehicles.map((vehicle) {
                        final price = _calculatePrice(
                          vehicle['baseRate'] as double,
                        );
                        return _buildVehicleCard(vehicle, price);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: VaneLuxColors.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectVehicle(vehicle['name'], price),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vehicle Image Placeholder
                    Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: VaneLuxColors.primaryBlue,
                      ),
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
                              color: VaneLuxColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehicle['passengers'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.luggage,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehicle['luggage'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: VaneLuxColors.gold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: VaneLuxColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SELECT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// PASO 3: Login o continuar como invitado
class MobileLoginScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String vehicleName;
  final double totalPrice;
  final double distanceMiles;
  final String duration;
  final String serviceType;

  const MobileLoginScreen({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.vehicleName,
    required this.totalPrice,
    required this.distanceMiles,
    required this.duration,
    required this.serviceType,
  });

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _continueAsGuest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileBookingDetailsScreen(
          pickupAddress: widget.pickupAddress,
          dropoffAddress: widget.dropoffAddress,
          pickupLat: widget.pickupLat,
          pickupLng: widget.pickupLng,
          dropoffLat: widget.dropoffLat,
          dropoffLng: widget.dropoffLng,
          vehicleName: widget.vehicleName,
          totalPrice: widget.totalPrice,
          distanceMiles: widget.distanceMiles,
          duration: widget.duration,
          serviceType: widget.serviceType,
        ),
      ),
    );
  }

  void _login() {
    // TODO: Implement actual login
    _continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [VaneLuxColors.primaryBlue, Color(0xFF154a74)],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'VANELUX',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: VaneLuxColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(
                        Icons.email,
                        color: VaneLuxColors.gold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: VaneLuxColors.gold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: VaneLuxColors.gold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: VaneLuxColors.gold,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: VaneLuxColors.gold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaneLuxColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Continue as Guest Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: VaneLuxColors.gold,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE AS GUEST',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: VaneLuxColors.gold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to sign up
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: VaneLuxColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PASO 4: Detalles de la reserva
class MobileBookingDetailsScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String vehicleName;
  final double totalPrice;
  final double distanceMiles;
  final String duration;
  final String serviceType;

  const MobileBookingDetailsScreen({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.vehicleName,
    required this.totalPrice,
    required this.distanceMiles,
    required this.duration,
    required this.serviceType,
  });

  @override
  State<MobileBookingDetailsScreen> createState() =>
      _MobileBookingDetailsScreenState();
}

class _MobileBookingDetailsScreenState
    extends State<MobileBookingDetailsScreen> {
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  bool _meetAndGreet = false;
  bool _childSafetySeat = false;
  bool _extraStop = false;

  bool _isAirportService() {
    final serviceType = widget.serviceType.toLowerCase().replaceAll(' ', '-');
    return serviceType == 'to-airport' || serviceType == 'from-airport';
  }

  double _getExtraServicesTotal() {
    double total = 0;
    if (_meetAndGreet) total += 25;
    if (_childSafetySeat) total += 15;
    if (_extraStop) total += 20;
    return total;
  }

  void _proceedToPayment() {
    if (_isAirportService() && _flightNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flight number is required for airport services'),
          backgroundColor: VaneLuxColors.error,
        ),
      );
      return;
    }

    final extraServicesTotal = _getExtraServicesTotal();
    final finalTotal = widget.totalPrice + extraServicesTotal;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobilePaymentScreen(
          pickupAddress: widget.pickupAddress,
          dropoffAddress: widget.dropoffAddress,
          pickupLat: widget.pickupLat,
          pickupLng: widget.pickupLng,
          dropoffLat: widget.dropoffLat,
          dropoffLng: widget.dropoffLng,
          vehicleName: widget.vehicleName,
          totalPrice: finalTotal,
          distanceMiles: widget.distanceMiles,
          duration: widget.duration,
          flightNumber: _flightNumberController.text.trim(),
          specialRequests: _specialRequestsController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VaneLuxColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VaneLuxColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Vehicle', widget.vehicleName),
                  _buildSummaryRow(
                    'Distance',
                    '${widget.distanceMiles.toStringAsFixed(1)} miles',
                  ),
                  _buildSummaryRow('Duration', widget.duration),
                  _buildSummaryRow(
                    'Base Price',
                    '\$${widget.totalPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Flight Number (conditional)
            if (_isAirportService()) ...[
              const Text(
                'Flight Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VaneLuxColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flightNumberController,
                decoration: InputDecoration(
                  labelText: 'Flight Number (Required)',
                  hintText: 'e.g., AA1234',
                  prefixIcon: const Icon(
                    Icons.flight,
                    color: VaneLuxColors.gold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: VaneLuxColors.gold,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Extra Services
            const Text(
              'Extra Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VaneLuxColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            _buildExtraServiceCheckbox(
              'Meet & Greet Service',
              '\$25.00',
              'Driver will meet you at arrivals with a name sign',
              _meetAndGreet,
              (value) => setState(() => _meetAndGreet = value!),
            ),
            _buildExtraServiceCheckbox(
              'Child Safety Seat',
              '\$15.00',
              'Complimentary child safety seat',
              _childSafetySeat,
              (value) => setState(() => _childSafetySeat = value!),
            ),
            _buildExtraServiceCheckbox(
              'Additional Stop',
              '\$20.00',
              'Add an extra stop along the way',
              _extraStop,
              (value) => setState(() => _extraStop = value!),
            ),

            const SizedBox(height: 24),

            // Special Requests
            const Text(
              'Special Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VaneLuxColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequestsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Any special requests or instructions for the driver...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VaneLuxColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Total Price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VaneLuxColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VaneLuxColors.gold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: VaneLuxColors.primaryBlue,
                    ),
                  ),
                  Text(
                    '\$${(widget.totalPrice + _getExtraServicesTotal()).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: VaneLuxColors.gold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaneLuxColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'PROCEED TO PAYMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: VaneLuxColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraServiceCheckbox(
    String title,
    String price,
    String description,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: VaneLuxColors.gold.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              price,
              style: const TextStyle(
                color: VaneLuxColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: VaneLuxColors.gold,
      ),
    );
  }
}

// PASO 5: Pago y confirmación
class MobilePaymentScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String vehicleName;
  final double totalPrice;
  final double distanceMiles;
  final String duration;
  final String flightNumber;
  final String specialRequests;

  const MobilePaymentScreen({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.vehicleName,
    required this.totalPrice,
    required this.distanceMiles,
    required this.duration,
    required this.flightNumber,
    required this.specialRequests,
  });

  @override
  State<MobilePaymentScreen> createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all payment fields'),
          backgroundColor: VaneLuxColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: VaneLuxColors.success, size: 32),
              SizedBox(width: 12),
              Text('Booking Confirmed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your luxury ride has been booked successfully.'),
              const SizedBox(height: 16),
              Text('Total: \$${widget.totalPrice.toStringAsFixed(2)}'),
              Text('Vehicle: ${widget.vehicleName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'DONE',
                style: TextStyle(
                  color: VaneLuxColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: VaneLuxColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VaneLuxColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VaneLuxColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Vehicle', widget.vehicleName),
                  _buildSummaryRow(
                    'Distance',
                    '${widget.distanceMiles.toStringAsFixed(1)} miles',
                  ),
                  _buildSummaryRow('Duration', widget.duration),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    '\$${widget.totalPrice.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Payment Form
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: VaneLuxColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),

            // Card Number
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(
                  Icons.credit_card,
                  color: VaneLuxColors.gold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VaneLuxColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expiry and CVV Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: VaneLuxColors.gold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: VaneLuxColors.gold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: VaneLuxColors.gold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: VaneLuxColors.gold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cardholder Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                prefixIcon: const Icon(Icons.person, color: VaneLuxColors.gold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VaneLuxColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaneLuxColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'PAY \$${widget.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Secure Payment Notice
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Secure Payment',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? VaneLuxColors.primaryBlue : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isTotal ? VaneLuxColors.gold : VaneLuxColors.primaryBlue,
              fontSize: isTotal ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
