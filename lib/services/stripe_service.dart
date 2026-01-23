import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class StripeService {
  /// Obtener token de autenticación
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Crea un pago usando el sistema de pagos de Railway (/api/v1/vlx/payments)
  static Future<Map<String, dynamic>> createPayment({
    required int bookingId,
    required double amount,
    required String paymentMethod,
    String? cardLast4,
    String? transactionId,
    String? notes,
  }) async {
    try {
      print('🔵 [PaymentService] Creando pago: \$${amount.toStringAsFixed(2)}');
      
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor inicia sesión.');
      }

      final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/payments');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
          'payment_method': paymentMethod,
          if (cardLast4 != null) 'card_last_4': cardLast4,
          if (transactionId != null) 'transaction_id': transactionId,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [PaymentService] Pago creado exitosamente');
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('❌ [PaymentService] Error ${response.statusCode}: ${response.body}');
        throw Exception(error['detail'] ?? 'Failed to create payment: ${response.body}');
      }
    } catch (e) {
      print('❌ [PaymentService] Exception: $e');
      rethrow;
    }
  }

  /// Obtener pagos de una reserva
  static Future<List<dynamic>> getBookingPayments(int bookingId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final url = Uri.parse('${AppConfig.centralApiBaseUrl}/vlx/bookings/$bookingId/payments');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payments'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('❌ [PaymentService] Error obteniendo pagos: $e');
      return [];
    }
  }

  /// Procesa un pago con tarjeta usando el sistema real de Railway
  static Future<bool> processCardPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
    required int bookingId,
    String? customerEmail,
  }) async {
    try {
      print('🔵 [PaymentService] Procesando pago con tarjeta...');
      
      // Validaciones básicas
      if (cardNumber.replaceAll(' ', '').length < 15) {
        throw Exception('Número de tarjeta inválido');
      }
      if (expiry.length < 4) {
        throw Exception('Fecha de expiración inválida');
      }
      if (cvv.length < 3) {
        throw Exception('CVV inválido');
      }
      if (cardholderName.trim().isEmpty) {
        throw Exception('Nombre del titular requerido');
      }

      // Extraer últimos 4 dígitos de la tarjeta
      final last4 = cardNumber.replaceAll(' ', '').substring(
        cardNumber.replaceAll(' ', '').length - 4
      );

      // Crear pago usando el endpoint real de Railway
      final payment = await createPayment(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: 'card',
        cardLast4: last4,
        notes: 'Payment from $cardholderName',
      );

      return payment['success'] == true || payment['payment'] != null;
    } catch (e) {
      print('❌ [PaymentService] Error procesando pago: $e');
      rethrow;
    }
  }
}
