import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';

  /// Create a payment intent for booking
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).round().toString(), // Stripe uses cents
          'currency': currency,
          if (customerId != null) 'customer': customerId,
          if (metadata != null)
            ...metadata.map(
              (key, value) => MapEntry('metadata[$key]', value.toString()),
            ),
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error creando intención de pago: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// Create a customer in Stripe
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'email': email, 'name': name, if (phone != null) 'phone': phone},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error creando cliente: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// Retrieve customer by ID
  static Future<Map<String, dynamic>> getCustomer(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$customerId'),
        headers: {'Authorization': 'Bearer ${AppConfig.stripeSecretKey}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error obteniendo cliente: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// Create a setup intent for saving payment method
  static Future<Map<String, dynamic>> createSetupIntent({
    required String customerId,
    List<String>? paymentMethodTypes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/setup_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'payment_method_types[]': paymentMethodTypes?.join(',') ?? 'card',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error creando setup intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// List payment methods for customer
  static Future<List<Map<String, dynamic>>> getPaymentMethods(
    String customerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_methods?customer=$customerId&type=card'),
        headers: {'Authorization': 'Bearer ${AppConfig.stripeSecretKey}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Error obteniendo métodos de pago: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// Confirm payment intent
  static Future<Map<String, dynamic>> confirmPaymentIntent(
    String paymentIntentId,
    String paymentMethodId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'payment_method': paymentMethodId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error confirmando pago: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }

  /// Process refund
  static Future<Map<String, dynamic>> createRefund({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_intent': paymentIntentId,
          if (amount != null) 'amount': (amount * 100).round().toString(),
          if (reason != null) 'reason': reason,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error procesando reembolso: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en Stripe: $e');
    }
  }
}
