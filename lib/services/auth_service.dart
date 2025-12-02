import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/driver.dart';
import '../models/user.dart';
import '../utils/demo_users.dart';
import 'api_service.dart';
import 'central_backend_service.dart';

enum UserRole { passenger, driver, admin }

class AuthService {
  static const String _userKey = 'user_data';
  static const String _driverKey = 'driver_data';
  static const String _userRoleKey = 'user_role';
  static const String demoDriverEmail = 'driver.demo@vanelux.com';
  static const String demoDriverPassword = 'Driver#2024';

  // Login for passengers
  static Future<User> login(String email, String password) async {
    try {
      final session = await CentralBackendService.login(
        email: email.trim(),
        password: password,
        requiredApp: AppConfig.appIdentifier,
      );

      await _persistUser(session.user, UserRole.passenger);
      return session.user;
    } catch (e) {
      // Si el backend falla, intentar con usuario demo
      print('⚠️ Backend login failed, trying demo user: $e');
      final demoUser = DemoUsers.getUserIfValid(email, password);
      if (demoUser != null) {
        print('✅ Demo user logged in: ${demoUser.name}');
        await _persistUser(demoUser, UserRole.passenger);
        return demoUser;
      }
      rethrow; // Si no es usuario demo, propagar el error
    }
  }

  // Login for drivers
  static Future<Driver> loginDriver(String email, String password) async {
    final session = await CentralBackendService.login(
      email: email.trim(),
      password: password,
      requiredApp: AppConfig.driverAppIdentifier,
    );

    final driverProfile =
        await CentralBackendService.fetchCurrentDriverProfile();
    await _persistUser(session.user, UserRole.driver);
    await _saveDriverData(driverProfile.toJson());
    return driverProfile;
  }

  // Register as passenger
  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final normalizedEmail = email.trim();
    if (await CentralBackendService.userExists(normalizedEmail)) {
      throw Exception('Ya existe un usuario registrado con $normalizedEmail.');
    }

    final session = await CentralBackendService.registerPassengerAndLogin(
      fullName: name,
      email: normalizedEmail,
      phone: phone,
      password: password,
    );

    await _persistUser(session.user, UserRole.passenger);
    return session.user;
  }

  // Register as driver
  static Future<Driver> registerDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    required String vehicleMake,
    required String vehicleModel,
    required int vehicleYear,
  }) async {
    final normalizedEmail = email.trim();
    if (await CentralBackendService.userExists(normalizedEmail)) {
      throw Exception('Ya existe un usuario registrado con $normalizedEmail.');
    }

    final session = await CentralBackendService.registerDriverAndLogin(
      fullName: name,
      email: normalizedEmail,
      phone: phone,
      password: password,
      licenseNumber: licenseNumber,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
    );

    final driverProfile =
        await CentralBackendService.fetchCurrentDriverProfile();
    await _persistUser(session.user, UserRole.driver);
    await _saveDriverData(driverProfile.toJson());
    return driverProfile;
  }

  // Verificar si está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await CentralBackendService.getValidAccessToken();
    return token != null;
  }

  // Obtener token
  static Future<String?> getToken() async {
    return CentralBackendService.getValidAccessToken();
  }

  // Save driver data
  static Future<void> _saveDriverData(Map<String, dynamic> driverData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverKey, jsonEncode(driverData));
    await prefs.setString(_userRoleKey, UserRole.driver.name);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final storedUser = User.fromJson(jsonDecode(userData));
      final normalizedUser = _normalizeStoredUser(storedUser);

      final needsUpdate =
          normalizedUser.firstName != storedUser.firstName ||
          normalizedUser.lastName != storedUser.lastName ||
          normalizedUser.name != storedUser.name;

      if (needsUpdate) {
        final role = await getUserRole();
        await _persistUser(normalizedUser, role);
      }

      return normalizedUser;
    }
    try {
      final fresh = await CentralBackendService.fetchCurrentUser();
      await _persistUser(fresh, await getUserRole());
      return fresh;
    } catch (_) {
      return null;
    }
  }

  // Get current driver
  static Future<Driver?> getCurrentDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final driverData = prefs.getString(_driverKey);
    if (driverData != null) {
      return Driver.fromJson(jsonDecode(driverData));
    }
    try {
      final profile = await CentralBackendService.fetchCurrentDriverProfile();
      await _saveDriverData(profile.toJson());
      return profile;
    } catch (_) {
      return null;
    }
  }

  // Get user role
  static Future<UserRole> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_userRoleKey) ?? UserRole.passenger.name;
    return role == 'driver' ? UserRole.driver : UserRole.passenger;
  }

  // Actualizar perfil
  static Future<User> updateProfile(Map<String, dynamic> userData) async {
    final token = await getToken();
    final response = await ApiService.put(
      '/auth/profile',
      userData,
      token: token,
    );
    final updatedUser = User.fromJson(response['user']);
    await _persistUser(updatedUser, await getUserRole());
    return updatedUser;
  }

  // Cambiar contraseña
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await getToken();
    await ApiService.put('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }, token: token);
  }

  // Logout
  static Future<void> logout() async {
    await CentralBackendService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_driverKey);
    await prefs.remove(_userRoleKey);
  }

  static Future<void> _persistUser(User user, UserRole role) async {
    // Asegurarse de que el usuario tenga allowedApps configurado
    final userJson = user.toJson();
    if (userJson['allowed_apps'] == null ||
        (userJson['allowed_apps'] is List &&
            (userJson['allowed_apps'] as List).isEmpty)) {
      // Si no tiene allowed_apps, agregarlo según el rol
      final allowedApp = role == UserRole.driver
          ? AppConfig.driverAppIdentifier
          : AppConfig.appIdentifier;
      userJson['allowed_apps'] = [allowedApp];
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userJson));
    await prefs.setString(_userRoleKey, role.name);
  }

  static User _normalizeStoredUser(User user) {
    // Si coincide con el usuario demo, usar los datos actuales del demo
    if (user.email.toLowerCase() == DemoUsers.elkinEmail.toLowerCase()) {
      final demoUser = DemoUsers.getElkinUser();
      return demoUser.copyWith(
        id: user.id.isNotEmpty ? user.id : demoUser.id,
        createdAt: user.createdAt,
        isActive: user.isActive,
        roles: user.roles.isNotEmpty ? user.roles : demoUser.roles,
        allowedApps: user.allowedApps.isNotEmpty
            ? user.allowedApps
            : demoUser.allowedApps,
        phone: user.phone.isNotEmpty ? user.phone : demoUser.phone,
        profileImageUrl: user.profileImageUrl ?? demoUser.profileImageUrl,
        defaultLocation: user.defaultLocation ?? demoUser.defaultLocation,
      );
    }

    var normalizedFirstName = user.firstName.trim();
    var normalizedLastName = user.lastName.trim();
    var normalizedName = user.name.trim();

    if (normalizedFirstName.isEmpty && normalizedName.isNotEmpty) {
      final parts = normalizedName.split(RegExp(r'\s+'));
      normalizedFirstName = parts.first;
      if (normalizedLastName.isEmpty && parts.length > 1) {
        normalizedLastName = parts.sublist(1).join(' ').trim();
      }
    }

    if (normalizedFirstName.isEmpty && user.email.isNotEmpty) {
      normalizedFirstName = user.email.split('@').first;
    }

    if (normalizedLastName.isEmpty && normalizedName.isNotEmpty) {
      final parts = normalizedName.split(RegExp(r'\s+'));
      if (parts.length > 1) {
        normalizedLastName = parts.sublist(1).join(' ').trim();
      }
    }

    if ((normalizedName.isEmpty || !normalizedName.contains(' ')) &&
        normalizedFirstName.isNotEmpty) {
      final possibleLastName = normalizedLastName.isNotEmpty
          ? normalizedLastName
          : user.lastName.trim();
      final combined =
          ('$normalizedFirstName ${possibleLastName.isNotEmpty ? possibleLastName : ''}')
              .trim();
      if (combined.isNotEmpty) {
        normalizedName = combined;
      } else if (user.email.isNotEmpty) {
        normalizedName = user.email.split('@').first;
      }
    }

    return user.copyWith(
      firstName: normalizedFirstName,
      lastName: normalizedLastName,
      name: normalizedName,
    );
  }
}
