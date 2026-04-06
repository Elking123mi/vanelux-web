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
    final response = await http.post(
      Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      ),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': AppConfig.googleMapsApiKey,
        'X-Goog-FieldMask':
            'routes.travelAdvisory.tollInfo,routes.distanceMeters,routes.duration',
      },
      body: jsonEncode({
        'origin': {'address': origin},
        'destination': {'address': destination},
        'travelMode': 'DRIVE',
        'extraComputations': ['TOLLS'],
        'routeModifiers': {
          'vehicleInfo': {'emissionType': 'GASOLINE'},
        },
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
    final travelAdvisory = route['travelAdvisory'] as Map<String, dynamic>?;
    final tollInfo = travelAdvisory?['tollInfo'] as Map<String, dynamic>?;
    final estimatedPrice = tollInfo?['estimatedPrice'] as List<dynamic>?;

    if (estimatedPrice == null || estimatedPrice.isEmpty) {
      return {'has_tolls': false, 'toll_cost': 0.0};
    }

    final price = estimatedPrice.first as Map<String, dynamic>;
    final units = double.tryParse(price['units']?.toString() ?? '0') ?? 0.0;
    final nanos = ((price['nanos'] as num?) ?? 0) / 1e9;
    return {'has_tolls': true, 'toll_cost': units + nanos};
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
