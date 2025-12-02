import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'central_backend_service.dart';

class ApiService {
  static String get _baseUrl => AppConfig.centralApiBaseUrl;
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Headers con autenticación
  static Map<String, String> _headersWithAuth(String? token) {
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Manejo de errores
  static void _handleError(http.Response response) {
    if (response.statusCode < 400) return;
    throw Exception(_extractErrorMessage(response));
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return 'Error ${response.statusCode} desde el backend';
      }
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail']?.toString();
        final hint = decoded['hint'] != null ? '\n${decoded['hint']}' : '';
        if (detail != null && detail.isNotEmpty) {
          return '$detail$hint';
        }
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
      return decoded.toString();
    } catch (_) {
      return 'Error ${response.statusCode} desde el backend';
    }
  }

  static Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(String? resolvedToken) sender, {
    String? token,
    bool requiresAuth = false,
  }) async {
    String? currentToken = token;

    Future<http.Response> call() => sender(currentToken);

    http.Response response = await call();

    if (response.statusCode == 401 && requiresAuth) {
      try {
        final refreshed = await CentralBackendService.refreshTokens();
        currentToken = refreshed.accessToken;
        response = await call();
      } catch (_) {
        await CentralBackendService.logout();
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }
    }

    _handleError(response);

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return _request(
      (resolvedToken) => http
          .get(
            url,
            headers: _headersWithAuth(resolvedToken ?? token),
          )
          .timeout(AppConfig.defaultRequestTimeout),
      token: token,
      requiresAuth: token != null,
    );
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return _request(
      (resolvedToken) => http
          .post(
            url,
            headers: _headersWithAuth(resolvedToken ?? token),
            body: json.encode(data),
          )
          .timeout(AppConfig.defaultRequestTimeout),
      token: token,
      requiresAuth: token != null,
    );
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return _request(
      (resolvedToken) => http
          .put(
            url,
            headers: _headersWithAuth(resolvedToken ?? token),
            body: json.encode(data),
          )
          .timeout(AppConfig.defaultRequestTimeout),
      token: token,
      requiresAuth: token != null,
    );
  }

  // DELETE request
  static Future<void> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    await _request(
      (resolvedToken) => http
          .delete(
            url,
            headers: _headersWithAuth(resolvedToken ?? token),
          )
          .timeout(AppConfig.defaultRequestTimeout),
      token: token,
      requiresAuth: token != null,
    );
  }
}
