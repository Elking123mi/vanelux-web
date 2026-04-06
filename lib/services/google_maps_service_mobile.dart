import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

const String _baseUrl = 'https://maps.googleapis.com/maps/api';

Future<Map<String, dynamic>> getLocationFromCoordinates(
  double latitude,
  double longitude,
) async {
  try {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/geocode/json?latlng=$latitude,$longitude&key=${AppConfig.googleMapsApiKey}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en Google Maps API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    final results = data['results'] as List<dynamic>?;

    if (status == 'OK' && results != null && results.isNotEmpty) {
      final first = results.first as Map<String, dynamic>;
      return {
        'address': first['formatted_address'],
        'location': {'lat': latitude, 'lng': longitude},
        'place_id': first['place_id'],
      };
    }

    throw Exception('No se pudo obtener la ubicación');
  } catch (e) {
    throw Exception('Error obteniendo ubicación: $e');
  }
}

Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
  try {
    final uri = Uri.parse(
      '$_baseUrl/place/autocomplete/json?input=${Uri.encodeComponent(query)}&language=es&components=country:us&key=${AppConfig.googleMapsApiKey}',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error buscando lugares: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';

    if (status == 'OK') {
      final predictions = (data['predictions'] as List<dynamic>)
          .map((prediction) => Map<String, dynamic>.from(prediction as Map))
          .toList();
      return predictions;
    }

    if (status == 'ZERO_RESULTS') {
      return const [];
    }

    final message = data['error_message'] as String?;
    throw Exception(message ?? 'Error en Google Places API: $status');
  } catch (e) {
    throw Exception('Error en búsqueda: $e');
  }
}

Future<Map<String, dynamic>> getDistanceMatrix(
  String origin,
  String destination,
) async {
  try {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/distancematrix/json?origins=${Uri.encodeComponent(origin)}&destinations=${Uri.encodeComponent(destination)}&key=${AppConfig.googleMapsApiKey}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en Google Maps API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    final rows = data['rows'] as List<dynamic>?;

    if (status == 'OK' && rows != null && rows.isNotEmpty) {
      final row = rows.first as Map<String, dynamic>;
      final elements = row['elements'] as List<dynamic>?;
      if (elements != null && elements.isNotEmpty) {
        final element = elements.first as Map<String, dynamic>;
        if (element['status'] == 'OK') {
          final distance = element['distance'] as Map<String, dynamic>?;
          final duration = element['duration'] as Map<String, dynamic>?;
          return {
            'distance': distance?['text'],
            'distance_value': distance?['value'],
            'duration': duration?['text'],
            'duration_value': duration?['value'],
          };
        }
      }
      throw Exception('No se pudo calcular la ruta');
    }

    throw Exception('Error en cálculo de distancia');
  } catch (e) {
    throw Exception('Error calculando distancia: $e');
  }
}

Future<Map<String, dynamic>> getRouteWithTolls(
  String origin,
  String destination,
) async {
  try {
    final apiKey = AppConfig.tollGuruApiKey;
    if (apiKey.isEmpty) return {'has_tolls': false, 'toll_cost': 0.0};

    final response = await http.post(
      Uri.parse('https://apis.tollguru.com/toll/v2/origin-destination-waypoints'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'from': {'address': origin},
        'to': {'address': destination},
        'vehicleType': '2AxlesAuto',
        'departure_time': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      return {'has_tolls': false, 'toll_cost': 0.0};
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return {'has_tolls': false, 'toll_cost': 0.0};
    }

    final route = routes.first as Map<String, dynamic>;
    final costs = route['costs'] as Map<String, dynamic>?;

    double parseCost(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    double tollCost = 0.0;
    if (costs != null) {
      tollCost = parseCost(costs['licensePlate']);
      if (tollCost <= 0) tollCost = parseCost(costs['tag']);
      if (tollCost <= 0) tollCost = parseCost(costs['cash']);
      if (tollCost <= 0) tollCost = parseCost(costs['prepaidCard']);
    }

    final tolls = route['tolls'] as List<dynamic>?;
    final hasTolls = tollCost > 0 || (tolls != null && tolls.isNotEmpty);
    return {'has_tolls': hasTolls, 'toll_cost': tollCost};
  } catch (e) {
    return {'has_tolls': false, 'toll_cost': 0.0};
  }
}

Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
  try {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/place/details/json?place_id=$placeId&key=${AppConfig.googleMapsApiKey}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en Google Maps API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';

    if (status == 'OK') {
      final result = data['result'] as Map<String, dynamic>;
      final geometry = result['geometry'];
      final location = geometry != null ? geometry['location'] : null;

      // Debug: Imprimir la estructura
      print('🗺️ Place Details Response:');
      print('  - Name: ${result['name']}');
      print('  - Geometry: $geometry');
      print('  - Location: $location');

      return {
        'name': result['name'],
        'address': result['formatted_address'],
        'location': location,
        'geometry': geometry, // Agregar geometry también para compatibilidad
        'phone': result['formatted_phone_number'],
        'rating': result['rating'] ?? 0.0,
        'website': result['website'],
      };
    }

    throw Exception('No se encontraron detalles del lugar');
  } catch (e) {
    throw Exception('Error obteniendo detalles: $e');
  }
}
