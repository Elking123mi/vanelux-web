import 'types.dart';

class Driver {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String licenseNumber;
  final String vehicleId;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final bool isAvailable;
  final Location? currentLocation;
  final DateTime licenseExpiry;
  final String? profileImageUrl;

  Driver({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.vehicleId,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.isOnline = false,
    this.isAvailable = true,
    this.currentLocation,
    required this.licenseExpiry,
    this.profileImageUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    final dynamic userPayload = json['user'];
    final Map<String, dynamic>? userMap =
        userPayload is Map<String, dynamic> ? userPayload : null;

    String composeName() {
      final dynamic providedName = json['name'];
      if (providedName is String && providedName.isNotEmpty) {
        return providedName;
      }
      final firstName = userMap?['first_name'] ?? userMap?['firstName'] ?? '';
      final lastName = userMap?['last_name'] ?? userMap?['lastName'] ?? '';
      final combined = '$firstName $lastName'.trim();
      if (combined.isNotEmpty) {
        return combined;
      }
      return userMap?['name'] ?? userMap?['full_name'] ?? '';
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Driver(
      id: (json['id'] ?? userMap?['id'] ?? '').toString(),
      userId: (json['user_id'] ?? userMap?['id'] ?? '').toString(),
      name: composeName(),
      phone: json['phone'] ?? userMap?['phone'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
    rating: asDouble(json['rating'] ?? userMap?['rating']),
    totalTrips:
      asInt(json['total_trips'] ?? json['trips_completed'] ?? userMap?['total_trips']),
      isOnline: json['is_online'] ?? false,
      isAvailable: json['is_available'] ?? true,
      currentLocation: json['current_location'] != null
          ? Location.fromJson(json['current_location'])
          : null,
      licenseExpiry: DateTime.tryParse(
            json['license_expiry'] ??
                json['license_expiration'] ??
                userMap?['license_expiry'] ??
                '',
          ) ??
          DateTime.now(),
      profileImageUrl:
          json['profile_image_url'] ?? userMap?['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'license_number': licenseNumber,
      'vehicle_id': vehicleId,
      'rating': rating,
      'total_trips': totalTrips,
      'is_online': isOnline,
      'is_available': isAvailable,
      'current_location': currentLocation?.toJson(),
      'license_expiry': licenseExpiry.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  String get displayRating => rating.toStringAsFixed(1);
  bool get isActive => isOnline && isAvailable;
}
