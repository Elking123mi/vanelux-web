import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_service.dart';

class StorageService {
  /// Solicita URLs prefirmadas para subir/descargar archivos.
  static Future<Map<String, String>> requestPresignedUrls({
    required String filename,
    required String contentType,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Sesión expirada. Inicia sesión nuevamente.');
    }

    final response = await ApiService.get(
      '/storage/presign?filename=$filename&content_type=$contentType',
      token: token,
    );

    return {
      'put_url': response['put_url'] as String,
      'get_url': response['get_url'] as String,
    };
  }

  /// Sube un archivo a la URL prefirmada usando HTTP PUT.
  static Future<void> uploadToPresignedUrl({
    required String putUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await http
        .put(
          Uri.parse(putUrl),
          headers: {'Content-Type': contentType},
          body: bytes,
        )
        .timeout(const Duration(minutes: 1));

    if (response.statusCode >= 400) {
      throw Exception(
        'No se pudo subir el archivo (status ${response.statusCode}).',
      );
    }
  }
}
