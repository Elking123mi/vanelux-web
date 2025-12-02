import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Verificando usuario Edgar con autenticación...\n');
  
  try {
    // Primero hacer login para obtener token
    print('1️⃣ Obteniendo token de autenticación...');
    final loginResponse = await http.post(
      Uri.parse('http://localhost:3000/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'admin@example.com',  // Usuario admin de la BD
        'password': 'admin123'
      }),
    ).timeout(Duration(seconds: 10));
    
    if (loginResponse.statusCode != 200) {
      print('❌ Error en login: ${loginResponse.statusCode}');
      print('   ${loginResponse.body}');
      return;
    }
    
    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['access_token'];
    print('✅ Token obtenido\n');
    
    // Ahora verificar Edgar con el token
    print('2️⃣ Buscando usuario Edgar...\n');
    
    // Verificar con email
    await checkUserWithToken('edgar@example.com', token);
    
    // Verificar con username
    await checkUserWithToken('edgar', token);
    
    // Listar todos los usuarios
    await listAllUsersWithToken(token);
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> checkUserWithToken(String identifier, String token) async {
  print('📧 Buscando: $identifier');
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/v1/users/check/$identifier'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['exists'] == true) {
        final user = data['user'];
        print('✅ Usuario encontrado:');
        print('   ID: ${user['id']}');
        print('   Username: ${user['username']}');
        print('   Email: ${user['email']}');
        print('   Roles: ${user['roles']}');
        print('   Apps: ${user['allowed_apps']}');
        print('   Estado: ${user['status']}\n');
      } else {
        print('❌ No existe: ${data['message']}\n');
      }
    } else if (response.statusCode == 404) {
      print('❌ No encontrado (404)\n');
    } else {
      print('⚠️  Error ${response.statusCode}: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Error de conexión: $e\n');
  }
}

Future<void> listAllUsersWithToken(String token) async {
  print('📋 Listando todos los usuarios del sistema...\n');
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/v1/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['results'] ?? data['users'] ?? data;
      
      print('✅ Total de usuarios: ${users.length}\n');
      for (var user in users) {
        print('  • ${user['username']} (${user['email']}) - ${user['roles']}');
      }
    } else {
      print('⚠️  Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('❌ Error de conexión: $e');
  }
}
