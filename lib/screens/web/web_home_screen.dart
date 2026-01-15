import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/google_maps_service.dart';
import '../../widgets/route_map_view.dart';
import 'customer_dashboard_web.dart';
import 'fleet_page.dart';
import 'fleet_screen.dart';
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
  const WebHomeScreen({super.key});

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

  // Mobile menu state
  bool _isMobileMenuOpen = false;

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

  @override
  void initState() {
    super.initState();
    _showPickupDropdown = false;
    _showDestinationDropdown = false;
    // NO cerrar dropdown al perder foco - esto causaba el problema
    _loadCurrentUser();
    _startCarousel();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome back to VaneLux!')),
      );
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
        builder: (dialogContext) {
          bool isLoading = false;
          String? errorMessage;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text('Sign in to VaneLux'),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your credentials to access personalized bookings.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            if (email.isEmpty || password.isEmpty) {
                              setDialogState(() {
                                errorMessage =
                                    'Please provide both email and password.';
                              });
                              return;
                            }

                            setDialogState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final user = await AuthService.login(email, password);
                              if (!dialogContext.mounted) {
                                return;
                              }
                              Navigator.of(dialogContext).pop(user);
                            } catch (e) {
                              setDialogState(() {
                                errorMessage =
                                    'We could not sign you in. Please verify your credentials.';
                                isLoading = false;
                              });
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ],
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

  Future<User?> _showSignupDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    try {
      return await showDialog<User>(
        context: context,
        builder: (dialogContext) {
          bool isLoading = false;
          String? errorMessage;
          bool acceptTerms = false;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text('Create your VaneLux account'),
                content: SizedBox(
                  width: 480,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Unlock exclusive offers and manage all your rides in one place.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Create password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: acceptTerms,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        acceptTerms = value ?? false;
                                      });
                                    },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the VaneLux terms of service and privacy policy.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
              Text(
                errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final phone = phoneController.text.trim();
                            final password = passwordController.text;

                            if (name.isEmpty ||
                                email.isEmpty ||
                                phone.isEmpty ||
                                password.isEmpty) {
                              setDialogState(() {
                                errorMessage =
                                    'Please fill in all required fields.';
                              });
                              return;
                            }

                            if (!acceptTerms) {
                              setDialogState(() {
                                errorMessage =
                                    'Please accept the terms to create your account.';
                              });
                              return;
                            }

                            setDialogState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final user = await AuthService.register(
                                name: name,
                                email: email,
                                phone: phone,
                                password: password,
                              );
                              if (!dialogContext.mounted) {
                                return;
                              }
                              Navigator.of(dialogContext).pop(user);
                            } catch (e) {
                              setDialogState(() {
                                // Mostrar el error específico del backend
                                final errorText = e.toString();
                                if (errorText.contains('Ya existe un usuario')) {
                                  errorMessage =
                                      'This email is already registered. Please login instead.';
                                } else if (errorText.contains('timeout') ||
                                    errorText.contains('connection')) {
                                  errorMessage =
                                      'Connection timeout. Please check your internet and try again.';
                                } else if (errorText.contains('Exception:')) {
                                  // Extraer el mensaje después de "Exception: "
                                  errorMessage = errorText
                                      .replaceAll('Exception:', '')
                                      .trim();
                                } else {
                                  errorMessage =
                                      'We could not create your account. Please try again later.';
                                }
                                isLoading = false;
                              });
                              // Log del error para debugging
                              print('Registration error: $e');
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ],
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
          quoteError = 'Selecciona direcciones válidas desde las sugerencias.';
        });
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona direcciones válidas desde las sugerencias para continuar.',
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
        throw Exception(
          'No se encontró una ruta entre los puntos seleccionados',
        );
      }

      final oneWayMiles = distanceValue / 1609.344;
      final totalMiles = oneWayMiles * (isReturnTrip ? 2 : 1);
      const double baseRate = 2.0;

      final options = _quoteVehicleOptions.map((vehicle) {
        final ratePerMile = baseRate * vehicle.rateMultiplier;
        final totalPrice = totalMiles * ratePerMile;
        return _VehicleQuote(
          vehicle: vehicle,
          totalPrice: totalPrice,
          ratePerMile: ratePerMile,
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
          baseRatePerMile: baseRate,
          includesReturnTrip: isReturnTrip,
          options: options,
          originLat: originPlace.latitude,
          originLng: originPlace.longitude,
          destinationLat: destinationPlace.latitude,
          destinationLng: destinationPlace.longitude,
          pickupDateTime: selectedDateTime,
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
    final TextEditingController controller =
        isPickup ? pickupController : destinationController;

    if (placeId == null || placeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'No se pudieron obtener los detalles de la dirección de origen seleccionada.'
                : 'No se pudieron obtener los detalles de la dirección de destino seleccionada.',
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
                ? 'Error al obtener detalles del origen: ${error.toString().replaceFirst('Exception: ', '')}'
                : 'Error al obtener detalles del destino: ${error.toString().replaceFirst('Exception: ', '')}',
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
    final TextEditingController controller =
        isPickup ? pickupController : destinationController;
    final _SelectedLocation? currentSelection =
        isPickup ? _pickupPlace : _destinationPlace;
    final String input = controller.text.trim();

    if (input.isEmpty) {
      return null;
    }

    if (currentSelection != null &&
        input.toLowerCase() == currentSelection.description.trim().toLowerCase()) {
      return currentSelection;
    }

    final List<Map<String, dynamic>> suggestions =
        isPickup ? pickupSuggestions : destinationSuggestions;

    Map<String, dynamic>? matchingSuggestion;
    for (final suggestion in suggestions) {
      final String fallback = _suggestionFallback(suggestion).trim().toLowerCase();
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
      return 'Selecciona fecha y hora';
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
                  'Reserva tu viaje',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Servicio personalizado con chofer profesional',
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
                  'Tipo de servicio',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedServiceType,
                  hint: const Text('Selecciona el servicio'),
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
                  'Punto de recogida',
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
                    hintText: 'Ingresa la dirección de origen',
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
                  'Destino',
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
                    hintText: '¿A dónde viajamos?',
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
                  'Fecha y hora de recogida',
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
                      'Añadir viaje de regreso',
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
                          'OBTENER PRECIOS',
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
                  'Mostramos tarifas estimadas en segundos. Nuestros especialistas confirmarán tu reserva de inmediato.',
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
    final double maxWidth = isCompact ? 560 : 520;
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
            'Verifica las direcciones e intenta de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      );
    } else if (currentQuote == null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.directions_car_filled_outlined,
            size: 56,
            color: Color(0xFF0B3254),
          ),
          SizedBox(height: 16),
          Text(
            'Solicita tu cotización',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B3254),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Ingresa la dirección de origen y destino para ver las tarifas en tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
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
        padding: const EdgeInsets.all(28),
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
          'Tu experiencia Vanelux',
          style: TextStyle(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B3254),
          ),
        ),
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
                'Distancia total',
                quote.distanceText,
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildInfoPill(
                Icons.schedule,
                'Duración estimada',
                quote.durationText.isEmpty
                    ? 'Calculando...'
                    : quote.durationText,
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildInfoPill(
                Icons.calendar_today_outlined,
                'Fecha',
                _formatDateTime(quote.pickupDateTime),
                isCompact,
              ),
              if (quote.includesReturnTrip) ...[
                const SizedBox(height: 12),
                _buildInfoPill(
                  Icons.repeat,
                  'Servicio',
                  'Viaje redondo',
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
                      '${quote.distanceText} • ${quote.durationText.isEmpty ? 'Calculando...' : quote.durationText}',
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
          'Selecciona tu vehículo',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B3254),
          ),
        ),
        const SizedBox(height: 16),
        ...quote.options.map(
          (option) => _buildVehicleQuoteTile(option, quote.totalMiles, isCompact),
        ),
        const SizedBox(height: 12),
        Text(
          'Tarifas calculadas con base de \$${quote.baseRatePerMile.toStringAsFixed(2)} por milla.\nLos precios finales incluyen viaje redondo cuando aplica.',
          style: TextStyle(
            color: Colors.grey[600],
            height: 1.5,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleQuoteTile(_VehicleQuote option, double totalMiles, bool isCompact) {
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
                    const SizedBox(height: 4),
                    Text(
                      '\$${option.ratePerMile.toStringAsFixed(2)} / milla',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isCompact ? 12 : 14,
                      ),
                    ),
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
                    '${vehicle.luggage} equipajes',
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

  Widget _buildInfoPill(IconData icon, String label, String value, bool isCompact) {
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                                      builder: (context) => const ServiceDetailScreen(
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
                                    builder: (context) => const ServiceDetailScreen(
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B3254),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'VANELUX',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Luxury Transportation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildMobileMenuItem('HOME', Icons.home),
                    _buildMobileMenuItem('SERVICES', Icons.car_rental),
                    _buildMobileMenuItem('FLEET', Icons.directions_car),
                    _buildMobileMenuItem('ABOUT', Icons.info),
                    _buildMobileMenuItem('CONTACT', Icons.contact_mail),
                    const Divider(color: Colors.white24, height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Color(0xFFFFD700), size: 20),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header/Navbar
            _buildHeader(context),

            // Hero Section
            Container(key: _heroKey, child: _buildHeroSection(context)),

            // World Cup Section
            _buildWorldCupSection(context),

            // Services Section
            Container(key: _servicesKey, child: _buildServicesSection(context)),

            // Fleet Section
            Container(key: _fleetKey, child: _buildFleetSection(context)),

            // About Section
            Container(key: _aboutKey, child: _buildAboutSection(context)),

            // Contact Section
            Container(key: _contactKey, child: _buildContactSection(context)),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
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
              const SizedBox(width: 24),
            ];

            if (_isCheckingAuth) {
              trailingChildren.add(const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ));
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  const Text(
                    'VANELUX',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (_isCheckingAuth)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_currentUser == null)
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
                    )
                  else
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
                const Text(
                  'VANELUX',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3254),
                    letterSpacing: 2,
                  ),
                ),
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
                  'Selecciona un servicio y completa tu reserva desde esta página.',
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
          const Text(
            'VANELUX',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
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
              fontSize: isCompact ? 34 : 48,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B3254),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Choferes profesionales, vehículos exclusivos y reservas confirmadas al instante.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 16 : 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
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
              fontSize: isCompact ? 32 : 42,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We offer luxury transportation for all your needs with first-class vehicles and chauffeurs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isCompact ? 16 : 18, color: Colors.grey),
          ),
          const SizedBox(height: 48),

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
      padding: const EdgeInsets.all(32),
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
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF0B3254),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(
                    serviceType: getServiceType(title),
                  ),
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

  Widget _buildFleetSection(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 900;

    final vehicles = [
      {
        'name': 'Mercedes S-Class',
        'subtitle': 'Mercedes S550, BMW 750 or similar',
        'description': 'Luxury sedan perfect for executive transport',
        'capacity': 'max. 3',
        'luggage': 'max. 3',
        'image': 'assets/images/mercdes-s-class.png',
        'category': 'First Class',
      },
      {
        'name': 'BMW 7 Series',
        'subtitle': 'Premium comfort with advanced technology',
        'description': 'Premium comfort with advanced technology',
        'capacity': 'max. 3',
        'luggage': 'max. 3',
        'image': 'assets/images/bmw 7 series.jpg',
        'category': 'First Class',
      },
      {
        'name': 'Audi A8',
        'subtitle': 'Sophisticated design meets performance',
        'description': 'Sophisticated design meets cutting-edge performance',
        'capacity': 'max. 3',
        'luggage': 'max. 3',
        'image': 'assets/images/audi a8.jpg',
        'category': 'First Class',
      },
      {
        'name': 'Cadillac Escalade',
        'subtitle': 'Spacious luxury SUV',
        'description': 'Spacious SUV for families and groups',
        'capacity': 'max. 6',
        'luggage': 'max. 6',
        'image': 'assets/images/cadillac-scalade.png',
        'category': 'SUV',
      },
      {
        'name': 'Suburban',
        'subtitle': 'Comfortable group transportation',
        'description': 'Comfortable group transportation',
        'capacity': 'max. 7',
        'luggage': 'max. 7',
        'image': 'assets/images/suburban.png',
        'category': 'SUV',
      },
      {
        'name': 'Suburban RTS',
        'subtitle': 'Extended SUV for special events',
        'description': 'Extended SUV for special events',
        'capacity': 'max. 7',
        'luggage': 'max. 7',
        'image': 'assets/images/suburban rts.png',
        'category': 'SUV',
      },
      {
        'name': 'Mercedes Sprinter',
        'subtitle': 'Luxury van for group transportation',
        'description': 'Luxury van for group transportation',
        'capacity': 'max. 14',
        'luggage': 'max. 14',
        'image': 'assets/images/mercedez-sprinter.png',
        'category': 'VAN',
      },
    ];

    final currentVehicle = vehicles[_currentVehicleIndex];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 48 : 80,
        horizontal: 20,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'OUR FLEET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Comfort, privacy and luxury.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Experience the ultimate private chauffeur service. Encounter every destination in our top of the line vehicles, where high end luxury meets safe, private and reliable journeys; just what the upscale modern day passenger needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 60),
          
          // Carrusel de vehículos - Responsive
          isCompact
              ? Column(
                  children: [
                    // Imagen del vehículo en móvil
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        key: ValueKey(_currentVehicleIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                currentVehicle['image']!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 250,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Premium Vehicle',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              currentVehicle['category']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentVehicle['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                currentVehicle['subtitle']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 18,
                                      color: Color(0xFF0B3254),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentVehicle['capacity']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0B3254),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.luggage,
                                      size: 18,
                                      color: Color(0xFF0B3254),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentVehicle['luggage']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0B3254),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Botones de navegación en móvil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _currentVehicleIndex = (_currentVehicleIndex - 1 + vehicles.length) % vehicles.length;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF0B3254),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _currentVehicleIndex = (_currentVehicleIndex + 1) % vehicles.length;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF0B3254),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón anterior en desktop
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentVehicleIndex = (_currentVehicleIndex - 1 + vehicles.length) % vehicles.length;
                        });
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF0B3254),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    
                    // Imagen del vehículo en desktop
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          key: ValueKey(_currentVehicleIndex),
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  currentVehicle['image']!,
                                  height: 400,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 400,
                                      color: Colors.grey[200],
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 100,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Premium Vehicle',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                currentVehicle['category']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3254),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentVehicle['name']!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3254),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentVehicle['subtitle']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        size: 20,
                                        color: Color(0xFF0B3254),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currentVehicle['capacity']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0B3254),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.luggage,
                                        size: 20,
                                        color: Color(0xFF0B3254),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currentVehicle['luggage']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0B3254),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 40),
                    // Botón siguiente en desktop
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentVehicleIndex = (_currentVehicleIndex + 1) % vehicles.length;
                        });
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF0B3254),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
          
          const SizedBox(height: 40),
          
          // Indicadores de punto
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              vehicles.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentVehicleIndex == index ? 30 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentVehicleIndex == index
                      ? const Color(0xFFFFD700)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 60),
          
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FleetScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B3254),
              foregroundColor: const Color(0xFFFFD700),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 32 : 50,
                vertical: isCompact ? 16 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'VIEW FULL FLEET',
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
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
                        _buildSocialIcon(Icons.facebook),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.chat),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.camera_alt),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.video_camera_back),
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
                    _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
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

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF0B3254), size: 20),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey[300], height: 1.2),
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
