import 'types.dart';
import 'driver.dart';

class Trip {
  final String id;
  final String userId;
  final String? driverId;
  final VehicleType vehicleType;
  final Location pickupLocation;
  final Location destinationLocation;
  final TripStatus status;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime requestTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final PaymentMethod paymentMethod;
  final Driver? driver;

  Trip({
    required this.id,
    required this.userId,
    this.driverId,
    required this.vehicleType,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    this.estimatedPrice,
    this.finalPrice,
    required this.requestTime,
    this.startTime,
    this.endTime,
    required this.paymentMethod,
    this.driver,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      driverId: json['driver_id'],
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['vehicle_type'],
        orElse: () => VehicleType.sedan,
      ),
      pickupLocation: Location.fromJson(json['pickup_location'] ?? {}),
      destinationLocation: Location.fromJson(
        json['destination_location'] ?? {},
      ),
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TripStatus.requested,
      ),
      estimatedPrice: json['estimated_price']?.toDouble(),
      finalPrice: json['final_price']?.toDouble(),
      requestTime:
          DateTime.tryParse(json['request_time'] ?? '') ?? DateTime.now(),
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'])
          : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'driver_id': driverId,
      'vehicle_type': vehicleType.toString().split('.').last,
      'pickup_location': pickupLocation.toJson(),
      'destination_location': destinationLocation.toJson(),
      'status': status.toString().split('.').last,
      'estimated_price': estimatedPrice,
      'final_price': finalPrice,
      'request_time': requestTime.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'payment_method': paymentMethod.toString().split('.').last,
      'driver': driver?.toJson(),
    };
  }
}
