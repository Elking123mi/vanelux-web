import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Get AI assistance for trip planning
  static Future<String> getTripSuggestions({
    required String from,
    required String to,
    String? preferences,
    String? occasion,
  }) async {
    try {
      final prompt =
          '''
Eres un asistente de VaneLux, un servicio de transporte de lujo. 
Ayuda al cliente con sugerencias para su viaje desde "$from" hasta "$to".
${preferences != null ? 'Preferencias del cliente: $preferences' : ''}
${occasion != null ? 'Ocasión: $occasion' : ''}

Proporciona:
1. Sugerencias de vehículos de lujo apropiados
2. Recomendaciones de tiempo de viaje
3. Consejos especiales para el viaje
4. Servicios adicionales que podrían interesar

Responde de manera profesional y enfocada en el lujo.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un asistente experto en servicios de transporte de lujo para VaneLux.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error en ChatGPT API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo sugerencias: $e');
    }
  }

  /// Get customer service assistance
  static Future<String> getCustomerServiceHelp(String query) async {
    try {
      final prompt =
          '''
Eres un asistente de atención al cliente de VaneLux, un servicio de transporte de lujo premium.
El cliente pregunta: "$query"

Proporciona una respuesta útil, profesional y enfocada en:
- Servicios de VaneLux
- Reservas y cancelaciones
- Tipos de vehículos disponibles
- Políticas de la empresa
- Resolución de problemas

Mantén un tono elegante y profesional apropiado para un servicio de lujo.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un asistente de atención al cliente experto para VaneLux, un servicio de transporte de lujo.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 400,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error en ChatGPT API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo ayuda: $e');
    }
  }

  /// Get driver assistance and tips
  static Future<String> getDriverAssistance(String situation) async {
    try {
      final prompt =
          '''
Eres un asistente para conductores de VaneLux, un servicio de transporte de lujo.
Situación del conductor: "$situation"

Proporciona consejos profesionales sobre:
- Servicio al cliente de lujo
- Manejo de situaciones especiales
- Etiqueta y protocolo
- Optimización de rutas
- Seguridad y comodidad

Mantén un enfoque profesional apropiado para conductores de servicios premium.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un asistente experto para conductores de servicios de transporte de lujo.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 400,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error en ChatGPT API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo asistencia: $e');
    }
  }
}
