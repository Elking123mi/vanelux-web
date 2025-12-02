import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Simple local persistence layer for storing recent bookings on device.
class LocalBookingService {
  static const _storageLimit = 20;

  static Future<List<Map<String, dynamic>>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(AppConfig.keyStoredBookings);
    if (stored == null) {
      return [];
    }

    return stored
        .map((item) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map<String, dynamic>) {
              final map = Map<String, dynamic>.from(decoded);
              map['syncedWithBackend'] =
                  map['syncedWithBackend'] ?? map['isBackendPayload'] ?? false;
              map['source'] =
                  map['source'] ??
                  (map['syncedWithBackend'] == true
                      ? 'backend'
                      : 'local-cache');
              return map;
            }
          } catch (_) {
            // Ignore malformed entry.
          }
          return <String, dynamic>{};
        })
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  static Future<void> saveBooking(Map<String, dynamic> booking) async {
    final bookings = await getBookings();
    bookings.insert(0, booking);
    await storeBookings(bookings);
  }

  static Future<void> clearBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keyStoredBookings);
  }

  static Future<void> storeBookings(List<Map<String, dynamic>> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = bookings
        .where((booking) => booking.isNotEmpty)
        .take(_storageLimit)
        .map((booking) => jsonEncode(booking))
        .toList();
    await prefs.setStringList(AppConfig.keyStoredBookings, normalized);
  }

  static Future<void> replaceBooking(Map<String, dynamic> booking) async {
    final bookings = await getBookings();
    final backendId = booking['backendId'] ?? booking['id'];

    if (backendId != null) {
      final index = bookings.indexWhere((existing) {
        final existingId = existing['backendId'] ?? existing['id'];
        return existingId == backendId;
      });

      if (index != -1) {
        bookings[index] = booking;
      } else {
        bookings.insert(0, booking);
      }
    } else {
      bookings.insert(0, booking);
    }

    await storeBookings(bookings);
  }
}
