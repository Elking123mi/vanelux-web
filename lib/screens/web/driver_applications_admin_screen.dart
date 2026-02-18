// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../services/auth_service.dart';

class DriverApplicationsAdminScreen extends StatefulWidget {
  const DriverApplicationsAdminScreen({super.key});

  @override
  State<DriverApplicationsAdminScreen> createState() =>
      _DriverApplicationsAdminScreenState();
}

class _DriverApplicationsAdminScreenState
    extends State<DriverApplicationsAdminScreen> {
  bool _isLoading = true;
  String _statusFilter = 'pending';
  List<Map<String, dynamic>> _applications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url =
          '${AppConfig.centralApiBaseUrl}/vlx/drivers/applications?status_filter=$_statusFilter';
      final resp = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _applications =
              List<Map<String, dynamic>>.from(data['applications'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception('Error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveApplication(
      Map<String, dynamic> app, String adminNote) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final resp = await http.post(
      Uri.parse(
          '${AppConfig.centralApiBaseUrl}/vlx/drivers/applications/${app['id']}/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'admin_note': adminNote}),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (mounted) {
        _showResultDialog(
          success: true,
          title: '✅ Application Approved',
          message:
              'Email sent to ${app['email']}.\n\nSetup link (for testing):\n${data['setup_link'] ?? ''}',
          setupLink: data['setup_link'],
        );
        _loadApplications();
      }
    } else {
      _showResultDialog(
        success: false,
        title: 'Error',
        message: 'Error: ${resp.body}',
      );
    }
  }

  Future<void> _rejectApplication(
      Map<String, dynamic> app, String reason) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final resp = await http.post(
      Uri.parse(
          '${AppConfig.centralApiBaseUrl}/vlx/drivers/applications/${app['id']}/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'admin_note': reason}),
    );

    if (resp.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected and driver notified.'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadApplications();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${resp.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showApproveDialog(Map<String, dynamic> app) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('Approve ${app['full_name']}?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'An email will be sent to the driver with a link to create their password.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note for driver (optional)',
                hintText: 'e.g. "Welcome! Please report on Monday at 9am"',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _approveApplication(app, noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve & Send Email',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> app) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('Reject ${app['full_name']}?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The driver will receive an email notification.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText:
                    'e.g. "Vehicle does not meet our requirements"',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rejectApplication(app, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetail(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B3254),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFD4AF37),
                        size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        app['full_name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailSection('📋 Personal Information', [
                        _detailRow('Email', app['email']),
                        _detailRow('Phone', app['phone']),
                        _detailRow('License #', app['driver_license']),
                        _detailRow(
                            'License Expires', app['license_expiry_date']),
                        _detailRow('Experience',
                            '${app['years_of_experience']} years'),
                        _detailRow('Languages', app['languages'] ?? '-'),
                        _detailRow('Background Check',
                            app['has_background_check'] == true ? '✅ Yes' : '❌ No'),
                      ]),
                      const SizedBox(height: 20),
                      _detailSection('🚘 Vehicle', [
                        _detailRow('Type', app['vehicle_type']),
                        _detailRow(
                            'Vehicle',
                            '${app['vehicle_year']} ${app['vehicle_make']} ${app['vehicle_model']}'),
                        _detailRow('Color', app['vehicle_color']),
                        _detailRow('Plate', app['license_plate']),
                      ]),
                      const SizedBox(height: 20),
                      _detailSection('🛡️ Insurance', [
                        _detailRow(
                            'Company', app['insurance_company']),
                        _detailRow(
                            'Policy #', app['insurance_policy_number']),
                        _detailRow(
                            'Expires', app['insurance_expiry_date']),
                      ]),
                      if (app['additional_notes']?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        _detailSection('📝 Notes', [
                          _detailRow('', app['additional_notes']),
                        ]),
                      ],
                      if (app['admin_note']?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            border:
                                Border.all(color: const Color(0xFFD4AF37)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.admin_panel_settings,
                                  color: Color(0xFF0B3254), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Admin note: ${app['admin_note']}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0B3254)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer buttons
              if (app['status'] == 'pending')
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRejectDialog(app);
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Reject',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showApproveDialog(app);
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Approve',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(
      {required bool success,
      required String title,
      required String message,
      String? setupLink}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (setupLink != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    html.window.open(setupLink, '_blank'),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Setup Link'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3254)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
            ),
          Expanded(
            child: Text(value ?? '-',
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'onboarded':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3254),
        foregroundColor: Colors.white,
        title: const Text('Driver Applications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter tabs
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text('Filter:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                ...[
                  ('pending', 'Pending', Colors.orange),
                  ('approved', 'Approved', Colors.blue),
                  ('onboarded', 'Active Drivers', Colors.green),
                  ('rejected', 'Rejected', Colors.red),
                  ('', 'All', Colors.grey),
                ].map((item) {
                  final (value, label, color) = item;
                  final isSelected = _statusFilter == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _statusFilter = value);
                        _loadApplications();
                      },
                      selectedColor: color.withOpacity(0.2),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0B3254)))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[300], size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: TextStyle(color: Colors.red[700])),
                            const SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: _loadApplications,
                                child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _applications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text(
                                  'No $_statusFilter applications',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _applications.length,
                            itemBuilder: (ctx, i) {
                              final app = _applications[i];
                              final status =
                                  app['status'] as String? ?? 'pending';
                              final statusColor = _statusColor(status);

                              return Card(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                elevation: 2,
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  onTap: () =>
                                      _showApplicationDetail(app),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color(
                                                  0xFF0B3254)
                                              .withOpacity(0.1),
                                          child: Text(
                                            (app['full_name'] as String)
                                                .isNotEmpty
                                                ? (app['full_name']
                                                        as String)[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0B3254),
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                app['full_name'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(app['email'] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors
                                                          .grey[600])),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${app['vehicle_year']} ${app['vehicle_make']} ${app['vehicle_model']} • ${app['vehicle_type']}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .grey[500]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Status + actions
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                            if (status == 'pending') ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  _actionBtn(
                                                    Icons.check,
                                                    Colors.green,
                                                    'Approve',
                                                    () =>
                                                        _showApproveDialog(
                                                            app),
                                                  ),
                                                  const SizedBox(
                                                      width: 6),
                                                  _actionBtn(
                                                    Icons.close,
                                                    Colors.red,
                                                    'Reject',
                                                    () =>
                                                        _showRejectDialog(
                                                            app),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
