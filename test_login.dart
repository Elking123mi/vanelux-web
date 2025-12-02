import 'dart:convert';
import 'package:http/http.dart' as http;

// Script para probar el login con el backend
void main() async {
  const String loginUrl = 'http://localhost:3000/api/v1/auth/login';
  
  final credentials = {
    'username': 'ampueroelkin@gmail.com',  // El backend usa 'username' no 'email'
    'password': 'azlanzapata143@',
  };

  try {
    print('🔐 Intentando login en $loginUrl...');
    print('👤 Username: ${credentials['username']}');
    
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials),
    );

    print('\n📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n✅ ¡Login exitoso!');
      print('🎫 Access Token: ${data['access_token']?.substring(0, 20)}...');
      print('🔄 Refresh Token: ${data['refresh_token']?.substring(0, 20)}...');
      print('👤 User ID: ${data['user']?['id']}');
      print('📧 Email: ${data['user']?['email']}');
      print('🏷️ Roles: ${data['user']?['roles']}');
      print('📱 Allowed Apps: ${data['user']?['allowed_apps']}');
    } else {
      print('\n❌ Error en login: ${response.statusCode}');
      print('Mensaje: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Error de conexión: $e');
    print('\n💡 Asegúrate de que el backend Python esté corriendo en localhost:3000');
  }
}
