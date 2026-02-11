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
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_licenseExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the license expiration date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_insuranceExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the insurance expiration date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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

      // Send email notification via FormSubmit
      bool emailSent = false;
      try {
        final emailUrl = Uri.parse(
          'https://formsubmit.co/ajax/elkinchila2006@gmail.com',
        );
        final emailBody = {
          '_subject': 'New Driver Application - Vanelux',
          '_template': 'table',
          'Full Name': applicationData['full_name'],
          'Email': applicationData['email'],
          'Phone': applicationData['phone'],
          'Driver License': applicationData['driver_license'],
          'License Expiry': applicationData['license_expiry_date'],
          'Vehicle Type': applicationData['vehicle_type'],
          'Vehicle':
              '${applicationData['vehicle_year']} ${applicationData['vehicle_make']} ${applicationData['vehicle_model']}',
          'Vehicle Color': applicationData['vehicle_color'],
          'License Plate': applicationData['license_plate'],
          'Insurance Company': applicationData['insurance_company'],
          'Policy Number': applicationData['insurance_policy_number'],
          'Insurance Expiry': applicationData['insurance_expiry_date'],
          'Years of Experience': applicationData['years_of_experience']
              .toString(),
          'Languages': applicationData['languages'],
          'Background Check': applicationData['has_background_check'] == true
              ? 'Yes'
              : 'No',
          'Additional Notes': applicationData['additional_notes'],
        };
        final emailResponse = await http.post(
          emailUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(emailBody),
        );
        emailSent = emailResponse.statusCode == 200;
      } catch (_) {
        // Email sending failed, continue with API
      }

      // Also try backend API for database storage
      bool apiSuccess = false;
      String applicationId = '';
      try {
        final apiUrl = Uri.parse(
          'https://web-production-700fe.up.railway.app/api/v1/vlx/drivers/apply',
        );
        final response = await http.post(
          apiUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...applicationData,
            'notification_email': 'elkinchila2006@gmail.com',
          }),
        );
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          applicationId = data['application_id'] ?? '';
          apiSuccess = true;
        }
      } catch (_) {
        // API call failed, continue
      }

      setState(() {
        _isLoading = false;
      });

      if (emailSent || apiSuccess) {
        _showSuccessDialog(
          applicationId.isNotEmpty ? applicationId : 'SUBMITTED',
        );
      } else {
        _showErrorDialog('Error submitting application. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Connection error. Please try again.');
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
            Text('Application Submitted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your application has been submitted successfully.',
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
                    'Application ID:',
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
              'Our team will review your application and contact you soon.',
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
            child: const Text('Back to Home'),
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
            child: const Text('Close'),
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
                    'Join Vanelux',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join the most exclusive luxury driver team',
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
                    _buildSectionTitle('📋 Personal Information'),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
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
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().length < 10) {
                                return 'Invalid phone number';
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
                            label: 'License Number',
                            icon: Icons.badge,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDateField(
                            label: 'License Expiration',
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
                            label: 'Years of Experience',
                            icon: Icons.work,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final years = int.tryParse(value);
                              if (years == null || years < 0) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _languagesController,
                            label: 'Languages (comma separated)',
                            icon: Icons.language,
                            hintText: 'English, Spanish, French',
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
                      title: const Text('I have a completed Background Check'),
                      activeColor: const Color(0xFF0B3254),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: const Color(0xFFF8F9FA),
                    ),

                    const SizedBox(height: 40),

                    // Vehicle Information Section
                    _buildSectionTitle('🚘 Vehicle Information'),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Type',
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
                            label: 'Make',
                            icon: Icons.business,
                            hintText: 'Mercedes-Benz, BMW, etc.',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _vehicleModelController,
                            label: 'Model',
                            icon: Icons.car_rental,
                            hintText: 'S-Class, 7 Series, etc.',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
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
                            label: 'Year',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final year = int.tryParse(value);
                              if (year == null ||
                                  year < 2015 ||
                                  year > DateTime.now().year + 1) {
                                return 'Year between 2015 and ${DateTime.now().year + 1}';
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
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _licensePlateController,
                            label: 'License Plate',
                            icon: Icons.pin,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Insurance Information Section
                    _buildSectionTitle('🛡️ Insurance Information'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _insuranceCompanyController,
                            label: 'Insurance Company',
                            icon: Icons.shield,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _insurancePolicyController,
                            label: 'Policy Number',
                            icon: Icons.confirmation_number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDateField(
                      label: 'Insurance Expiration',
                      date: _insuranceExpiryDate,
                      onTap: () => _selectDate(context, false),
                    ),

                    const SizedBox(height: 40),

                    // Additional Notes Section
                    _buildSectionTitle('📝 Additional Notes (Optional)'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about your experience, availability, specialties, etc.',
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
                                'Submit Application',
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
                                'What happens next?',
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
                            '1. You will receive an Application ID upon submission\n'
                            '2. Our team will review your application within 24-48 hours\n'
                            '3. We will contact you by email or phone for next steps\n'
                            '4. We will schedule an interview and vehicle inspection\n'
                            '5. Welcome to the Vanelux team!',
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
          date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select date',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
