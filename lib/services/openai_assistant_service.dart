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
        return 'Eres el asistente virtual de VaneLux para clientes. Habla en español y ofrece ayuda concisa sobre reservas, tarifas, rutas, recomendaciones y estado de viajes. '
            'Si necesitas datos específicos que la app aún no implementa, menciona la limitación y sugiere la acción adecuada.';
      case AssistantPersona.driver:
        return 'Eres el asistente virtual de VaneLux para conductores. Habla en español y enfócate en soporte operativo: aceptar viajes, mejores prácticas de servicio, '
            'protocolos de seguridad y recordatorios administrativos. Sé claro y directo, y sugiere contactar a soporte humano si la pregunta supera tus capacidades.';
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
