import '../config/app_config.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'local_booking_service.dart';

class BookingService {
  static const String _endpoint = '${AppConfig.vaneLuxNamespace}/bookings';

  /// Creates a booking in the backend and returns the normalized payload used by the UI.
  static Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> payload,
  ) async {
    final token = await AuthService.getToken();
    print('🔵 [BookingService] Creando reserva...');
    print('🔵 [BookingService] Token: ${token != null ? "✓ presente" : "✗ ausente"}');
    print('🔵 [BookingService] Endpoint: $_endpoint');
    
    // Transform payload to match backend expectations
    final backendPayload = _transformPayloadForBackend(payload);
    print('🔵 [BookingService] Payload transformed: $backendPayload');
    
    try {
      final response = await ApiService.post(_endpoint, backendPayload, token: token);
      print('✅ [BookingService] Respuesta del backend: $response');
      
      final booking = _extractBooking(response);
      final normalized = normalizeBooking(booking ?? payload);
      await LocalBookingService.saveBooking(normalized);
      
      print('✅ [BookingService] Reserva guardada localmente y en backend');
      return normalized;
    } catch (e) {
      print('❌ [BookingService] Error al guardar en backend: $e');
      // If backend is unavailable, store locally as fallback but return it so the UI still
      // shows the reservation.
      final fallback = normalizeBooking(payload, isBackendPayload: false);
      await LocalBookingService.saveBooking(fallback);
      print('⚠️  [BookingService] Reserva guardada solo localmente (offline)');
      return fallback;
    }
  }

  /// Transform frontend payload to match backend API expectations
  static Map<String, dynamic> _transformPayloadForBackend(Map<String, dynamic> payload) {
    final transformed = Map<String, dynamic>.from(payload);
    
    // Map origin → pickup_address
    if (transformed.containsKey('origin')) {
      transformed['pickup_address'] = transformed['origin'];
      transformed.remove('origin');
    }
    
    // Map destination → destination_address
    if (transformed.containsKey('destination')) {
      transformed['destination_address'] = transformed['destination'];
      transformed.remove('destination');
    }
    
    // Map fare → price (backend expects 'price')
    if (transformed.containsKey('fare')) {
      transformed['price'] = transformed['fare'];
      transformed.remove('fare');
    }
    
    return transformed;
  }

  /// Fetches bookings from the backend, falling back to local cache when offline.
  static Future<List<Map<String, dynamic>>> fetchBookings() async {
    final token = await AuthService.getToken();
    print('🔵 [BookingService] Consultando reservas...');
    print('🔵 [BookingService] Token: ${token != null ? "✓ presente" : "✗ ausente"}');
    print('🔵 [BookingService] Endpoint: $_endpoint');
    
    try {
      final response = await ApiService.get(_endpoint, token: token);
      print('✅ [BookingService] Respuesta del backend: $response');
      
      final rawBookings = _extractBookingList(response);
      print('✅ [BookingService] Reservas encontradas: ${rawBookings.length}');
      
      final normalized = rawBookings
          .map((booking) => normalizeBooking(booking))
          .toList();
      await LocalBookingService.storeBookings(normalized);
      
      print('✅ [BookingService] Reservas sincronizadas localmente');
      return normalized;
    } catch (e) {
      print('❌ [BookingService] Error al consultar backend: $e');
      
      final cached = await LocalBookingService.getBookings();
      print('⚠️  [BookingService] Mostrando ${cached.length} reservas del cache local');
      
      return cached.map((booking) {
        final copy = Map<String, dynamic>.from(booking);
        copy['source'] = booking['source'] ?? 'local-cache-offline';
        copy['syncedWithBackend'] = booking['syncedWithBackend'] ?? false;
        return copy;
      }).toList();
    }
  }

  static Map<String, dynamic> normalizeBooking(
    Map<String, dynamic> booking, {
    bool isBackendPayload = true,
  }) {
    final normalized = Map<String, dynamic>.from(booking);

    String? stringValue(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    double? doubleValue(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    bool boolValue(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final backendId = stringValue(
      normalized['id'] ??
          normalized['booking_id'] ??
          normalized['uuid'] ??
          normalized['bookingId'],
    );

    final createdAt =
        parseDate(
          normalized['created_at'] ??
              normalized['createdAt'] ??
              normalized['created_at_utc'] ??
              normalized['created'],
        ) ??
        DateTime.now();

    final pickupTime =
        parseDate(
          normalized['pickup_time'] ??
              normalized['pickupTime'] ??
              normalized['scheduled_at'] ??
              normalized['pickup_at'],
        ) ??
        createdAt;

    final pickupAddress =
        stringValue(
          normalized['pickup_address'] ??
              normalized['origin'] ??
              normalized['pickupAddress'],
        ) ??
        'Pickup not set';

    final destinationAddress =
        stringValue(
          normalized['destination_address'] ??
              normalized['destination'] ??
              normalized['destinationAddress'],
        ) ??
        'Destination not set';

    final vehicleName =
        stringValue(
          normalized['vehicle_name'] ??
              normalized['vehicleName'] ??
              normalized['vehicle'] ??
              normalized['vehicle_type'],
        ) ??
        'Vehicle';

    final distanceText =
        stringValue(
          normalized['distance_text'] ??
              normalized['distanceText'] ??
              normalized['distance'],
        ) ??
        '';

    final durationText =
        stringValue(
          normalized['duration_text'] ??
              normalized['durationText'] ??
              normalized['duration'],
        ) ??
        '';

    final price = doubleValue(
      normalized['fare'] ?? normalized['price'] ?? normalized['total_price'],
    );

    final status = stringValue(normalized['status']) ?? 'pending';
    final isScheduled = boolValue(
      normalized['is_scheduled'] ?? normalized['isScheduled'],
    );

    final pickupLat = doubleValue(
      normalized['pickup_lat'] ?? normalized['pickupLat'],
    );
    final pickupLng = doubleValue(
      normalized['pickup_lng'] ?? normalized['pickupLng'],
    );
    final destinationLat = doubleValue(
      normalized['destination_lat'] ?? normalized['destinationLat'],
    );
    final destinationLng = doubleValue(
      normalized['destination_lng'] ?? normalized['destinationLng'],
    );

    return {
      'id':
          backendId ??
          stringValue(normalized['id']) ??
          createdAt.microsecondsSinceEpoch.toString(),
      'backendId': backendId,
      'createdAt': createdAt.toIso8601String(),
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'distanceMiles': doubleValue(
        normalized['distance_miles'] ?? normalized['distanceMiles'],
      ),
      'distanceText': distanceText,
      'durationText': durationText,
      'vehicleName': vehicleName,
      'price': price,
      'serviceType': normalized['service_type'] ?? normalized['serviceType'],
      'status': status,
      'isScheduled': isScheduled,
      'scheduledAt': pickupTime.toIso8601String(),
      'metadata': normalized,
      'syncedWithBackend': isBackendPayload,
      'source': isBackendPayload ? 'backend' : 'local-cache',
    };
  }

  static Map<String, dynamic>? _extractBooking(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response.containsKey('booking') &&
        response['booking'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        response['booking'] as Map<String, dynamic>,
      );
    }
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('booking') &&
            data['booking'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(
            data['booking'] as Map<String, dynamic>,
          );
        }
        return Map<String, dynamic>.from(data);
      }
    }
    return Map<String, dynamic>.from(response);
  }

  static List<Map<String, dynamic>> _extractBookingList(
    Map<String, dynamic> response,
  ) {
    final List<Map<String, dynamic>> bookings = [];

    dynamic source;
    if (response.containsKey('bookings')) {
      source = response['bookings'];
    } else if (response.containsKey('data')) {
      source = response['data'];
    } else {
      source = response;
    }

    if (source is List) {
      for (final item in source) {
        if (item is Map<String, dynamic>) {
          bookings.add(Map<String, dynamic>.from(item));
        } else if (item is Map) {
          bookings.add(Map<String, dynamic>.from(item.cast<String, dynamic>()));
        }
      }
    } else if (source is Map<String, dynamic>) {
      bookings.add(Map<String, dynamic>.from(source));
    }

    return bookings;
  }
}
