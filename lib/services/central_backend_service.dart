import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_tokens.dart';
import '../models/central_session.dart';
import '../models/driver.dart';
import '../models/user.dart';

class CentralBackendService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'central_access_token';
  static const _refreshTokenKey = 'central_refresh_token';
  static const _accessTokenExpiryKey = 'central_access_token_expiry';

  static Uri get _loginUri => Uri.parse(AppConfig.authLoginUrl);
  static Uri get _refreshUri => Uri.parse(AppConfig.authRefreshUrl);

  static Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${AppConfig.centralApiBaseUrl}$normalized');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static void _validateAppAccess(User user, String requiredApp) {
    if (!user.allowedApps.contains(requiredApp)) {
      throw Exception(
        'Tu cuenta no tiene acceso a "$requiredApp". Pide a un administrador que actualice tus allowed_apps.',
      );
    }
  }

  static Future<CentralSession> login({
    required String email,
    required String password,
    String requiredApp = AppConfig.appIdentifier,
  }) async {
    // El backend puede aceptar tanto email como username
    final response = await http
        .post(
          _loginUri,
          headers: _headers(),
          body: jsonEncode({
            'username': email, 
            'password': password,
            'app': requiredApp,  // ← IMPORTANTE: especificar VaneLux para Railway
          }),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    final decoded = _decodeResponse(response);
    final tokens = _extractTokens(decoded);
    await _persistTokens(tokens);

    final userPayload = _extractUser(decoded);
    final user = User.fromJson(userPayload);
    _validateAppAccess(user, requiredApp);

    return CentralSession(user: user, tokens: tokens);
  }

  static Future<CentralSession> registerPassengerAndLogin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final names = fullName.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : fullName;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    await _publicRegister(
      payload: {
        'username': email, // Usar email como username
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'roles': ['passenger'],
        'allowed_apps': [AppConfig.appIdentifier],
        'app': AppConfig.appIdentifier,  // ← Especificar vanelux en registro
      },
    );

    return login(email: email, password: password);
  }

  static Future<CentralSession> registerDriverAndLogin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String vehicleMake,
    required String vehicleModel,
    required int vehicleYear,
  }) async {
    final names = fullName.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : fullName;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    await _publicRegister(
      payload: {
        'username': email, // Usar email como username
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'license_number': licenseNumber,
        'vehicle_make': vehicleMake,
        'vehicle_model': vehicleModel,
        'vehicle_year': vehicleYear,
        'roles': ['driver'],
        'allowed_apps': [
          AppConfig.appIdentifier,
          AppConfig.driverAppIdentifier,
        ],
        'app': AppConfig.driverAppIdentifier,  // ← Especificar app en registro
      },
    );

    return login(
      email: email,
      password: password,
      requiredApp: AppConfig.driverAppIdentifier,
    );
  }

  static Future<Map<String, dynamic>> _publicRegister({
    String endpoint = '/auth/register',
    required Map<String, dynamic> payload,
  }) async {
    final response = await http
        .post(
          _buildUri(endpoint),
          headers: _headers(),
          body: jsonEncode(payload),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    return _decodeResponse(response);
  }

  static Future<AuthTokens> refreshTokens() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No hay refresh token disponible');
    }

    final response = await http
        .post(
          _refreshUri,
          headers: _headers(),
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    final decoded = _decodeResponse(response);
    final tokens = _extractTokens(decoded);
    await _persistTokens(tokens);
    return tokens;
  }

  static Future<String?> getValidAccessToken() async {
    final stored = await _loadStoredTokens();
    if (stored == null) return null;

    if (stored.isExpired) {
      try {
        final refreshed = await refreshTokens();
        return refreshed.accessToken;
      } catch (_) {
        await _clearTokens();
        return null;
      }
    }

    return stored.accessToken;
  }

  static Future<User> fetchCurrentUser() async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw Exception('Sesión expirada. Inicia sesión nuevamente.');
    }

    final response = await http
        .get(_buildUri('/auth/me'), headers: _headers(token: token))
        .timeout(AppConfig.defaultRequestTimeout);

    final decoded = _decodeResponse(response);
    return User.fromJson(_extractUser(decoded));
  }

  static Future<List<User>> fetchUsers({
    int page = 1,
    int pageSize = 25,
  }) async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw Exception('Sesión expirada. Inicia sesión nuevamente.');
    }

    final response = await http
        .get(
          _buildUri('/users', {'page': page, 'page_size': pageSize}),
          headers: _headers(token: token),
        )
        .timeout(AppConfig.defaultRequestTimeout);

    final decoded = _decodeResponse(response);
    final usersPayload = decoded['results'] ?? decoded['users'] ?? [];
    return (usersPayload as List)
        .map((entry) => User.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  static Future<User?> lookupUser(String identifier) async {
    final cleaned = identifier.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError('identifier no puede estar vacío');
    }

    // Intentar sin token primero (endpoint público)
    var response = await http
        .get(_buildUri('/users/check/$cleaned'), headers: _headers())
        .timeout(AppConfig.defaultRequestTimeout);

    // Si falla con 403, intentar con token (backend mal configurado)
    if (response.statusCode == 403) {
      final token = await getValidAccessToken();
      if (token != null) {
        response = await http
            .get(_buildUri('/users/check/$cleaned'), headers: _headers(token: token))
            .timeout(AppConfig.defaultRequestTimeout);
      }
    }

    if (response.statusCode == 404) {
      return null;
    }

    final decoded = _decodeResponse(response);
    if (decoded['exists'] != true) {
      return null;
    }

    final payloadRaw = decoded['user'];
    if (payloadRaw is Map<String, dynamic>) {
      return User.fromJson(Map<String, dynamic>.from(payloadRaw));
    }
    if (payloadRaw is Map) {
      return User.fromJson(payloadRaw.cast<String, dynamic>());
    }
    return null;
  }

  static Future<bool> userExists(String identifier) async {
    final user = await lookupUser(identifier);
    return user != null;
  }

  static Future<Driver> fetchCurrentDriverProfile() async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw Exception('Sesión expirada. Inicia sesión nuevamente.');
    }

    final response = await http
        .get(_buildUri('/drivers/me'), headers: _headers(token: token))
        .timeout(AppConfig.defaultRequestTimeout);

    final decoded = _decodeResponse(response);
    final payload = decoded['driver'] ?? decoded;
    return Driver.fromJson(Map<String, dynamic>.from(payload));
  }

  static Future<User> createOrUpdateUser({
    String? userId,
    required String email,
    required String firstName,
    required String lastName,
    required List<String> allowedApps,
    List<String> roles = const [],
    String? phone,
    bool isActive = true,
  }) async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw Exception('Sesión expirada. Inicia sesión nuevamente.');
    }

    final payload = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'allowed_apps': allowedApps,
      'roles': roles,
      'is_active': isActive,
    }..removeWhere((key, value) => value == null);

    final http.Response response;
    if (userId == null) {
      response = await http
          .post(
            _buildUri('/users'),
            headers: _headers(token: token),
            body: jsonEncode(payload),
          )
          .timeout(AppConfig.defaultRequestTimeout);
    } else {
      response = await http
          .patch(
            _buildUri('/users/$userId'),
            headers: _headers(token: token),
            body: jsonEncode(payload),
          )
          .timeout(AppConfig.defaultRequestTimeout);
    }

    final decoded = _decodeResponse(response);
    return User.fromJson(_extractUser(decoded));
  }

  static Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final accessToken = await _storage.read(key: _accessTokenKey);

    if (refreshToken != null && accessToken != null) {
      try {
        await http
            .post(
              _buildUri('/auth/logout'),
              headers: _headers(token: accessToken),
              body: jsonEncode({'refresh_token': refreshToken}),
            )
            .timeout(AppConfig.defaultRequestTimeout);
      } catch (_) {
        // Ignore backend logout failures; tokens will be purged locally.
      }
    }

    await _clearTokens();
  }

  static Map<String, dynamic> _extractUser(Map<String, dynamic> decoded) {
    if (decoded.containsKey('user')) {
      return Map<String, dynamic>.from(decoded['user'] as Map);
    }
    if (decoded.containsKey('data') &&
        decoded['data'] is Map<String, dynamic> &&
        (decoded['data'] as Map<String, dynamic>).containsKey('user')) {
      return Map<String, dynamic>.from(
        (decoded['data'] as Map<String, dynamic>)['user'] as Map,
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  static AuthTokens _extractTokens(Map<String, dynamic> decoded) {
    final payload = decoded['tokens'] ?? decoded;
    final issuedAt = DateTime.now().toUtc();
    final expiresInRaw =
        payload['expires_in'] ?? payload['access_expires_in'] ?? 900;
    final expiresInSeconds = expiresInRaw is int
        ? expiresInRaw
        : int.tryParse(expiresInRaw.toString()) ?? 900;

    return AuthTokens(
      accessToken: payload['access_token'] as String,
      refreshToken: payload['refresh_token'] as String,
      accessTokenExpiresAt: issuedAt.add(Duration(seconds: expiresInSeconds)),
    );
  }

  static Future<void> _persistTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await _storage.write(
      key: _accessTokenExpiryKey,
      value: tokens.accessTokenExpiresAt.toIso8601String(),
    );
  }

  static Future<AuthTokens?> _loadStoredTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiryRaw = await _storage.read(key: _accessTokenExpiryKey);

    if (accessToken == null || refreshToken == null || expiryRaw == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: DateTime.tryParse(expiryRaw) ?? DateTime.now(),
    );
  }

  static Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    final message = _extractErrorMessage(response);
    throw Exception(message);
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return 'Error ${response.statusCode} desde el backend';
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            'Error ${response.statusCode} desde el backend';
      }
      return decoded.toString();
    } catch (_) {
      return 'Error ${response.statusCode} desde el backend';
    }
  }
}
