class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  bool get isExpired =>
      DateTime.now().isAfter(accessTokenExpiresAt.subtract(const Duration(seconds: 10)));

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'access_token_expires_at': accessTokenExpiresAt.toIso8601String(),
      };

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresAt: DateTime.parse(json['access_token_expires_at'] as String),
    );
  }

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
    );
  }
}
