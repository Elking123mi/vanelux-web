import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/auth_service.dart';
import 'booking_details_screen.dart';

class LoginWebScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime? selectedDateTime;
  final String vehicleName;
  final double totalPrice;
  final double distanceMiles;
  final String duration;
  final String serviceType;

  const LoginWebScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    this.selectedDateTime,
    required this.vehicleName,
    required this.totalPrice,
    required this.distanceMiles,
    required this.duration,
    this.serviceType = 'point-to-point',
  });

  @override
  State<LoginWebScreen> createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends State<LoginWebScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _guestFirstNameController = TextEditingController();
  final _guestLastNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  bool _rememberMe = false;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // BARRA DE NAVEGACIÓN SUPERIOR
          _buildTopNavBar(),

          // INDICADOR DE PASOS
          _buildStepIndicator(),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  padding: EdgeInsets.all(isMobile ? 16 : 80),
                  child: Column(
                    children: [
                      Text(
                        'Step 3 of 5: Login or Continue as Guest',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 32,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B3254),
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please login to your account or continue as a guest to proceed with your booking',
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey),
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      ),
                      SizedBox(height: isMobile ? 24 : 48),

                      // DOS COLUMNAS EN DESKTOP, UNA COLUMNA EN MÓVIL
                      Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COLUMNA IZQUIERDA - Continue as Guest
                          if (!isMobile) Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B3254),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Email address *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _guestEmailController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'First name *',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller:
                                                  _guestFirstNameController,
                                              decoration: InputDecoration(
                                                hintText: 'First name',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Last name *',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller:
                                                  _guestLastNameController,
                                              decoration: InputDecoration(
                                                hintText: 'Last name',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Phone *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '+1',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _guestPhoneController,
                                          decoration: InputDecoration(
                                            hintText: 'Phone number',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Validar que todos los campos estén llenos
                                        if (_guestEmailController.text.trim().isEmpty ||
                                            _guestFirstNameController.text.trim().isEmpty ||
                                            _guestLastNameController.text.trim().isEmpty ||
                                            _guestPhoneController.text.trim().isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please fill in all guest information fields'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        // Validar formato de email
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(_guestEmailController.text.trim())) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter a valid email address'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        // Navegar al paso 4 (Details) CON LOS DATOS DEL GUEST
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BookingDetailsScreen(
                                                  pickupAddress:
                                                      widget.pickupAddress,
                                                  destinationAddress:
                                                      widget.destinationAddress,
                                                  pickupLat: widget.pickupLat,
                                                  pickupLng: widget.pickupLng,
                                                  destinationLat:
                                                      widget.destinationLat,
                                                  destinationLng:
                                                      widget.destinationLng,
                                                  selectedDateTime:
                                                      widget.selectedDateTime,
                                                  vehicleName:
                                                      widget.vehicleName,
                                                  totalPrice: widget.totalPrice,
                                                  distanceMiles:
                                                      widget.distanceMiles,
                                                  duration: widget.duration,
                                                  serviceType:
                                                      widget.serviceType,
                                                  guestEmail: _guestEmailController.text.trim(),
                                                  guestName: '${_guestFirstNameController.text.trim()} ${_guestLastNameController.text.trim()}',
                                                  guestPhone: '+1${_guestPhoneController.text.trim()}',
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0B3254,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'CONTINUE AS GUEST',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMobile) Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Email address *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _guestEmailController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'First name *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _guestFirstNameController,
                                  decoration: InputDecoration(
                                    hintText: 'First name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Last name *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _guestLastNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Last name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Phone *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text('+1', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _guestPhoneController,
                                        decoration: InputDecoration(
                                          hintText: 'Phone number',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Validar que todos los campos estén llenos
                                      if (_guestEmailController.text.trim().isEmpty ||
                                          _guestFirstNameController.text.trim().isEmpty ||
                                          _guestLastNameController.text.trim().isEmpty ||
                                          _guestPhoneController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please fill in all guest information fields'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Validar formato de email
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(_guestEmailController.text.trim())) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter a valid email address'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingDetailsScreen(
                                            pickupAddress: widget.pickupAddress,
                                            destinationAddress: widget.destinationAddress,
                                            pickupLat: widget.pickupLat,
                                            pickupLng: widget.pickupLng,
                                            destinationLat: widget.destinationLat,
                                            destinationLng: widget.destinationLng,
                                            selectedDateTime: widget.selectedDateTime,
                                            vehicleName: widget.vehicleName,
                                            totalPrice: widget.totalPrice,
                                            distanceMiles: widget.distanceMiles,
                                            duration: widget.duration,
                                            serviceType: widget.serviceType,
                                            guestEmail: _guestEmailController.text.trim(),
                                            guestName: '${_guestFirstNameController.text.trim()} ${_guestLastNameController.text.trim()}',
                                            guestPhone: '+1${_guestPhoneController.text.trim()}',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B3254),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'CONTINUE AS GUEST',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (!isMobile) const SizedBox(width: 40),
                          if (isMobile) const SizedBox(height: 24),

                          // COLUMNA DERECHA - Login
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _isLogin = true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: _isLogin
                                                      ? const Color(0xFF4169E1)
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Login',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _isLogin
                                                    ? const Color(0xFF4169E1)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _isLogin = false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: !_isLogin
                                                      ? const Color(0xFF4169E1)
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Create Account',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: !_isLogin
                                                    ? const Color(0xFF4169E1)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  const Text(
                                    'Login to Your Account',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B3254),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Email address *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Password *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(
                                            () => _rememberMe = value ?? false,
                                          );
                                        },
                                      ),
                                      const Text('Remember me'),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Forgot your password?',
                                          style: TextStyle(
                                            color: Color(0xFF4169E1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : () async {
                                        // Validar campos
                                        if (_emailController.text.trim().isEmpty || 
                                            _passwordController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter email and password'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => _isLoading = true);

                                        try {
                                          // Llamar al servicio de autenticación
                                          await AuthService.login(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                          );

                                          if (mounted) {
                                            // Navegar al paso 4 (Details)
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookingDetailsScreen(
                                                      pickupAddress:
                                                          widget.pickupAddress,
                                                      destinationAddress:
                                                          widget.destinationAddress,
                                                      pickupLat: widget.pickupLat,
                                                      pickupLng: widget.pickupLng,
                                                      destinationLat:
                                                          widget.destinationLat,
                                                      destinationLng:
                                                          widget.destinationLng,
                                                      selectedDateTime:
                                                          widget.selectedDateTime,
                                                      vehicleName:
                                                          widget.vehicleName,
                                                      totalPrice: widget.totalPrice,
                                                      distanceMiles:
                                                          widget.distanceMiles,
                                                      duration: widget.duration,
                                                      serviceType:
                                                          widget.serviceType,
                                                    ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          setState(() => _isLoading = false);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Login failed: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4169E1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading 
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'or',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const FaIcon(
                                      FontAwesomeIcons.google,
                                      color: Color(0xFFDB4437),
                                      size: 18,
                                    ),
                                    label: const Text('Continue with Google'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.facebook,
                                      color: Color(0xFF1877F2),
                                    ),
                                    label: const Text('Continue with Facebook'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMobile) Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isLogin = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _isLogin ? const Color(0xFF4169E1) : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Login',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _isLogin ? const Color(0xFF4169E1) : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isLogin = false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: !_isLogin ? const Color(0xFF4169E1) : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Create Account',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: !_isLogin ? const Color(0xFF4169E1) : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isLogin ? 'Login to Your Account' : 'Create Your Account',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Full Name - Solo para registro
                                if (!_isLogin) ...[
                                  const Text(
                                    'Full Name *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _fullNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your full name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                
                                const Text(
                                  'Email address *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Password *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                
                                // Phone - Solo para registro
                                if (!_isLogin) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Phone Number *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: 'e.g., 9294180058',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                // Confirm Password - Solo para registro
                                if (!_isLogin) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Confirm Password *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Confirm your password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 12),
                                
                                // Remember Me y forgot password - Solo para login
                                if (_isLogin)
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                      ),
                                      const Text('Remember me', style: TextStyle(fontSize: 14)),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(color: Color(0xFF4169E1), fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () async {
                                      // Validación diferente para login vs registro
                                      if (_isLogin) {
                                        // Validación de login
                                        if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter email and password'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                      } else {
                                        // Validación de registro
                                        if (_fullNameController.text.trim().isEmpty ||
                                            _emailController.text.trim().isEmpty ||
                                            _passwordController.text.isEmpty ||
                                            _confirmPasswordController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please fill in all fields'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        if (_passwordController.text != _confirmPasswordController.text) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Passwords do not match'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                      }
                                      
                                      setState(() => _isLoading = true);
                                      
                                      try {
                                        if (_isLogin) {
                                          // Login
                                          await AuthService.login(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                          );
                                        } else {
                                          // Registro
                                          await AuthService.register(
                                            name: _fullNameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                            phone: '', // Teléfono opcional
                                          );
                                        }
                                        
                                        if (mounted) {
                                          // Navegar al paso 4 (Details)
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookingDetailsScreen(
                                                pickupAddress: widget.pickupAddress,
                                                destinationAddress: widget.destinationAddress,
                                                pickupLat: widget.pickupLat,
                                                pickupLng: widget.pickupLng,
                                                destinationLat: widget.destinationLat,
                                                destinationLng: widget.destinationLng,
                                                selectedDateTime: widget.selectedDateTime,
                                                vehicleName: widget.vehicleName,
                                                totalPrice: widget.totalPrice,
                                                distanceMiles: widget.distanceMiles,
                                                duration: widget.duration,
                                                serviceType: widget.serviceType,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() => _isLoading = false);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${_isLogin ? 'Login' : 'Registration'} failed: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4169E1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('or', style: TextStyle(color: Colors.grey)),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const FaIcon(
                                    FontAwesomeIcons.google,
                                    color: Color(0xFFDB4437),
                                    size: 18,
                                  ),
                                  label: const Text('Continue with Google'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                                  label: const Text('Continue with Facebook'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Vehicle Selection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'VANELUX',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const Spacer(),
          _buildNavLink('HOME'),
          _buildNavLink('SERVICES'),
          _buildNavLink('FLEET'),
          _buildNavLink('ABOUT'),
          _buildNavLink('CONTACT'),
          const SizedBox(width: 32),
          const Text(
            '+1 917 599-5522',
            style: TextStyle(fontSize: 14, color: Color(0xFF0B3254)),
          ),
          const SizedBox(width: 24),
          const Text(
            'CITIES WE SERVE',
            style: TextStyle(fontSize: 14, color: Color(0xFF0B3254)),
          ),
          const SizedBox(width: 32),
          TextButton(
            onPressed: () {},
            child: const Text(
              'LOGIN',
              style: TextStyle(color: Color(0xFF0B3254)),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            child: const Text(
              'SIGNUP',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF0B3254),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Information', true),
          _buildStepLine(true),
          _buildStep(2, 'Vehicle', true),
          _buildStepLine(true),
          _buildStep(3, 'Login', true),
          _buildStepLine(false),
          _buildStep(4, 'Details', false),
          _buildStepLine(false),
          _buildStep(5, 'Payment', false),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF0B3254) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 80,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
    );
  }
}
