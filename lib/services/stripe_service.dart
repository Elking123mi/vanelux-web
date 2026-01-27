import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StripeService {
  static const String baseUrl = 'https://web-production-700fe.up.railway.app/api/v1';
  final storage = const FlutterSecureStorage();
  
  bool _initialized = false;

  // Inicializar Stripe con la clave pública
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Obtener clave pública desde el backend
      final response = await http.get(
        Uri.parse('$baseUrl/vlx/payments/stripe/config'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final publishableKey = data['publishable_key'] as String;
        
        Stripe.publishableKey = publishableKey;
        _initialized = true;
        print('✅ Stripe inicializado correctamente');
      } else {
        throw Exception('Error al obtener config de Stripe: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error inicializando Stripe: $e');
      rethrow;
    }
  }

  // Procesar pago
  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required double amount,
    String? description,
    String? customerEmail,
  }) async {
    try {
      await init();
      
      // 1. Crear Payment Intent en el backend (SIN autenticación - guest checkout)
      print('📤 Creando Payment Intent: \$${amount.toStringAsFixed(2)}');
      final intentResponse = await http.post(
        Uri.parse('$baseUrl/vlx/payments/stripe/create-intent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
          'currency': 'usd',
          'description': description ?? 'Pago de reserva',
          'customer_email': customerEmail,
        }),
      );

      print('📥 Response status: ${intentResponse.statusCode}');
      print('📥 Response body: ${intentResponse.body}');

      if (intentResponse.statusCode != 200) {
        throw Exception('Error al crear intento de pago: ${intentResponse.body}');
      }

      final intentData = jsonDecode(intentResponse.body);
      final clientSecret = intentData['clientSecret'] as String;
      final paymentIntentId = intentData['paymentIntentId'] as String;

      print('✅ Payment Intent creado: $paymentIntentId');

      // 2. Mostrar Payment Sheet de Stripe
      print('🎨 Inicializando Payment Sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VaneLux Luxury Transportation',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1E3A8A),
            ),
          ),
        ),
      );

      print('📱 Presentando Payment Sheet...');
      await Stripe.instance.presentPaymentSheet();

      print('✅ Pago completado en Stripe');

      // 3. Confirmar pago en el backend (SIN autenticación)
      print('📤 Confirmando pago en backend...');
      final confirmResponse = await http.post(
        Uri.parse('$baseUrl/vlx/payments/stripe/confirm'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
          'booking_id': bookingId,
        }),
      );

      print('📥 Confirm status: ${confirmResponse.statusCode}');
      print('📥 Confirm body: ${confirmResponse.body}');

      if (confirmResponse.statusCode == 200) {
        final confirmData = jsonDecode(confirmResponse.body);
        return {
          'success': true,
          'message': confirmData['message'],
          'payment_intent_id': paymentIntentId,
        };
      } else {
        throw Exception('Error al confirmar el pago: ${confirmResponse.body}');
      }

    } on StripeException catch (e) {
      print('❌ StripeException: ${e.error.code} - ${e.error.message}');
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Pago cancelado por el usuario');
      }
      throw Exception('Error de Stripe: ${e.error.message}');
    } catch (e) {
      print('❌ Error general: $e');
      rethrow;
    }
  }
}
