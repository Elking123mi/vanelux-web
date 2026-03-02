import 'package:flutter/material.dart';

/// A single notification item.
class VaneluxNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;
  final NotificationCategory category;

  VaneluxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory VaneluxNotification.fromBookingStatus({
    required int bookingId,
    required String status,
    String? locale,
  }) {
    final messages = _statusMessages[status] ?? _statusMessages['default']!;
    return VaneluxNotification(
      id: 'booking_${bookingId}_$status',
      title: (locale == 'es') ? messages['title_es']! : messages['title_en']!,
      body: (locale == 'es')
          ? '${messages['body_es']!} (Booking #$bookingId)'
          : '${messages['body_en']!} (Booking #$bookingId)',
      category: NotificationCategory.tripUpdate,
    );
  }

  static const _statusMessages = {
    'confirmed': {
      'title_en': '✅ Booking Confirmed',
      'body_en': 'Your Vanelux ride has been confirmed',
      'title_es': '✅ Reserva Confirmada',
      'body_es': 'Tu reserva en Vanelux ha sido confirmada',
    },
    'en_route_to_pickup': {
      'title_en': '🚗 Driver On The Way',
      'body_en': 'Your driver is heading to pick you up',
      'title_es': '🚗 Conductor en camino',
      'body_es': 'Tu conductor va en camino a recogerte',
    },
    'arrived_at_pickup': {
      'title_en': '📍 Driver Has Arrived',
      'body_en': 'Your driver is waiting for you',
      'title_es': '📍 Conductor ha llegado',
      'body_es': 'Tu conductor te está esperando',
    },
    'in_progress': {
      'title_en': '🛣️ Trip Started',
      'body_en': 'Your Vanelux trip is in progress',
      'title_es': '🛣️ Viaje iniciado',
      'body_es': 'Tu viaje Vanelux está en curso',
    },
    'completed': {
      'title_en': '🏁 Trip Completed',
      'body_en': 'Your ride is complete. Thank you for choosing Vanelux!',
      'title_es': '🏁 Viaje completado',
      'body_es': '¡Gracias por elegir Vanelux! Tu viaje ha finalizado.',
    },
    'cancelled': {
      'title_en': '❌ Booking Cancelled',
      'body_en': 'Your booking has been cancelled',
      'title_es': '❌ Reserva cancelada',
      'body_es': 'Tu reserva ha sido cancelada',
    },
    'default': {
      'title_en': '📢 Vanelux Update',
      'body_en': 'Your booking status has been updated',
      'title_es': '📢 Actualización Vanelux',
      'body_es': 'El estado de tu reserva ha sido actualizado',
    },
  };
}

enum NotificationCategory { tripUpdate, system, promo }

/// Provider that manages the notification list.
class NotificationProvider extends ChangeNotifier {
  final List<VaneluxNotification> _notifications = [];

  List<VaneluxNotification> get all => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Add a notification and immediately notify listeners.
  void add(VaneluxNotification notification) {
    // Avoid duplicate for same booking_status combo
    _notifications.removeWhere((n) => n.id == notification.id);
    _notifications.insert(0, notification);
    if (_notifications.length > 50) _notifications.removeLast();
    notifyListeners();
  }

  void addBookingStatus({
    required int bookingId,
    required String status,
    String? locale,
  }) {
    add(VaneluxNotification.fromBookingStatus(
      bookingId: bookingId,
      status: status,
      locale: locale,
    ));
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null) {
      n.read = true;
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
