import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../utils/web_url_sync.dart';
import 'web_home_screen.dart';

class CorporateDashboardWeb extends StatefulWidget {
  final User user;

  const CorporateDashboardWeb({super.key, required this.user});

  @override
  State<CorporateDashboardWeb> createState() => _CorporateDashboardWebState();
}

class _CorporateDashboardWebState extends State<CorporateDashboardWeb> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];

  static const List<String> _menuItems = [
    'Overview',
    'Corporate Trips',
    'Team',
    'Billing',
    'Policy',
  ];

  static const List<IconData> _menuIcons = [
    Icons.business_center_outlined,
    Icons.directions_car_filled_outlined,
    Icons.groups_2_outlined,
    Icons.receipt_long_outlined,
    Icons.rule_folder_outlined,
  ];

  String get _currentTabSlug {
    switch (_selectedIndex) {
      case 0:
        return 'overview';
      case 1:
        return 'trips';
      case 2:
        return 'team';
      case 3:
        return 'billing';
      case 4:
        return 'policy';
      default:
        return 'overview';
    }
  }

  @override
  void initState() {
    super.initState();
    syncWebPath('/dashboard/corporate/overview');
    _loadCorporateBookings();
  }

  Future<void> _loadCorporateBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await BookingService.fetchBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading corporate data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  int get _monthlyTrips {
    final now = DateTime.now();
    return _bookings.where((b) {
      final raw = b['scheduledAt'] ?? b['createdAt'];
      if (raw == null) return false;
      final dt = DateTime.tryParse(raw.toString());
      if (dt == null) return false;
      return dt.year == now.year && dt.month == now.month;
    }).length;
  }

  int get _activeTrips {
    return _bookings
        .where((b) => (b['status'] ?? '').toString().toLowerCase() == 'assigned')
        .length;
  }

  int get _pendingTrips {
    return _bookings
        .where((b) => (b['status'] ?? '').toString().toLowerCase() == 'pending')
        .length;
  }

  double get _monthlySpend {
    return _bookings.fold<double>(0, (sum, b) {
      final raw = b['price'];
      if (raw is num) return sum + raw.toDouble();
      return sum + (double.tryParse(raw?.toString() ?? '') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    syncWebPath('/dashboard/corporate/$_currentTabSlug');
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainPanel()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 290,
      color: const Color(0xFF0B3254),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VANELUX',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Corporate Dashboard',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFD4AF37),
                    child: Icon(Icons.business, color: Color(0xFF0B3254), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          widget.user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final selected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    selected: selected,
                    selectedTileColor: Colors.white.withOpacity(0.13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(_menuIcons[index], color: selected ? const Color(0xFFD4AF37) : Colors.white70),
                    title: Text(
                      _menuItems[index],
                      style: TextStyle(
                        color: selected ? const Color(0xFFD4AF37) : Colors.white,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WebHomeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Log out'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPanel() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadCorporateBookings, child: const Text('Retry')),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 1:
        return _buildTripsTab();
      case 2:
        return _buildTeamTab();
      case 3:
        return _buildBillingTab();
      case 4:
        return _buildPolicyTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Account Overview',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0B3254)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track business rides, billing and team mobility from one place.',
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard('Trips this month', _monthlyTrips.toString(), Icons.route),
              _metricCard('Active rides', _activeTrips.toString(), Icons.local_taxi),
              _metricCard('Pending requests', _pendingTrips.toString(), Icons.schedule),
              _metricCard('Estimated spend', '\$${_monthlySpend.toStringAsFixed(2)}', Icons.attach_money),
            ],
          ),
          const SizedBox(height: 24),
          _businessBox(
            title: 'Business Features Enabled',
            items: const [
              'Corporate dashboard different from passenger accounts',
              'Priority support for account-level requests',
              'Monthly billing visibility and spend tracking',
              'Team travel coordination workspace',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTab() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('No corporate trips yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = _bookings[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.business_center),
          title: Text((b['pickupAddress'] ?? 'Pickup').toString()),
          subtitle: Text((b['destinationAddress'] ?? 'Destination').toString()),
          trailing: Text((b['status'] ?? 'pending').toString().toUpperCase()),
        );
      },
    );
  }

  Widget _buildTeamTab() {
    return _placeholderTab(
      title: 'Team Travel Management',
      subtitle: 'Use this area to assign trips to departments, cost centers and employees.',
    );
  }

  Widget _buildBillingTab() {
    return _placeholderTab(
      title: 'Billing & Invoices',
      subtitle: 'Monthly statements and invoice exports can be connected here from your Python admin panel.',
    );
  }

  Widget _buildPolicyTab() {
    return _placeholderTab(
      title: 'Corporate Policy',
      subtitle: 'Define approved routes, pickup windows, and spending policies for your organization.',
    );
  }

  Widget _placeholderTab({required String title, required String subtitle}) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_center, size: 48, color: Color(0xFF0B3254)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0B3254)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF4B5563))),
        ],
      ),
    );
  }

  Widget _businessBox({required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3254),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
