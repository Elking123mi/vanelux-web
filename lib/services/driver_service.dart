import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/driver.dart';
import 'auth_service.dart';

/// Servicio para gestionar conductores de VaneLux
class DriverService {
  /// Crear perfil de conductor después del registro
  static Future<Map<String, dynamic>> createDriverProfile({
    required int userId,
    required String fullName,
    required String phone,
    required String licenseNumber,
    required String vehiclePlate,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleColor,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final response = await http
        .post(
          Uri.parse(AppConfig.vlxDriversUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'user_id': userId,
            'full_name': fullName,
            'phone': phone,
            'license_number': licenseNumber,
            'vehicle_plate': vehiclePlate,
            if (vehicleMake != null) 'vehicle_make': vehicleMake,
            if (vehicleModel != null) 'vehicle_model': vehicleModel,
            if (vehicleYear != null) 'vehicle_year': vehicleYear,
            if (vehicleColor != null) 'vehicle_color': vehicleColor,
          }),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear perfil de conductor: ${response.body}');
    }
  }

  /// Obtener perfil del conductor actual
  static Future<Driver?> getCurrentDriverProfile() async {
    try {
      return await AuthService.getCurrentDriver();
    } catch (e) {
      throw Exception('Error al obtener perfil de conductor: $e');
    }
  }

  /// Actualizar perfil de conductor
  static Future<Map<String, dynamic>> updateDriverProfile({
    required int driverId,
    String? fullName,
    String? phone,
    String? licenseNumber,
    String? vehiclePlate,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleColor,
    bool? isAvailable,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final Map<String, dynamic> updateData = {};
    if (fullName != null) updateData['full_name'] = fullName;
    if (phone != null) updateData['phone'] = phone;
    if (licenseNumber != null) updateData['license_number'] = licenseNumber;
    if (vehiclePlate != null) updateData['vehicle_plate'] = vehiclePlate;
    if (vehicleMake != null) updateData['vehicle_make'] = vehicleMake;
    if (vehicleModel != null) updateData['vehicle_model'] = vehicleModel;
    if (vehicleYear != null) updateData['vehicle_year'] = vehicleYear;
    if (vehicleColor != null) updateData['vehicle_color'] = vehicleColor;
    if (isAvailable != null) updateData['is_available'] = isAvailable;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.vlxDriversUrl}/$driverId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(updateData),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al actualizar perfil de conductor: ${response.body}',
      );
    }
  }

  /// Actualizar disponibilidad del conductor
  static Future<void> updateAvailability(bool isAvailable) async {
    final driver = await getCurrentDriverProfile();
    if (driver == null) {
      throw Exception('No se encontró el perfil del conductor');
    }

    // Asumir que driver tiene un campo id
    await updateDriverProfile(
      driverId: int.parse(driver.id),
      isAvailable: isAvailable,
    );
  }

  /// Validar si el usuario actual es conductor
  static Future<bool> isDriver() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    return user.allowedApps.contains(AppConfig.driverAppIdentifier);
  }

  /// Obtener lista de conductores disponibles (solo para admins)
  static Future<List<Map<String, dynamic>>> getAvailableDrivers() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final response = await http
        .get(
          Uri.parse('${AppConfig.vlxDriversUrl}?available=true'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(AppConfig.defaultRequestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener conductores: ${response.body}');
    }
  }
}
