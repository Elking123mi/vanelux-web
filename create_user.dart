import 'dart:convert';
import 'package:http/http.dart' as http;

// Script para crear el usuario Elkin Chila en el backend
void main() async {
  const String apiUrl = 'http://localhost:3000/api/v1/auth/register';
  
  final userData = {
    'username': 'ampueroelkin@gmail.com',
    'email': 'ampueroelkin@gmail.com',
    'password': 'azlanzapata143@',
    'name': 'Elkin Chila',
    'phone': '+1234567890', // Puedes cambiar esto
    'roles': ['passenger'], // Rol de pasajero
    'allowed_apps': ['vanelux'], // Acceso a la app VaneLux
  };

  try {
    print('🚀 Intentando crear usuario en $apiUrl...');
    print('📧 Email: ${userData['email']}');
    print('👤 Nombre: ${userData['name']}');
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    print('\n📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('\n✅ ¡Usuario creado exitosamente!');
      final data = jsonDecode(response.body);
      print('🎉 Usuario ID: ${data['user']?['id'] ?? 'N/A'}');
      print('📧 Email: ${data['user']?['email'] ?? 'N/A'}');
    } else {
      print('\n❌ Error al crear usuario: ${response.statusCode}');
      print('Mensaje: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Error de conexión: $e');
    print('\n💡 Asegúrate de que el backend Python esté corriendo en localhost:3000');
    print('   Ejecuta: python -m uvicorn main:app --reload --port 3000');
  }
}
