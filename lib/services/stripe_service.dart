import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StripeService {
  static const String baseUrl = 'https://web-production-700fe.up.railway.app/api/v1';
  final storage = const FlutterSecureStorage();
  
  String? _publishableKey;
  bool _initialized = false;

  // Inicializar Stripe
  Future<void> init() async {
    if (_initialized) return;

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/vlx/payments/stripe/config'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _publishableKey = data['publishable_key'];
        
        if (_publishableKey != null && _publishableKey!.isNotEmpty) {
          Stripe.publishableKey = _publishableKey!;
          _initialized = true;
        }
      }
    } catch (e) {
      print('Error inicializando Stripe: $e');
      rethrow;
    }
  }

  // Procesar pago
  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required double amount,
    String? description,
  }) async {
    try {
      await init();
      
      final token = await storage.read(key: 'access_token');

      // 1. Crear Payment Intent
      final intentResponse = await http.post(
        Uri.parse('$baseUrl/vlx/payments/stripe/create-intent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
          'currency': 'usd',
          'description': description,
        }),
      );

      if (intentResponse.statusCode != 200) {
        throw Exception('Error al crear intento de pago');
      }

      final intentData = jsonDecode(intentResponse.body);
      final clientSecret = intentData['client_secret'] as String;
      final paymentIntentId = intentData['payment_intent_id'] as String;

      // 2. Mostrar Payment Sheet de Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VaneLux',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 3. Confirmar pago en el backend
      final confirmResponse = await http.post(
        Uri.parse('$baseUrl/vlx/payments/stripe/confirm'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'payment_intent_id': paymentIntentId,
          'amount': amount,
        }),
      );

      if (confirmResponse.statusCode == 201) {
        return {
          'success': true,
          'payment': jsonDecode(confirmResponse.body)['payment'],
        };
      } else {
        throw Exception('Error al confirmar el pago');
      }

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Pago cancelado');
      }
      throw Exception('Error de Stripe: ${e.error.message}');
    }
  }
}
