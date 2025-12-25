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
  // Para desarrollo local: Descomentar la línea con la key real
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'CHANGE_ME', // Valor por defecto seguro
  );
  
  // Fallback para desarrollo - SOLO usar en local, comentar antes de deploy
  static String get mapsApiKeyFallback => 
    googleMapsApiKey == 'CHANGE_ME' 
      ? 'AIzaSyAfE3eJvvl5jRYcPjey3FuvZ5qVnnPhFFQ' 
      : googleMapsApiKey;

  // OpenAI ChatGPT API Key (configurar en Netlify)
  static const String openaiApiKey = '';

  // Stripe API Keys (configurar en Netlify)
  static const String stripePublicKey = '';
  static const String stripeSecretKey = '';

  // Environment Configuration
  static const bool isProduction = true;
  static const bool enableLogging = true;
}
