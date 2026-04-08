import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../utils/web_url_sync.dart';

class CorporateSetPasswordScreen extends StatefulWidget {
  final String token;

  const CorporateSetPasswordScreen({super.key, required this.token});

  @override
  State<CorporateSetPasswordScreen> createState() =>
      _CorporateSetPasswordScreenState();
}

class _CorporateSetPasswordScreenState extends State<CorporateSetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _success = false;
  String? _error;

  String _contactName = '';
  String _email = '';
  String _company = '';

  @override
  void initState() {
    super.initState();
    syncWebPath(
      '/set-password',
      replace: true,
      queryParameters: {
        'token': widget.token,
        'account': 'corporate',
      },
    );
    _decodeTokenPreview();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _decodeTokenPreview() {
    try {
      final parts = widget.token.split('.');
      if (parts.length != 3) return;
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      setState(() {
        _contactName = (decoded['contact_name'] ?? '').toString();
        _email = (decoded['email'] ?? '').toString();
        _company = (decoded['company_name'] ?? '').toString();
      });
    } catch (_) {
      // Keep silent: this preview is optional UI information.
    }
  }

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.centralApiBaseUrl}/auth/corporate-set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': widget.token,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        setState(() {
          _success = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = (data['detail'] ?? 'Could not activate account.').toString();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Connection error. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: _success ? _successView() : _formView(),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Color(0xFF0B3254),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              const Icon(Icons.business_center, size: 52, color: Color(0xFFD4AF37)),
              const SizedBox(height: 14),
              const Text(
                'Corporate Account Approved',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              if (_contactName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Welcome, $_contactName',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w700),
                ),
              ],
              if (_company.isNotEmpty)
                Text(
                  _company,
                  style: const TextStyle(color: Colors.white70),
                ),
              if (_email.isNotEmpty)
                Text(
                  _email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0B3254)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your password to activate your corporate dashboard access.',
                  style: TextStyle(color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _setPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3254),
                      foregroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFFD4AF37)),
                          )
                        : const Text('Activate Corporate Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _successView() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.green,
            child: Icon(Icons.check, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Corporate Account Activated',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0B3254)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'You can now sign in from the normal VaneLux login and you will see your corporate dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Go to Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B3254),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
