import '../models/user.dart';

/// Usuarios de demostración para pruebas locales
/// Estos usuarios se pueden usar cuando el backend no está disponible
class DemoUsers {
  // Usuario: Elkin Jeremias (VALIDADO EN RAILWAY ✅)
  static const String elkinEmail = 'elkinjeremias123@gmail.com';
  static const String elkinPassword = 'azlanzapata143@';
  
  static User getElkinUser() {
    return User(
      id: 'demo-elkin-001',
      name: 'Elkin Jeremias',
      firstName: 'Elkin',
      lastName: 'Jeremias',
      email: elkinEmail,
      phone: '+1234567890',
      profileImageUrl: null,
      createdAt: DateTime.now(),
      roles: ['passenger', 'client'],
      allowedApps: ['conexaship', 'vanelux'], // ✅ Tiene acceso a VaneLux en Railway
    );
  }

  /// Verifica si las credenciales coinciden con el usuario de demo
  static bool validateCredentials(String email, String password) {
    return email.toLowerCase() == elkinEmail.toLowerCase() && 
           password == elkinPassword;
  }

  /// Obtiene el usuario de demo si las credenciales son válidas
  static User? getUserIfValid(String email, String password) {
    if (validateCredentials(email, password)) {
      return getElkinUser();
    }
    return null;
  }
}
