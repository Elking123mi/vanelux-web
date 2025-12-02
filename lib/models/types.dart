// Definición de tipos comunes de la app

enum VehicleType { sedan, suv, luxury, van }

enum ServiceType { pointToPoint, hourly, airport, corporate, wedding, tour }

enum TripStatus { requested, accepted, inProgress, completed, cancelled }

enum PaymentMethod {
  cash,
  card,
  creditCard,
  debitCard,
  digitalWallet,
  corporate,
  paypal,
  applePay,
  googlePay,
}

class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? country;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}
