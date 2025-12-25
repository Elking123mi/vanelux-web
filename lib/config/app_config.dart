class AppConfig {
    // ================= Env / Backend =================
    // 🚀 Backend en Railway (24/7 en la nube - Supabase)
    // URL: https://web-production-700fe.up.railway.app
    // Docs: https://web-production-700fe.up.railway.app/docs
    static const String apiBaseUrl = 'https://web-production-700fe.up.railway.app';
    
    static const String apiVersionPath = '/api/v1';
    static String get centralApiBaseUrl => '$apiBaseUrl$apiVersionPath';
    static String get authLoginUrl => '$centralApiBaseUrl/auth/login';
    static String get authRefreshUrl => '$centralApiBaseUrl/auth/refresh';
    static String get authLogoutUrl => '$centralApiBaseUrl/auth/logout';
    static String get authMeUrl => '$centralApiBaseUrl/auth/me';
    static String get authRegisterUrl => '$centralApiBaseUrl/auth/register';
    
    static const int _apiTimeoutSeconds = 60;
    static const Duration defaultRequestTimeout =
            Duration(seconds: _apiTimeoutSeconds);
    static const String originWebAllowed = 'http://localhost:8080';

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

  // Google Maps API Key - USAR VARIABLE DE ENTORNO PARA SEGURIDAD
  // Para Netlify: Configurar en Site settings > Environment variables > GOOGLE_MAPS_API_KEY
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '', // NO poner la key aquí - usar variable de entorno
  );

  // OpenAI ChatGPT API Key (configurar en Netlify)
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // Stripe API Keys (configurar en Netlify)
  static const String stripePublicKey = String.fromEnvironment(
    'STRIPE_PUBLIC_KEY',
    defaultValue: '',
  );
  
  static const String stripeSecretKey = String.fromEnvironment(
    'STRIPE_SECRET_KEY',
    defaultValue: '',
  );

  // Environment Configuration
  static const bool isProduction = true;
  static const bool enableLogging = true;
}
