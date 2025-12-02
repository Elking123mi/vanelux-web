import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/app_strings.dart';
import '../home/home_screen.dart';
import 'driver_login_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConstants.loginSuccessful),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1C36), Color(0xFF0F2D52), Color(0xFF13386B)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth >= 700;
              final bool isDesktop = constraints.maxWidth >= 1024;

              final double maxFormWidth =
                  isDesktop ? 520 : (isTablet ? 460 : double.infinity);
              final EdgeInsets scrollPadding = EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? 80
                    : isTablet
                        ? 48
                        : 24,
                vertical: isDesktop ? 56 : isTablet ? 48 : 24,
              );
              final EdgeInsets panelPadding = EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 0,
                vertical: isTablet ? 36 : 0,
              );
              final BoxDecoration? panelDecoration = isTablet
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 36,
                          offset: const Offset(0, 24),
                        ),
                      ],
                    )
                  : null;

              final double topSpacing = isTablet ? 36 : 48;
              final double betweenSections = isTablet ? 28 : 48;
              final double fieldSpacing = isTablet ? 20 : 24;
              final double blockSpacing = isTablet ? 28 : 36;

              return SingleChildScrollView(
                padding: scrollPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxFormWidth),
                    child: Container(
                      padding: panelPadding,
                      decoration: panelDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: topSpacing),
                          Column(
                            children: [
                              Container(
                                width: isTablet ? 120 : 110,
                                height: isTablet ? 120 : 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.car,
                                  size: 48,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'VaneLux',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                  letterSpacing: 2,
                                ),
                              ),
                              const Text(
                                'Luxury Transportation',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: betweenSections),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFFFD700),
                                      width: 2,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      hintText: AppConstants.email,
                                      hintStyle: TextStyle(color: Colors.black45),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFFFFD700),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(20),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppConstants.pleaseEnterEmail;
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return AppConstants.pleaseEnterValidEmail;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: fieldSpacing),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFFFD700),
                                      width: 2,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: AppConstants.password,
                                      hintStyle:
                                          const TextStyle(color: Colors.black45),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFFFFD700),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.black54,
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
                                      if (value.length <
                                          AppConstants.minPasswordLength) {
                                        return AppConstants.passwordTooShort;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: blockSpacing),
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700)
                                            .withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Color(0xFF1A1A2E),
                                          )
                                        : const Text(
                                            AppConstants.signIn,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: fieldSpacing),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Implement password recovery
                                  },
                                  child: const Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: blockSpacing),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: fieldSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildSocialButton(
                                icon: FontAwesomeIcons.google,
                                onPressed: () {
                                  // TODO: Google login
                                },
                              ),
                              _buildSocialButton(
                                icon: FontAwesomeIcons.facebook,
                                onPressed: () {
                                  // TODO: Facebook login
                                },
                              ),
                              _buildSocialButton(
                                icon: FontAwesomeIcons.apple,
                                onPressed: () {
                                  // TODO: Apple login
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: blockSpacing),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              ),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DriverLoginScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                FontAwesomeIcons.userTie,
                                color: Color(0xFFD4AF37),
                                size: 18,
                              ),
                              label: const Text(
                                AppConstants.driverSignIn,
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: fieldSpacing),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 8,
                            children: [
                              Text(
                                AppConstants.dontHaveAccount,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  AppConstants.signUp,
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 16 : 32),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: FaIcon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
