import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment.dart';
import '../config/app_config.dart';

class PaymentService {
  /// Obtener token de autenticación
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  /// Crear un nuevo pago
  Future<Payment> createPayment({
    required int bookingId,
    required double amount,
    required String paymentMethod,
    String? cardLast4,
    String? transactionId,
    String? notes,
  }) async {
    final token = await _getToken();

    final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/payments');
    print('🔵 [PaymentService] Creando pago: $url');
    print('🔵 [PaymentService] Token: ${token != null ? "Presente" : "Guest"}');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        if (cardLast4 != null) 'card_last_4': cardLast4,
        if (transactionId != null) 'transaction_id': transactionId,
        if (notes != null) 'notes': notes,
      }),
    );

    print('📡 Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data['payment']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al crear el pago');
    }
  }

  /// Listar todos los pagos del usuario
  Future<List<Payment>> getMyPayments() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión.');
    }

    final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/payments');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentsList = data['payments'] as List;
      return paymentsList.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los pagos');
    }
  }

  /// Obtener detalles de un pago específico
  Future<Payment> getPayment(int paymentId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión.');
    }

    final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/payments/$paymentId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data['payment']);
    } else {
      throw Exception('Error al obtener el pago');
    }
  }

  /// Obtener todos los pagos de una reserva
  Future<List<Payment>> getBookingPayments(int bookingId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión.');
    }

    final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/bookings/$bookingId/payments');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentsList = data['payments'] as List;
      return paymentsList.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los pagos de la reserva');
    }
  }

  /// Calcular el total pagado de una reserva
  Future<double> getTotalPaid(int bookingId) async {
    final payments = await getBookingPayments(bookingId);
    double total = 0.0;
    for (final payment in payments) {
      if (payment.status == 'completed') {
        total += payment.amount;
      }
    }
    return total;
  }

  /// Verificar si una reserva está pagada completamente
  Future<bool> isBookingFullyPaid(int bookingId, double bookingPrice) async {
    final totalPaid = await getTotalPaid(bookingId);
    return totalPaid >= bookingPrice;
  }
}
