import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Script de prueba para verificar la conexión con el backend de Supabase
/// 
/// Ejecutar con:
/// dart run luxury_taxi_app/test_supabase_connection.dart
/// 
/// Este script verifica:
/// - Conectividad con el backend
/// - Login de usuario
/// - Obtener información del usuario
/// - Crear una reserva
/// - Listar reservas

void main() async {
  print('🧪 INICIANDO PRUEBAS DE CONEXIÓN CON SUPABASE\n');
  
  final String baseUrl = Platform.isAndroid || Platform.isIOS
      ? 'http://192.168.1.43:3000/api/v1'
      : 'http://localhost:3000/api/v1';
  
  print('📡 URL del backend: $baseUrl\n');
  
  // Test 1: Verificar conectividad
  print('─' * 60);
  print('TEST 1: Verificando conectividad con el backend...');
  final healthCheck = await testHealthCheck(baseUrl);
  if (!healthCheck) {
    print('❌ No se pudo conectar con el backend');
    print('   Asegúrate de que el backend esté corriendo en el puerto 3000');
    exit(1);
  }
  print('✅ Backend conectado correctamente\n');
  
  // Test 2: Login
  print('─' * 60);
  print('TEST 2: Probando login...');
  final loginResult = await testLogin(baseUrl);
  if (loginResult == null) {
    print('❌ Login falló');
    exit(1);
  }
  print('✅ Login exitoso');
  print('   Usuario: ${loginResult['user']['username']}');
  print('   Email: ${loginResult['user']['email']}');
  print('   Roles: ${loginResult['user']['roles']}');
  print('   Apps permitidas: ${loginResult['user']['allowed_apps']}\n');
  
  final accessToken = loginResult['access_token'] as String;
  
  // Test 3: Obtener información del usuario
  print('─' * 60);
  print('TEST 3: Obteniendo información del usuario...');
  final userInfo = await testGetMe(baseUrl, accessToken);
  if (userInfo == null) {
    print('❌ No se pudo obtener información del usuario');
    exit(1);
  }
  print('✅ Información del usuario obtenida');
  print('   ID: ${userInfo['id']}');
  print('   Nombre completo: ${userInfo['full_name']}');
  print('   Estado: ${userInfo['status']}\n');
  
  // Test 4: Crear reserva
  print('─' * 60);
  print('TEST 4: Creando reserva de prueba...');
  final booking = await testCreateBooking(baseUrl, accessToken);
  if (booking == null) {
    print('❌ No se pudo crear la reserva');
    exit(1);
  }
  print('✅ Reserva creada exitosamente');
  print('   ID: ${booking['id']}');
  print('   Origen: ${booking['pickup_address']}');
  print('   Destino: ${booking['destination_address']}');
  print('   Precio: \$${booking['price']}');
  print('   Estado: ${booking['status']}\n');
  
  // Test 5: Listar reservas
  print('─' * 60);
  print('TEST 5: Listando reservas del usuario...');
  final bookings = await testListBookings(baseUrl, accessToken);
  if (bookings == null) {
    print('❌ No se pudieron listar las reservas');
    exit(1);
  }
  print('✅ Reservas listadas correctamente');
  print('   Total de reservas: ${bookings.length}');
  for (var i = 0; i < bookings.length && i < 3; i++) {
    final b = bookings[i];
    print('   ${i + 1}. ${b['pickup_address']} → ${b['destination_address']}');
    print('      Estado: ${b['status']} | Precio: \$${b['price']}');
  }
  
  print('\n${'═' * 60}');
  print('🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE');
  print('═' * 60);
  print('\n✅ VaneLux está correctamente configurado con Supabase');
  print('✅ El backend está funcionando');
  print('✅ Los endpoints de autenticación funcionan');
  print('✅ Los endpoints de reservas funcionan');
  print('\n🚀 ¡Tu app está lista para usarse!\n');
}

Future<bool> testHealthCheck(String baseUrl) async {
  try {
    // Intentar conectar al endpoint raíz o health
    final url = baseUrl.replaceAll('/api/v1', '');
    final response = await http.get(
      Uri.parse('$url/health'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    
    return response.statusCode == 200 || response.statusCode == 404;
  } catch (e) {
    print('   Error: $e');
    return false;
  }
}

Future<Map<String, dynamic>?> testLogin(String baseUrl) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'admin',
        'password': 'admin123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('   Status: ${response.statusCode}');
      print('   Respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   Error: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> testGetMe(String baseUrl, String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'] ?? data;
    } else {
      print('   Status: ${response.statusCode}');
      print('   Respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   Error: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> testCreateBooking(String baseUrl, String token) async {
  try {
    final now = DateTime.now();
    final pickupTime = now.add(const Duration(hours: 2));
    
    final response = await http.post(
      Uri.parse('$baseUrl/vlx/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pickup_address': '350 5th Ave, New York, NY 10118, USA',
        'pickup_lat': 40.748817,
        'pickup_lng': -73.985428,
        'destination_address': 'Times Square, New York, NY, USA',
        'destination_lat': 40.758896,
        'destination_lng': -73.985130,
        'pickup_time': pickupTime.toIso8601String(),
        'vehicle_name': 'Luxury Sedan',
        'passengers': 2,
        'price': 45.50,
        'distance_miles': 1.2,
        'distance_text': '1.2 mi',
        'duration_text': '8 min',
        'service_type': 'standard',
        'is_scheduled': true,
        'status': 'pending',
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['booking'] ?? data;
    } else {
      print('   Status: ${response.statusCode}');
      print('   Respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   Error: $e');
    return null;
  }
}

Future<List<dynamic>?> testListBookings(String baseUrl, String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/vlx/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bookings'] ?? data['results'] ?? [];
    } else {
      print('   Status: ${response.statusCode}');
      print('   Respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    print('   Error: $e');
    return null;
  }
}
