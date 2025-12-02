import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🧪 Probando conectividad con VaneLux API...\n');

  // Test 1: Verificar si el servidor está disponible
  await testServerConnection();

  // Test 2: Probar endpoint de vehículos
  await testVehiclesEndpoint();

  // Test 3: Probar endpoint de registro (debe fallar con datos falsos)
  await testRegistrationEndpoint();

  // Test 4: Probar endpoint de login (debe fallar con credenciales falsas)
  await testLoginEndpoint();
}

Future<void> testServerConnection() async {
  print('1️⃣ Probando conexión al servidor...');
  try {
    final response = await http
        .get(
          Uri.parse('https://vane-lux.com'),
          headers: {'User-Agent': 'VaneLux-Mobile-Test'},
        )
        .timeout(Duration(seconds: 10));

    print('✅ Servidor respondió con código: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('   Servidor VaneLux está activo y funcionando');
    }
  } catch (e) {
    print('❌ Error conectando al servidor: $e');
  }
  print('');
}

Future<void> testVehiclesEndpoint() async {
  print('2️⃣ Probando endpoint de vehículos...');
  try {
    final response = await http
        .get(
          Uri.parse('https://vane-lux.com/api/vehicles'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(Duration(seconds: 10));

    print('   Código de respuesta: ${response.statusCode}');
    print(
      '   Cuerpo de respuesta: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Endpoint de vehículos funciona correctamente');
      print('   Número de vehículos: ${data.length}');
    } else {
      print(
        '⚠️  Endpoint de vehículos respondió con código: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('❌ Error en endpoint de vehículos: $e');
  }
  print('');
}

Future<void> testRegistrationEndpoint() async {
  print('3️⃣ Probando endpoint de registro (con datos de prueba)...');
  try {
    final response = await http
        .post(
          Uri.parse('https://vane-lux.com/api/mobile/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
            'email': 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
            'password': 'TestPassword123',
            'phone': '+1234567890',
            'fullName': 'Test User',
          }),
        )
        .timeout(Duration(seconds: 10));

    print('   Código de respuesta: ${response.statusCode}');
    print('   Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 201) {
      print('✅ Endpoint de registro funciona (usuario creado)');
    } else if (response.statusCode == 409) {
      print(
        '✅ Endpoint de registro funciona (usuario ya existe - comportamiento esperado)',
      );
    } else {
      print('⚠️  Respuesta inesperada del endpoint de registro');
    }
  } catch (e) {
    print('❌ Error en endpoint de registro: $e');
  }
  print('');
}

Future<void> testLoginEndpoint() async {
  print('4️⃣ Probando endpoint de login (con credenciales falsas)...');
  try {
    final response = await http
        .post(
          Uri.parse('https://vane-lux.com/api/mobile/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': 'fake_user@test.com',
            'password': 'fake_password',
          }),
        )
        .timeout(Duration(seconds: 10));

    print('   Código de respuesta: ${response.statusCode}');
    print('   Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 401 || response.statusCode == 404) {
      print(
        '✅ Endpoint de login funciona (credenciales inválidas - comportamiento esperado)',
      );
    } else {
      print('⚠️  Respuesta inesperada del endpoint de login');
    }
  } catch (e) {
    print('❌ Error en endpoint de login: $e');
  }
  print('');
}
