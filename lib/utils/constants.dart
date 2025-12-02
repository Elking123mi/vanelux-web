// Re-export app-level constants/strings so existing imports of this file
// (which expect "AppConstants") keep working without changing every
// import site.
export 'app_strings.dart';

import 'package:flutter/material.dart';

class AppConfig {
  // Colores de la app
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color secondaryColor = Color(0xFFFFD700);
  static const Color accentColor = Color(0xFF16213E);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF50C878);
  static const Color warningColor = Color(0xFFFFA500);
  static const Color infoColor = Color(0xFF4A90E2);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [secondaryColor, warningColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Texto
  static const String appName = 'VaneLux';
  static const String appSlogan = 'Luxury Transportation';

  // Configuración de API
  static const String baseApiUrl = 'https://api.vanelux.com';
  static const String mapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Configuración de la app
  static const double defaultPadding = 20.0;
  static const double defaultRadius = 15.0;
  static const double cardElevation = 8.0;

  // Tamaños de fuente
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Durations for animations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Configuración de vehículos
  static const Map<String, Map<String, dynamic>> vehicleConfig = {
    'sedan': {
      'name': 'Sedán Premium',
      'description': 'Cómodo para 4 pasajeros',
      'basePrice': 15.0,
      'color': infoColor,
    },
    'suv': {
      'name': 'SUV Ejecutivo',
      'description': 'Espacioso para 6 pasajeros',
      'basePrice': 25.0,
      'color': successColor,
    },
    'luxury': {
      'name': 'Vehículo de Lujo',
      'description': 'Máximo confort y exclusividad',
      'basePrice': 45.0,
      'color': secondaryColor,
    },
  };

  // Configuración de validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Regex patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String namePattern = r'^[a-zA-ZÀ-ÿ\s]+$';

  // URLs para redes sociales y soporte
  static const String facebookUrl = 'https://facebook.com/vanelux';
  static const String twitterUrl = 'https://twitter.com/vanelux';
  static const String instagramUrl = 'https://instagram.com/vanelux';
  static const String supportEmail = 'support@vanelux.com';
  static const String supportPhone = '+593-4-123-4567';

  // Configuración de localización
  static const double defaultLatitude = -2.1469; // Guayaquil, Ecuador
  static const double defaultLongitude = -79.6694;
  static const double locationAccuracyRadius = 100.0; // metros

  // Configuración de cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // Keys para SharedPreferences
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLocationEnabled = 'location_enabled';
  static const String keySelectedLanguage = 'selected_language';
  static const String keySelectedTheme = 'selected_theme';
  static const String keyStoredBookings = 'stored_bookings';
}

// Extensiones útiles
extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(AppConfig.emailPattern).hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(AppConfig.phonePattern).hasMatch(this);
  }

  bool get isValidName {
    return RegExp(AppConfig.namePattern).hasMatch(this) &&
        length >= AppConfig.minNameLength &&
        length <= AppConfig.maxNameLength;
  }

  bool get isValidPassword {
    return length >= AppConfig.minPasswordLength &&
        length <= AppConfig.maxPasswordLength;
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension DoubleExtension on double {
  String get toCurrency {
    return '\$${toStringAsFixed(2)}';
  }
}

extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return '$day/$month/$year';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Hace un momento';
    }
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '$day de ${months[month - 1]} de $year';
  }
}
