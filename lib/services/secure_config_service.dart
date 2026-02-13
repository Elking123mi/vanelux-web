import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Centraliza la obtención de llaves sensibles evitando que queden
/// codificadas directamente en el árbol de fuentes de Flutter.
class SecureConfigService {
  SecureConfigService._();

  static const MethodChannel _channel = MethodChannel('com.vanelux/config');

  static const Map<String, String> _envOverrides = {
    'OPENAI_API_KEY_CLIENT': String.fromEnvironment(
      'OPENAI_API_KEY_CLIENT',
      defaultValue: String.fromEnvironment('OPENAI_API_KEY'),
    ),
    'OPENAI_API_KEY_DRIVER': String.fromEnvironment(
      'OPENAI_API_KEY_DRIVER',
      defaultValue: String.fromEnvironment('OPENAI_API_KEY'),
    ),
    'STRIPE_PUBLISHABLE_KEY': String.fromEnvironment('STRIPE_PUBLISHABLE_KEY'),
    'STRIPE_SECRET_KEY': String.fromEnvironment('STRIPE_SECRET_KEY'),
  };

  static final Map<String, String> _cache = <String, String>{};
  static Map<String, String>? _webSecretsCache;

  static Future<String?> getOpenAiClientKey() =>
      _getSecret('OPENAI_API_KEY_CLIENT');

  static Future<String?> getOpenAiDriverKey() =>
      _getSecret('OPENAI_API_KEY_DRIVER');

  static Future<String?> getStripePublishableKey() =>
      _getSecret('STRIPE_PUBLISHABLE_KEY');

  static Future<String?> getStripeSecretKey() =>
      _getSecret('STRIPE_SECRET_KEY');

  static Future<String?> _getSecret(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final override = _envOverrides[key];
    if (override != null && override.isNotEmpty) {
      _cache[key] = override;
      return override;
    }

    if (kIsWeb) {
      final secrets = await _loadWebSecrets();
      final value = secrets[key];
      if (value != null && value.isNotEmpty) {
        _cache[key] = value;
        return value;
      }
      return null;
    }

    try {
      final value = await _channel.invokeMethod<String>(
        'getSecret',
        <String, String>{'key': key},
      );
      final sanitized = value?.trim();
      if (sanitized != null && sanitized.isNotEmpty) {
        _cache[key] = sanitized;
        return sanitized;
      }
    } on MissingPluginException {
      return await _fallbackForLegacyMethods(key);
    } on PlatformException {
      return null;
    }

    return null;
  }

  static Future<String?> _fallbackForLegacyMethods(String key) async {
    // Compatibilidad con builds antiguos que sólo exponían getOpenAiKey.
    if (key == 'OPENAI_API_KEY_CLIENT' || key == 'OPENAI_API_KEY_DRIVER') {
      final persona = key == 'OPENAI_API_KEY_DRIVER' ? 'driver' : 'client';
      try {
        final value = await _channel.invokeMethod<String>(
          'getOpenAiKey',
          <String, String>{'persona': persona},
        );
        final sanitized = value?.trim();
        if (sanitized != null && sanitized.isNotEmpty) {
          _cache[key] = sanitized;
          return sanitized;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<Map<String, String>> _loadWebSecrets() async {
    if (_webSecretsCache != null) {
      return _webSecretsCache!;
    }

    try {
      final response = await http.get(Uri.parse('local.properties'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final parsed = _parseProperties(response.body);
        _webSecretsCache = parsed;
        return parsed;
      }
    } catch (_) {
      // Ignora fallos al cargar secretos en web.
    }

    _webSecretsCache = const {};
    return _webSecretsCache!;
  }

  static Map<String, String> _parseProperties(String raw) {
    final result = <String, String>{};
    final lines = const LineSplitter().convert(raw);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      final value = trimmed.substring(separatorIndex + 1).trim();
      if (key.isEmpty) {
        continue;
      }
      result[key] = value;
    }
    return result;
  }
}
