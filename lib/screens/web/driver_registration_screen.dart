import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Personal Information
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  DateTime? _licenseExpiryDate;
  final _experienceController = TextEditingController();
  final _languagesController = TextEditingController();
  bool _hasBackgroundCheck = false;

  // Vehicle Information
  String _selectedVehicleType = 'Sedan';
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _licensePlateController = TextEditingController();

  // Insurance Information
  final _insuranceCompanyController = TextEditingController();
  final _insurancePolicyController = TextEditingController();
  DateTime? _insuranceExpiryDate;

  // Additional Notes
  final _notesController = TextEditingController();

  final List<String> _vehicleTypes = ['Sedan', 'SUV', 'Van', 'Luxury', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _driverLicenseController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehicleColorController.dispose();
    _licensePlateController.dispose();
    _insuranceCompanyController.dispose();
    _insurancePolicyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isLicenseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B3254),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B3254),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isLicenseDate) {
          _licenseExpiryDate = picked;
        } else {
          _insuranceExpiryDate = picked;
        }
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_licenseExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor selecciona la fecha de expiración de la licencia',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_insuranceExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor selecciona la fecha de expiración del seguro',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://web-production-700fe.up.railway.app/api/v1/vlx/drivers/apply',
      );

      final applicationData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'driver_license': _driverLicenseController.text.trim(),
        'license_expiry_date': DateFormat(
          'yyyy-MM-dd',
        ).format(_licenseExpiryDate!),
        'vehicle_type': _selectedVehicleType,
        'vehicle_make': _vehicleMakeController.text.trim(),
        'vehicle_model': _vehicleModelController.text.trim(),
        'vehicle_year': int.parse(_vehicleYearController.text.trim()),
        'vehicle_color': _vehicleColorController.text.trim(),
        'license_plate': _licensePlateController.text.trim(),
        'insurance_company': _insuranceCompanyController.text.trim(),
        'insurance_policy_number': _insurancePolicyController.text.trim(),
        'insurance_expiry_date': DateFormat(
          'yyyy-MM-dd',
        ).format(_insuranceExpiryDate!),
        'years_of_experience': int.parse(_experienceController.text.trim()),
        'languages': _languagesController.text.trim(),
        'has_background_check': _hasBackgroundCheck,
        'additional_notes': _notesController.text.trim(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(applicationData),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSuccessDialog(data['application_id']);
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['detail'] ?? 'Error al enviar la aplicación');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error de conexión. Por favor intenta de nuevo.');
    }
  }

  void _showSuccessDialog(String applicationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('¡Aplicación Enviada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu aplicación ha sido enviada exitosamente.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ID de Aplicación:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(applicationId, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nuestro equipo revisará tu aplicación y te contactaremos pronto.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B3254),
              foregroundColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0B3254), Color(0xFF1a4a6f)],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_taxi,
                    size: 64,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Únete a Vanelux',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Forma parte del equipo de conductores de lujo más exclusivo',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionTitle('📋 Información Personal'),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Nombre Completo',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().length < 10) {
                                return 'Teléfono inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _driverLicenseController,
                            label: 'Número de Licencia',
                            icon: Icons.badge,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDateField(
                            label: 'Licencia Expira',
                            date: _licenseExpiryDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _experienceController,
                            label: 'Años de Experiencia',
                            icon: Icons.work,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final years = int.tryParse(value);
                              if (years == null || years < 0) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _languagesController,
                            label: 'Idiomas (separados por comas)',
                            icon: Icons.language,
                            hintText: 'Español, Inglés, Francés',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      value: _hasBackgroundCheck,
                      onChanged: (value) {
                        setState(() {
                          _hasBackgroundCheck = value ?? false;
                        });
                      },
                      title: const Text('Tengo Background Check completado'),
                      activeColor: const Color(0xFF0B3254),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: const Color(0xFFF8F9FA),
                    ),

                    const SizedBox(height: 40),

                    // Vehicle Information Section
                    _buildSectionTitle('🚘 Información del Vehículo'),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Vehículo',
                        prefixIcon: const Icon(Icons.directions_car),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _vehicleMakeController,
                            label: 'Marca',
                            icon: Icons.business,
                            hintText: 'Mercedes-Benz, BMW, etc.',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _vehicleModelController,
                            label: 'Modelo',
                            icon: Icons.car_rental,
                            hintText: 'S-Class, Serie 7, etc.',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _vehicleYearController,
                            label: 'Año',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final year = int.tryParse(value);
                              if (year == null ||
                                  year < 2015 ||
                                  year > DateTime.now().year + 1) {
                                return 'Año entre 2015 y ${DateTime.now().year + 1}';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _vehicleColorController,
                            label: 'Color',
                            icon: Icons.palette,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _licensePlateController,
                            label: 'Placa',
                            icon: Icons.pin,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Insurance Information Section
                    _buildSectionTitle('🛡️ Información del Seguro'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _insuranceCompanyController,
                            label: 'Compañía de Seguro',
                            icon: Icons.shield,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _insurancePolicyController,
                            label: 'Número de Póliza',
                            icon: Icons.confirmation_number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDateField(
                      label: 'Seguro Expira',
                      date: _insuranceExpiryDate,
                      onTap: () => _selectDate(context, false),
                    ),

                    const SizedBox(height: 40),

                    // Additional Notes Section
                    _buildSectionTitle('📝 Notas Adicionales (Opcional)'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Cuéntanos sobre tu experiencia, disponibilidad, especialidades, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B3254),
                          foregroundColor: const Color(0xFFD4AF37),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFFD4AF37),
                              )
                            : const Text(
                                'Enviar Aplicación',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF5),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF0B3254),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '¿Qué pasa después?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3254),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '1. Recibirás un ID de aplicación al enviar el formulario\n'
                            '2. Nuestro equipo revisará tu aplicación en 24-48 horas\n'
                            '3. Te contactaremos por email o teléfono para próximos pasos\n'
                            '4. Programaremos una entrevista y revisión del vehículo\n'
                            '5. ¡Bienvenido al equipo de Vanelux!',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF0B3254),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0B3254),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
        ),
        child: Text(
          date != null
              ? DateFormat('yyyy-MM-dd').format(date)
              : 'Seleccionar fecha',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
