import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../services/passenger_service.dart';

/// Ejemplos de uso de los servicios de VaneLux

// ============================================================================
// EJEMPLO 1: Login de Pasajero
// ============================================================================
Future<void> ejemploLoginPasajero() async {
  try {
    // Login
    final user = await AuthService.login(
      'pasajero@vanelux.com',
      'MiPassword123!',
    );

    print('✅ Login exitoso: ${user.name}');
    print('Roles: ${user.roles}');
    print('Apps permitidas: ${user.allowedApps}');

    // Verificar si es pasajero
    final esPasajero = await PassengerService.isPassenger();
    if (esPasajero) {
      print('✅ Usuario es pasajero');

      // Obtener perfil de pasajero
      final perfil = await PassengerService.getCurrentPassengerProfile();
      print('Perfil: $perfil');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 2: Login de Conductor
// ============================================================================
Future<void> ejemploLoginConductor() async {
  try {
    // Login
    final user = await AuthService.loginDriver(
      'conductor@vanelux.com',
      'MiPassword123!',
    );

    print('✅ Login exitoso: ${user.name}');

    // Verificar si es conductor
    final esConductor = await DriverService.isDriver();
    if (esConductor) {
      print('✅ Usuario es conductor');

      // Obtener perfil de conductor
      final perfil = await DriverService.getCurrentDriverProfile();
      print('Conductor: ${perfil?.name}');
      print('Licencia: ${perfil?.licenseNumber}');

      // Actualizar disponibilidad
      await DriverService.updateAvailability(true);
      print('✅ Disponibilidad actualizada');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 3: Registro de Pasajero
// ============================================================================
Future<void> ejemploRegistroPasajero() async {
  try {
    final user = await AuthService.register(
      name: 'Juan Pérez',
      email: 'juan.perez@example.com',
      password: 'SecurePass123!',
      phone: '+57 300 1234567',
    );

    print('✅ Pasajero registrado: ${user.name}');
    print('Email: ${user.email}');
    print('Apps permitidas: ${user.allowedApps}');

    // El usuario ya está logueado automáticamente
    final yaEstaAutenticado = await AuthService.isAuthenticated();
    print('Autenticado: $yaEstaAutenticado');
  } catch (e) {
    print('❌ Error al registrar: $e');
  }
}

// ============================================================================
// EJEMPLO 4: Registro de Conductor
// ============================================================================
Future<void> ejemploRegistroConductor() async {
  try {
    final driver = await AuthService.registerDriver(
      name: 'María López',
      email: 'maria.lopez@example.com',
      password: 'SecurePass123!',
      phone: '+57 310 7654321',
      licenseNumber: 'D-123456789',
      vehicleMake: 'Mercedes-Benz',
      vehicleModel: 'S-Class',
      vehicleYear: 2023,
    );

    print('✅ Conductor registrado: ${driver.name}');
    print('Licencia: ${driver.licenseNumber}');
    print('ID Vehículo: ${driver.vehicleId}');
  } catch (e) {
    print('❌ Error al registrar: $e');
  }
}

// ============================================================================
// EJEMPLO 5: Actualizar Perfil de Pasajero
// ============================================================================
Future<void> ejemploActualizarPasajero() async {
  try {
    // Obtener perfil actual
    final perfil = await PassengerService.getCurrentPassengerProfile();
    final passengerId = perfil['id'];

    // Actualizar
    await PassengerService.updatePassengerProfile(
      passengerId: passengerId,
      phone: '+57 320 9876543',
      address: 'Calle 123 #45-67, Bogotá',
      preferences: {
        'vehicle_type': 'luxury',
        'music': 'jazz',
        'temperature': 'cool',
      },
    );

    print('✅ Perfil de pasajero actualizado');
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 6: Actualizar Perfil de Conductor
// ============================================================================
Future<void> ejemploActualizarConductor() async {
  try {
    // Obtener perfil actual
    final driver = await DriverService.getCurrentDriverProfile();
    if (driver == null) {
      print('❌ No se encontró perfil de conductor');
      return;
    }

    // Actualizar
    await DriverService.updateDriverProfile(
      driverId: int.parse(driver.id),
      phone: '+57 310 1112233',
      vehicleColor: 'Negro',
      isAvailable: true,
    );

    print('✅ Perfil de conductor actualizado');
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 7: Cambiar Disponibilidad del Conductor
// ============================================================================
Future<void> ejemploCambiarDisponibilidad(bool disponible) async {
  try {
    await DriverService.updateAvailability(disponible);
    print('✅ Disponibilidad cambiada a: ${disponible ? "Disponible" : "No disponible"}');
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 8: Obtener Conductores Disponibles (Admin)
// ============================================================================
Future<void> ejemploObtenerConductoresDisponibles() async {
  try {
    final conductores = await DriverService.getAvailableDrivers();
    print('✅ Conductores disponibles: ${conductores.length}');

    for (final conductor in conductores) {
      print('- ${conductor['full_name']} (${conductor['vehicle_make']} ${conductor['vehicle_model']})');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 9: Logout
// ============================================================================
Future<void> ejemploLogout() async {
  try {
    await AuthService.logout();
    print('✅ Sesión cerrada correctamente');

    // Verificar que ya no está autenticado
    final estaAutenticado = await AuthService.isAuthenticated();
    print('Autenticado: $estaAutenticado'); // false
  } catch (e) {
    print('❌ Error al cerrar sesión: $e');
  }
}

// ============================================================================
// EJEMPLO 10: Widget de Login Completo
// ============================================================================
class EjemploLoginWidget extends StatefulWidget {
  const EjemploLoginWidget({super.key});

  @override
  State<EjemploLoginWidget> createState() => _EjemploLoginWidgetState();
}

class _EjemploLoginWidgetState extends State<EjemploLoginWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // Login
      final user = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Validar allowed_apps
      if (!user.allowedApps.contains('vanelux')) {
        await AuthService.logout();
        throw Exception('No tienes acceso a VaneLux');
      }

      // Determinar tipo de usuario
      final esConductor = user.allowedApps.contains('vanelux_driver');

      // Navegar según tipo
      if (esConductor) {
        // Navigator.pushReplacementNamed(context, '/driver-home');
        print('→ Navegar a DriverHomeScreen');
      } else {
        // Navigator.pushReplacementNamed(context, '/home');
        print('→ Navegar a HomeScreen');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${user.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VaneLux Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Iniciar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
