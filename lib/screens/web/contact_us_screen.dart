import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/web_url_sync.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const Color _brandBlue = Color(0xFF0B3254);
  static const Color _brandGold = Color(0xFFD4AF37);

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;
  String _issueType = 'General Inquiry';

  static const List<String> _issueTypes = [
    'General Inquiry',
    'Booking Support',
    'Payment Issue',
    'Change/Cancel Trip',
    'Complaint / Service Feedback',
    'Lost Item',
    'Corporate Account',
  ];

  static const List<Map<String, String>> _faqItems = [
    {
      'q': 'How fast do you respond to inquiries?',
      'a':
          'Most inquiries are answered within 1 hour during daytime operations. Urgent booking requests are prioritized immediately.',
    },
    {
      'q': 'What if I have a booking problem today?',
      'a':
          'Select "Booking Support" or "Change/Cancel Trip" and include your name, phone number, and ride details. Our dispatch team will contact you quickly.',
    },
    {
      'q': 'Can I report a service issue?',
      'a':
          'Yes. Choose "Complaint / Service Feedback" and describe what happened. We review every report and follow up directly.',
    },
    {
      'q': 'Do you support corporate clients?',
      'a':
          'Yes. Choose "Corporate Account" and provide company information so we can prepare account setup and billing options.',
    },
  ];

  @override
  void initState() {
    super.initState();
    syncWebPath('/contact');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitContactForm() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        subject.isEmpty ||
        message.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all contact form fields.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final composedMessage =
        'Issue type: $_issueType\nSubject: $subject\n\n$message';

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://web-production-700fe.up.railway.app/api/v1/vlx/contact',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'phone': phone,
              'message': composedMessage,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _issueType = 'General Inquiry';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Message sent successfully. We will contact you shortly at infovanelux@vane-lux.com.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to send message right now (code ${response.statusCode}). Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to send message right now. Please try again. ($e)',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 980;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _brandBlue,
        elevation: 0.8,
        title: const Text(
          'Contact VaneLux',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(isCompact),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 50,
                vertical: 24,
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormCard(),
                        const SizedBox(height: 20),
                        _buildHelpColumn(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildFormCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildHelpColumn()),
                      ],
                    ),
            ),
            _buildFaqBlock(isCompact),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 50,
        vertical: isCompact ? 24 : 36,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B3254), Color(0xFF1A4E77)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroText(isCompact),
                const SizedBox(height: 18),
                _buildHeroImage(isCompact),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _buildHeroText(isCompact)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildHeroImage(isCompact)),
              ],
            ),
    );
  }

  Widget _buildHeroText(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need help with your ride, booking, or account?',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 28 : 42,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Send us your request and the VaneLux team will follow up quickly. All form submissions are delivered directly to infovanelux@vane-lux.com.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isCompact ? 15 : 18,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(bool isCompact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: isCompact ? 16 / 9 : 4 / 3,
        child: Image.asset(
          'assets/images/telefono4.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white.withOpacity(0.12),
            alignment: Alignment.center,
            child: const Icon(Icons.contact_phone, color: _brandGold, size: 56),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x13000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send us a message',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _brandBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tell us what you need and we will assist you right away.',
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  'First Name',
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInput(
                  'Last Name',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInput(
                  'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIssueDropdown(),
          const SizedBox(height: 16),
          _buildInput('Subject', controller: _subjectController),
          const SizedBox(height: 16),
          _buildInput(
            'Describe your request or problem',
            controller: _messageController,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _submitContactForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: _brandGold,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isSending ? 'SENDING...' : 'SEND MESSAGE',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issue Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _brandBlue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _issueType,
          decoration: InputDecoration(
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
          items: _issueTypes
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _issueType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInput(
    String label, {
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _brandBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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

  Widget _buildHelpColumn() {
    return Column(
      children: [
        _buildSupportCard(
          icon: Icons.phone_in_talk,
          title: 'Phone Support',
          value: '9294180058',
          subtitle: '24/7 dispatch assistance',
        ),
        const SizedBox(height: 14),
        _buildSupportCard(
          icon: Icons.email,
          title: 'Direct Email',
          value: 'infovanelux@vane-lux.com',
          subtitle: 'All form messages arrive here',
        ),
        const SizedBox(height: 14),
        _buildSupportCard(
          icon: Icons.warning_amber,
          title: 'Common Problems',
          value: 'Booking changes, payment, lost items',
          subtitle: 'Choose the issue type in the form for priority handling',
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE4EF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _brandGold.withOpacity(0.17),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _brandBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _brandBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqBlock(bool isCompact) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 50),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FAQ and Problem Resolution',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _brandBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'If you are experiencing a problem, include all trip details in the form so we can resolve it faster.',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 10),
          ..._faqItems.map(
            (faq) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              iconColor: _brandBlue,
              collapsedIconColor: _brandBlue,
              title: Text(
                faq['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _brandBlue,
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    faq['a']!,
                    style: TextStyle(color: Colors.grey[800], height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
