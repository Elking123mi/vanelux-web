import 'dart:convert';

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
    final apiKey = await _resolveApiKey(persona);
    if (apiKey == null || apiKey.isEmpty) {
      throw OpenAIAssistantException(
        'No se encontró una API key de OpenAI para ${persona.name}. Configúrala e intenta nuevamente.',
      );
    }

    final filteredMessages = messages.where((m) => m.includeInContext).toList();
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPromptFor(persona)},
      ...filteredMessages.map((message) => message.toRequestMap()),
    ];

    final uri = Uri.https('api.openai.com', '/v1/chat/completions');
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(<String, dynamic>{
            'model': _model,
            'messages': requestMessages,
            'temperature': 0.7,
            'max_tokens': 600,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
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
        return '''You are the Vanelux AI Concierge — the virtual assistant for Vanelux Luxury Transportation in New York City. 
You help customers with:
- Booking luxury rides (sedan, SUV, Escalade, Sprinter, Mini Coach)
- Airport transfers (JFK, LaGuardia, Newark) with flat-rate pricing from Manhattan
- NYC local rides with base fare + per-mile pricing
- Outside NYC rides with per-mile pricing
- Service types: Airport, Point to Point, Hourly/As Directed, Corporate, Wedding, Tour
- Fleet information (Mercedes-Maybach S 680, Cadillac Escalade ESV, Range Rover, Sprinter Jet, Mini Coach)
- General questions about our premium service

Be professional, concise, and helpful. Respond in the same language the user writes in (English or Spanish).
Keep answers short (2-4 sentences max unless more detail is needed).
If asked about specific pricing, mention that rates depend on route type and vehicle selection.
Always maintain a luxury and professional tone befitting a premium transportation brand.''';
      case AssistantPersona.driver:
        return 'You are the Vanelux AI assistant for drivers. Focus on operational support: accepting trips, best service practices, '
            'safety protocols and administrative reminders. Be clear and direct, and suggest contacting human support if the question exceeds your capabilities.';
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
