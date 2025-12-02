import 'google_maps_service_mobile.dart'
    if (dart.library.html) 'google_maps_service_web_impl.dart'
    as platform;

class GoogleMapsService {
  static Future<Map<String, dynamic>> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) {
    return platform.getLocationFromCoordinates(latitude, longitude);
  }

  static Future<List<Map<String, dynamic>>> searchPlaces(String query) {
    return platform.searchPlaces(query);
  }

  static Future<Map<String, dynamic>> getDistanceMatrix(
    String origin,
    String destination,
  ) {
    return platform.getDistanceMatrix(origin, destination);
  }

  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) {
    return platform.getPlaceDetails(placeId);
  }
}
