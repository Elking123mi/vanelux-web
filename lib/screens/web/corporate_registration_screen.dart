import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/web_url_sync.dart';

class CorporateRegistrationScreen extends StatefulWidget {
  const CorporateRegistrationScreen({super.key});

  @override
  State<CorporateRegistrationScreen> createState() =>
      _CorporateRegistrationScreenState();
}

class _CorporateRegistrationScreenState
    extends State<CorporateRegistrationScreen> {
  static const Color _brandBlue = Color(0xFF0B3254);
  static const Color _brandGold = Color(0xFFD4AF37);

  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companySizeController = TextEditingController();
  final _monthlyRidesController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _servicesNeededController = TextEditingController();
  final _notesController = TextEditingController();

  User? _currentUser;
  bool _isSubmitting = false;
  bool _isCorporateVerified = false;

  @override
  void initState() {
    super.initState();
    syncWebPath('/corporate/register');
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactNameController.dispose();
    _jobTitleController.dispose();
    _businessEmailController.dispose();
    _phoneController.dispose();
    _companySizeController.dispose();
    _monthlyRidesController.dispose();
    _billingAddressController.dispose();
    _servicesNeededController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (!mounted || user == null) return;

      final corporateVerified =
          user.roles.contains('corporate') ||
          user.allowedApps.contains('vanelux_corporate');

      setState(() {
        _currentUser = user;
        _isCorporateVerified = corporateVerified;
      });

      if (_contactNameController.text.trim().isEmpty) {
        _contactNameController.text = user.name;
      }
      if (_businessEmailController.text.trim().isEmpty) {
        _businessEmailController.text = user.email;
      }
      if (_phoneController.text.trim().isEmpty) {
        _phoneController.text = user.phone;
      }
    } catch (_) {
      // Non-blocking: user can still complete manually.
    }
  }

  Future<void> _submitCorporateApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final businessEmail = _businessEmailController.text.trim();
    if (!emailRegex.hasMatch(businessEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid business email.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      'company_name': _companyNameController.text.trim(),
      'contact_name': _contactNameController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'business_email': businessEmail,
      'contact_phone': _phoneController.text.trim(),
      'company_size': _companySizeController.text.trim(),
      'monthly_rides_estimate':
          int.tryParse(_monthlyRidesController.text.trim()),
      'billing_address': _billingAddressController.text.trim(),
      'preferred_services': _servicesNeededController.text.trim(),
      'additional_notes': _notesController.text.trim(),
      'submitted_by_user_email': _currentUser?.email,
      'submitted_by_user_name': _currentUser?.name,
      'is_verified_corporate_user': _isCorporateVerified,
    };

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://web-production-700fe.up.railway.app/api/v1/vlx/corporate/apply',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _companyNameController.clear();
        _jobTitleController.clear();
        _companySizeController.clear();
        _monthlyRidesController.clear();
        _billingAddressController.clear();
        _servicesNeededController.clear();
        _notesController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Corporate application sent successfully. Our team will contact you at infovanelux@vane-lux.com.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to submit right now (code ${response.statusCode}). Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to submit right now. Please try again. ($e)'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 980;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _brandBlue,
        elevation: 1,
        title: const Text(
          'Corporate Account Request',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(isCompact),
            if (_isCorporateVerified)
              Container(
                margin: EdgeInsets.fromLTRB(isCompact ? 16 : 56, 20, isCompact ? 16 : 56, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF22C55E)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Color(0xFF166534)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your account is already verified as Corporate. You can still submit this form for new account requirements.',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 56,
                vertical: 20,
              ),
              padding: EdgeInsets.all(isCompact ? 18 : 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormField(
                      label: 'Company Name',
                      controller: _companyNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                          ? 'Company name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildRowFields(
                      isCompact: isCompact,
                      left: _buildFormField(
                        label: 'Contact Full Name',
                        controller: _contactNameController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                            ? 'Contact name is required'
                            : null,
                      ),
                      right: _buildFormField(
                        label: 'Job Title',
                        controller: _jobTitleController,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildRowFields(
                      isCompact: isCompact,
                      left: _buildFormField(
                        label: 'Business Email',
                        controller: _businessEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                            ? 'Business email is required'
                            : null,
                      ),
                      right: _buildFormField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                            ? 'Phone number is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildRowFields(
                      isCompact: isCompact,
                      left: _buildFormField(
                        label: 'Company Size',
                        controller: _companySizeController,
                        hintText: 'e.g. 50 employees',
                      ),
                      right: _buildFormField(
                        label: 'Estimated Monthly Rides',
                        controller: _monthlyRidesController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g. 35',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFormField(
                      label: 'Billing Address',
                      controller: _billingAddressController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    _buildFormField(
                      label: 'Preferred Services',
                      controller: _servicesNeededController,
                      maxLines: 3,
                      hintText:
                          'Airport transfers, executive meetings, events, hourly, etc.',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                          ? 'Please describe required services'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildFormField(
                      label: 'Additional Notes',
                      controller: _notesController,
                      maxLines: 4,
                      hintText:
                          'Include dispatch needs, billing flow, VIP requirements, or any issue to solve.',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _submitCorporateApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          foregroundColor: _brandGold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isSubmitting
                              ? 'SUBMITTING...'
                              : 'SUBMIT CORPORATE REQUEST',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
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

  Widget _buildHero(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 56,
        vertical: isCompact ? 24 : 34,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B3254), Color(0xFF164B73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_heroText(isCompact), const SizedBox(height: 16), _heroImage()],
            )
          : Row(
              children: [
                Expanded(child: _heroText(isCompact)),
                const SizedBox(width: 24),
                SizedBox(width: 360, child: _heroImage()),
              ],
            ),
    );
  }

  Widget _heroText(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corporate Accounts for Teams That Need Precision and Reliability',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 26 : 38,
            fontWeight: FontWeight.w800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Submit this request from the Corporate service page and our team will review and verify your account manually. Once approved, your user will be marked as corporate.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isCompact ? 15 : 17,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _heroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/images/corporate service.jpg',
        height: 220,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRowFields({
    required bool isCompact,
    required Widget left,
    required Widget right,
  }) {
    if (isCompact) {
      return Column(
        children: [left, const SizedBox(height: 14), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _brandBlue,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brandGold, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
