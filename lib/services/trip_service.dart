import '../models/trip.dart';
import '../models/driver.dart';
import '../models/types.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TripService {
  // Solicitar un taxi
  static Future<Trip> requestTrip({
    required Location pickupLocation,
    required Location destinationLocation,
    required VehicleType vehicleType,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    final token = await AuthService.getToken();

    final response = await ApiService.post('/trips/request', {
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'vehicleType': vehicleType.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'notes': notes,
    }, token: token);

    return Trip.fromJson(response['trip']);
  }

  // Cancelar viaje
  static Future<void> cancelTrip(String tripId) async {
    final token = await AuthService.getToken();
    await ApiService.put('/trips/$tripId/cancel', {}, token: token);
  }

  // Obtener historial de viajes (alias para getUserTrips)
  static Future<List<Trip>> getTripHistory() async {
    return getUserTrips();
  }

  // Obtener viajes del usuario
  static Future<List<Trip>> getUserTrips({
    int page = 1,
    int limit = 20,
    TripStatus? status,
  }) async {
    final token = await AuthService.getToken();

    String endpoint = '/trips/user?page=$page&limit=$limit';
    if (status != null) {
      endpoint += '&status=${status.toString().split('.').last}';
    }

    final response = await ApiService.get(endpoint, token: token);

    return (response['trips'] as List)
        .map((trip) => Trip.fromJson(trip))
        .toList();
  }

  // Obtener detalles de un viaje
  static Future<Trip> getTripDetails(String tripId) async {
    final token = await AuthService.getToken();
    final response = await ApiService.get('/trips/$tripId', token: token);
    return Trip.fromJson(response['trip']);
  }

  // Calificar conductor
  static Future<void> rateDriver(
    String tripId,
    double rating,
    String? comment,
  ) async {
    final token = await AuthService.getToken();
    await ApiService.put('/trips/$tripId/rate-driver', {
      'rating': rating,
      'comment': comment,
    }, token: token);
  }

  // Obtener estimación de precio
  static Future<double> getEstimatedPrice({
    required Location pickupLocation,
    required Location destinationLocation,
    required VehicleType vehicleType,
  }) async {
    final response = await ApiService.post('/trips/estimate', {
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'vehicleType': vehicleType.toString().split('.').last,
    });

    return response['estimatedPrice'].toDouble();
  }

  // Obtener conductores cercanos
  static Future<List<Driver>> getNearbyDrivers(Location location) async {
    final response = await ApiService.post('/trips/nearby-drivers', {
      'location': location.toJson(),
    });

    return (response['drivers'] as List)
        .map((driver) => Driver.fromJson(driver))
        .toList();
  }

  // Seguimiento en tiempo real del viaje
  static Future<Trip> trackTrip(String tripId) async {
    final token = await AuthService.getToken();
    final response = await ApiService.get('/trips/$tripId/track', token: token);
    return Trip.fromJson(response['trip']);
  }
}
