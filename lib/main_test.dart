import 'package:flutter/material.dart';
import 'constants/vanelux_colors.dart';
import 'services/vanelux_api_service.dart';

void main() {
  runApp(const VaneLuxTestApp());
}

class VaneLuxTestApp extends StatelessWidget {
  const VaneLuxTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaneLux Test',
      theme: ThemeData(
        primaryColor: VaneLuxColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: VaneLuxColors.primaryBlue),
      ),
      home: const TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _status = 'Iniciando tests...';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
      _status = message;
    });
    print(message);
  }

  Future<void> _runTests() async {
    _addLog('🧪 Iniciando tests de conectividad...');

    // Test 1: Conexión básica
    try {
      _addLog('1️⃣ Probando conexión básica...');
      final vehicles = await VaneLuxApiService.getVehicles();
      _addLog('✅ Vehículos obtenidos: ${vehicles.length}');

      if (vehicles.isNotEmpty) {
        _addLog('📋 Primer vehículo: ${vehicles[0]['name'] ?? 'Sin nombre'}');
      }
    } catch (e) {
      _addLog('❌ Error obteniendo vehículos: $e');
    }

    // Test 2: Verificar login con credenciales reales
    try {
      _addLog('2️⃣ Probando login con email real...');
      _addLog('   Intenta hacer login con el email que usaste en la webapp');
    } catch (e) {
      _addLog('❌ Error en login: $e');
    }

    // Test 3: Estado de autenticación
    try {
      _addLog('3️⃣ Verificando estado de autenticación...');
      final isLoggedIn = await VaneLuxApiService.isLoggedIn();
      _addLog(
        '   Estado de login: ${isLoggedIn ? 'Autenticado' : 'No autenticado'}',
      );

      if (isLoggedIn) {
        final userType = await VaneLuxApiService.getUserType();
        _addLog('   Tipo de usuario: $userType');
      }
    } catch (e) {
      _addLog('❌ Error verificando autenticación: $e');
    }

    _addLog('🏁 Tests completados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VaneLux API Test'),
        backgroundColor: VaneLuxColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: VaneLuxColors.primaryBlue),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Logs de Debug:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs
                        .map(
                          (log) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                        _status = 'Reiniciando tests...';
                      });
                      _runTests();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaneLuxColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Repetir Tests'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimpleLoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaneLuxColors.gold,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Test Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = '❌ Por favor, ingresa email y contraseña';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '🔄 Probando login...';
    });

    try {
      final response = await VaneLuxApiService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _message =
            '✅ Login exitoso!\nUsuario: ${response['user']?['username'] ?? 'Unknown'}';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error de login: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Login'),
        backgroundColor: VaneLuxColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: VaneLuxColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Probar Login'),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _message.isEmpty
                    ? 'Ingresa las credenciales que usaste en la webapp de VaneLux'
                    : _message,
                style: TextStyle(
                  fontSize: 14,
                  color: _message.startsWith('✅')
                      ? Colors.green
                      : _message.startsWith('❌')
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
