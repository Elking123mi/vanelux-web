import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/types.dart';
import '../../services/booking_service.dart';
import '../../services/google_maps_service.dart';
import '../../widgets/places_autocomplete_field.dart';

/// Step-by-step booking flow screen for mobile
class BookingFlowScreen extends StatefulWidget {
  final bool isScheduled;

  const BookingFlowScreen({super.key, this.isScheduled = false});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  late bool _isScheduled;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  double? _pickupLat;
  double? _pickupLng;
  double? _destinationLat;
  double? _destinationLng;

  bool _showMap = false;
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = <Marker>{};
  Set<Polyline> _mapPolylines = <Polyline>{};

  bool _isCalculating = false;
  double _distanceInMiles = 0;
  String _distanceText = '';
  String _durationText = '';
  bool _isSubmittingBooking = false;

  ServiceType _selectedServiceType = ServiceType.pointToPoint;
  String? _selectedVehicle;
  double? _selectedPrice;

  final List<Map<String, dynamic>> _vehicleOptions = [
    {
      'name': 'Sedán Ejecutivo',
      'description': 'Premium comfort for up to 3 passengers',
      'icon': FontAwesomeIcons.carSide,
      'passengers': 3,
      'luggage': 2,
      'basePrice': 2.6,
    },
    {
      'name': 'Luxury SUV',
      'description': 'Additional space and luxury finishes',
      'icon': FontAwesomeIcons.car,
      'passengers': 5,
      'luggage': 4,
      'basePrice': 3.2,
    },
    {
      'name': 'VIP Sprinter',
      'description': 'Ideal for groups and corporate experiences',
      'icon': FontAwesomeIcons.shuttleVan,
      'passengers': 10,
      'luggage': 10,
      'basePrice': 4.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _isScheduled = widget.isScheduled;
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      if (_pickupLat == null ||
          _pickupLng == null ||
          _destinationLat == null ||
          _destinationLng == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selecciona origen y Destination válidos.\n'
              'Pickup: ${_pickupLat != null ? "✓" : "✗"}, '
              'Destination: ${_destinationLat != null ? "✓" : "✗"}',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      await _calculateDistance();
    } else if (_currentStep == 1) {
      if (_selectedVehicle == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un vehículo')),
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _calculateDistance() async {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      return;
    }

    setState(() {
      _isCalculating = true;
      _distanceInMiles = 0;
      _distanceText = '';
      _durationText = '';
      _selectedVehicle = null;
      _selectedPrice = null;
    });

    try {
      final matrix = await GoogleMapsService.getDistanceMatrix(
        _pickupController.text,
        _destinationController.text,
      );

      final distanceMeters = (matrix['distance_value'] as num?)?.toDouble();
      final durationText = matrix['duration'] as String? ?? '';
      final distanceText = matrix['distance'] as String? ?? '';

      final fallbackMiles = _computeStraightLineMiles();
      final miles = distanceMeters != null
          ? distanceMeters / 1609.344
          : fallbackMiles;

      if (!mounted) {
        return;
      }

      setState(() {
        _isCalculating = false;
        _distanceInMiles = miles;
        _distanceText = distanceText.isNotEmpty
            ? distanceText
            : miles > 0
            ? '${miles.toStringAsFixed(1)} mi'
            : '';
        _durationText = durationText;
      });
    } catch (e) {
      final miles = _computeStraightLineMiles();

      if (!mounted) {
        return;
      }

      setState(() {
        _isCalculating = false;
        _distanceInMiles = miles;
        _distanceText = miles > 0 ? '${miles.toStringAsFixed(1)} mi' : '';
        _durationText = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo obtener la Distance de Google Maps. Estimación aproximada utilizada. Detalle: $e',
          ),
        ),
      );
    }
  }

  double _computeStraightLineMiles() {
    if (_pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null) {
      return 0;
    }

    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(_destinationLat! - _pickupLat!);
    final dLng = _degreesToRadians(_destinationLng! - _pickupLng!);

    final lat1 = _degreesToRadians(_pickupLat!);
    final lat2 = _degreesToRadians(_destinationLat!);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    return distanceKm * 0.621371;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  Future<void> _confirmBooking() async {
    if (_selectedVehicle == null || _selectedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo para Continue')),
      );
      return;
    }

    if (_isSubmittingBooking) {
      return;
    }

    setState(() {
      _isSubmittingBooking = true;
    });

    final now = DateTime.now();
    DateTime? scheduledDateTime;

    if (_isScheduled && _scheduledDate != null && _scheduledTime != null) {
      scheduledDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    }

    Map<String, dynamic> cleanMap(Map<String, dynamic> map) {
      final cleaned = Map<String, dynamic>.from(map);
      cleaned.removeWhere((key, value) {
        if (value == null) return true;
        if (value is String && value.isEmpty) return true;
        if (value is Map && value.isEmpty) return true;
        return false;
      });
      return cleaned;
    }

    final vehicleInfo = _vehicleOptions.firstWhere(
      (vehicle) => vehicle['name'] == _selectedVehicle,
      orElse: () => const <String, dynamic>{},
    );

    final passengers = (vehicleInfo['passengers'] as int?) ?? 1;

    final metadata = cleanMap({
      'created_from': 'mobile_app',
      'created_step': _currentStep,
      'distance_miles': _distanceInMiles,
      'distance_text': _distanceText,
      'duration_text': _durationText,
      'pickup_lat': _pickupLat,
      'pickup_lng': _pickupLng,
      'destination_lat': _destinationLat,
      'destination_lng': _destinationLng,
      'vehicle_name': _selectedVehicle,
      'service_type': _selectedServiceType.name,
    });

    final payload = cleanMap({
      'origin': _pickupController.text.trim(),
      'destination': _destinationController.text.trim(),
      'pickup_time': (scheduledDateTime ?? now).toUtc().toIso8601String(),
      'passengers': passengers,
      'fare': _selectedPrice,
      'status': 'pending',
      'is_scheduled': _isScheduled,
      'service_type': _selectedServiceType.name,
      'vehicle_name': _selectedVehicle,
      'distance_miles': _distanceInMiles,
      'distance_text': _distanceText,
      'duration_text': _durationText,
      'pickup_lat': _pickupLat,
      'pickup_lng': _pickupLng,
      'destination_lat': _destinationLat,
      'destination_lng': _destinationLng,
      'metadata': metadata,
    });

    try {
      final savedBooking = await BookingService.createBooking(payload);

      if (!mounted) {
        return;
      }

      final synced = savedBooking['syncedWithBackend'] != false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? 'Booking saved and synced with VaneLux.'
                : 'Reserva guardada sin conexión. Se sincronizará cuando haya internet.',
          ),
          backgroundColor: synced ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingBooking = false;
        });
      }
    }
  }

  void _checkAndShowMap() {
    final hasPickup = _pickupLat != null && _pickupLng != null;
    final hasDestination = _destinationLat != null && _destinationLng != null;

    if (hasPickup && hasDestination) {
      if (!_showMap) {
        setState(() {
          _showMap = true;
        });
      }
      _updateMapPreview();
      _calculateDistance();
    } else if (_showMap) {
      setState(() {
        _showMap = false;
        _mapMarkers = <Marker>{};
        _mapPolylines = <Polyline>{};
        _distanceInMiles = 0;
        _distanceText = '';
        _durationText = '';
      });
    }
  }

  void _updateMapPreview() {
    if (_pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null) {
      return;
    }

    final pickup = LatLng(_pickupLat!, _pickupLng!);
    final dropoff = LatLng(_destinationLat!, _destinationLng!);

    setState(() {
      _mapMarkers = {
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          infoWindow: const InfoWindow(title: 'Origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: dropoff,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      _mapPolylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: const Color(0xFFFFD700),
          width: 5,
          points: [pickup, dropoff],
        ),
      };
    });

    if (_mapController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToRoute());
    }
  }

  void _fitMapToRoute() {
    if (_mapController == null ||
        _pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null) {
      return;
    }

    final southwestLat = min(_pickupLat!, _destinationLat!);
    final southwestLng = min(_pickupLng!, _destinationLng!);
    final northeastLat = max(_pickupLat!, _destinationLat!);
    final northeastLng = max(_pickupLng!, _destinationLng!);

    final latDelta = (northeastLat - southwestLat).abs();
    final lngDelta = (northeastLng - southwestLng).abs();

    final bounds = LatLngBounds(
      southwest: LatLng(
        southwestLat - (latDelta == 0 ? 0.002 : 0),
        southwestLng - (lngDelta == 0 ? 0.002 : 0),
      ),
      northeast: LatLng(
        northeastLat + (latDelta == 0 ? 0.002 : 0),
        northeastLng + (lngDelta == 0 ? 0.002 : 0),
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  Widget _buildRouteMapPreview() {
    final hasRoute =
        _pickupLat != null &&
        _pickupLng != null &&
        _destinationLat != null &&
        _destinationLng != null;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: hasRoute
            ? Stack(
                children: [
                  // Check if platform supports Google Maps
                  if (!kIsWeb && Platform.isWindows)
                    // Windows doesn't support Google Maps - show placeholder
                    Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Map preview not available on Windows',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your route: $_distanceText • $_durationText',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Mobile/Web - show actual map
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          (_pickupLat! + _destinationLat!) / 2,
                          (_pickupLng! + _destinationLng!) / 2,
                        ),
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _fitMapToRoute();
                      },
                      markers: _mapMarkers,
                      polylines: _mapPolylines,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      buildingsEnabled: false,
                      tiltGesturesEnabled: false,
                      mapType: MapType.normal,
                    ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.route,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isCalculating
                                      ? 'Calculando Distance...'
                                      : _distanceText.isNotEmpty
                                      ? _distanceText
                                      : '${_distanceInMiles.toStringAsFixed(1)} mi',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  _isCalculating
                                      ? 'Estimando duración...'
                                      : _durationText.isNotEmpty
                                      ? _durationText
                                      : 'Tiempo estimado pendiente',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  'Selecciona origen y Destination para ver el mapa',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('New Booking'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(child: _buildCurrentStep()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepCircle(0, 'Location'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Vehicle'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFFFFD700)
                  : isActive
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey[300],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF1A1A2E) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;

    return Container(
      height: 2,
      width: 30,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? const Color(0xFFFFD700) : Colors.grey[300],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1LocationSelection();
      case 1:
        return _buildStep2VehicleSelection();
      case 2:
        return _buildStep3Confirmation();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1LocationSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select locations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter where we\'ll pick you up and where you\'re going',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Tipo de viaje: Inmediato o Programado
          _buildTripTypeSelector(),
          const SizedBox(height: 24),

          // Service Type
          _buildServiceTypeSelector(),
          const SizedBox(height: 24),

          // Fecha y hora (solo si es programado)
          if (_isScheduled) ...[
            _buildDateTimeSelector(),
            const SizedBox(height: 24),
          ],

          // Pickup Location
          const Text(
            'Pickup location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          PlacesAutocompleteField(
            controller: _pickupController,
            hintText: 'Enter pickup address',
            prefixIcon: Icons.location_on,
            iconColor: const Color(0xFF4CAF50),
            onPlaceSelected: (placeId, description, lat, lng) {
              debugPrint(
                '🎯 PICKUP CALLBACK - PlaceId: $placeId, Lat: $lat, Lng: $lng',
              );
              setState(() {
                _pickupLat = lat;
                _pickupLng = lng;
              });
              _checkAndShowMap();
              debugPrint(
                '🎯 PICKUP STATE UPDATED - _pickupLat: $_pickupLat, _pickupLng: $_pickupLng',
              );
            },
          ),
          const SizedBox(height: 24),

          // Destination Location
          const Text(
            'Destination location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          PlacesAutocompleteField(
            controller: _destinationController,
            hintText: 'Enter destination address',
            prefixIcon: Icons.flag,
            iconColor: const Color(0xFFF44336),
            onPlaceSelected: (placeId, description, lat, lng) {
              debugPrint(
                '🎯 DESTINATION CALLBACK - PlaceId: $placeId, Lat: $lat, Lng: $lng',
              );
              setState(() {
                _destinationLat = lat;
                _destinationLng = lng;
              });
              _checkAndShowMap();
              debugPrint(
                '🎯 DESTINATION STATE UPDATED - _destinationLat: $_destinationLat, _destinationLng: $_destinationLng',
              );
            },
          ),
          const SizedBox(height: 24),

          // Mapa de ruta (se muestra cuando ambas ubicaciones están seleccionadas)
          if (_showMap && _pickupLat != null && _destinationLat != null) ...[
            _buildRouteMapPreview(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ServiceType>(
              value: _selectedServiceType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              items: [
                DropdownMenuItem(
                  value: ServiceType.pointToPoint,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Point to Point'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ServiceType.hourly,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('By Hour'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ServiceType.airport,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Aeropuerto'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cuándo necesitas el servicio?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTripTypeOption(
                icon: FontAwesomeIcons.bolt,
                title: 'Now',
                subtitle: 'Viaje inmediato',
                isSelected: !_isScheduled,
                onTap: () {
                  setState(() {
                    _isScheduled = false;
                    _scheduledDate = null;
                    _scheduledTime = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTripTypeOption(
                icon: FontAwesomeIcons.calendar,
                title: 'Schedule',
                subtitle: 'Reserva futura',
                isSelected: _isScheduled,
                onTap: () {
                  setState(() {
                    _isScheduled = true;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD700) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey[700],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service date and time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        _scheduledDate ??
                        DateTime.now().add(const Duration(hours: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFFFD700),
                            onPrimary: Color(0xFF1A1A2E),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      _scheduledDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _scheduledDate != null
                              ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                              : 'Select date',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _scheduledDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _scheduledTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFFFD700),
                            onPrimary: Color(0xFF1A1A2E),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _scheduledTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFFFD700)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _scheduledTime != null
                              ? _scheduledTime!.format(context)
                              : 'Select time',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _scheduledTime != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2VehicleSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona tu vehículo preferido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          if (_isCalculating)
            const Center(child: CircularProgressIndicator())
          else if (_distanceInMiles > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.straighten, color: Color(0xFF1976D2)),
                      const SizedBox(height: 4),
                      Text(
                        _distanceText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const Text('Distance', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF1976D2)),
                      const SizedBox(height: 4),
                      Text(
                        _durationText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const Text('Tiempo est.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          ...vehicleOptions.map((vehicle) => _buildVehicleCard(vehicle)),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final isSelected = _selectedVehicle == vehicle['name'];
    final price = (_distanceInMiles * (vehicle['basePrice'] as double) * 35)
        .toStringAsFixed(2);
    final pricePerMile = (vehicle['basePrice'] as double).toStringAsFixed(2);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle = vehicle['name'];
          _selectedPrice = double.parse(price);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icono del vehículo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    vehicle['icon'] as IconData,
                    size: 32,
                    color: const Color(0xFF1A1A2E),
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
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle['description'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (_distanceInMiles > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$$price',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        '\$$pricePerMile/mi',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFeature(Icons.person, '${vehicle['passengers']} pax'),
                const SizedBox(width: 20),
                _buildFeature(
                  Icons.work_outline,
                  '${vehicle['luggage']} luggage',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFFD700)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
        ),
      ],
    );
  }

  Widget _buildStep3Confirmation() {
    final selectedVehicleData = _vehicleOptions.firstWhere(
      (v) => v['name'] == _selectedVehicle,
      orElse: () => _vehicleOptions[0],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tu reserva',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),

          _buildSummaryCard(
            'Ruta',
            Icons.location_on,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 12,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pickupController.text,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 12,
                      color: Color(0xFFF44336),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _destinationController.text,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildSummaryCard(
            'Vehículo',
            Icons.directions_car,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedVehicleData['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedVehicleData['passengers']} passengers • ${selectedVehicleData['luggage']} luggage',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          if (_distanceInMiles > 0)
            _buildSummaryCard(
              'Distance and time',
              Icons.route,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _distanceText.isNotEmpty
                        ? _distanceText
                        : '${_distanceInMiles.toStringAsFixed(1)} mi',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _durationText.isNotEmpty ? _durationText : 'Estimando...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          if (_isScheduled)
            _buildSummaryCard(
              'Scheduled date',
              Icons.calendar_today,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scheduledDate != null
                        ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                        : 'No date',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scheduledTime != null
                        ? _scheduledTime!.format(context)
                        : 'No time',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          _buildSummaryCard(
            'Total Price',
            Icons.attach_money,
            Text(
              '\$${_selectedPrice?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF1A1A2E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 2
                  ? (_isSubmittingBooking ? null : _confirmBooking)
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _currentStep == 2 && _isSubmittingBooking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _currentStep == 2 ? 'Confirm Booking' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get vehicleOptions => _vehicleOptions;
}




