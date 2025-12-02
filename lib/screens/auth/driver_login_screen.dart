import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/app_strings.dart';
import '../../widgets/custom_widgets.dart';
import '../home/driver_home_screen.dart';
import 'register_screen.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.loginDriver(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppConstants.loginSuccessful),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('${AppConstants.errorOccurred}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Logo and title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.car,
                          size: 50,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        '${AppConstants.appName} Driver',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Sign in to start driving',
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(height: 24),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppConstants.email,
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFFD4AF37),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppConstants.pleaseEnterEmail;
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return AppConstants.pleaseEnterValidEmail;
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppConstants.password,
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFD4AF37),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppConstants.pleaseEnterPassword;
                            }
                            if (value.length < 6) {
                              return AppConstants.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Sign In Button
                      VaneLuxButton(
                        text: _isLoading
                            ? AppConstants.pleaseWait
                            : AppConstants.signIn,
                        onPressed: _isLoading ? null : _login,
                        width: double.infinity,
                        height: 55,
                        backgroundColor: const Color(0xFFD4AF37),
                        textColor: const Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 30),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.dontHaveAccount,
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen(isDriver: true),
                                ),
                              );
                            },
                            child: const Text(
                              AppConstants.signUp,
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
