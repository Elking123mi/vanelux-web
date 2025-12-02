import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../booking/bookings_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We could not load your profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('We could not sign you out. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sign out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement profile editing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile editing is coming soon.'),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.maxWidth >= 1200;
                final bool isTablet = constraints.maxWidth >= 800;

                final double maxContentWidth = isDesktop
                    ? 900
                    : isTablet
                        ? 720
                        : constraints.maxWidth;

                final EdgeInsets horizontalPadding = EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 20,
                );

                final double sectionSpacing = isDesktop ? 32 : 24;

                final List<Widget> statsCards = [
                  _buildStatCard(
                    '28',
                    'Trips\nCompleted',
                    FontAwesomeIcons.route,
                    const Color(0xFF4A90E2),
                  ),
                  _buildStatCard(
                    '\$1,245',
                    'Total\nSpent',
                    FontAwesomeIcons.dollarSign,
                    const Color(0xFF50C878),
                  ),
                  _buildStatCard(
                    '6 months',
                    'VaneLux\nMember',
                    FontAwesomeIcons.crown,
                    const Color(0xFFFFD700),
                  ),
                ];

                final int statColumns = isDesktop ? 3 : isTablet ? 2 : 1;
                const double statSpacing = 20;
                final double availableStatWidth =
                    maxContentWidth - horizontalPadding.horizontal;
                final double statItemWidth = statColumns == 1
                    ? availableStatWidth
                    : (availableStatWidth - (statColumns - 1) * statSpacing) /
                        statColumns;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: sectionSpacing),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(28),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 40 : 24,
                                vertical: isDesktop ? 36 : 28,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: isDesktop ? 130 : 110,
                                    height: isDesktop ? 130 : 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFFD700),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _currentUser?.profileImageUrl != null
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              _currentUser!.profileImageUrl!,
                                            ),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor:
                                                Color(0xFFFFD700),
                                            child: Icon(
                                              Icons.person,
                                              size: 56,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: isDesktop ? 24 : 20),
                                  Text(
                                    _currentUser?.name ?? 'VaneLux Rider',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 26 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentUser?.email ?? 'rider@vanelux.com',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_currentUser?.phone != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _currentUser!.phone,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: isDesktop ? 24 : 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFFFD700).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: const Color(0xFFFFD700),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Color(0xFFFFD700),
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '4.8',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Rating',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: sectionSpacing),
                          Padding(
                            padding: horizontalPadding,
                            child: Wrap(
                              alignment: statColumns == 1
                                  ? WrapAlignment.center
                                  : WrapAlignment.start,
                              spacing: statSpacing,
                              runSpacing: statSpacing,
                              children: statsCards
                                  .map(
                                    (card) => SizedBox(
                                      width: statItemWidth,
                                      child: card,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          SizedBox(height: sectionSpacing),
                          Padding(
                            padding: horizontalPadding,
                            child: Column(
                              children: [
                                _buildProfileOption(
                                  'Trip History',
                                  FontAwesomeIcons.clockRotateLeft,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BookingsHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildProfileOption(
                                  'Payment Methods',
                                  FontAwesomeIcons.creditCard,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Payment methods are coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildProfileOption(
                                  'Saved Addresses',
                                  FontAwesomeIcons.locationDot,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Saved addresses are coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildProfileOption(
                                  'Promotions',
                                  FontAwesomeIcons.gift,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Promotions are coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildSwitchOption(
                                  'Notifications',
                                  FontAwesomeIcons.bell,
                                  _notificationsEnabled,
                                  (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                ),
                                _buildSwitchOption(
                                  'Share Location',
                                  FontAwesomeIcons.locationArrow,
                                  _locationEnabled,
                                  (value) {
                                    setState(() {
                                      _locationEnabled = value;
                                    });
                                  },
                                ),
                                _buildProfileOption(
                                  'Help & Support',
                                  FontAwesomeIcons.headset,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Support is coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildProfileOption(
                                  'Terms & Conditions',
                                  FontAwesomeIcons.fileContract,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Terms and conditions are coming soon.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _logout,
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.rightFromBracket,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Sign out',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: sectionSpacing),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF1A1A2E),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchOption(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFFFD700),
          activeTrackColor: const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
    );
  }
}
