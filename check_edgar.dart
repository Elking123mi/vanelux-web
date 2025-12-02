import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Verificando si Edgar existe en el backend...\n');
  
  try {
    // Verificar con email
    await checkUser('edgar@example.com');
    
    // Verificar con username
    await checkUser('edgar');
    
    // Listar todos los usuarios
    await listAllUsers();
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> checkUser(String identifier) async {
  print('📧 Buscando: $identifier');
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/v1/users/check/$identifier'),
      headers: {'Content-Type': 'application/json'},
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

Future<void> listAllUsers() async {
  print('📋 Listando todos los usuarios del sistema...\n');
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/v1/users'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['results'] ?? data['users'] ?? [];
      
      print('Total de usuarios: ${users.length}\n');
      
      for (var user in users) {
        print('👤 ${user['username']} (${user['email']})');
        print('   Roles: ${user['roles']}');
        print('   Apps: ${user['allowed_apps']}\n');
      }
    } else if (response.statusCode == 401) {
      print('⚠️  Requiere autenticación. Endpoint protegido.\n');
    } else {
      print('⚠️  Error ${response.statusCode}: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }
}
