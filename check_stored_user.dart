import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('user_data');
  
  if (userData != null) {
    print('📦 Datos guardados en SharedPreferences:');
    print(userData);
    print('\n📋 Datos parseados:');
    final json = jsonDecode(userData);
    print('- id: ${json['id']}');
    print('- email: ${json['email']}');
    print('- name: ${json['name']}');
    print('- first_name: ${json['first_name']}');
    print('- last_name: ${json['last_name']}');
  } else {
    print('❌ No hay usuario guardado');
  }
}
