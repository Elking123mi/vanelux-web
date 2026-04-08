import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/web/web_home_screen.dart';
import 'screens/web/about_us_screen.dart';
import 'screens/web/contact_us_screen.dart';
import 'screens/web/fleet_screen.dart';
import 'screens/web/service_detail_screen.dart';
import 'screens/web/driver_registration_screen.dart';
import 'screens/web/corporate_registration_screen.dart';
import 'screens/web/driver_applications_admin_screen.dart';
import 'screens/web/driver_set_password_screen.dart';
import 'screens/web/corporate_set_password_screen.dart';
import 'screens/auth/register_screen.dart';
import 'constants/vanelux_colors.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A1A2E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const VaneLuxApp(),
    ),
  );
}

class VaneLuxApp extends StatelessWidget {
  const VaneLuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaneLux - Luxury Transportation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          brightness: Brightness.light,
        ),
        primarySwatch: Colors.blue,
        primaryColor: VaneLuxColors.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF1A1A2E),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      home: kIsWeb ? const _WebEntry() : const LoginScreen(),
    );
  }
}

/// Checks the current URL hash on startup.
/// If the URL is `#/set-password?token=...`, shows the password setup screen.
/// Otherwise shows the normal web home.
class _WebEntry extends StatelessWidget {
  const _WebEntry();

  Uri _resolveEntryUri() {
    final base = Uri.base;

    if (base.fragment.isNotEmpty) {
      final fragmentPath = base.fragment.startsWith('/')
          ? base.fragment
          : '/${base.fragment}';
      return Uri.tryParse(fragmentPath) ?? Uri(path: '/');
    }

    if (base.path.isNotEmpty && base.path != '/') {
      return Uri(
        path: base.path,
        queryParameters: base.queryParameters.isEmpty
            ? null
            : base.queryParameters,
      );
    }

    return Uri(path: '/');
  }

  String _serviceTypeFromSlug(String slug) {
    switch (slug.trim().toLowerCase()) {
      case 'airport-transfer':
        return 'Airport Transfer';
      case 'point-to-point':
        return 'Point to Point';
      case 'hourly-service':
        return 'Hourly Service';
      case 'corporate':
        return 'Corporate';
      case 'events':
        return 'Events';
      case 'tours':
        return 'Tours';
      default:
        return 'Point to Point';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final uri = _resolveEntryUri();
      final path = (uri?.path ?? '/').trim().isEmpty ? '/' : (uri?.path ?? '/');
      final segments = uri?.pathSegments ?? const <String>[];

      if (path == '/set-password') {
        final token = uri?.queryParameters['token'] ?? '';
        final account =
            (uri?.queryParameters['account'] ?? '').trim().toLowerCase();
        if (token.isNotEmpty) {
          if (account == 'corporate') {
            return CorporateSetPasswordScreen(token: token);
          }
          return DriverSetPasswordScreen(token: token);
        }
      }

      if (path == '/about') {
        return const AboutUsScreen();
      }

      if (path == '/contact') {
        return const ContactUsScreen();
      }

      if (path == '/fleet') {
        return const FleetScreen();
      }

      if (path == '/drivers/register') {
        return const DriverRegistrationScreen();
      }

      if (path == '/corporate/register') {
        return const CorporateRegistrationScreen();
      }

      if (path == '/admin/driver-applications') {
        return const DriverApplicationsAdminScreen();
      }

      if (path == '/services') {
        return const ServiceDetailScreen(serviceType: 'Point to Point');
      }

      if (segments.length >= 2 && segments.first == 'services') {
        return ServiceDetailScreen(
          serviceType: _serviceTypeFromSlug(segments[1]),
        );
      }
    }
    return const WebHomeScreen();
  }
}
