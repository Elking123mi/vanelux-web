import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('✅ Todos los datos de SharedPreferences han sido eliminados');
  print('Ahora puedes iniciar la app y hacer login de nuevo');
}
