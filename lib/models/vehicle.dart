import 'types.dart';

class Vehicle {
  final String id;
  final String driverId;
  final VehicleType type;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final bool isActive;
  final Location? currentLocation;

  Vehicle({
    required this.id,
    required this.driverId,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.isActive = true,
    this.currentLocation,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      driverId: json['driver_id'] ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => VehicleType.sedan,
      ),
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      color: json['color'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      isActive: json['is_active'] ?? true,
      currentLocation: json['current_location'] != null
          ? Location.fromJson(json['current_location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'type': type.toString().split('.').last,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'is_active': isActive,
      'current_location': currentLocation?.toJson(),
    };
  }

  String get displayName => '$make $model ($year)';

  String get fullDescription => '$color $make $model $year';
}
