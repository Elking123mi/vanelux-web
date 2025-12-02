import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/openai_assistant_service.dart';
import '../assistant/assistant_chat_screen.dart';
import '../auth/login_screen.dart';
import '../booking/booking_flow_screen.dart';
import '../booking/bookings_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  String _currentLocation = 'Fetching location...';
  bool _isLoadingLocation = true;
  bool _isLoadingUser = true;
  bool _blockedByPermissions = false;
  bool _mustReauthenticate = false;
  String? _userLoadError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  Future<void> _loadUserData({bool showLoader = true}) async {
    if (mounted) {
      setState(() {
        if (showLoader) {
          _isLoadingUser = true;
        }
        _userLoadError = null;
        _blockedByPermissions = false;
        _mustReauthenticate = false;
      });
    }

    try {
      final user = await AuthService.getCurrentUser();

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _currentUser = null;
          _mustReauthenticate = true;
          _userLoadError =
              'Necesitas iniciar sesión nuevamente para continuar usando VaneLux.';
        });
        return;
      }

      // Permitir acceso si:
      // 1. El usuario tiene allowedApps y contiene la app actual
      // 2. El usuario no tiene allowedApps configurado (usuarios demo/viejos)
      final hasAllowedApps = user.allowedApps.isNotEmpty;
      final hasAccess = !hasAllowedApps || user.allowedApps.contains(AppConfig.appIdentifier);
      
      if (!hasAccess) {
        setState(() {
          _currentUser = user;
          _blockedByPermissions = true;
          _userLoadError =
              'Tu cuenta ya no tiene acceso a ${AppConfig.appIdentifier}. Pide a un administrador que te incluya en allowed_apps.';
        });
        return;
      }

      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
        _userLoadError = e.toString();
      });
    } finally {
      if (mounted && showLoader) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permissions denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permissions permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Could not retrieve location';
        _isLoadingLocation = false;
      });
    }
  }

    Future<void> _refreshHomeData() async {
      await _loadUserData(showLoader: false);
      await _getCurrentLocation();
    }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out'),
        content: const Text('Do you want to sign out from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await AuthService.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not sign you out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoadingUser) {
      bodyContent = _buildStatusView(
        icon: Icons.verified_user,
        title: 'Verifying your profile',
        message: 'Sincronizando con VaneLux Central...',
        showSpinner: true,
      );
    } else if (_blockedByPermissions) {
      bodyContent = _buildStatusView(
        icon: Icons.lock_outline,
        title: 'Acceso restringido',
        message: _userLoadError ??
            'Your profile does not have the necessary permissions to use the app.',
        actions: [
          ElevatedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: const Color(0xFFFFD700),
            ),
          ),
          TextButton.icon(
            onPressed: () => _loadUserData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    } else if (_mustReauthenticate || _currentUser == null) {
      bodyContent = _buildStatusView(
        icon: Icons.logout,
        title: 'Vuelve a iniciar sesión',
        message: _userLoadError ??
            'Tu sesión caducó o no pudimos validar tus credenciales.',
        actions: [
          ElevatedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.login),
            label: const Text('Ir al login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF1A1A2E),
            ),
          ),
          TextButton.icon(
            onPressed: () => _loadUserData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      );
    } else if (_userLoadError != null) {
      bodyContent = _buildStatusView(
        icon: Icons.wifi_off,
        title: 'No pudimos cargar tus datos',
        message: _userLoadError!,
        actions: [
          TextButton.icon(
            onPressed: () => _loadUserData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
          TextButton.icon(
            onPressed: _refreshHomeData,
            icon: const Icon(Icons.location_searching),
            label: const Text('Actualizar ubicación'),
          ),
        ],
      );
    } else {
      bodyContent = _buildAuthorizedContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: bodyContent),
    );
  }

  Widget _buildAuthorizedContent() {
    final avatarInitial = _userInitial;
    final greetingName = _currentUser?.displayFirstName ?? 'Guest';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFFFD700),
                    child: Text(
                      avatarInitial,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $greetingName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Where are we heading today?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFFFFD700),
                      size: 28,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'profile':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                          break;
                        case 'logout':
                          _confirmLogout();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('My profile'),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Sign out'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFFFD700),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your current location',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _isLoadingLocation
                                ? 'Loading...'
                                : _currentLocation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    if (!_isLoadingLocation)
                      IconButton(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 1200;
              final bool isTablet = constraints.maxWidth >= 800;

              final double maxContentWidth = isDesktop
                  ? 1100
                  : isTablet
                      ? 900
                      : constraints.maxWidth;

              final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
                20,
                isDesktop ? 36 : 24,
                20,
                isDesktop ? 48 : 32,
              );

              final services = [
                _ServiceCardData(
                  title: 'AI Assistant',
                  subtitle: 'Concierge support',
                  icon: FontAwesomeIcons.robot,
                  color: const Color(0xFFFFD700),
                  action: _openAssistant,
                ),
                _ServiceCardData(
                  title: 'Luxury Taxi',
                  subtitle: 'Premium vehicles',
                  icon: FontAwesomeIcons.car,
                  color: const Color(0xFF4A90E2),
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingFlowScreen(),
                      ),
                    );
                  },
                ),
                _ServiceCardData(
                  title: 'Executive SUV',
                  subtitle: 'Maximum comfort',
                  icon: FontAwesomeIcons.truck,
                  color: const Color(0xFF50C878),
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingFlowScreen(),
                      ),
                    );
                  },
                ),
                _ServiceCardData(
                  title: 'History',
                  subtitle: 'Previous trips',
                  icon: FontAwesomeIcons.clockRotateLeft,
                  color: const Color(0xFFFF6B6B),
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingsHistoryScreen(),
                      ),
                    );
                  },
                ),
                _ServiceCardData(
                  title: 'Profile',
                  subtitle: 'My account',
                  icon: FontAwesomeIcons.user,
                  color: const Color(0xFFFFB347),
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ];

              final int crossAxisCount = isDesktop
                  ? 3
                  : isTablet
                      ? 2
                      : 2;

              final bool useDenseCards = isDesktop || isTablet;

              final double childAspectRatio = isDesktop
                  ? 1.1
                  : isTablet
                      ? 1.1
                      : 0.95;

              return RefreshIndicator(
                onRefresh: _refreshHomeData,
                displacement: 32,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: contentPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Services',
                            style: TextStyle(
                              fontSize: isDesktop ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: services.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: isDesktop ? 24 : 16,
                              mainAxisSpacing: isDesktop ? 24 : 16,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return _buildServiceCard(
                                title: service.title,
                                subtitle: service.subtitle,
                                icon: service.icon,
                                color: service.color,
                                onTap: service.action,
                                dense: useDenseCards,
                              );
                            },
                          ),
                          SizedBox(height: isDesktop ? 32 : 24),
                          Wrap(
                            alignment: isDesktop
                                ? WrapAlignment.spaceBetween
                                : WrapAlignment.start,
                            runSpacing: isDesktop ? 24 : 16,
                            spacing: 24,
                            children: [
                              _BookingActionCard(
                                title: 'Quick Request',
                                subtitle: 'Closest chauffeur in 3 minutes',
                                icon: Icons.flash_on,
                                gradientColors: const [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA500),
                                ],
                                accentColor: const Color(0xFF1A1A2E),
                                buttonLabel: 'Request',
                                buttonForeground: const Color(0xFFFFD700),
                                buttonBackground: const Color(0xFF1A1A2E),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingFlowScreen(
                                        isScheduled: false,
                                      ),
                                    ),
                                  );
                                },
                                maxWidth: isDesktop ? 520 : double.infinity,
                              ),
                              _BookingActionCard(
                                title: 'Schedule Ride',
                                subtitle: 'Plan your trip in advance',
                                icon: Icons.calendar_today,
                                borderColor: const Color(0xFFFFD700),
                                accentColor: const Color(0xFF1A1A2E),
                                buttonLabel: 'Schedule',
                                buttonForeground: const Color(0xFF1A1A2E),
                                buttonBackground: const Color(0xFFFFD700),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingFlowScreen(
                                        isScheduled: true,
                                      ),
                                    ),
                                  );
                                },
                                maxWidth: isDesktop ? 520 : double.infinity,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool dense = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 18 : 20,
            vertical: dense ? 18 : 22,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: dense ? 52 : 60,
                height: dense ? 52 : 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: dense ? 26 : 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AssistantChatScreen(persona: AssistantPersona.client),
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required String title,
    required String message,
    List<Widget>? actions,
    bool showSpinner = false,
  }) {
  final actionWidgets = actions ?? const <Widget>[];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: const Color(0xFF1A1A2E)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showSpinner) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)),
                  ),
                ],
                if (actionWidgets.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: actionWidgets,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _userInitial {
    final user = _currentUser;
    if (user == null) {
      return 'U';
    }

    final candidates = [user.firstName, user.name, user.email];
    for (final candidate in candidates) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        return trimmed.substring(0, 1).toUpperCase();
      }
    }

    return 'U';
  }
}

class _ServiceCardData {
  const _ServiceCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback action;
}

class _BookingActionCard extends StatelessWidget {
  const _BookingActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    required this.maxWidth,
    this.gradientColors,
    this.borderColor,
    this.accentColor = const Color(0xFF1A1A2E),
    required this.buttonLabel,
    required this.buttonForeground,
    required this.buttonBackground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final double maxWidth;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final Color accentColor;
  final String buttonLabel;
  final Color buttonForeground;
  final Color buttonBackground;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;
    if (gradientColors != null) {
      decoration = BoxDecoration(
        gradient: LinearGradient(colors: gradientColors!),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors!.first.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: decoration,
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: accentColor.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackground,
                foregroundColor: buttonForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

