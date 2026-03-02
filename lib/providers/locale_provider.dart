import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages EN/ES language selection, persisted via SharedPreferences.
class LocaleProvider extends ChangeNotifier {
  String _locale = 'en';

  String get locale => _locale;

  LocaleProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('app_locale') ?? 'en';
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', code);
    notifyListeners();
  }

  /// Shorthand: translate a key using current locale.
  String t(String key) => AppStrings.get(key, _locale);
}

/// Central string table for EN / ES.
class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    // ── Navigation ─────────────────────────────────────────────
    'nav_home':        {'en': 'Home',          'es': 'Inicio'},
    'nav_services':    {'en': 'Services',       'es': 'Servicios'},
    'nav_about':       {'en': 'About',          'es': 'Nosotros'},
    'nav_contact':     {'en': 'Contact',        'es': 'Contacto'},
    'nav_book_now':    {'en': 'Book Now',        'es': 'Reservar'},
    'nav_login':       {'en': 'Log In',         'es': 'Iniciar sesión'},
    'nav_logout':      {'en': 'Log Out',        'es': 'Cerrar sesión'},

    // ── Hero / Home ─────────────────────────────────────────────
    'hero_title':      {'en': 'Premium Transportation\nin New York City',
                        'es': 'Transporte Premium\nen Nueva York'},
    'hero_subtitle':   {'en': 'Luxury rides tailored to your needs',
                        'es': 'Viajes de lujo adaptados a tus necesidades'},
    'hero_cta':        {'en': 'Book Your Ride',  'es': 'Reserva tu viaje'},

    // ── Booking Form ────────────────────────────────────────────
    'book_pickup':     {'en': 'Pickup Location',    'es': 'Lugar de recogida'},
    'book_dest':       {'en': 'Destination',         'es': 'Destino'},
    'book_date':       {'en': 'Pickup Date & Time',  'es': 'Fecha y hora'},
    'book_passengers': {'en': 'Passengers',           'es': 'Pasajeros'},
    'book_vehicle':    {'en': 'Vehicle Class',        'es': 'Clase de vehículo'},
    'book_submit':     {'en': 'Request Booking',      'es': 'Solicitar reserva'},
    'book_name':       {'en': 'Full Name',            'es': 'Nombre completo'},
    'book_email':      {'en': 'Email',                'es': 'Correo electrónico'},
    'book_phone':      {'en': 'Phone',                'es': 'Teléfono'},

    // ── Status ──────────────────────────────────────────────────
    'status_pending':           {'en': 'Pending',              'es': 'Pendiente'},
    'status_confirmed':         {'en': 'Confirmed',            'es': 'Confirmada'},
    'status_en_route':          {'en': 'Driver on the way',    'es': 'Conductor en camino'},
    'status_arrived':           {'en': 'Driver arrived',       'es': 'Conductor llegó'},
    'status_in_progress':       {'en': 'In Progress',          'es': 'En curso'},
    'status_completed':         {'en': 'Completed',            'es': 'Completada'},
    'status_cancelled':         {'en': 'Cancelled',            'es': 'Cancelada'},

    // ── Dashboard ───────────────────────────────────────────────
    'dash_my_bookings':  {'en': 'My Bookings',      'es': 'Mis reservas'},
    'dash_track_live':   {'en': 'Track Live',        'es': 'Rastrear en vivo'},
    'dash_rate_trip':    {'en': 'Rate this trip',    'es': 'Calificar viaje'},
    'dash_driver':       {'en': 'Driver Dashboard',  'es': 'Panel del conductor'},

    // ── Rating ──────────────────────────────────────────────────
    'rate_title':        {'en': 'How was your ride?',       'es': '¿Cómo fue tu viaje?'},
    'rate_placeholder':  {'en': 'Share your experience…',  'es': 'Cuéntanos tu experiencia…'},
    'rate_submit':       {'en': 'Submit Rating',            'es': 'Enviar calificación'},
    'rate_thanks':       {'en': 'Thank you for your feedback!', 'es': '¡Gracias por tu opinión!'},

    // ── Notifications ───────────────────────────────────────────
    'notif_title':       {'en': 'Notifications',        'es': 'Notificaciones'},
    'notif_empty':       {'en': 'No notifications yet', 'es': 'Sin notificaciones'},
    'notif_clear':       {'en': 'Clear all',             'es': 'Limpiar todo'},

    // ── General ─────────────────────────────────────────────────
    'confirm':           {'en': 'Confirm',  'es': 'Confirmar'},
    'cancel':            {'en': 'Cancel',   'es': 'Cancelar'},
    'save':              {'en': 'Save',     'es': 'Guardar'},
    'close':             {'en': 'Close',    'es': 'Cerrar'},
    'loading':           {'en': 'Loading…', 'es': 'Cargando…'},
    'error_generic':     {'en': 'Something went wrong. Please try again.',
                          'es': 'Algo salió mal. Por favor intenta de nuevo.'},
  };

  static String get(String key, String locale) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[locale] ?? entry['en'] ?? key;
  }

  /// All supported locales.
  static const List<String> supported = ['en', 'es'];
}
