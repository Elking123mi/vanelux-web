import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class StripeService {
  /// Crea un Payment Intent a través del backend
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    int? bookingId,
    String? customerEmail,
  }) async {
    try {
      print('🔵 [StripeService] Creando Payment Intent: \$${amount.toStringAsFixed(2)}');
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'booking_id': bookingId,
          'customer_email': customerEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [StripeService] Payment Intent creado: ${data['paymentIntentId']}');
        return data;
      } else {
        print('❌ [StripeService] Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      print('❌ [StripeService] Exception: $e');
      rethrow;
    }
  }

  /// Confirma el pago en el backend
  static Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    int? bookingId,
  }) async {
    try {
      print('🔵 [StripeService] Confirmando pago: $paymentIntentId');
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/confirm-payment?payment_intent_id=$paymentIntentId${bookingId != null ? '&booking_id=$bookingId' : ''}');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [StripeService] Pago confirmado');
        return data;
      } else {
        throw Exception('Failed to confirm payment: ${response.body}');
      }
    } catch (e) {
      print('❌ [StripeService] Exception al confirmar: $e');
      rethrow;
    }
  }

  /// Procesa un pago con tarjeta
  static Future<bool> processCardPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
    int? bookingId,
    String? customerEmail,
  }) async {
    try {
      print('🔵 [StripeService] Procesando pago con tarjeta...');
      
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

      // Crear Payment Intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: 'usd',
        bookingId: bookingId,
        customerEmail: customerEmail,
      );

      // Simular procesamiento de tarjeta (en producción usar Stripe.js)
      print('💳 [StripeService] Procesando pago...');
      await Future.delayed(const Duration(seconds: 2));

      // Confirmar el pago
      final confirmation = await confirmPayment(
        paymentIntentId: paymentIntent['paymentIntentId'],
        bookingId: bookingId,
      );

      return confirmation['success'] == true;
    } catch (e) {
      print('❌ [StripeService] Error procesando pago: $e');
      rethrow;
    }
  }
}
