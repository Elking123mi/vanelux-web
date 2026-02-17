import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/driver.dart';
import '../../services/auth_service.dart';

// ─── Data models used only by this screen ─────────────────────────────────

class _DriverTrip {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double earnings;
  final DateTime date;
  final String status; // 'completed' | 'cancelled' | 'pending'
  final String vehicleName;
  final double distanceMiles;
  final String durationMin;

  const _DriverTrip({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.earnings,
    required this.date,
    required this.status,
    required this.vehicleName,
    required this.distanceMiles,
    required this.durationMin,
  });
}

// ─── Main Widget ──────────────────────────────────────────────────────────

class DriverDashboardWeb extends StatefulWidget {
  final Driver driver;

  const DriverDashboardWeb({super.key, required this.driver});

  @override
  State<DriverDashboardWeb> createState() => _DriverDashboardWebState();
}

class _DriverDashboardWebState extends State<DriverDashboardWeb>
    with TickerProviderStateMixin {
  // Navigation
  int _selectedIndex = 0;

  // Online status
  bool _isOnline = false;
  bool _isSharingLocation = false;
  Position? _currentPosition;
  Timer? _locationTimer;

  // Animation for online toggle
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mock trips (replace with real API call)
  final List<_DriverTrip> _trips = [
    _DriverTrip(
      id: '1',
      pickupAddress: '350 5th Ave, Manhattan, NY',
      dropoffAddress: 'JFK Airport, Queens, NY',
      earnings: 140.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'completed',
      vehicleName: 'Mercedes-Maybach S 680',
      distanceMiles: 16.2,
      durationMin: '42',
    ),
    _DriverTrip(
      id: '2',
      pickupAddress: 'LaGuardia Airport, Queens, NY',
      dropoffAddress: '30 Rockefeller Plaza, Manhattan',
      earnings: 120.00,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'completed',
      vehicleName: 'Cadillac Escalade ESV',
      distanceMiles: 11.4,
      durationMin: '35',
    ),
    _DriverTrip(
      id: '3',
      pickupAddress: 'One World Trade Center, NYC',
      dropoffAddress: 'Newark Airport, NJ',
      earnings: 180.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      vehicleName: 'Range Rover Autobiography',
      distanceMiles: 19.7,
      durationMin: '55',
    ),
    _DriverTrip(
      id: '4',
      pickupAddress: 'Central Park South, NYC',
      dropoffAddress: 'Brooklyn Bridge, NYC',
      earnings: 85.00,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: 'completed',
      vehicleName: 'Mercedes-Maybach S 680',
      distanceMiles: 6.8,
      durationMin: '28',
    ),
    _DriverTrip(
      id: '5',
      pickupAddress: 'Times Square, Manhattan, NY',
      dropoffAddress: 'JFK Airport, Queens, NY',
      earnings: 140.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'cancelled',
      vehicleName: 'Cadillac Escalade ESV',
      distanceMiles: 17.1,
      durationMin: '0',
    ),
  ];

  // ── Computed stats ──
  double get _todayEarnings {
    final today = DateTime.now();
    return _trips
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day &&
            t.status == 'completed')
        .fold(0.0, (sum, t) => sum + t.earnings);
  }

  int get _todayTrips {
    final today = DateTime.now();
    return _trips
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day &&
            t.status == 'completed')
        .length;
  }

  double get _weekEarnings {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _trips
        .where((t) => t.date.isAfter(weekAgo) && t.status == 'completed')
        .fold(0.0, (sum, t) => sum + t.earnings);
  }

  double get _totalEarnings =>
      _trips.where((t) => t.status == 'completed').fold(0.0, (sum, t) => sum + t.earnings);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  // ── Location ──

  Future<void> _toggleOnline() async {
    if (_isOnline) {
      // Go offline
      _locationTimer?.cancel();
      setState(() {
        _isOnline = false;
        _isSharingLocation = false;
        _currentPosition = null;
      });
      return;
    }

    // Go online — request location permission
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled. Please enable them.', isError: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied.', isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permissions are permanently denied.', isError: true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isOnline = true;
        _isSharingLocation = true;
        _currentPosition = pos;
      });

      // Update location every 30 seconds
      _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        try {
          final newPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          if (mounted) setState(() => _currentPosition = newPos);
          // TODO: POST location to backend
          // await ApiService.updateDriverLocation(lat: newPos.latitude, lng: newPos.longitude);
        } catch (_) {}
      });

      _showSnack('You are now online. Your location is being shared.', isError: false);
    } catch (e) {
      // On web, geolocator may throw. Fallback: go online without location.
      setState(() {
        _isOnline = true;
        _isSharingLocation = false;
      });
      _showSnack('Online (location not available in this browser).', isError: false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) Navigator.of(context).pop();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // ── Desktop: Sidebar + Content ──

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  // ── Mobile: Bottom nav ──

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(child: _buildContent()),
        _buildBottomNav(),
      ],
    );
  }

  // ─── SIDEBAR ─────────────────────────────────────────────────────────────

  Widget _buildSidebar() {
    const navItems = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.directions_car_outlined, 'label': 'My Trips'},
      {'icon': Icons.attach_money, 'label': 'Earnings'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B3254), Color(0xFF0D3F66)],
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car, color: Color(0xFFD4AF37), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VANELUX', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2)),
                    Text('Driver Portal', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Driver info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                  child: Text(
                    widget.driver.name.isNotEmpty ? widget.driver.name[0].toUpperCase() : 'D',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driver.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: _isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                              fontSize: 11,
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
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          // Nav items
          ...List.generate(navItems.length, (i) {
            final item = navItems[i];
            final selected = _selectedIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: selected ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: selected ? const Color(0xFFD4AF37) : Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: selected ? const Color(0xFFD4AF37) : Colors.white70,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.directions_car_outlined, 'label': 'Trips'},
      {'icon': Icons.attach_money, 'label': 'Earnings'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B3254),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final sel = _selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData, size: 22, color: sel ? const Color(0xFFD4AF37) : Colors.white54),
                    const SizedBox(height: 3),
                    Text(item['label'] as String, style: TextStyle(fontSize: 10, color: sel ? const Color(0xFFD4AF37) : Colors.white54)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── CONTENT ─────────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildTripsPage();
      case 2:
        return _buildEarningsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildDashboardPage();
    }
  }

  // ─── DASHBOARD PAGE ───────────────────────────────────────────────────────

  Widget _buildDashboardPage() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()}, ${widget.driver.name.split(' ').first}! 👋',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B3254),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isOnline
                          ? '🟢 You are online and accepting rides'
                          : '⚫ You are offline',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Small logout on mobile
              if (isMobile)
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Color(0xFF0B3254)),
                ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Online/Offline toggle card ──
          _buildOnlineToggleCard(),
          const SizedBox(height: 24),

          // ── Stats ──
          isMobile ? _buildStatsColumnMobile() : _buildStatsRowDesktop(),
          const SizedBox(height: 24),

          // ── Recent trips ──
          const Text(
            'Recent Trips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0B3254)),
          ),
          const SizedBox(height: 12),
          ..._trips.take(3).map((t) => _buildTripCard(t)),
          if (_trips.length > 3)
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              child: const Text('View all trips →', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isOnline
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFF0B3254), const Color(0xFF163D5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isOnline ? const Color(0xFF2E7D32) : const Color(0xFF0B3254)).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing indicator
          if (_isOnline)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 28),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_tethering_off, color: Colors.white54, size: 28),
            ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'You are ONLINE' : 'You are OFFLINE',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline
                      ? _isSharingLocation
                          ? '📍 Location: ${_currentPosition != null ? '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}' : 'Sharing...'}'
                          : '📍 Location sharing not available'
                      : 'Tap the button to go online and start receiving rides',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Toggle button
          GestureDetector(
            onTap: _toggleOnline,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.white.withOpacity(0.2) : const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isOnline ? 42 : 4,
                    top: 4,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        _isOnline ? Icons.check : Icons.power_settings_new,
                        size: 16,
                        color: _isOnline ? const Color(0xFF2E7D32) : const Color(0xFF0B3254),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRowDesktop() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Today's Earnings", '\$${_todayEarnings.toStringAsFixed(0)}', Icons.today, const Color(0xFF0B3254))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Today's Trips", '$_todayTrips', Icons.directions_car, const Color(0xFFD4AF37))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("This Week", '\$${_weekEarnings.toStringAsFixed(0)}', Icons.calendar_today, const Color(0xFF2196F3))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Total Earned', '\$${_totalEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet, const Color(0xFF4CAF50))),
      ],
    );
  }

  Widget _buildStatsColumnMobile() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard("Today's Earnings", '\$${_todayEarnings.toStringAsFixed(0)}', Icons.today, const Color(0xFF0B3254))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard("Today's Trips", '$_todayTrips', Icons.directions_car, const Color(0xFFD4AF37))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard("This Week", '\$${_weekEarnings.toStringAsFixed(0)}', Icons.calendar_today, const Color(0xFF2196F3))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Earned', '\$${_totalEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet, const Color(0xFF4CAF50))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ─── TRIPS PAGE ───────────────────────────────────────────────────────────

  Widget _buildTripsPage() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Trips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0B3254))),
          const SizedBox(height: 4),
          Text('${_trips.length} total trips', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', true),
                const SizedBox(width: 8),
                _filterChip('Completed', false),
                const SizedBox(width: 8),
                _filterChip('Cancelled', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._trips.map((t) => _buildTripCard(t, expanded: true)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0B3254) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? const Color(0xFF0B3254) : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTripCard(_DriverTrip trip, {bool expanded = false}) {
    final statusColor = trip.status == 'completed'
        ? const Color(0xFF4CAF50)
        : trip.status == 'cancelled'
            ? Colors.red
            : const Color(0xFFD4AF37);

    final statusLabel = trip.status == 'completed' ? 'Completed' : trip.status == 'cancelled' ? 'Cancelled' : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3254).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car, size: 18, color: Color(0xFF0B3254)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.vehicleName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0B3254))),
                    Text(_formatDate(trip.date), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trip.status == 'cancelled' ? '—' : '\$${trip.earnings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: trip.status == 'cancelled' ? Colors.grey : const Color(0xFFD4AF37),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[100]),
            const SizedBox(height: 10),
            _addressRow(Icons.my_location, const Color(0xFF0B3254), trip.pickupAddress),
            const SizedBox(height: 6),
            _addressRow(Icons.location_on, const Color(0xFFD4AF37), trip.dropoffAddress),
            if (trip.status == 'completed') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _tripMeta(Icons.straighten, '${trip.distanceMiles} mi'),
                  const SizedBox(width: 16),
                  if (trip.durationMin != '0') _tripMeta(Icons.timer, '${trip.durationMin} min'),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _addressRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(address, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _tripMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  // ─── EARNINGS PAGE ────────────────────────────────────────────────────────

  Widget _buildEarningsPage() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final completedTrips = _trips.where((t) => t.status == 'completed').toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Earnings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0B3254))),
          const SizedBox(height: 24),
          // Big total card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B3254), Color(0xFF163D5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF0B3254).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Earnings', style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 40, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _earningsBadge('Today', '\$${_todayEarnings.toStringAsFixed(0)}'),
                    const SizedBox(width: 16),
                    _earningsBadge('This Week', '\$${_weekEarnings.toStringAsFixed(0)}'),
                    const SizedBox(width: 16),
                    _earningsBadge('Trips', '${completedTrips.length}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Per-trip breakdown
          const Text('Trip Earnings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0B3254))),
          const SizedBox(height: 12),
          ...completedTrips.map((t) => _buildEarningsRow(t)),
        ],
      ),
    );
  }

  Widget _earningsBadge(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildEarningsRow(_DriverTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.pickupAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text('→ ${trip.dropoffAddress}', style: TextStyle(fontSize: 11, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                Text(_formatDate(trip.date), style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
          Text('\$${trip.earnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  // ─── PROFILE PAGE ─────────────────────────────────────────────────────────

  Widget _buildProfilePage() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0B3254), Color(0xFFD4AF37)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF0B3254).withOpacity(0.3), blurRadius: 16)],
            ),
            child: Center(
              child: Text(
                widget.driver.name.isNotEmpty ? widget.driver.name[0].toUpperCase() : 'D',
                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.driver.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0B3254))),
          const SizedBox(height: 4),
          Text('Professional Chauffeur', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 12),
          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) => Icon(
                Icons.star,
                size: 20,
                color: i < widget.driver.rating.floor() ? const Color(0xFFD4AF37) : Colors.grey[300],
              )),
              const SizedBox(width: 6),
              Text('${widget.driver.rating.toStringAsFixed(1)} rating', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 28),
          // Info cards
          _profileInfoCard(Icons.phone, 'Phone', widget.driver.phone),
          _profileInfoCard(Icons.badge, 'License Number', widget.driver.licenseNumber),
          _profileInfoCard(Icons.directions_car, 'Total Trips', '${widget.driver.totalTrips + _trips.where((t) => t.status == 'completed').length}'),
          _profileInfoCard(Icons.calendar_today, 'Member Since', 'Vanelux Driver'),
          const SizedBox(height: 24),
          // Sign out button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0B3254)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0B3254))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
