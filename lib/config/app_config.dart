class AppConfig {
    // ================= Env / Backend =================
    // 🚀 Backend en Railway (24/7 en la nube - Supabase)
    // URL: https://web-production-700fe.up.railway.app
    // Docs: https://web-production-700fe.up.railway.app/docs
    static String get apiBaseUrl {
      // Backend compartido con Conexaship en Railway
      // Base de datos PostgreSQL en Supabase (siempre sincronizado)
      // TEMPORALMENTE usando localhost para testing
      return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
    }
    
    static const String apiVersionPath = '/api/v1';
    static String get centralApiBaseUrl => '$apiBaseUrl$apiVersionPath';
    static String get authLoginUrl =>
            String.fromEnvironment('AUTH_LOGIN_URL', defaultValue: '$centralApiBaseUrl/auth/login');
    static String get authRefreshUrl =>
            String.fromEnvironment('AUTH_REFRESH_URL', defaultValue: '$centralApiBaseUrl/auth/refresh');
    static String get authLogoutUrl => '$centralApiBaseUrl/auth/logout';
    static String get authMeUrl => '$centralApiBaseUrl/auth/me';
    static String get authRegisterUrl => '$centralApiBaseUrl/auth/register';
    
    static const int _apiTimeoutSeconds =
            int.fromEnvironment('API_TIMEOUT', defaultValue: 30);
    static const Duration defaultRequestTimeout =
            Duration(seconds: _apiTimeoutSeconds);
    static const String originWebAllowed = String.fromEnvironment(
        'ORIGIN_WEB_ALLOWED',
        defaultValue: 'http://localhost:8080',
    );

    // VaneLux Endpoints
    static const String vaneLuxNamespace = '/vlx';
    static String get vlxPassengersUrl => '$centralApiBaseUrl$vaneLuxNamespace/passengers';
    static String get vlxDriversUrl => '$centralApiBaseUrl$vaneLuxNamespace/drivers';
    static String get vlxTripsUrl => '$centralApiBaseUrl$vaneLuxNamespace/trips';
    static String get vlxVehiclesUrl => '$centralApiBaseUrl$vaneLuxNamespace/vehicles';
    static String get vlxBookingsUrl => '$centralApiBaseUrl$vaneLuxNamespace/bookings';
    
    static const String appIdentifier = 'vanelux';
    static const String driverAppIdentifier = 'vanelux_driver';

    // ================= Integrations =================
    static const String vaneLuxBaseUrl = 'https://vane-lux.com';

  // Google Maps API Key
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'AIzaSyAfE3eJvvl5jRYcPjey3FuvZ5qVnnPhFFQ');

  // OpenAI ChatGPT API Key (configurar en Netlify)
  static const String openaiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  // Stripe API Keys (configurar en Netlify)
  static const String stripePublicKey =
      String.fromEnvironment('STRIPE_PUBLIC_KEY', 
        defaultValue: 'pk_live_51RCrU0LcVFDlHSTpysEqLwQMCoqkSyky9pVxXeSV7J7xzmUQ0hDxEEhT74SbkrRiLY58bXBPUh3iJ85w95P8UHME00K8iOIvZd');
  static const String stripeSecretKey =
      String.fromEnvironment('STRIPE_SECRET_KEY', defaultValue: '');

  // Environment Configuration
  static const bool isProduction = true;
  static const bool enableLogging = true;
}
