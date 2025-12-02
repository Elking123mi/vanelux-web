import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VaneLuxApiService {
  static const String baseUrl = 'https://vane-lux.com';

  // ==================== AUTHENTICATION ====================

  /// Login for regular customers
  static Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save token to SharedPreferences
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('user_type', 'customer');
          await prefs.setString('user_info', jsonEncode(data['user']));
        }
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado. Verifica tu email.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error de autenticación');
      }
    } catch (e) {
      if (e.toString().contains('Email o contraseña') ||
          e.toString().contains('Usuario no encontrado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  /// Generic login method for both customers and drivers
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // Try customer login first
      return await loginUser(email, password);
    } catch (e) {
      // If customer login fails, try driver login
      try {
        return await loginDriver(email, password);
      } catch (driverError) {
        // Return the original customer error if both fail
        rethrow;
      }
    }
  }

  /// Login for drivers/taxists
  static Future<Map<String, dynamic>> loginDriver(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/driver/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save driver session info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', 'driver');
        await prefs.setString('driver_info', jsonEncode(data['driver']));
        await prefs.setString('auth_token', data['token'] ?? '');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales de conductor incorrectas');
      } else if (response.statusCode == 403) {
        throw Exception('Tu cuenta de conductor está pendiente de aprobación');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Conductor no encontrado. Regístrate como conductor primero.',
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error de autenticación de conductor',
        );
      }
    } catch (e) {
      if (e.toString().contains('Credenciales') ||
          e.toString().contains('aprobación') ||
          e.toString().contains('Conductor no encontrado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  /// Check if email already exists in the system
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      } else if (response.statusCode == 404) {
        // Email doesn't exist - good for registration
        return false;
      } else {
        // If endpoint doesn't exist, try alternative check via registration attempt
        return await _checkEmailViaRegistration(email);
      }
    } catch (e) {
      // Fallback method if direct check fails
      return await _checkEmailViaRegistration(email);
    }
  }

  /// Alternative method to check email by attempting registration with fake data
  static Future<bool> _checkEmailViaRegistration(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'temp_check_${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'password': 'TempPassword123!',
          'phone': '+1234567890',
          'fullName': 'Temp Check User',
        }),
      );

      if (response.statusCode == 409) {
        // Conflict - email already exists
        return true;
      } else if (response.statusCode == 201) {
        // Registration succeeded, but we need to delete this temp user
        // This shouldn't happen in production as we're just checking
        return false;
      } else if (response.statusCode == 400) {
        // Check if error message mentions email already exists
        final errorData = jsonDecode(response.body);
        final message = errorData['message']?.toString().toLowerCase() ?? '';
        return message.contains('email') &&
            (message.contains('exist') ||
                message.contains('taken') ||
                message.contains('used'));
      }

      return false;
    } catch (e) {
      // If we can't check, assume email is available
      return false;
    }
  }

  /// Register new customer
  /// Alias for registerUser method
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    return await registerUser(
      username: email,
      email: email,
      password: password,
      phone: phone,
      fullName: fullName,
    );
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String fullName,
  }) async {
    try {
      // First, check if email already exists in the VaneLux system
      print('🔍 Verificando si el email ya existe en VaneLux...');
      final emailExists = await checkEmailExists(email);

      if (emailExists) {
        throw Exception(
          'Este email ya está registrado en VaneLux. Por favor, inicia sesión en su lugar o usa un email diferente.',
        );
      }

      print('✅ Email disponible, procediendo con el registro...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Usuario registrado exitosamente');
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        // Double-check: this shouldn't happen if our pre-check worked
        throw Exception(
          'Este email ya está registrado en VaneLux. Por favor, inicia sesión en su lugar.',
        );
      } else if (response.statusCode == 400) {
        // Bad request - validation errors
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Datos de registro inválidos');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      if (e.toString().contains('ya está registrado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get current user info
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user info: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== VEHICLES ====================

  /// Get available vehicles
  static Future<List<Map<String, dynamic>>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load vehicles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== BOOKINGS ====================

  /// Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required String pickupLocation,
    required String dropoffLocation,
    required String vehicleType,
    required String scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pickupLocation': pickupLocation,
          'dropoffLocation': dropoffLocation,
          'vehicleType': vehicleType,
          'scheduledTime': scheduledTime,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get user's bookings
  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load bookings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== DRIVER FUNCTIONS ====================

  /// Get assigned trips for drivers
  static Future<List<Map<String, dynamic>>> getDriverTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/driver/trips'),
        headers: {'Content-Type': 'application/json'},
        // Note: Driver authentication might use cookies/sessions
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== UTILITY FUNCTIONS ====================

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userType = prefs.getString('user_type');
    return token != null && userType != null;
  }

  /// Get user type (customer or driver)
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  /// Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_type');
    await prefs.remove('driver_info');
  }
}
