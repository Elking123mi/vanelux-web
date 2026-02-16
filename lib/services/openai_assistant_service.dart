import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/assistant_message.dart';
import 'secure_config_service.dart';

enum AssistantPersona { client, driver }

class OpenAIAssistantException implements Exception {
  OpenAIAssistantException(this.message);

  final String message;

  @override
  String toString() => 'OpenAIAssistantException: $message';
}

class OpenAIAssistantService {
  OpenAIAssistantService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _model = 'gpt-4o-mini';

  final http.Client _client;
  final Map<AssistantPersona, String> _cachedKeys =
      <AssistantPersona, String>{};

  Future<String> sendMessage({
    required AssistantPersona persona,
    required List<AssistantMessage> messages,
  }) async {
    final filteredMessages = messages.where((m) => m.includeInContext).toList();
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPromptFor(persona)},
      ...filteredMessages.map((message) => message.toRequestMap()),
    ];

    // On web: use Netlify serverless function (API key is server-side, no CORS)
    // On mobile: call OpenAI directly with key from SecureConfigService
    final Uri uri;
    final Map<String, String> headers;
    
    if (kIsWeb) {
      final origin = Uri.base.origin;
      uri = Uri.parse('$origin/api/chat');
      headers = {'Content-Type': 'application/json'};
      print('🤖 AI Concierge: Using Netlify Function at $uri');
    } else {
      final apiKey = await _resolveApiKey(persona);
      if (apiKey == null || apiKey.isEmpty) {
        throw OpenAIAssistantException(
          'OpenAI API key not found.',
        );
      }
      uri = Uri.https('api.openai.com', '/v1/chat/completions');
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
    }

    print('🤖 AI Concierge: Sending ${requestMessages.length} messages');

    final response = await _client
        .post(
          uri,
          headers: headers,
          body: jsonEncode(<String, dynamic>{
            'model': _model,
            'messages': requestMessages,
            'temperature': 0.8,
            'max_tokens': 1000,
          }),
        )
        .timeout(const Duration(seconds: 60));

    print('🤖 AI Concierge: Response status: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('🤖 AI Concierge ERROR: ${response.body}');
      throw OpenAIAssistantException(
        _buildErrorMessage(response.body, response.statusCode),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw OpenAIAssistantException(
        'La respuesta de OpenAI no incluyó sugerencias.',
      );
    }

    final completion = choices.first as Map<String, dynamic>;
    final message = completion['message'] as Map<String, dynamic>?;
    if (message == null) {
      throw OpenAIAssistantException('OpenAI no devolvió un mensaje válido.');
    }

    final content = message['content'];
    if (content is String && content.isNotEmpty) {
      return content.trim();
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final segment in content) {
        if (segment is Map<String, dynamic>) {
          final text = segment['text'];
          if (text is String) {
            buffer.write(text);
          }
        } else if (segment is String) {
          buffer.write(segment);
        }
      }
      final combined = buffer.toString().trim();
      if (combined.isNotEmpty) {
        return combined;
      }
    }

    throw OpenAIAssistantException(
      'No se pudo interpretar la respuesta de OpenAI.',
    );
  }

  Future<String?> _resolveApiKey(AssistantPersona persona) async {
    if (_cachedKeys.containsKey(persona)) {
      return _cachedKeys[persona];
    }

    final key = persona == AssistantPersona.client
        ? await SecureConfigService.getOpenAiClientKey()
        : await SecureConfigService.getOpenAiDriverKey();

    if (key != null && key.isNotEmpty) {
      _cachedKeys[persona] = key;
      return key;
    }

    return null;
  }

  String _systemPromptFor(AssistantPersona persona) {
    switch (persona) {
      case AssistantPersona.client:
        return '''You are the **Vanelux AI Concierge** — a world-class virtual assistant for Vanelux Luxury Transportation based in New York City.

🌍 LANGUAGE RULES (CRITICAL):
- ALWAYS detect and respond in the SAME language the user writes in.
- You are fluent in English, Spanish, French, Portuguese, Italian, German, Chinese, Japanese, Korean, Arabic, Russian, Hindi, and any other language.
- If user writes in Spanish, reply in Spanish. If in French, reply in French. Etc.
- NEVER default to English unless the user writes in English.

🚗 ABOUT VANELUX:
- Premium luxury transportation company serving NYC and the tri-state area
- Website: www.vane-lux.com
- Available 24/7, 365 days a year
- Email: info@vane-lux.com

🚘 FLEET (5 Vehicle Classes):
1. **Mercedes-Maybach S 680** — Ultra-luxury sedan, 4 passengers, 3 luggage
2. **Cadillac Escalade ESV** — Premium SUV, 6 passengers, 6 luggage
3. **Range Rover Autobiography** — Executive SUV, 4 passengers, 4 luggage
4. **Mercedes-Benz Sprinter Jet** — Executive sprinter, 10 passengers, 12 luggage
5. **Mini Coach 27 pax** — Luxury mini coach, 27 passengers, 32 luggage

💰 PRICING (Share when asked):
• AIRPORT ↔ MANHATTAN (Flat Rates):
  - JFK: Sedan \$140 | SUV \$150 | Escalade \$170 | Sprinter \$220 | Mini Coach \$280
  - LaGuardia: Sedan \$120 | SUV \$135 | Escalade \$155 | Sprinter \$200 | Mini Coach \$260
  - Newark: Sedan \$180 | SUV \$210 | Escalade \$240 | Sprinter \$280 | Mini Coach \$350
• NYC LOCAL (within city):
  - Base fare (up to 5 miles): Sedan \$60 | SUV \$80 | Escalade \$95 | Sprinter \$120 | Mini Coach \$150
  - Per extra mile: Sedan \$3.00 | SUV \$3.75 | Escalade \$4.25 | Sprinter \$5.50 | Mini Coach \$7.00
• OUTSIDE NYC:
  - Per mile: Sedan \$2.75 | SUV \$3.50 | Escalade \$4.25 | Sprinter \$5.50 | Mini Coach \$7.00

📋 SERVICE TYPES:
- To Airport / From Airport — Airport transfers with meet-and-greet
- Point to Point — Direct A-to-B transportation
- Hourly / As Directed — Chauffeur at your disposal (min 3 hours)
- Corporate — Business travel and executive transportation
- Wedding — Luxury bridal party transportation
- City Tour — Guided NYC sightseeing experience

🌟 SPECIAL SERVICES:
- Meet & greet at airports with name sign
- Flight tracking for delays
- Child car seats available on request
- WiFi, water, and refreshments in all vehicles
- Professional, uniformed chauffeurs
- Coming soon: Vanelux Mobile App for iOS and Android

⚽ FIFA WORLD CUP 2026:
- Vanelux offers special packages for World Cup events at MetLife Stadium
- Luxury transportation from Manhattan to MetLife and back
- Group packages available for fans

💳 PAYMENT:
- Accept all major credit cards via Stripe secure checkout
- Corporate accounts available with monthly billing

🤝 YOUR PERSONALITY:
- You are elegant, warm, and professional
- You are proactive — suggest options and upsell when appropriate
- If someone asks about becoming a driver, direct them to the "Become a Driver" section on the website
- If someone needs immediate help beyond your scope, suggest calling or emailing info@vane-lux.com
- Be conversational but concise (2-4 sentences unless more detail is needed)
- Use emojis sparingly for a modern luxury feel''';
      case AssistantPersona.driver:
        return '''You are the Vanelux AI assistant for drivers. You speak ALL languages — always respond in the same language the user writes in.
Focus on: accepting trips, best service practices, safety protocols, earnings info, and administrative reminders.
Be clear, direct, and supportive. Suggest contacting dispatch if the question exceeds your capabilities.''';
    }
  }

  String _buildErrorMessage(String rawBody, int statusCode) {
    try {
      final decoded = jsonDecode(rawBody) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return 'OpenAI devolvió un error ($statusCode): ${message.trim()}';
        }
      } else if (error is String && error.isNotEmpty) {
        return 'OpenAI devolvió un error ($statusCode): ${error.trim()}';
      }
    } catch (_) {
      // Ignored: prefer to fall back to generic message.
    }
    return 'No se pudo obtener respuesta de OpenAI (código $statusCode).';
  }

  void dispose() {
    _client.close();
  }
}
