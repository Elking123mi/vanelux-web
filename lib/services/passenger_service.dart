import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'auth_service.dart';

/// Servicio para gestionar pasajeros de VaneLux
class PassengerService {
  /// Crear perfil de pasajero después del registro
  static Future<Map<String, dynamic>> createPassengerProfile({
    required int userId,
    required String fullName,
    required String phone,
    String? address,
    Map<String, dynamic>? preferences,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final response = await http
        .post(
          Uri.parse(AppConfig.vlxPassengersUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'user_id': userId,
            'full_name': fullName,
            'phone': phone,
            if (address != null) 'address': address,
            if (preferences != null) 'preferences': preferences,
          }),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear perfil de pasajero: ${response.body}');
    }
  }

  /// Obtener perfil del pasajero actual
  static Future<Map<String, dynamic>> getCurrentPassengerProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final user = await AuthService.getCurrentUser();
    if (user == null) {
      throw Exception('No se pudo obtener el usuario actual');
    }

    final response = await http
        .get(
          Uri.parse('${AppConfig.vlxPassengersUrl}?user_id=${user.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(AppConfig.defaultRequestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener perfil de pasajero: ${response.body}');
    }
  }

  /// Actualizar perfil de pasajero
  static Future<Map<String, dynamic>> updatePassengerProfile({
    required int passengerId,
    String? fullName,
    String? phone,
    String? address,
    Map<String, dynamic>? preferences,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No estás autenticado');
    }

    final Map<String, dynamic> updateData = {};
    if (fullName != null) updateData['full_name'] = fullName;
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;
    if (preferences != null) updateData['preferences'] = preferences;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.vlxPassengersUrl}/$passengerId'),
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
        'Error al actualizar perfil de pasajero: ${response.body}',
      );
    }
  }

  /// Validar si el usuario actual es pasajero
  static Future<bool> isPassenger() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    return user.allowedApps.contains(AppConfig.appIdentifier) &&
        !user.allowedApps.contains(AppConfig.driverAppIdentifier);
  }
}
