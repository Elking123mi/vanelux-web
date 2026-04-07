// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../services/auth_service.dart';

class TripTrackingScreen extends StatefulWidget {
  final int bookingId;
  final String? pickupAddress;
  final String? destinationAddress;

  const TripTrackingScreen({
    super.key,
    required this.bookingId,
    this.pickupAddress,
    this.destinationAddress,
  });

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  static int _mapCounter = 0;
  late final String _mapId;

  Timer? _pollTimer;
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  String? _error;
  bool _mapInitialized = false;

  // Status display config
  static const Map<String, Map<String, dynamic>> _statusConfig = {
    'pending': {
      'label': 'Waiting for driver assignment',
      'icon': Icons.access_time,
      'color': Color(0xFFF59E0B),
    },
    'assigned': {
      'label': 'Driver assigned — preparing to depart',
      'icon': Icons.directions_car,
      'color': Color(0xFF3B82F6),
    },
    'en_route_to_pickup': {
      'label': 'Driver is on the way to you',
      'icon': Icons.navigation,
      'color': Color(0xFF8B5CF6),
    },
    'arrived_at_pickup': {
      'label': '🚗 Driver has arrived — please come out!',
      'icon': Icons.location_on,
      'color': Color(0xFF10B981),
    },
    'in_progress': {
      'label': 'Trip in progress — enjoy your ride!',
      'icon': Icons.airport_shuttle,
      'color': Color(0xFF0B3254),
    },
    'completed': {
      'label': '✅ Trip completed. Thank you!',
      'icon': Icons.check_circle,
      'color': Color(0xFF10B981),
    },
    'cancelled': {
      'label': 'Trip cancelled',
      'icon': Icons.cancel,
      'color': Color(0xFFEF4444),
    },
  };

  @override
  void initState() {
    super.initState();
    _mapId = 'tracking-map-${_mapCounter++}';
    _loadTracking();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadTracking());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTracking() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final resp = await http.get(
        Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/bookings/${widget.bookingId}/tracking'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _trackingData = data;
          _isLoading = false;
          _error = null;
        });
        _updateMapMarker(data);
      } else {
        setState(() {
          _error = 'Could not load tracking data';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Connection error — retrying...';
      });
    }
  }

  void _updateMapMarker(Map<String, dynamic> data) {
    final loc = data['driver_location'];
    if (loc == null) return;
    final lat = loc['lat'];
    final lng = loc['lng'];
    if (lat == null || lng == null) return;

    try {
      final js = '''
        (function() {
          if (window._trackingMap_$_mapId && window._driverMarker_$_mapId) {
            var pos = new google.maps.LatLng($lat, $lng);
            window._driverMarker_$_mapId.setPosition(pos);
            window._trackingMap_$_mapId.panTo(pos);
          }
        })();
      ''';
      js_util.callMethod(html.window, 'eval', [js]);
    } catch (_) {}
  }

  void _initMap(Map<String, dynamic> data) {
    if (_mapInitialized) return;
    final apiKey = AppConfig.googleMapsApiKey;

    final pickupLat = data['pickup_lat'] ?? 40.7128;
    final pickupLng = data['pickup_lng'] ?? -74.0060;
    final destLat = data['destination_lat'] ?? 40.7580;
    final destLng = data['destination_lng'] ?? -73.9855;
    final driverLoc = data['driver_location'];
    final driverLat = driverLoc?['lat'] ?? pickupLat;
    final driverLng = driverLoc?['lng'] ?? pickupLng;

    final mapScript = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <style>
    html,body,#map { width:100%; height:100%; margin:0; padding:0; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    function initMap() {
      var driverPos = { lat: $driverLat, lng: $driverLng };
      var pickupPos = { lat: $pickupLat, lng: $pickupLng };
      var destPos   = { lat: $destLat,   lng: $destLng };

      var map = new google.maps.Map(document.getElementById("map"), {
        center: driverPos,
        zoom: 13,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
        styles: [
          { featureType:"poi", stylers:[{visibility:"off"}] },
          { featureType:"transit", stylers:[{visibility:"off"}] }
        ]
      });

      // Driver marker (car icon)
      var driverMarker = new google.maps.Marker({
        position: driverPos,
        map: map,
        title: "Your Driver",
        icon: {
          url: "https://maps.google.com/mapfiles/kml/shapes/cabs.png",
          scaledSize: new google.maps.Size(40, 40),
          anchor: new google.maps.Point(20, 20)
        },
        zIndex: 10
      });

      // Pickup marker (green)
      new google.maps.Marker({
        position: pickupPos,
        map: map,
        title: "Pickup",
        icon: {
          url: "https://maps.google.com/mapfiles/ms/icons/green-dot.png"
        }
      });

      // Destination marker (red)
      new google.maps.Marker({
        position: destPos,
        map: map,
        title: "Destination",
        icon: {
          url: "https://maps.google.com/mapfiles/ms/icons/red-dot.png"
        }
      });

      // Draw route
      var directionsService = new google.maps.DirectionsService();
      var directionsRenderer = new google.maps.DirectionsRenderer({
        suppressMarkers: true,
        polylineOptions: {
          strokeColor: "#D4AF37",
          strokeWeight: 4
        }
      });
      directionsRenderer.setMap(map);
      directionsService.route({
        origin: pickupPos,
        destination: destPos,
        travelMode: google.maps.TravelMode.DRIVING
      }, function(result, status) {
        if (status === "OK") directionsRenderer.setDirections(result);
      });

      // Expose to Flutter for updates
      window._trackingMap_$_mapId = map;
      window._driverMarker_$_mapId = driverMarker;
    }
  </script>
  <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap">
  </script>
</body>
</html>
    ''';

    final blob = html.Blob([mapScript], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final iframe = html.IFrameElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..allow = 'geolocation';

    final container = html.DivElement()
      ..id = _mapId
      ..style.width = '100%'
      ..style.height = '100%';
    container.append(iframe);

    ui_web.platformViewRegistry.registerViewFactory(
      _mapId,
      (_) => container,
    );

    _mapInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3254),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              'Booking #${widget.bookingId}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTracking,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0B3254)),
                  SizedBox(height: 16),
                  Text('Loading tracking data...'),
                ],
              ),
            )
          : _error != null && _trackingData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.signal_wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadTracking, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildTrackingView(),
    );
  }

  Widget _buildTrackingView() {
    final data = _trackingData!;
    final status = data['booking_status'] as String? ?? 'pending';
    final cfg = _statusConfig[status] ?? _statusConfig['pending']!;
    final driver = data['driver'] as Map<String, dynamic>?;
    final driverLoc = data['driver_location'] as Map<String, dynamic>?;
    final trackingActive = data['tracking_active'] as bool? ?? false;
    final completed = status == 'completed';
    final cancelled = status == 'cancelled';

    // Initialize map on first render with data
    if (!_mapInitialized) _initMap(data);

    return Column(
      children: [
        // ── Status banner ─────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: (cfg['color'] as Color).withOpacity(0.12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cfg['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg['icon'] as IconData, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cfg['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: (cfg['color'] as Color),
                  ),
                ),
              ),
              if (!completed && !cancelled)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: trackingActive ? const Color(0xFF10B981) : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!completed && !cancelled)
                const SizedBox(width: 6),
              if (!completed && !cancelled)
                Text(
                  trackingActive ? 'Live' : 'Connecting...',
                  style: TextStyle(
                    fontSize: 11,
                    color: trackingActive ? const Color(0xFF10B981) : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        // ── Map ───────────────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              if (!completed && !cancelled && _mapInitialized)
                HtmlElementView(viewType: _mapId)
              else
                _buildStaticMap(data, status),

              // Pickup / Destination labels overlay
              Positioned(
                left: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _mapLabel(Icons.trip_origin, Colors.green, data['pickup_address'] ?? widget.pickupAddress ?? '—'),
                    const SizedBox(height: 6),
                    _mapLabel(Icons.location_on, Colors.red, data['destination_address'] ?? widget.destinationAddress ?? '—'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Driver info card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))],
          ),
          child: Column(
            children: [
              // Addresses
              Row(
                children: [
                  const Icon(Icons.trip_origin, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['pickup_address'] ?? widget.pickupAddress ?? '—',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['destination_address'] ?? widget.destinationAddress ?? '—',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Driver info
              if (driver != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF0B3254),
                      child: Text(
                        (driver['full_name'] as String? ?? 'D')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver['full_name'] ?? 'Your driver',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B3254)),
                          ),
                          if (data['vehicle_name'] != null)
                            Text(
                              data['vehicle_name'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    if (driver['phone'] != null)
                      _iconBtn(Icons.phone, const Color(0xFF10B981), () => _callDriver(driver['phone'])),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.message, const Color(0xFF0B3254), () => _messageDriver(driver)),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF0B3254),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver pending assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B3254))),
                          Text('You will be notified when assigned', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Last updated
              if (driverLoc != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Driver location updated just now',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticMap(Map<String, dynamic> data, String status) {
    final pickupLat = data['pickup_lat'] ?? 40.7128;
    final pickupLng = data['pickup_lng'] ?? -74.0060;
    final destLat = data['destination_lat'] ?? 40.7580;
    final destLng = data['destination_lng'] ?? -73.9855;
    final apiKey = AppConfig.googleMapsApiKey;

    final staticUrl = 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=600x400&scale=2&maptype=roadmap'
        '&markers=color:green|label:A|$pickupLat,$pickupLng'
        '&markers=color:red|label:B|$destLat,$destLng'
        '&path=color:0xD4AF37|weight:4|$pickupLat,$pickupLng|$destLat,$destLng'
        '&key=$apiKey';

    if (status == 'completed') {
      return Container(
        color: const Color(0xFFECFDF5),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
              SizedBox(height: 16),
              Text('Trip Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B3254))),
              SizedBox(height: 8),
              Text('Thank you for riding with Vanelux', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(staticUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF10223D),
              child: const Center(child: Icon(Icons.map, size: 60, color: Colors.white24)),
            )),
        Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B3254)),
                    ),
                    SizedBox(width: 10),
                    Text('Waiting for driver to start tracking...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapLabel(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _callDriver(String phone) {
    html.window.open('tel:$phone', '_blank');
  }

  void _messageDriver(Map<String, dynamic> driver) {
    html.window.open(
      'https://wa.me/${(driver['phone'] as String?)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '19294180058'}',
      '_blank',
    );
  }
}
