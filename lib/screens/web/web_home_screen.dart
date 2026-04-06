import 'dart:async';
import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../models/assistant_message.dart';
import '../../models/driver.dart';
import '../../models/user.dart';
import '../../providers/locale_provider.dart';
import '../../services/auth_service.dart';
import '../../services/oauth_service.dart';
import '../../services/google_maps_service.dart';
import '../../services/openai_assistant_service.dart';
import '../../services/pricing_service.dart';
import '../../widgets/vanelux_logo.dart';
import '../../widgets/notifications_panel.dart';
import 'driver_applications_admin_screen.dart';
import 'driver_registration_screen.dart';
import '../../widgets/route_map_view.dart';
import 'customer_dashboard_web.dart';
import 'driver_dashboard_web.dart';
import 'fleet_screen.dart';
import 'payment_screen.dart';
import 'service_detail_screen.dart';
import 'trip_details_web_screen.dart';

class _QuoteVehicleOption {
  const _QuoteVehicleOption({
    required this.name,
    required this.description,
    required this.passengers,
    required this.luggage,
    required this.imageUrl,
    required this.rateMultiplier,
  });

  final String name;
  final String description;
  final int passengers;
  final int luggage;
  final String imageUrl;
  final double rateMultiplier;
}

class _VehicleQuote {
  const _VehicleQuote({
    required this.vehicle,
    required this.totalPrice,
    required this.ratePerMile,
  });

  final _QuoteVehicleOption vehicle;
  final double totalPrice;
  final double ratePerMile;
}

class _RouteQuote {
  const _RouteQuote({
    required this.origin,
    required this.destination,
    required this.distanceText,
    required this.durationText,
    required this.totalMiles,
    required this.baseRatePerMile,
    required this.includesReturnTrip,
    required this.options,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.pickupDateTime,
    this.routeLabel,
    this.routeType,
  });

  final String origin;
  final String destination;
  final String distanceText;
  final String durationText;
  final double totalMiles;
  final double baseRatePerMile;
  final bool includesReturnTrip;
  final List<_VehicleQuote> options;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime? pickupDateTime;
  final String? routeLabel;
  final RouteType? routeType;
}

class _SelectedLocation {
  const _SelectedLocation({
    required this.placeId,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String description;
  final double latitude;
  final double longitude;
}

String _suggestionFallback(Map<String, dynamic> suggestion) {
  final structured =
      suggestion['structured_formatting'] as Map<String, dynamic>?;
  final mainText = structured?['main_text'] as String?;
  final secondaryText = structured?['secondary_text'] as String?;
  final dynamic fallback =
      [
        suggestion['description'] as String?,
        if (mainText != null &&
            mainText.isNotEmpty &&
            secondaryText != null &&
            secondaryText.isNotEmpty)
          '$mainText, $secondaryText',
        mainText,
        suggestion['name'] as String?,
      ].firstWhere(
        (value) => value != null && value.trim().isNotEmpty,
        orElse: () => '',
      );
  return (fallback ?? '').toString();
}

String _getSuggestionMainText(Map<String, dynamic> suggestion) {
  try {
    final structured = suggestion['structured_formatting'];
    if (structured != null && structured is Map) {
      final mainText = structured['main_text'];
      if (mainText != null) {
        return mainText.toString();
      }
    }
    final description = suggestion['description'];
    if (description != null) {
      return description.toString();
    }
  } catch (e) {
    // Ignorar errores y usar fallback
  }
  return '';
}

String _getSuggestionSecondaryText(Map<String, dynamic> suggestion) {
  try {
    final structured = suggestion['structured_formatting'];
    if (structured != null && structured is Map) {
      final secondaryText = structured['secondary_text'];
      if (secondaryText != null) {
        return secondaryText.toString();
      }
    }
  } catch (e) {
    // Ignorar errores
  }
  return '';
}

bool _sameAddress(String? a, String? b) {
  final first = (a ?? '').trim().toLowerCase();
  final second = (b ?? '').trim().toLowerCase();
  if (first.isEmpty || second.isEmpty) {
    return false;
  }
  return first == second;
}

class WebHomeScreen extends StatefulWidget {
  final String? initialServiceType;
  final String? selectedPackage;
  final bool isServiceLocked;

  const WebHomeScreen({
    super.key,
    this.initialServiceType,
    this.selectedPackage,
    this.isServiceLocked = false,
  });

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _fleetKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  // Fleet carousel state
  int _currentVehicleIndex = 0;
  Timer? _carouselTimer;

  // Mobile app ad carousel state
  int _mobileAppAdIndex = 0;
  Timer? _mobileAppAdTimer;

  // Mobile menu state
  final bool _isMobileMenuOpen = false;

  // Booking form state
  String? selectedServiceType;
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  DateTime? selectedDateTime;
  bool isReturnTrip = false;
  final FocusNode pickupFocusNode = FocusNode();
  final FocusNode destinationFocusNode = FocusNode();
  List<Map<String, dynamic>> pickupSuggestions = [];
  List<Map<String, dynamic>> destinationSuggestions = [];
  Timer? _pickupDebounce;
  Timer? _destinationDebounce;
  bool isFetchingQuote = false;
  _RouteQuote? currentQuote;
  String? quoteError;
  _SelectedLocation? _pickupPlace;
  _SelectedLocation? _destinationPlace;
  bool _isResolvingPickup = false;
  bool _isResolvingDestination = false;
  bool _showPickupDropdown = false;
  bool _showDestinationDropdown = false;
  User? _currentUser;
  bool _isCheckingAuth = true;
  bool _isServiceLockedState = false;

  // AI Assistant state
  bool _showAssistantChat = false;
  final List<AssistantMessage> _assistantMessages = [];
  final TextEditingController _assistantController = TextEditingController();
  final OpenAIAssistantService _assistantService = OpenAIAssistantService();
  bool _isAssistantTyping = false;

  // Chat Booking Form state
  bool _showChatBookingForm = false;
  final TextEditingController _chatPickupController = TextEditingController();
  final TextEditingController _chatDropoffController = TextEditingController();
  List<Map<String, dynamic>> _chatPickupSuggestions = [];
  List<Map<String, dynamic>> _chatDropoffSuggestions = [];
  bool _showChatPickupDropdown = false;
  bool _showChatDropoffDropdown = false;
  Timer? _chatPickupDebounce;
  Timer? _chatDropoffDebounce;
  _SelectedLocation? _chatPickupPlace;
  _SelectedLocation? _chatDropoffPlace;
  bool _showChatVehicleCards = false;
  Map<VehicleTier, PriceEstimate>? _chatPrices;
  double _chatDistanceMiles = 0.0;

  final List<String> serviceTypes = const [
    'To Airport',
    'From Airport',
    'Hourly/As Directed',
    'Point to Point',
    'Corporate',
    'Wedding',
    'Tour',
  ];

  final List<_QuoteVehicleOption> _quoteVehicleOptions = const [
    _QuoteVehicleOption(
      name: 'Mercedes-Maybach S 680',
      description: 'Sedan de lujo • 4 pasajeros • 3 equipajes',
      passengers: 4,
      luggage: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1617450365226-a9994d16ff2a?auto=format&fit=crop&w=1200&q=80',
      rateMultiplier: 2.0,
    ),
    _QuoteVehicleOption(
      name: 'Cadillac Escalade ESV',
      description: 'SUV premium • 6 pasajeros • 6 equipajes',
      passengers: 6,
      luggage: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1571422789648-ef357f10d838?auto=format&fit=crop&w=1200&q=80',
      rateMultiplier: 1.6,
    ),
    _QuoteVehicleOption(
      name: 'Range Rover Autobiography',
      description: 'SUV ejecutiva • 4 pasajeros • 4 equipajes',
      passengers: 4,
      luggage: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1617813486164-1f910f7cc8e9?auto=format&fit=crop&w=1200&q=80',
      rateMultiplier: 1.8,
    ),
    _QuoteVehicleOption(
      name: 'Mercedes-Benz Sprinter Jet',
      description: 'Sprinter ejecutiva • 10 pasajeros • 12 equipajes',
      passengers: 10,
      luggage: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1605559424639-1d74fd9f5bff?auto=format&fit=crop&w=1200&q=80',
      rateMultiplier: 2.4,
    ),
    _QuoteVehicleOption(
      name: 'Mini Coach 27 pax',
      description: 'Mini coach de lujo • 27 pasajeros • 32 equipajes',
      passengers: 27,
      luggage: 32,
      imageUrl:
          'https://images.unsplash.com/photo-1603562619648-5ef0ed15d9c4?auto=format&fit=crop&w=1200&q=80',
      rateMultiplier: 2.8,
    ),
  ];

  // Verificar si viene de un pago exitoso y enviar email de confirmación
  Future<void> _checkPaymentSuccess() async {
    try {
      final uri = Uri.base;
      print('🔍 URL actual completa: ${uri.toString()}');

      final paymentStatus = uri.queryParameters['payment'];
      final bookingId = uri.queryParameters['booking_id'];

      print('🔍 payment parameter: $paymentStatus');
      print('🔍 booking_id parameter: $bookingId');

      if (paymentStatus == 'success' && bookingId != null) {
        print('✅ Payment success detected for booking #$bookingId');
        print('📧 Sending confirmation email...');

        // Show message BEFORE sending
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '📧 Sending email confirmation for booking #$bookingId...',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        final response = await http.post(
          Uri.parse(
            'https://web-production-700fe.up.railway.app/api/v1/vlx/bookings/$bookingId/send-confirmation',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        print('📬 Response status: ${response.statusCode}');
        print('📬 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('✅ Email sent: ${data['message']}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Confirmation email sent successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          print('⚠️ Could not send email: ${response.body}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ Error sending confirmation: ${response.statusCode}',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        print(
          'ℹ️ No successful payment to process (payment=$paymentStatus, booking_id=$bookingId)',
        );
      }
    } catch (e) {
      print('❌ Error sending confirmation email: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize service type from widget parameters
    if (widget.initialServiceType != null) {
      selectedServiceType = widget.initialServiceType;
    }
    _isServiceLockedState = widget.isServiceLocked;
    _showPickupDropdown = false;
    _showDestinationDropdown = false;
    // NO cerrar dropdown al perder foco - esto causaba el problema
    _loadCurrentUser();
    _startCarousel();
    _startMobileAppAdCarousel();
    _checkPaymentSuccess(); // Verificar si viene de pago exitoso
  }

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    pickupFocusNode.dispose();
    destinationFocusNode.dispose();
    _pickupDebounce?.cancel();
    _destinationDebounce?.cancel();
    _carouselTimer?.cancel();
    _mobileAppAdTimer?.cancel();
    _assistantController.dispose();
    _assistantService.dispose();
    _chatPickupController.dispose();
    _chatDropoffController.dispose();
    _chatPickupDebounce?.cancel();
    _chatDropoffDebounce?.cancel();
    super.dispose();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentVehicleIndex = (_currentVehicleIndex + 1) % 7; // 7 vehículos
        });
      }
    });
  }

  void _startMobileAppAdCarousel() {
    _mobileAppAdTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _mobileAppAdIndex = (_mobileAppAdIndex + 1) % 2; // 2 imágenes
        });
      }
    });
  }

  void _scrollToSection(GlobalKey key) {
    final BuildContext? targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentUser = user;
        _isCheckingAuth = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentUser = null;
        _isCheckingAuth = false;
      });
    }
  }

  void _navigateToLogin() {
    _handleLoginFlow();
  }

  void _navigateToSignup() {
    _handleSignupFlow();
  }

  Future<void> _handleLoginFlow() async {
    final user = await _showLoginDialog();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Welcome back to VaneLux!')));
    }
  }

  Future<void> _handleSignupFlow() async {
    final user = await _showSignupDialog();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    }
  }

  Future<User?> _showLoginDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    try {
      return await showDialog<User>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (dialogContext) {
          bool isLoading = false;
          String? errorMessage;
          bool isDriverMode = false;
          bool obscurePassword = true;

          // ── helpers ────────────────────────────────────────────────
          InputDecoration fieldDeco(String label, {IconData? icon}) {
            return InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF999999)) : null,
              filled: true,
              fillColor: const Color(0xFFF6F7FA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0B3254), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            );
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              color: const Color(0xFF0B3254),
                            ),
                            child: const Center(child: Text('V',
                              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.w800))),
                          ),
                          const SizedBox(width: 10),
                          const Text('VANELUX',
                            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Color(0xFF999999)),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        const Text('Welcome', style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF0B3254))),
                        const SizedBox(height: 4),
                        Text(isDriverMode ? 'Sign in to your driver account.' : 'Log in to continue to Vanelux.',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
                        const SizedBox(height: 20),

                        // Client / Driver toggle (pill)
                        Container(
                          height: 40,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            Expanded(child: GestureDetector(
                              onTap: () => setDialogState(() { isDriverMode = false; errorMessage = null; }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: !isDriverMode ? const Color(0xFF0B3254) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(child: Text('Client',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    color: !isDriverMode ? Colors.white : const Color(0xFF888888)))),
                              ),
                            )),
                            Expanded(child: GestureDetector(
                              onTap: () => setDialogState(() { isDriverMode = true; errorMessage = null; }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isDriverMode ? const Color(0xFFD4AF37) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(child: Text('Driver',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    color: isDriverMode ? const Color(0xFF0B3254) : const Color(0xFF888888)))),
                              ),
                            )),
                          ]),
                        ),

                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: fieldDeco('Email address', icon: Icons.email_outlined),
                        ),
                        const SizedBox(height: 14),
                        StatefulBuilder(builder: (_, setSuffix) => TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(fontSize: 14),
                          decoration: fieldDeco('Password', icon: Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18, color: const Color(0xFF999999)),
                              onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                            ),
                          ),
                        )),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.25)),
                            ),
                            child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ),
                        ],

                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDriverMode ? const Color(0xFFD4AF37) : const Color(0xFF0B3254),
                              foregroundColor: isDriverMode ? const Color(0xFF0B3254) : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: isLoading ? null : () async {
                              final email = emailController.text.trim();
                              final password = passwordController.text;
                              if (email.isEmpty || password.isEmpty) {
                                setDialogState(() => errorMessage = 'Please enter your email and password.');
                                return;
                              }
                              setDialogState(() { isLoading = true; errorMessage = null; });
                              if (isDriverMode) {
                                try {
                                  final Driver driver = await AuthService.loginDriver(email, password);
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DriverDashboardWeb(driver: driver)));
                                } catch (e) {
                                  setDialogState(() { errorMessage = 'Driver sign-in failed. Check your credentials.'; isLoading = false; });
                                }
                              } else {
                                try {
                                  final user = await AuthService.login(email, password);
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop(user);
                                } catch (e) {
                                  setDialogState(() { errorMessage = 'Sign-in failed. Please verify your credentials.'; isLoading = false; });
                                }
                              }
                            },
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ]),
                        const SizedBox(height: 16),

                        _authSocialBtn(Icons.apple, 'Continue with Apple', () {}),
                        const SizedBox(height: 8),
                        _authSocialBtn(Icons.g_mobiledata, 'Continue with Google', () async {
                          setDialogState(() { isLoading = true; errorMessage = null; });
                          try {
                            final result = await OAuthService.signInWithGoogle();
                            if (result != null && result['success'] == true && dialogContext.mounted) {
                              final userData = result['user'];
                              final user = userData != null ? User.fromJson(userData as Map<String, dynamic>) : null;
                              Navigator.of(dialogContext).pop(user);
                            } else if (dialogContext.mounted) {
                              setDialogState(() { errorMessage = 'Google sign-in failed. Please try again.'; isLoading = false; });
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() { errorMessage = 'Google sign-in error: ${e.toString()}'; isLoading = false; });
                            }
                          }
                        }),
                        const SizedBox(height: 8),
                        _authSocialBtn(Icons.facebook, 'Continue with Facebook', () async {
                          setDialogState(() { isLoading = true; errorMessage = null; });
                          try {
                            final result = await OAuthService.signInWithFacebook();
                            if (result != null && result['success'] == true && dialogContext.mounted) {
                              final userData = result['user'];
                              final user = userData != null ? User.fromJson(userData as Map<String, dynamic>) : null;
                              Navigator.of(dialogContext).pop(user);
                            } else if (dialogContext.mounted) {
                              setDialogState(() { errorMessage = 'Facebook sign-in failed. Please try again.'; isLoading = false; });
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() { errorMessage = 'Facebook sign-in error: ${e.toString()}'; isLoading = false; });
                            }
                          }
                        }),

                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              _navigateToSignup();
                            },
                            child: const Text('Sign up',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0B3254),
                                decoration: TextDecoration.underline)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      emailController.dispose();
      passwordController.dispose();
    }
  }

  Widget _authSocialBtn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Future<User?> _showSignupDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    try {
      return await showDialog<User>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (dialogContext) {
          bool isLoading = false;
          String? errorMessage;
          bool acceptTerms = false;
          bool obscurePassword = true;

          InputDecoration fieldDeco(String label, {IconData? icon}) {
            return InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF999999)) : null,
              filled: true,
              fillColor: const Color(0xFFF6F7FA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0B3254), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            );
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                                color: const Color(0xFF0B3254),
                              ),
                              child: const Center(child: Text('V',
                                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.w800))),
                            ),
                            const SizedBox(width: 10),
                            const Text('VANELUX',
                              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Color(0xFF999999)),
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ]),
                          const SizedBox(height: 24),
                          const Text('Create account', style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF0B3254))),
                          const SizedBox(height: 4),
                          const Text('Join Vanelux for a premium ride experience.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                          const SizedBox(height: 20),

                          TextField(
                            controller: nameController,
                            style: const TextStyle(fontSize: 14),
                            decoration: fieldDeco('Full name', icon: Icons.person_outline),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14),
                            decoration: fieldDeco('Email address', icon: Icons.email_outlined),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 14),
                            decoration: fieldDeco('Phone number', icon: Icons.phone_outlined),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(fontSize: 14),
                            decoration: fieldDeco('Create password', icon: Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18, color: const Color(0xFF999999)),
                                onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Terms checkbox
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: acceptTerms,
                                onChanged: isLoading ? null : (v) => setDialogState(() => acceptTerms = v ?? false),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                activeColor: const Color(0xFF0B3254),
                                side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: Text(
                              'I agree to the Vanelux terms of service and privacy policy.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.4),
                            )),
                          ]),

                          if (errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.25)),
                              ),
                              child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          ],

                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B3254),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: isLoading ? null : () async {
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final phone = phoneController.text.trim();
                                final password = passwordController.text;
                                if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                                  setDialogState(() => errorMessage = 'Please fill in all required fields.');
                                  return;
                                }
                                if (!acceptTerms) {
                                  setDialogState(() => errorMessage = 'Please accept the terms to continue.');
                                  return;
                                }
                                setDialogState(() { isLoading = true; errorMessage = null; });
                                try {
                                  final user = await AuthService.register(
                                    name: name, email: email, phone: phone, password: password);
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop(user);
                                } catch (e) {
                                  setDialogState(() {
                                    final errorText = e.toString();
                                    if (errorText.contains('Ya existe un usuario')) {
                                      errorMessage = 'This email is already registered. Please log in.';
                                    } else if (errorText.contains('timeout') || errorText.contains('connection')) {
                                      errorMessage = 'Connection error. Check your internet and try again.';
                                    } else if (errorText.contains('Exception:')) {
                                      errorMessage = errorText.replaceAll('Exception:', '').trim();
                                    } else {
                                      errorMessage = 'Could not create account. Please try again.';
                                    }
                                    isLoading = false;
                                  });
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Create account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Divider
                          Row(children: [
                            Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Or sign up with', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
                          ]),
                          const SizedBox(height: 16),
                          // OAuth Buttons
                          Row(children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Image.network('https://www.google.com/favicon.ico', width: 16, height: 16),
                                label: const Text('Google', style: TextStyle(fontSize: 13, color: Color(0xFF333333))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: isLoading ? null : () async {
                                  setDialogState(() { isLoading = true; errorMessage = null; });
                                  try {
                                    final result = await OAuthService.signUpWithGoogle();
                                    if (result != null && result['success'] == true && dialogContext.mounted) {
                                      final userData = result['user'];
                                      final user = userData != null ? User.fromJson(userData as Map<String, dynamic>) : null;
                                      Navigator.of(dialogContext).pop(user);
                                    } else if (dialogContext.mounted) {
                                      setDialogState(() {
                                        errorMessage = result?['error'] ?? 'Google sign-up failed. Please try again.';
                                        isLoading = false;
                                      });
                                    }
                                  } catch (e) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        errorMessage = 'Google sign-up error: ${e.toString()}';
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 18),
                                label: const Text('Facebook', style: TextStyle(fontSize: 13, color: Color(0xFF333333))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: isLoading ? null : () async {
                                  setDialogState(() { isLoading = true; errorMessage = null; });
                                  try {
                                    final result = await OAuthService.signInWithFacebook();
                                    if (result != null && result['success'] == true && dialogContext.mounted) {
                                      final userData = result['user'];
                                      final user = userData != null ? User.fromJson(userData as Map<String, dynamic>) : null;
                                      Navigator.of(dialogContext).pop(user);
                                    } else if (dialogContext.mounted) {
                                      setDialogState(() {
                                        errorMessage = 'Facebook sign-in failed. Please try again.';
                                        isLoading = false;
                                      });
                                    }
                                  } catch (e) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        errorMessage = 'Facebook sign-in error: ${e.toString()}';
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                _showLoginDialog();
                              },
                              child: const Text('Log in',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0B3254),
                                  decoration: TextDecoration.underline)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentUser = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have signed out of VaneLux.')),
    );
  }

  Future<void> _showMapAndRoute() async {
    FocusScope.of(context).unfocus();
    setState(() {
      quoteError = null;
    });

    final _SelectedLocation? originPlace = await _ensurePlaceSelection(
      isPickup: true,
    );
    final _SelectedLocation? destinationPlace = await _ensurePlaceSelection(
      isPickup: false,
    );

    if (originPlace == null || destinationPlace == null) {
      if (mounted) {
        setState(() {
          quoteError = 'Please select valid addresses from the suggestions.';
        });
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select valid addresses from the suggestions to continue.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String origin = originPlace.description.trim();
    final String destination = destinationPlace.description.trim();

    setState(() {
      isFetchingQuote = true;
    });

    try {
      final route = await GoogleMapsService.getDistanceMatrix(
        '${originPlace.latitude},${originPlace.longitude}',
        '${destinationPlace.latitude},${destinationPlace.longitude}',
      );
      if (!mounted) {
        return;
      }

      final distanceValue = (route['distance_value'] as num?)?.toDouble() ?? 0;
      if (distanceValue <= 0) {
        throw Exception('No route found between the selected locations');
      }

      final oneWayMiles = distanceValue / 1609.344;
      final totalMiles = oneWayMiles * (isReturnTrip ? 2 : 1);

      // Fetch real toll cost from Google Routes API
      double tollCost = 0.0;
      try {
        final tollData = await GoogleMapsService.getRouteWithTolls(
          '${originPlace.latitude},${originPlace.longitude}',
          '${destinationPlace.latitude},${destinationPlace.longitude}',
        );
        tollCost = (tollData['toll_cost'] as num?)?.toDouble() ?? 0.0;
        print('💰 Toll cost for quote: \$$tollCost');
      } catch (e) {
        print('⚠️ Could not fetch toll cost for quote: $e');
      }

      // Detect route type and calculate prices using PricingService
      final routeType = PricingService.detectRouteType(
        originPlace.latitude,
        originPlace.longitude,
        destinationPlace.latitude,
        destinationPlace.longitude,
      );
      final routeLabel = PricingService.getRouteLabel(routeType);

      final options = _quoteVehicleOptions.map((vehicle) {
        final estimate = PricingService.calculatePrice(
          pickupLat: originPlace.latitude,
          pickupLng: originPlace.longitude,
          dropoffLat: destinationPlace.latitude,
          dropoffLng: destinationPlace.longitude,
          distanceMiles: oneWayMiles,
          vehicleName: vehicle.name,
          isReturnTrip: isReturnTrip,
          tollCost: tollCost,
        );
        return _VehicleQuote(
          vehicle: vehicle,
          totalPrice: estimate.totalPrice,
          ratePerMile: estimate.perMileRate ?? 0,
        );
      }).toList();

      setState(() {
        currentQuote = _RouteQuote(
          origin: origin,
          destination: destination,
          distanceText:
              route['distance'] as String? ??
              '${oneWayMiles.toStringAsFixed(1)} mi',
          durationText: route['duration'] as String? ?? '',
          totalMiles: totalMiles,
          baseRatePerMile: 0,
          includesReturnTrip: isReturnTrip,
          options: options,
          originLat: originPlace.latitude,
          originLng: originPlace.longitude,
          destinationLat: destinationPlace.latitude,
          destinationLng: destinationPlace.longitude,
          pickupDateTime: selectedDateTime,
          routeLabel: routeLabel,
          routeType: routeType,
        );
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        quoteError = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo calcular la tarifa: ${quoteError ?? 'Inténtalo nuevamente'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isFetchingQuote = false;
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
    );

    if (timePicked == null) {
      return;
    }

    setState(() {
      selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        timePicked.hour,
        timePicked.minute,
      );
    });
  }

  void _onPickupChanged(String value) {
    _pickupDebounce?.cancel();

    final String query = value.trim();

    // Si el campo está vacío, limpiar todo
    if (query.isEmpty) {
      setState(() {
        _pickupPlace = null;
        currentQuote = null;
        pickupSuggestions = [];
        _showPickupDropdown = false;
      });
      return;
    }

    // Limpiar lugar seleccionado si el usuario está editando
    setState(() {
      _pickupPlace = null;
      currentQuote = null;
      _showPickupDropdown = true;
    });

    // Buscar solo si hay al menos 3 caracteres
    if (query.length < 3) {
      setState(() => pickupSuggestions = []);
      return;
    }

    _pickupDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await GoogleMapsService.searchPlaces(query);
        if (!mounted) return;
        setState(() => pickupSuggestions = results.take(6).toList());
      } catch (e) {
        if (!mounted) return;
        setState(() => pickupSuggestions = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error buscando direcciones: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _onDestinationChanged(String value) {
    _destinationDebounce?.cancel();

    final String query = value.trim();

    // Si el campo está vacío, limpiar todo
    if (query.isEmpty) {
      setState(() {
        _destinationPlace = null;
        currentQuote = null;
        destinationSuggestions = [];
        _showDestinationDropdown = false;
      });
      return;
    }

    // Limpiar lugar seleccionado si el usuario está editando
    setState(() {
      _destinationPlace = null;
      currentQuote = null;
      _showDestinationDropdown = true;
    });

    // Buscar solo si hay al menos 3 caracteres
    if (query.length < 3) {
      setState(() => destinationSuggestions = []);
      return;
    }

    _destinationDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await GoogleMapsService.searchPlaces(query);
        if (!mounted) return;
        setState(() => destinationSuggestions = results.take(6).toList());
      } catch (e) {
        if (!mounted) return;
        setState(() => destinationSuggestions = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error buscando direcciones: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<_SelectedLocation?> _resolvePlaceId(
    String? placeId,
    String fallback, {
    required bool isPickup,
  }) async {
    final TextEditingController controller = isPickup
        ? pickupController
        : destinationController;

    if (placeId == null || placeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Could not get details of the selected origin address.'
                : 'Could not get details of the selected destination address.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    setState(() {
      currentQuote = null;
      if (isPickup) {
        _pickupPlace = null;
        _isResolvingPickup = true;
      } else {
        _destinationPlace = null;
        _isResolvingDestination = true;
      }
    });

    try {
      final details = await GoogleMapsService.getPlaceDetails(placeId);
      if (!mounted) {
        return null;
      }

      final Map<String, dynamic>? location =
          details['location'] as Map<String, dynamic>?;
      final double? lat = (location?['lat'] as num?)?.toDouble();
      final double? lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        throw Exception('No se recibieron coordenadas válidas.');
      }

      final String resolvedAddress =
          (details['address'] as String?)?.trim().isNotEmpty == true
          ? details['address'] as String
          : fallback;

      final _SelectedLocation selection = _SelectedLocation(
        placeId: placeId,
        description: resolvedAddress,
        latitude: lat,
        longitude: lng,
      );

      setState(() {
        controller.text = resolvedAddress;
        if (isPickup) {
          _pickupPlace = selection;
        } else {
          _destinationPlace = selection;
        }
      });

      return selection;
    } catch (error) {
      if (!mounted) {
        return null;
      }

      setState(() {
        controller.text = fallback;
        if (isPickup) {
          _pickupPlace = null;
        } else {
          _destinationPlace = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Error getting origin details: ${error.toString().replaceFirst('Exception: ', '')}'
                : 'Error getting destination details: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          if (isPickup) {
            _isResolvingPickup = false;
          } else {
            _isResolvingDestination = false;
          }
        });
      }
    }
  }

  Future<_SelectedLocation?> _ensurePlaceSelection({
    required bool isPickup,
  }) async {
    final TextEditingController controller = isPickup
        ? pickupController
        : destinationController;
    final _SelectedLocation? currentSelection = isPickup
        ? _pickupPlace
        : _destinationPlace;
    final String input = controller.text.trim();

    if (input.isEmpty) {
      return null;
    }

    if (currentSelection != null &&
        input.toLowerCase() ==
            currentSelection.description.trim().toLowerCase()) {
      return currentSelection;
    }

    final List<Map<String, dynamic>> suggestions = isPickup
        ? pickupSuggestions
        : destinationSuggestions;

    Map<String, dynamic>? matchingSuggestion;
    for (final suggestion in suggestions) {
      final String fallback = _suggestionFallback(
        suggestion,
      ).trim().toLowerCase();
      if (fallback == input.toLowerCase()) {
        matchingSuggestion = suggestion;
        break;
      }
    }

    if (matchingSuggestion == null) {
      return null;
    }

    final String fallback = _suggestionFallback(matchingSuggestion);
    final String? placeId = matchingSuggestion['place_id'] as String?;

    return _resolvePlaceId(placeId, fallback, isPickup: isPickup);
  }

  void _selectPickupSuggestion(Map<String, dynamic> suggestion) {
    _pickupDebounce?.cancel();
    final String fallback = _suggestionFallback(suggestion);
    final String? placeId = suggestion['place_id'] as String?;

    // Inmediatamente actualizar el texto y cerrar dropdown
    setState(() {
      pickupController.text = fallback;
      pickupSuggestions = [];
      _showPickupDropdown = false;
      currentQuote = null;
    });

    // Quitar el foco para prevenir reapertura
    pickupFocusNode.unfocus();

    // Resolver coordenadas
    unawaited(_resolvePlaceId(placeId, fallback, isPickup: true));
  }

  void _selectDestinationSuggestion(Map<String, dynamic> suggestion) {
    _destinationDebounce?.cancel();
    final String fallback = _suggestionFallback(suggestion);
    final String? placeId = suggestion['place_id'] as String?;

    // Inmediatamente actualizar el texto y cerrar dropdown
    setState(() {
      destinationController.text = fallback;
      destinationSuggestions = [];
      _showDestinationDropdown = false;
      currentQuote = null;
    });

    // Quitar el foco para prevenir reapertura
    destinationFocusNode.unfocus();

    // Resolver coordenadas
    unawaited(_resolvePlaceId(placeId, fallback, isPickup: false));
  }

  Widget _buildSuggestionDropdown({
    required List<Map<String, dynamic>> suggestions,
    required void Function(Map<String, dynamic>) onSelected,
    required bool isVisible,
    required double width,
  }) {
    if (!isVisible || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: width,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return GestureDetector(
              onTapDown: (_) {
                // Captura el tap ANTES de que se pierda el foco
                onSelected(suggestion);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF0B3254),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSuggestionMainText(suggestion),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (_getSuggestionSecondaryText(
                              suggestion,
                            ).isNotEmpty)
                              Text(
                                _getSuggestionSecondaryText(suggestion),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey[200]),
          itemCount: suggestions.length,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Select date and time';
    }
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day/$year • $hour:$minute';
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatMiles(double value) {
    return '${value.toStringAsFixed(1)} millas';
  }

  Widget _buildBookingForm(bool isCompact) {
    final double maxWidth = isCompact ? double.infinity : 460;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fieldWidth = constraints.maxWidth;
          final String dateLabel = _formatDateTime(selectedDateTime);

          return Container(
            padding: EdgeInsets.all(isCompact ? 20 : 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Book Your Ride',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalized service with professional chauffeur',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Text(
                        'POINT TO POINT',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'HOURLY',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Service Type',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isServiceLockedState)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                      color: const Color(0xFFFFFDF5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedServiceType ?? 'Hourly/As Directed',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3254),
                                ),
                              ),
                              if (widget.selectedPackage != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.selectedPackage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isServiceLockedState = false;
                              selectedServiceType = null;
                            });
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF0B3254),
                          ),
                          label: const Text(
                            'Change',
                            style: TextStyle(
                              color: Color(0xFF0B3254),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: selectedServiceType,
                    hint: const Text('Select service type'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: serviceTypes
                        .map(
                          (service) => DropdownMenuItem<String>(
                            value: service,
                            child: Text(service),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedServiceType = value),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Pickup Location',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pickupController,
                  focusNode: pickupFocusNode,
                  onChanged: _onPickupChanged,
                  decoration: InputDecoration(
                    hintText: 'Enter pickup address',
                    prefixIcon: const Icon(
                      Icons.my_location_outlined,
                      color: Color(0xFF0B3254),
                    ),
                    suffixIcon: _isResolvingPickup
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                          )
                        : (_pickupPlace != null
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                )
                              : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                _buildSuggestionDropdown(
                  suggestions: pickupSuggestions,
                  onSelected: _selectPickupSuggestion,
                  isVisible:
                      _showPickupDropdown && pickupSuggestions.isNotEmpty,
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Destination',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: destinationController,
                  focusNode: destinationFocusNode,
                  onChanged: _onDestinationChanged,
                  decoration: InputDecoration(
                    hintText: 'Where are you going?',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF0B3254),
                    ),
                    suffixIcon: _isResolvingDestination
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                          )
                        : (_destinationPlace != null
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                )
                              : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                _buildSuggestionDropdown(
                  suggestions: destinationSuggestions,
                  onSelected: _selectDestinationSuggestion,
                  isVisible:
                      _showDestinationDropdown &&
                      destinationSuggestions.isNotEmpty,
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pickup Date & Time',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF0B3254),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              color: selectedDateTime == null
                                  ? Colors.grey[500]
                                  : const Color(0xFF0B3254),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF0B3254),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isReturnTrip,
                      onChanged: (value) =>
                          setState(() => isReturnTrip = value ?? false),
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add return trip',
                      style: TextStyle(
                        color: Color(0xFF0B3254),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (isFetchingQuote ||
                            _isResolvingPickup ||
                            _isResolvingDestination)
                        ? null
                        : () {
                            if (selectedServiceType == null ||
                                pickupController.text.trim().isEmpty ||
                                destinationController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Completa los campos obligatorios',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validar que tengamos coordenadas
                            if (_pickupPlace == null ||
                                _destinationPlace == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Esperando validación de direcciones...',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Navegar a pantalla de detalles
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripDetailsWebScreen(
                                  pickupAddress: pickupController.text,
                                  destinationAddress:
                                      destinationController.text,
                                  pickupLat: _pickupPlace!.latitude,
                                  pickupLng: _pickupPlace!.longitude,
                                  destinationLat: _destinationPlace!.latitude,
                                  destinationLng: _destinationPlace!.longitude,
                                  selectedDateTime: selectedDateTime,
                                  serviceType:
                                      selectedServiceType ?? 'Point to Point',
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3254),
                      foregroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFetchingQuote) ...[
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Text(
                          'GET PRICES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We show estimated rates in seconds. Our specialists will confirm your reservation immediately.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5F6B7A)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuotePanel(bool isCompact) {
    final double maxWidth = isCompact ? double.infinity : 520;
    final double desktopMaxHeight = isCompact ? double.infinity : 560;
    Widget content;

    if (isFetchingQuote) {
      content = const Center(
        child: SizedBox(
          height: 48,
          width: 48,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (quoteError != null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            quoteError!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            'Check the addresses and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      );
    } else if (currentQuote == null) {
      // Mobile App Advertisement Carousel
      final images = [
        'assets/images/telefono3.png',
        'assets/images/telefono4.png',
      ];

      content = Stack(
        alignment: Alignment.center,
        children: [
          // Imágenes con transición
          ...List.generate(images.length, (index) {
            return AnimatedOpacity(
              opacity: _mobileAppAdIndex == index ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  images[index],
                  fit: BoxFit.contain,
                  height: isCompact ? 350 : 450,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.phone_android,
                      size: 100,
                      color: Color(0xFF0B3254),
                    );
                  },
                ),
              ),
            );
          }),
          // Badge "Coming Soon" pequeño y elegante
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0B3254).withOpacity(0.9),
                    const Color(0xFFD4AF37).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_iphone, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Indicadores de página
          Positioned(
            top: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _mobileAppAdIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _mobileAppAdIndex == index
                        ? const Color(0xFFD4AF37)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    } else {
      Widget quoteContent = _buildQuoteContent(currentQuote!, isCompact);
      if (!isCompact) {
        quoteContent = SizedBox(
          height: desktopMaxHeight,
          child: ListView(padding: EdgeInsets.zero, children: [quoteContent]),
        );
      }
      content = quoteContent;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: desktopMaxHeight,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isCompact ? 20 : 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: content,
        ),
      ),
    );
  }

  Widget _buildQuoteContent(_RouteQuote quote, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Vanelux Experience',
          style: TextStyle(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B3254),
          ),
        ),
        if (quote.routeLabel != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  quote.routeType == RouteType.localCity
                      ? Icons.location_city
                      : quote.routeType == RouteType.outsideCity
                      ? Icons.public
                      : Icons.flight,
                  size: 16,
                  color: const Color(0xFF0B3254),
                ),
                const SizedBox(width: 6),
                Text(
                  quote.routeLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '${quote.origin}\n→ ${quote.destination}',
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoPill(
                Icons.route,
                'Total Distance',
                quote.distanceText,
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildInfoPill(
                Icons.schedule,
                'Estimated Duration',
                quote.durationText.isEmpty
                    ? 'Calculating...'
                    : quote.durationText,
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildInfoPill(
                Icons.calendar_today_outlined,
                'Date',
                _formatDateTime(quote.pickupDateTime),
                isCompact,
              ),
              if (quote.includesReturnTrip) ...[
                const SizedBox(height: 12),
                _buildInfoPill(
                  Icons.repeat,
                  'Service',
                  'Round Trip',
                  isCompact,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: isCompact ? 200 : 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: RouteMapView(
                    originLabel: quote.origin,
                    destinationLabel: quote.destination,
                    originLat: quote.originLat,
                    originLng: quote.originLng,
                    destinationLat: quote.destinationLat,
                    destinationLng: quote.destinationLng,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 16,
                      vertical: isCompact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${quote.distanceText} • ${quote.durationText.isEmpty ? 'Calculating...' : quote.durationText}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 12 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Select Your Vehicle',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B3254),
          ),
        ),
        const SizedBox(height: 16),
        ...quote.options.map(
          (option) =>
              _buildVehicleQuoteTile(option, quote.totalMiles, isCompact),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            if (quote.routeType != null) {
              final rt = quote.routeType!;
              if (rt == RouteType.airportManhattanJFK ||
                  rt == RouteType.airportManhattanLGA ||
                  rt == RouteType.airportManhattanNewark) {
                return Text(
                  'Flat rate pricing for ${quote.routeLabel}. Round trip prices doubled when applicable.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.5,
                    fontSize: isCompact ? 12 : 14,
                  ),
                );
              } else if (rt == RouteType.localCity) {
                return Text(
                  'NYC local rates: base fare includes up to 5 miles. Extra miles charged per vehicle type.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.5,
                    fontSize: isCompact ? 12 : 14,
                  ),
                );
              }
            }
            return Text(
              'Outside NYC per-mile rates. Final prices include round trip when applicable.',
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
                fontSize: isCompact ? 12 : 14,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleQuoteTile(
    _VehicleQuote option,
    double totalMiles,
    bool isCompact,
  ) {
    final vehicle = option.vehicle;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen y precio arriba en móvil
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  vehicle.imageUrl,
                  width: isCompact ? 100 : 140,
                  height: isCompact ? 70 : 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: isCompact ? 100 : 140,
                    height: isCompact ? 70 : 90,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B3254),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(option.totalPrice),
                      style: TextStyle(
                        fontSize: isCompact ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    // Precio por milla oculto al cliente (se calcula internamente)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vehicle.description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.4,
              fontSize: isCompact ? 13 : 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: isCompact ? 12 : 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${vehicle.passengers} pax',
                    style: TextStyle(
                      color: const Color(0xFF0B3254),
                      fontSize: isCompact ? 13 : 14,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${vehicle.luggage} bags',
                    style: TextStyle(
                      color: const Color(0xFF0B3254),
                      fontSize: isCompact ? 13 : 14,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.straighten,
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatMiles(totalMiles),
                    style: TextStyle(
                      color: const Color(0xFF0B3254),
                      fontSize: isCompact ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    IconData icon,
    String label,
    String value,
    bool isCompact,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showServicesMenu() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 88),
              width: 760,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Airport Transfer',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Airport Transfer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Airport Transfer',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('To and from all airports'),
                            ),
                            const SizedBox(height: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Hourly Service',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Hourly Service',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Hourly Service',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('By the hour'),
                            ),
                          ],
                        ),
                      ),

                      // Column 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Point to Point',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Point to Point',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Point to Point',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Direct transfers'),
                            ),
                            const SizedBox(height: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Corporate',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Corporate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Corporate',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Business travel'),
                            ),
                          ],
                        ),
                      ),

                      // Column 3
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Events',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Events',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Events',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Wedding, party'),
                            ),
                            const SizedBox(height: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServiceDetailScreen(
                                            serviceType: 'Tours',
                                          ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Tours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceDetailScreen(
                                          serviceType: 'Tours',
                                        ),
                                  ),
                                );
                              },
                              child: const Text('City tours'),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      // Drawer para menú móvil
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: const Color(0xFF0B3254),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Color(0xFF0B3254)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const VaneluxLogo(size: 26, dark: true, showText: true),
                        ],
                      ),
                    ),
                    _buildMobileMenuItem('HOME', Icons.home),
                    _buildMobileMenuItem('SERVICES', Icons.car_rental),
                    _buildMobileMenuItem('FLEET', Icons.directions_car),
                    _buildMobileMenuItem('ABOUT', Icons.info),
                    _buildMobileMenuItem('CONTACT', Icons.contact_mail),
                    const Divider(color: Colors.white24, height: 32),
                    ListTile(
                      leading: const Icon(
                        Icons.local_taxi,
                        color: Color(0xFFFFD700),
                      ),
                      title: const Text(
                        'BECOME A DRIVER',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const DriverRegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+1 917 599-5522',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header/Navbar
                _buildHeader(context),

                // Hero Section
                Container(key: _heroKey, child: _buildHeroSection(context)),

                // World Cup Section
                _buildWorldCupSection(context),

                // Services Section
                Container(
                  key: _servicesKey,
                  child: _buildServicesSection(context),
                ),

                // Airport Transfer Feature Section
                _buildAirportSection(context),

                // City Routes Section
                _buildCityRoutesSection(context),

                // Fleet Section
                Container(key: _fleetKey, child: _buildFleetSection(context)),

                // Why Choose Us / Stats Section
                _buildWhyChooseUsSection(context),

                // About Section
                Container(key: _aboutKey, child: _buildAboutSection(context)),

                // Testimonials Section
                _buildTestimonialsSection(context),

                // Contact Section
                Container(
                  key: _contactKey,
                  child: _buildContactSection(context),
                ),

                // Footer
                _buildFooter(context),
              ],
            ),
          ),
          // WhatsApp Floating Button
          Positioned(
            bottom: isMobile ? 100 : 110,
            right: isMobile ? 16 : 24,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // ignore: avoid_web_libraries_in_flutter
                  html.window.open(
                      'https://wa.me/19175995522?text=Hello%2C%20I%27d%20like%20to%20book%20a%20luxury%20ride%20with%20Vanelux.',
                      '_blank');
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.chat, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          // AI Assistant Floating Button & Chat
          _buildFloatingAssistant(context, isMobile),
        ],
      ),
    );
  }

  Future<void> _sendAssistantMessage() async {
    final text = _assistantController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _assistantMessages.add(
        AssistantMessage(role: AssistantRole.user, content: text),
      );
      _assistantController.clear();
      _isAssistantTyping = true;
    });

    try {
      print('🤖 Sending message to AI Concierge: "$text"');
      final reply = await _assistantService.sendMessage(
        persona: AssistantPersona.client,
        messages: _assistantMessages,
      );
      print(
        '🤖 AI Concierge reply: "${reply.substring(0, reply.length > 50 ? 50 : reply.length)}..."',
      );
      // Detect booking intent in AI reply
      final lowerReply = reply.toLowerCase();
      final bookingKeywords = ['pickup', 'drop-off', 'dropoff', 'recogida', 'destino', 'where would you like', 'dónde te recojo', 'dirección', 'address', 'pick you up', 'destination', 'booking', 'reserv'];
      final showBooking = bookingKeywords.any((kw) => lowerReply.contains(kw));
      if (mounted) {
        setState(() {
          _assistantMessages.add(
            AssistantMessage(role: AssistantRole.assistant, content: reply),
          );
          _isAssistantTyping = false;
          if (showBooking) {
            _showChatBookingForm = true;
          }
        });
      }
    } catch (e) {
      print('🤖 AI Concierge ERROR: $e');
      if (mounted) {
        setState(() {
          _assistantMessages.add(
            AssistantMessage(
              role: AssistantRole.assistant,
              content:
                  'I apologize for the inconvenience. I\'m having trouble connecting right now. Please try again in a moment, or contact us directly at info@vane-lux.com or call us for immediate assistance.',
            ),
          );
          _isAssistantTyping = false;
        });
      }
    }
  }

  // ── Chat Booking Form helpers ──────────────────────────────────

  void _onChatPickupChanged(String value) {
    _chatPickupDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _chatPickupPlace = null;
        _chatPickupSuggestions = [];
        _showChatPickupDropdown = false;
      });
      return;
    }
    setState(() {
      _chatPickupPlace = null;
      _showChatPickupDropdown = true;
    });
    if (query.length < 3) {
      setState(() => _chatPickupSuggestions = []);
      return;
    }
    _chatPickupDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await GoogleMapsService.searchPlaces(query);
        if (mounted) setState(() => _chatPickupSuggestions = results.take(5).toList());
      } catch (_) {
        if (mounted) setState(() => _chatPickupSuggestions = []);
      }
    });
  }

  void _onChatDropoffChanged(String value) {
    _chatDropoffDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _chatDropoffPlace = null;
        _chatDropoffSuggestions = [];
        _showChatDropoffDropdown = false;
      });
      return;
    }
    setState(() {
      _chatDropoffPlace = null;
      _showChatDropoffDropdown = true;
    });
    if (query.length < 3) {
      setState(() => _chatDropoffSuggestions = []);
      return;
    }
    _chatDropoffDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await GoogleMapsService.searchPlaces(query);
        if (mounted) setState(() => _chatDropoffSuggestions = results.take(5).toList());
      } catch (_) {
        if (mounted) setState(() => _chatDropoffSuggestions = []);
      }
    });
  }

  void _selectChatPickup(Map<String, dynamic> suggestion) {
    _chatPickupDebounce?.cancel();
    final desc = suggestion['description'] ?? '';
    final placeId = suggestion['place_id'] as String?;
    setState(() {
      _chatPickupController.text = desc;
      _chatPickupSuggestions = [];
      _showChatPickupDropdown = false;
      _chatPickupPlace = null;
    });
    if (placeId != null) {
      _resolveChatPlace(placeId, desc).then((loc) {
        if (loc != null && mounted) {
          setState(() => _chatPickupPlace = loc);
        }
      });
    }
  }

  void _selectChatDropoff(Map<String, dynamic> suggestion) {
    _chatDropoffDebounce?.cancel();
    final desc = suggestion['description'] ?? '';
    final placeId = suggestion['place_id'] as String?;
    setState(() {
      _chatDropoffController.text = desc;
      _chatDropoffSuggestions = [];
      _showChatDropoffDropdown = false;
      _chatDropoffPlace = null;
    });
    if (placeId != null) {
      _resolveChatPlace(placeId, desc).then((loc) {
        if (loc != null && mounted) {
          setState(() => _chatDropoffPlace = loc);
        }
      });
    }
  }

  Future<_SelectedLocation?> _resolveChatPlace(String placeId, String fallback) async {
    try {
      final details = await GoogleMapsService.getPlaceDetails(placeId);
      if (!mounted) return null;
      final location = details['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      final address = (details['address'] as String?)?.trim().isNotEmpty == true
          ? details['address'] as String
          : fallback;
      return _SelectedLocation(
        placeId: placeId,
        description: address,
        latitude: lat,
        longitude: lng,
      );
    } catch (e) {
      debugPrint('Error resolving chat place: $e');
      return null;
    }
  }

  Widget _buildChatBookingCard() {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B3254).withOpacity(0.05),
            const Color(0xFFD4AF37).withOpacity(0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          bottom: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              const Icon(Icons.directions_car, color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _showChatVehicleCards ? 'Choose Your Vehicle' : 'Quick Booking',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B3254),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _showChatBookingForm = false;
                  _showChatVehicleCards = false;
                  _chatPrices = null;
                }),
                child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── STEP 1: Address fields ──
          if (!_showChatVehicleCards) ...[
            _buildChatAddressField(
              controller: _chatPickupController,
              hint: '📍 Pickup address',
              icon: Icons.my_location,
              onChanged: _onChatPickupChanged,
              selectedPlace: _chatPickupPlace,
            ),
            if (_showChatPickupDropdown && _chatPickupSuggestions.isNotEmpty)
              _buildChatSuggestions(_chatPickupSuggestions, _selectChatPickup),
            const SizedBox(height: 8),
            _buildChatAddressField(
              controller: _chatDropoffController,
              hint: '📍 Drop-off address',
              icon: Icons.location_on,
              onChanged: _onChatDropoffChanged,
              selectedPlace: _chatDropoffPlace,
            ),
            if (_showChatDropoffDropdown && _chatDropoffSuggestions.isNotEmpty)
              _buildChatSuggestions(_chatDropoffSuggestions, _selectChatDropoff),
            const SizedBox(height: 10),
            // See vehicles button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: (_chatPickupPlace != null && _chatDropoffPlace != null)
                    ? _calculateChatPrices
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B3254),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      (_chatPickupPlace != null && _chatDropoffPlace != null)
                          ? 'See Vehicles & Prices'
                          : 'Enter both addresses',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── STEP 2: Vehicle cards with prices ──
          if (_showChatVehicleCards && _chatPrices != null) ...[
            // Route info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3254).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, size: 14, color: Color(0xFF0B3254)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_chatPrices!.values.first.routeLabel} • ${_chatDistanceMiles.toStringAsFixed(1)} mi',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0B3254)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _showChatVehicleCards = false;
                      _chatPrices = null;
                    }),
                    child: const Text('✏️ Edit', style: TextStyle(fontSize: 11, color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Vehicle list
            ..._buildChatVehicleCards(),
          ],
        ],
      ),
    );
  }

  void _calculateChatPrices() {
    if (_chatPickupPlace == null || _chatDropoffPlace == null) return;

    // Estimate distance using Haversine (PricingService uses it internally too)
    final distanceMiles = _haversineDistance(
      _chatPickupPlace!.latitude, _chatPickupPlace!.longitude,
      _chatDropoffPlace!.latitude, _chatDropoffPlace!.longitude,
    );

    final prices = PricingService.calculateAllTierPrices(
      pickupLat: _chatPickupPlace!.latitude,
      pickupLng: _chatPickupPlace!.longitude,
      dropoffLat: _chatDropoffPlace!.latitude,
      dropoffLng: _chatDropoffPlace!.longitude,
      distanceMiles: distanceMiles,
    );

    setState(() {
      _chatDistanceMiles = distanceMiles;
      _chatPrices = prices;
      _showChatVehicleCards = true;
    });

    // Add AI message about the vehicles
    _assistantMessages.add(
      AssistantMessage(
        role: AssistantRole.assistant,
        content: 'Here are our available vehicles for your trip. Select one to proceed to payment:',
      ),
    );
  }

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadiusMiles = 3958.8;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  List<Widget> _buildChatVehicleCards() {
    // Define vehicle display info per tier
    const vehicleInfo = <VehicleTier, Map<String, dynamic>>{
      VehicleTier.sedan: {
        'name': 'Mercedes-Maybach S 680',
        'short': 'Luxury Sedan',
        'pax': '4 pax • 3 bags',
        'icon': Icons.directions_car,
      },
      VehicleTier.escalade: {
        'name': 'Cadillac Escalade ESV',
        'short': 'Premium SUV',
        'pax': '6 pax • 6 bags',
        'icon': Icons.directions_car,
      },
      VehicleTier.sprinter: {
        'name': 'Mercedes Sprinter Jet',
        'short': 'Executive Sprinter',
        'pax': '10 pax • 12 bags',
        'icon': Icons.airport_shuttle,
      },
      VehicleTier.miniCoach: {
        'name': 'Mini Coach 27 pax',
        'short': 'Luxury Mini Coach',
        'pax': '27 pax • 32 bags',
        'icon': Icons.directions_bus,
      },
    };

    final List<Widget> cards = [];
    for (final tier in [VehicleTier.sedan, VehicleTier.escalade, VehicleTier.sprinter, VehicleTier.miniCoach]) {
      final price = _chatPrices![tier];
      if (price == null) continue;
      final info = vehicleInfo[tier]!;

      cards.add(
        GestureDetector(
          onTap: () => _onChatVehicleSelected(tier, info['name'] as String, price),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3254).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(info['icon'] as IconData, size: 18, color: const Color(0xFF0B3254)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['short'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0B3254)),
                      ),
                      Text(
                        info['pax'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${price.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37)),
                    ),
                    if (price.isFlat)
                      Text('Flat rate', style: TextStyle(fontSize: 9, color: Colors.grey[500]))
                    else
                      Text('Est.', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF0B3254)),
              ],
            ),
          ),
        ),
      );
    }
    // ── TEST CARD ($0.50) ─────────────────────────────────────────
    cards.add(
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              pickupAddress: _chatPickupController.text,
              destinationAddress: _chatDropoffController.text,
              pickupLat: _chatPickupPlace!.latitude,
              pickupLng: _chatPickupPlace!.longitude,
              destinationLat: _chatDropoffPlace!.latitude,
              destinationLng: _chatDropoffPlace!.longitude,
              selectedDateTime: DateTime.now().add(const Duration(hours: 1)),
              vehicleName: 'TEST VEHICLE',
              totalPrice: 0.50,
              distanceMiles: _chatDistanceMiles,
              duration: '5 min',
              extraServices: const {},
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science, size: 18, color: Colors.orange),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEST VEHICLE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange),
                    ),
                    Text(
                      'Payment test only • \$0.50',
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$0.50',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.orange),
                  ),
                  Text('Test', style: TextStyle(fontSize: 9, color: Colors.orange)),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: Colors.orange),
            ],
          ),
        ),
      ),
    );

    return cards;
  }

  void _onChatVehicleSelected(VehicleTier tier, String vehicleName, PriceEstimate price) {
    // Navigate directly to payment
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          pickupAddress: _chatPickupController.text,
          destinationAddress: _chatDropoffController.text,
          pickupLat: _chatPickupPlace!.latitude,
          pickupLng: _chatPickupPlace!.longitude,
          destinationLat: _chatDropoffPlace!.latitude,
          destinationLng: _chatDropoffPlace!.longitude,
          selectedDateTime: DateTime.now().add(const Duration(hours: 1)),
          vehicleName: vehicleName,
          totalPrice: price.totalPrice,
          distanceMiles: price.distanceMiles,
          duration: '${(price.distanceMiles * 2.5).toInt()} min',
          extraServices: const {},
        ),
      ),
    );
  }

  Widget _buildChatAddressField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    _SelectedLocation? selectedPlace,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selectedPlace != null
              ? const Color(0xFF2E7D32)
              : Colors.grey.shade300,
          width: selectedPlace != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          prefixIcon: Icon(icon, size: 16, color: const Color(0xFF0B3254)),
          suffixIcon: selectedPlace != null
              ? const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildChatSuggestions(
    List<Map<String, dynamic>> suggestions,
    void Function(Map<String, dynamic>) onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final s = suggestions[index];
          final mainText = _getSuggestionMainText(s);
          final secondary = _getSuggestionSecondaryText(s);
          return InkWell(
            onTap: () => onSelect(s),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF0B3254)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mainText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        if (secondary.isNotEmpty)
                          Text(secondary, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingAssistant(BuildContext context, bool isMobile) {
    final chatWidth = isMobile
        ? MediaQuery.of(context).size.width - 32.0
        : 380.0;
    final chatHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.6
        : 500.0;

    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chat Window
          if (_showAssistantChat)
            Container(
              width: chatWidth,
              height: chatHeight,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B3254), Color(0xFF163D5C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFD4AF37),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vanelux Concierge',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'AI-Powered Assistant',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _showAssistantChat = false),
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: _assistantMessages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 48,
                                      color: const Color(
                                        0xFFD4AF37,
                                      ).withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Welcome to Vanelux',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0B3254),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ask me anything about our luxury transportation services, rates, or fleet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _buildQuickAction('📍 Book a ride'),
                                        _buildQuickAction('✈️ Airport rates'),
                                        _buildQuickAction('🚘 Our fleet'),
                                        _buildQuickAction('💰 Get a quote'),
                                        _buildQuickAction('📞 Contact us'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount:
                                  _assistantMessages.length +
                                  (_isAssistantTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_isAssistantTyping && index == 0) {
                                  return _buildTypingIndicator();
                                }
                                final msgIndex = _isAssistantTyping
                                    ? _assistantMessages.length - index
                                    : _assistantMessages.length - 1 - index;
                                if (msgIndex < 0 ||
                                    msgIndex >= _assistantMessages.length) {
                                  return const SizedBox.shrink();
                                }
                                final msg = _assistantMessages[msgIndex];
                                return _buildChatBubble(msg);
                              },
                            ),
                    ),
                    // Chat Booking Form (Google Maps autocomplete)
                    if (_showChatBookingForm) _buildChatBookingCard(),
                    // Input
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _assistantController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendAssistantMessage(),
                              textInputAction: TextInputAction.send,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B3254), Color(0xFFD4AF37)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _isAssistantTyping
                                  ? null
                                  : _sendAssistantMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Floating Button
          GestureDetector(
            onTap: () =>
                setState(() => _showAssistantChat = !_showAssistantChat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B3254), Color(0xFFD4AF37)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B3254).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                _showAssistantChat ? Icons.close : Icons.auto_awesome,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label) {
    return InkWell(
      onTap: () {
        _assistantController.text = label;
        _sendAssistantMessage();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF0B3254),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(AssistantMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0B3254) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFD700)),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        // Navegar según la sección
        switch (label) {
          case 'HOME':
            _scrollToSection(_heroKey);
            break;
          case 'SERVICES':
            _scrollToSection(_servicesKey);
            break;
          case 'FLEET':
            _scrollToSection(_fleetKey);
            break;
          case 'ABOUT':
            _scrollToSection(_aboutKey);
            break;
          case 'CONTACT':
            _scrollToSection(_contactKey);
            break;
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;

    // Show a full nav bar on web/large screens, compact on mobile
    final bool isWeb = kIsWeb;
    if (isWeb) {
      return Container(
        height: isMobile ? 70 : 88,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final navButtons = [
              _buildNavItem('HOME'),
              _buildNavItem('SERVICES'),
              _buildNavItem('FLEET'),
              _buildNavItem('ABOUT'),
              _buildNavItem('CONTACT'),
            ];

            final trailingChildren = <Widget>[
              const Text(
                '+1 917 599-5522',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B3254),
                ),
              ),
              const SizedBox(width: 24),
              const Text(
                'CITIES WE SERVE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B3254),
                ),
              ),
              const SizedBox(width: 16),
              // Language toggle EN | ES
              Consumer<LocaleProvider>(
                builder: (_, localeProvider, __) => TextButton(
                  onPressed: () => localeProvider.setLocale(
                    localeProvider.locale == 'en' ? 'es' : 'en',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0B3254),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        localeProvider.locale.toUpperCase(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Notification bell (only when logged in)
              if (_currentUser != null)
                const NotificationBell(iconColor: Color(0xFF0B3254)),
              const SizedBox(width: 8),
            ];

            if (_isCheckingAuth) {
              trailingChildren.add(
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else if (_currentUser == null) {
              trailingChildren.addAll([
                TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverRegistrationScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0B3254), width: 2),
                    foregroundColor: const Color(0xFF0B3254),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'BECOME A DRIVER',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _navigateToSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B3254),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'SIGNUP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ]);
            } else {
              trailingChildren.add(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3254).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFD4AF37),
                        child: Text(
                          _currentUser!.name.isNotEmpty
                              ? _currentUser!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3254),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hi, ${_currentUser!.name.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'dashboard':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerDashboardWeb(user: _currentUser!),
                                ),
                              );
                              break;
                            case 'driver_apps':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverApplicationsAdminScreen(),
                                ),
                              );
                              break;
                            case 'logout':
                              _logout();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'dashboard',
                            child: Row(
                              children: [
                                Icon(Icons.dashboard, size: 20),
                                SizedBox(width: 12),
                                Text('Dashboard'),
                              ],
                            ),
                          ),
                          if (_currentUser != null &&
                              (_currentUser!.roles.contains('admin') ||
                                  _currentUser!.roles.contains('ceo') ||
                                  _currentUser!.roles.contains('manager')))
                            const PopupMenuItem(
                              value: 'driver_apps',
                              child: Row(
                                children: [
                                  Icon(Icons.people, size: 20),
                                  SizedBox(width: 12),
                                  Text('Driver Applications'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 12),
                                Text('Log Out'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Mobile-specific simplified header (< 800px)
            if (isMobile) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Menú hamburguesa
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Color(0xFF0B3254),
                          size: 28,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const VaneluxLogo(size: 24, dark: false, showText: true),
                  const Spacer(),
                  if (_isCheckingAuth)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_currentUser == null) ...[
                    TextButton(
                      onPressed: _navigateToLogin,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: _navigateToSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B3254),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'SIGNUP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'dashboard':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerDashboardWeb(user: _currentUser!),
                              ),
                            );
                            break;
                          case 'driver_apps':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DriverApplicationsAdminScreen(),
                              ),
                            );
                            break;
                          case 'logout':
                            _logout();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'dashboard',
                          child: Row(
                            children: [
                              Icon(Icons.dashboard, size: 20),
                              SizedBox(width: 12),
                              Text('Dashboard'),
                            ],
                          ),
                        ),
                        if (_currentUser != null &&
                            (_currentUser!.roles.contains('admin') ||
                                _currentUser!.roles.contains('ceo') ||
                                _currentUser!.roles.contains('manager')))
                          const PopupMenuItem(
                            value: 'driver_apps',
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 20),
                                SizedBox(width: 12),
                                Text('Driver Applications'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20),
                              SizedBox(width: 12),
                              Text('Log Out'),
                            ],
                          ),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFD4AF37),
                        child: Text(
                          _currentUser!.name.isNotEmpty
                              ? _currentUser!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3254),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            // Desktop/tablet header (>= 800px)
            final bool isNarrow = constraints.maxWidth < 1024;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const VaneluxLogo(size: 28, dark: false, showText: true),
                const SizedBox(width: 32),
                Expanded(
                  child: isNarrow
                      ? Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: navButtons,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: navButtons,
                        ),
                ),
                const SizedBox(width: 24),
                Flexible(
                  child: isNarrow
                      ? Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: trailingChildren,
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: trailingChildren,
                        ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Compact (mobile) header
    final List<Widget> actions = [];

    if (_isCheckingAuth) {
      actions.add(
        const SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else if (_currentUser != null) {
      final String greetingName = _currentUser!.name.split(' ').first;
      actions.add(
        Text(
          'Hi, $greetingName',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B3254),
          ),
        ),
      );
      actions.add(const SizedBox(width: 8));
      actions.add(
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'dashboard':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerDashboardWeb(user: _currentUser!),
                  ),
                );
                break;
              case 'driver_apps':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DriverApplicationsAdminScreen(),
                  ),
                );
                break;
              case 'logout':
                _logout();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'dashboard',
              child: Row(
                children: [
                  Icon(Icons.dashboard, size: 20),
                  SizedBox(width: 12),
                  Text('Dashboard'),
                ],
              ),
            ),
            if (_currentUser != null &&
                (_currentUser!.roles.contains('admin') ||
                    _currentUser!.roles.contains('ceo') ||
                    _currentUser!.roles.contains('manager')))
              const PopupMenuItem(
                value: 'driver_apps',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20),
                    SizedBox(width: 12),
                    Text('Driver Applications'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 12),
                  Text('Log Out'),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0B3254)),
        ),
      );
    } else {
      actions.add(
        TextButton(
          onPressed: _navigateToLogin,
          child: const Text(
            'LOGIN',
            style: TextStyle(color: Color(0xFF0B3254)),
          ),
        ),
      );
      actions.add(const SizedBox(width: 8));
    }

    final VoidCallback bookNowHandler = _currentUser != null
        ? () {
            // For signed-in users keep them on web and surface booking flow entry.
            _scrollToSection(_servicesKey);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Select a service and complete your booking from this page.',
                ),
              ),
            );
          }
        : _navigateToSignup;

    if (actions.isNotEmpty) {
      actions.add(const SizedBox(width: 8));
    }

    actions.add(
      ElevatedButton(
        onPressed: _isCheckingAuth ? null : bookNowHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B3254),
        ),
        child: const Text('BOOK NOW'),
      ),
    );

    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const VaneluxLogo(size: 24, dark: false, showText: false),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildNavItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          switch (title) {
            case 'HOME':
              _scrollToSection(_heroKey);
              break;
            case 'SERVICES':
              // On web show a rich services dropdown, on mobile scroll to section
              if (kIsWeb) {
                _showServicesMenu();
              } else {
                _scrollToSection(_servicesKey);
              }
              break;
            case 'FLEET':
              // Navigate to a dedicated Fleet page instead of scrolling
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FleetScreen()));
              break;
            case 'ABOUT':
              _scrollToSection(_aboutKey);
              break;
            case 'CONTACT':
              _scrollToSection(_contactKey);
              break;
          }
        },
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0B3254),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 1100;
    final EdgeInsets padding = EdgeInsets.symmetric(
      vertical: isCompact ? 40 : 70,
      horizontal: isCompact ? 16 : 48,
    );

    return Container(
      padding: padding,
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Luxury Transportation in NYC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 26 : 38,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B3254),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Professional chauffeurs, exclusive vehicles and instant confirmed reservations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 13 : 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),
          if (isCompact)
            Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: _buildBookingForm(true),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: _buildQuotePanel(true),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 45,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildBookingForm(false),
                  ),
                ),
                const SizedBox(width: 32),
                Flexible(
                  flex: 55,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildQuotePanel(false),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWorldCupSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;
    final EdgeInsets highlightMargin = EdgeInsets.symmetric(
      horizontal: isCompact ? 16 : 100,
    );

    return Container(
      height: isCompact ? null : 600,
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 48 : 80,
        horizontal: isCompact ? 16 : 40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3254), Color(0xFF154a74)],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FIFA Logo placeholder
            Container(
              width: isCompact ? 160 : 200,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'FIFA\nUNITED2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3254),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'WORLD CUP 2026',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 36 : 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'USA • CANADA • MEXICO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 18 : 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFD4AF37),
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: isCompact ? 32 : 60),

            Container(
              padding: EdgeInsets.all(isCompact ? 24 : 40),
              margin: highlightMargin,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'OFFICIAL LUXURY TRANSPORTATION PARTNER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isCompact ? 22 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Experience the World\'s Greatest Tournament in unmatched luxury. From stadium transfers to\nexclusive hospitality events, Vanelux delivers championship-level service for the most prestigious\nsporting event on Earth.',
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 18,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;
    final EdgeInsets padding = EdgeInsets.symmetric(
      vertical: isCompact ? 48 : 80,
      horizontal: isCompact ? 16 : 40,
    );

    final services = [
      {
        'title': 'Point to Point',
        'description': 'Direct transportation from pickup to destination',
        'icon': Icons.location_on,
      },
      {
        'title': 'Hourly Service',
        'description': 'Hourly chauffeur service',
        'icon': Icons.access_time,
      },
      {
        'title': 'Airport Transfer',
        'description': 'Airport pickup and drop-off service',
        'icon': Icons.flight,
      },
      {
        'title': 'Weddings',
        'description':
            'Exclusive service for the most important day of your life',
        'icon': Icons.favorite,
      },
      {
        'title': 'Proms',
        'description': 'Arrive in style to your prom or special event',
        'icon': Icons.celebration,
      },
      {
        'title': 'Tours',
        'description':
            'Explore the city in style with a chauffeur who knows every corner',
        'icon': Icons.tour,
      },
    ];

    return Container(
      padding: padding,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Our Services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We offer luxury transportation for all your needs with first-class vehicles and chauffeurs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isCompact ? 13 : 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          if (isCompact)
            Column(
              children: [
                for (int i = 0; i < services.length; i++) ...[
                  _buildServiceCard(
                    services[i]['title'] as String,
                    services[i]['description'] as String,
                    services[i]['icon'] as IconData,
                  ),
                  if (i != services.length - 1) const SizedBox(height: 24),
                ],
              ],
            )
          else ...[
            _buildServiceRow(services.sublist(0, 3)),
            const SizedBox(height: 40),
            _buildServiceRow(services.sublist(3)),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceRow(List<Map<String, dynamic>> services) {
    return Row(
      children: [
        for (int i = 0; i < services.length; i++) ...[
          Expanded(
            child: _buildServiceCard(
              services[i]['title'] as String,
              services[i]['description'] as String,
              services[i]['icon'] as IconData,
            ),
          ),
          if (i != services.length - 1) const SizedBox(width: 30),
        ],
      ],
    );
  }

  Widget _buildServiceCard(String title, String description, IconData icon) {
    // Mapear títulos a los tipos de servicio para navegación
    String getServiceType(String title) {
      switch (title) {
        case 'Point to Point':
          return 'Point to Point';
        case 'Hourly Service':
          return 'Hourly Service';
        case 'Airport Transfer':
          return 'Airport Transfer';
        case 'Weddings':
          return 'Events';
        case 'Proms':
          return 'Events';
        case 'Tours':
          return 'Tours';
        default:
          return title;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF0B3254),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ServiceDetailScreen(serviceType: getServiceType(title)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B3254),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Airport Transfer Feature Section ──────────────────────────────────────
  Widget _buildAirportSection(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final bool isCompact = w < 900;

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.attach_money_outlined,
        'title': 'Competitive rates',
        'body': 'Transparent all-inclusive pricing with no hidden fees or surge charges.',
      },
      {
        'icon': Icons.flight_land_outlined,
        'title': 'Seamless airport travel',
        'body': 'We track your flight and wait up to 60 min free for delays at no extra cost.',
      },
      {
        'icon': Icons.route_outlined,
        'title': 'Travel on your terms',
        'body': 'Choose your preferred vehicle class and pick-up time for total flexibility.',
      },
    ];

    Widget featureCol(Map<String, dynamic> f) => Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0B3254),
            ),
            child: Icon(f['icon'] as IconData, color: const Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(height: 14),
          Text(f['title'] as String,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0B3254))),
          const SizedBox(height: 6),
          Text(f['body'] as String,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
        ]),
      ),
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3254).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('AIRPORT TRANSFER',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
              color: Color(0xFF0B3254), letterSpacing: 1.5)),
        ),
        const SizedBox(height: 20),
        Text(
          'Airport transfer\nin the New York area',
          style: TextStyle(
            fontSize: isCompact ? 28 : 36,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B3254),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Start your journey stress-free. Our professional chauffeurs meet you at arrivals, assist with luggage, and whisk you to your destination in premium comfort — from JFK, LGA, EWR and all metro-area airports.',
          style: TextStyle(fontSize: isCompact ? 14 : 16, color: Colors.grey[600], height: 1.65),
        ),
        const SizedBox(height: 16),
        Text(
          'Whether you\'re heading into Manhattan, the Hamptons, or anywhere else in the tri-state area, Vanelux delivers the most reliable airport ride you\'ve ever taken.',
          style: TextStyle(fontSize: isCompact ? 13 : 15, color: Colors.grey[500], height: 1.6),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ServiceDetailScreen(serviceType: 'Airport Transfer'))),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B3254),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Book Airport Transfer',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );

    final imageColumn = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isCompact ? 260 : 420,
        color: const Color(0xFF0B3254),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/cadillac-scalade.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0D2B45),
              child: Center(child: Icon(Icons.flight_takeoff,
                size: 80, color: Colors.white.withOpacity(0.15))),
            )),
          Container(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, const Color(0xFF0B3254).withOpacity(0.55)],
            ),
          )),
          Positioned(
            bottom: 20, left: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Serving all NYC metro airports',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('JFK · LGA · EWR · HPN · SWF',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 56 : 88,
        horizontal: isCompact ? 20 : 60,
      ),
      child: Column(children: [
        // Top split layout
        isCompact
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                textColumn,
                const SizedBox(height: 32),
                imageColumn,
              ])
            : Row(children: [
                Expanded(flex: 5, child: textColumn),
                const SizedBox(width: 60),
                Expanded(flex: 5, child: imageColumn),
              ]),
        const SizedBox(height: 56),
        // Feature columns
        isCompact
            ? Column(children: features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: featureCol(f))).toList())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map(featureCol).toList()),
      ]),
    );
  }

  // ── City Routes Section ────────────────────────────────────────────────────
  Widget _buildCityRoutesSection(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final bool isCompact = w < 900;

    final List<Map<String, dynamic>> cities = [
      {'name': 'New York', 'sub': '12 routes', 'color': const Color(0xFF1A3A5C), 'icon': Icons.location_city},
      {'name': 'Miami', 'sub': '8 routes', 'color': const Color(0xFF0E5952), 'icon': Icons.beach_access},
      {'name': 'Los Angeles', 'sub': '6 routes', 'color': const Color(0xFF5C3A1A), 'icon': Icons.wb_sunny_outlined},
      {'name': 'Chicago', 'sub': '5 routes', 'color': const Color(0xFF2A2A4A), 'icon': Icons.apartment},
    ];

    final List<Map<String, String>> routes = [
      {'from': 'New York', 'to': 'JFK Airport', 'duration': '45 min', 'distance': '15 mi'},
      {'from': 'Manhattan', 'to': 'Newark Airport', 'duration': '35 min', 'distance': '18 mi'},
      {'from': 'Brooklyn', 'to': 'LaGuardia Airport', 'duration': '30 min', 'distance': '12 mi'},
      {'from': 'New York', 'to': 'The Hamptons', 'duration': '2 hrs', 'distance': '98 mi'},
      {'from': 'Manhattan', 'to': 'Princeton, NJ', 'duration': '1 hr 15 min', 'distance': '57 mi'},
      {'from': 'New York', 'to': 'Philadelphia', 'duration': '2 hrs', 'distance': '95 mi'},
    ];

    Widget cityCard(Map<String, dynamic> city) => Container(
      width: isCompact ? 160 : 200,
      height: isCompact ? 120 : 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: city['color'] as Color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(children: [
        Positioned(bottom: 16, left: 16, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city['name'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(city['sub'] as String,
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
          ],
        )),
        Positioned(top: 14, right: 14, child: Icon(city['icon'] as IconData,
          color: Colors.white.withOpacity(0.2), size: 44)),
      ]),
    );

    Widget routeRow(Map<String, String> r, bool isLast) => Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Expanded(child: Row(children: [
            Container(width: 8, height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD4AF37))),
            const SizedBox(width: 10),
            Text(r['from']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0B3254))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_right_alt, color: Color(0xFFD4AF37), size: 18)),
            Text(r['to']!, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ])),
          const SizedBox(width: 16),
          Text('${r['duration']} · ${r['distance']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _navigateToSignup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3254),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
      if (!isLast) Divider(color: Colors.grey[200], height: 1),
    ]);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 48 : 80,
        horizontal: isCompact ? 20 : 60,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('CITY ROUTES', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            Text('Top destinations', style: TextStyle(
              fontSize: isCompact ? 26 : 36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B3254),
            )),
          ]),
        ]),
        const SizedBox(height: 28),

        // City cards horizontal scroll
        SizedBox(
          height: isCompact ? 120 : 150,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: cities.map(cityCard).toList()),
          ),
        ),
        const SizedBox(height: 40),

        // Top Routes list
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAED)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text('Popular routes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0B3254))),
              ),
              const Divider(height: 1),
              ...routes.asMap().entries.map((e) => routeRow(e.value, e.key == routes.length - 1)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildFleetSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;

    // ── Fleet categories (Blacklane-style) ──────────────────────────────────
    final List<Map<String, dynamic>> fleetCategories = [
      {
        'category': 'First Class',
        'tagline': 'Mercedes S-Class, BMW 7 Series or similar',
        'description': 'Premium sedans built for executive comfort and prestige.',
        'capacity': 'up to 3',
        'luggage': 'up to 3',
        'image': 'assets/images/mercdes-s-class.png',
        'vehicles': ['Mercedes S-Class', 'BMW 7 Series', 'Audi A8'],
        'highlight': false,
      },
      {
        'category': 'Business SUV',
        'tagline': 'Cadillac Escalade, Chevy Suburban or similar',
        'description': 'Spacious luxury SUVs for groups, events and airport runs.',
        'capacity': 'up to 6',
        'luggage': 'up to 6',
        'image': 'assets/images/cadillac-scalade.png',
        'vehicles': ['Cadillac Escalade', 'Suburban', 'Suburban RTS'],
        'highlight': true,
      },
      {
        'category': 'Business Van',
        'tagline': 'Mercedes Sprinter or similar',
        'description': 'Luxury vans ideal for larger groups and VIP events.',
        'capacity': 'up to 14',
        'luggage': 'up to 14',
        'image': 'assets/images/mercedez-sprinter.png',
        'vehicles': ['Mercedes Sprinter'],
        'highlight': false,
      },
    ];

    Widget fleetCard(Map<String, dynamic> cat) {
      final bool hi = cat['highlight'] as bool;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCompact ? width * 0.82 : 340,
        margin: EdgeInsets.only(right: isCompact ? 16 : 24),
        decoration: BoxDecoration(
          color: hi ? const Color(0xFF0B3254) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hi ? Colors.transparent : const Color(0xFFE8E8E8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(hi ? 0.18 : 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  cat['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1A3A5C),
                    child: Center(child: Icon(Icons.directions_car,
                      size: 72, color: Colors.white.withOpacity(0.3))),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hi ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF0B3254).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (cat['category'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: hi ? const Color(0xFFD4AF37) : const Color(0xFF0B3254),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(cat['tagline'] as String,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: hi ? Colors.white : const Color(0xFF0B3254),
                      height: 1.3,
                    )),
                  const SizedBox(height: 8),
                  Text(cat['description'] as String,
                    style: TextStyle(
                      fontSize: 13, height: 1.5,
                      color: hi ? Colors.white.withOpacity(0.65) : Colors.grey[600],
                    )),
                  const SizedBox(height: 18),

                  // Capacity & Luggage badges
                  Row(children: [
                    _fleetBadge(Icons.people_outline, cat['capacity'] as String, hi),
                    const SizedBox(width: 12),
                    _fleetBadge(Icons.luggage_outlined, cat['luggage'] as String, hi),
                  ]),
                  const SizedBox(height: 20),

                  // Models list
                  Wrap(spacing: 6, runSpacing: 6,
                    children: (cat['vehicles'] as List<String>).map((v) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hi ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: hi ? Colors.white.withOpacity(0.15) : Colors.grey.shade200),
                      ),
                      child: Text(v, style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: hi ? Colors.white.withOpacity(0.8) : Colors.grey[700],
                      )),
                    )).toList()),
                  const SizedBox(height: 22),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FleetScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hi ? const Color(0xFFD4AF37) : const Color(0xFF0B3254),
                        foregroundColor: hi ? const Color(0xFF0B3254) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Book ${cat['category']}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        top: isCompact ? 48 : 80,
        bottom: isCompact ? 48 : 80,
      ),
      color: Colors.white,
      child: Column(
        children: [
          // Section label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('OUR FLEET',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37), letterSpacing: 2)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Comfort, privacy and luxury.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 28 : 42,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B3254),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 80),
            child: Text(
              'Experience the ultimate private chauffeur service. Top-of-the-line vehicles for every occasion.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isCompact ? 14 : 16, color: Colors.grey[600], height: 1.6),
            ),
          ),
          const SizedBox(height: 48),

          // Cards — horizontal scroll
          SizedBox(
            height: isCompact ? 560 : 600,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fleetCategories.map((cat) => fleetCard(cat)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // View full fleet CTA
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FleetScreen()));
            },
            icon: const Icon(Icons.directions_car_outlined, size: 18),
            label: const Text('VIEW FULL FLEET',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B3254),
              side: const BorderSide(color: Color(0xFF0B3254), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fleetBadge(IconData icon, String label, bool dark) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: dark ? Colors.white.withOpacity(0.7) : Colors.grey[600]),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: dark ? Colors.white.withOpacity(0.8) : Colors.grey[700],
      )),
    ]);
  }

  Widget _buildAboutSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;
    final EdgeInsets padding = EdgeInsets.symmetric(
      vertical: isCompact ? 48 : 80,
      horizontal: isCompact ? 16 : 40,
    );

    final Widget statsLayout = isCompact
        ? Wrap(
            spacing: 32,
            runSpacing: 24,
            children: [
              _buildStatItem('10+', 'Years of\nExperience'),
              _buildStatItem('500K+', 'Happy\nCustomers'),
              _buildStatItem('50+', 'Luxury\nVehicles'),
            ],
          )
        : Row(
            children: [
              _buildStatItem('10+', 'Years of\nExperience'),
              const SizedBox(width: 60),
              _buildStatItem('500K+', 'Happy\nCustomers'),
              const SizedBox(width: 60),
              _buildStatItem('50+', 'Luxury\nVehicles'),
            ],
          );

    final Widget textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About VaneLux',
          style: TextStyle(
            fontSize: isCompact ? 32 : 42,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Luxury Transportation Redefined',
          style: TextStyle(
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'At VaneLux, we understand that every journey matters. Since our founding, we have been dedicated to providing exceptional luxury transportation services that exceed expectations.',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Our fleet of premium vehicles and professional chauffeurs ensure that every trip is comfortable, safe, and memorable. Whether you\'re traveling for business, celebrating a special occasion, or need reliable airport transportation, VaneLux delivers excellence.',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        statsLayout,
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF0B3254),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'LEARN MORE ABOUT US',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );

    final Widget imagePlaceholder = Container(
      height: isCompact ? 240 : 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: isCompact ? 72 : 100,
            color: const Color(0xFFD4AF37).withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Company Image',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: padding,
      color: const Color(0xFF0B3254),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textColumn,
                const SizedBox(height: 32),
                imagePlaceholder,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: textColumn),
                const SizedBox(width: 80),
                Expanded(flex: 2, child: imagePlaceholder),
              ],
            ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      color: const Color(0xFF1B2937),
      child: Column(
        children: [
          // Main Footer Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VANELUX',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Luxury transportation services for discerning clients. Experience the ultimate in comfort, style, and professional service.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social Media Icons
                    Row(
                      children: [
                        _buildSocialIcon(Icons.facebook, 'https://www.facebook.com/vanelux'),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.chat, 'https://wa.me/19175995522'),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.camera_alt, 'https://www.instagram.com/vanelux'),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.video_camera_back, 'https://www.tiktok.com/@vanelux'),
                      ],
                    ),
                  ],
                ),
              ),

              // Services
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink('Point to Point'),
                    _buildFooterLink('Airport Transfer'),
                    _buildFooterLink('Hourly Service'),
                    _buildFooterLink('Weddings'),
                    _buildFooterLink('Proms'),
                    _buildFooterLink('Tours'),
                  ],
                ),
              ),

              // Quick Links
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Links',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink('Book Now'),
                    _buildFooterLink('Our Fleet'),
                    _buildFooterLink('About Us'),
                    _buildFooterLink('Contact'),
                    _buildFooterLink(
                      'Become a Driver',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DriverRegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFooterLink('Terms & Conditions'),
                    _buildFooterLink('Privacy Policy'),
                  ],
                ),
              ),

              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Info',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(Icons.phone, '+1 (917) 599-5522'),
                    _buildContactItem(Icons.email, 'info@vanelux.com'),
                    _buildContactItem(Icons.location_on, 'Miami, FL 33101'),
                    const SizedBox(height: 16),
                    const Text(
                      '24/7 Available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Divider
          Container(height: 1, color: Colors.grey[600]),

          const SizedBox(height: 20),

          // Copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 VaneLux. All rights reserved.',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              Text(
                'Designed with luxury in mind',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // ignore: avoid_web_libraries_in_flutter
          html.window.open(url, '_blank');
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFD4AF37),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0B3254), size: 20),
        ),
      ),
    );
  }

  // ─── WHY CHOOSE US ────────────────────────────────────────────────────────
  Widget _buildWhyChooseUsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final stats = [
      {'number': '10,000+', 'label': 'Rides Completed', 'sub': 'Since 2019'},
      {'number': '4.9★', 'label': 'Average Rating', 'sub': 'Across all platforms'},
      {'number': '7', 'label': 'Luxury Vehicles', 'sub': 'Mercedes, Cadillac & more'},
      {'number': '24/7', 'label': 'Available', 'sub': 'Always here for you'},
      {'number': '\$0', 'label': 'Hidden Fees', 'sub': 'Transparent pricing'},
    ];
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 56, horizontal: isMobile ? 20 : 60),
      color: const Color(0xFF0B3254),
      child: Column(
        children: [
          const Text(
            'Why Choose Vanelux?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 2,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 10),
          const Text(
            'New York City\'s premium black-car service — trusted by executives,\ncelebrities, and travelers who refuse to compromise.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 36),
          isMobile
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: stats.length,
                  itemBuilder: (context, i) =>
                      _buildStatCard(stats[i], isMobile),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: stats
                      .map((s) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildStatCard(s, isMobile),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, String> stat, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat['number']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['label']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat['sub']!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55)),
          ),
        ],
      ),
    );
  }

  // ─── TESTIMONIALS ─────────────────────────────────────────────────────────
  Widget _buildTestimonialsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final reviews = [
      {
        'name': 'James M.',
        'location': 'Manhattan, NY',
        'text':
            'Vanelux made my JFK pickup absolutely seamless. The driver was early, the car was immaculate, and the service was five-star from start to finish. Won\'t use anyone else.',
        'initials': 'JM',
        'stars': 5,
      },
      {
        'name': 'Sarah L.',
        'location': 'Corporate Client, NYC',
        'text':
            'I book Vanelux for all my executive clients. The level of professionalism and the quality of the vehicles sets them completely apart. My clients are always impressed.',
        'initials': 'SL',
        'stars': 5,
      },
      {
        'name': 'Robert K.',
        'location': 'Wedding Event, NJ',
        'text':
            'Used Vanelux for our wedding day. The team went above and beyond — white-glove treatment throughout. The Mercedes was gorgeous and the driver was incredibly courteous.',
        'initials': 'RK',
        'stars': 5,
      },
      {
        'name': 'Diana P.',
        'location': 'LaGuardia Transfer',
        'text':
            'Flight was delayed and they tracked it and adjusted without me having to call. Peace of mind on a stressful travel day. Absolutely recommend Vanelux.',
        'initials': 'DP',
        'stars': 5,
      },
    ];
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80, horizontal: isMobile ? 24 : 60),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'What Our Clients Say',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 12),
          Container(width: 60, height: 3, color: const Color(0xFFD4AF37)),
          const SizedBox(height: 12),
          const Text(
            'Real experiences from real clients across New York City.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: Color(0xFF555555), height: 1.6),
          ),
          const SizedBox(height: 48),
          isMobile
              ? Column(
                  children: reviews
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildReviewCard(r),
                          ))
                      .toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reviews
                      .map((r) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: _buildReviewCard(r),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review['initials'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B3254),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      review['location'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              review['stars'] as int,
              (_) => const Icon(Icons.star,
                  color: Color(0xFFD4AF37), size: 16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"${review['text']}"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.65,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: onTap != null ? Colors.white : Colors.grey[300],
              height: 1.2,
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;
    final EdgeInsets padding = EdgeInsets.symmetric(
      vertical: isCompact ? 48 : 80,
      horizontal: isCompact ? 16 : 40,
    );

    Widget nameInputs;
    if (isCompact) {
      nameInputs = Column(
        children: [
          _buildContactInput('First Name'),
          const SizedBox(height: 20),
          _buildContactInput('Last Name'),
        ],
      );
    } else {
      nameInputs = Row(
        children: [
          Expanded(child: _buildContactInput('First Name')),
          const SizedBox(width: 20),
          Expanded(child: _buildContactInput('Last Name')),
        ],
      );
    }

    final Widget formCard = Container(
      padding: EdgeInsets.all(isCompact ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          nameInputs,
          const SizedBox(height: 20),
          _buildContactInput('Email Address'),
          const SizedBox(height: 20),
          _buildContactInput('Phone Number'),
          const SizedBox(height: 20),
          _buildContactInput('Message', maxLines: 4),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3254),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SEND MESSAGE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final Widget contactInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B3254),
          ),
        ),
        const SizedBox(height: 40),
        _buildContactInfoCard(
          Icons.phone,
          'Phone',
          '+1 (917) 599-5522',
          'Available 24/7',
        ),
        const SizedBox(height: 24),
        _buildContactInfoCard(
          Icons.email,
          'Email',
          'info@vanelux.com',
          'We respond within 1 hour',
        ),
        const SizedBox(height: 24),
        _buildContactInfoCard(
          Icons.location_on,
          'Location',
          'Miami, FL',
          'Serving all major cities',
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0B3254),
                const Color(0xFF0B3254).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.access_time, color: Color(0xFFD4AF37), size: 32),
              const SizedBox(height: 16),
              const Text(
                '24/7 Service',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Book anytime, anywhere. Our team is always ready to serve you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: padding,
      color: Colors.grey[50],
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get In Touch',
                  style: TextStyle(
                    fontSize: isCompact ? 32 : 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready to experience luxury transportation? Contact us for a quote or reservation.',
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                formCard,
                const SizedBox(height: 32),
                contactInfo,
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Get In Touch',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ready to experience luxury transportation? Contact us for a quote or reservation.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      formCard,
                    ],
                  ),
                ),
                const SizedBox(width: 80),
                Expanded(child: contactInfo),
              ],
            ),
    );
  }

  Widget _buildContactInput(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B3254),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0B3254), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
