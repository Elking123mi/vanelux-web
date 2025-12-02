// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

import '../config/app_config.dart';

dynamic _mapsBridge;
final Map<String, dynamic> _ensureSdkCache = <String, dynamic>{};

T _requireBridge<T>() {
  _mapsBridge ??= js_util.getProperty(js_util.globalThis, 'vaneluxMaps');
  if (_mapsBridge == null) {
    throw Exception('Google Maps bridge no disponible en el contexto web.');
  }
  return _mapsBridge as T;
}

Future<void> _ensureSdkLoaded() async {
  if (_ensureSdkCache['future'] != null) {
    return _ensureSdkCache['future'] as Future<void>;
  }

  final completer = js_util.promiseToFuture<void>(
    js_util.callMethod(_requireBridge(), 'ensureSdk', <dynamic>[
      AppConfig.googleMapsApiKey,
    ]),
  );

  _ensureSdkCache['future'] = completer;
  return completer;
}

Future<Map<String, dynamic>> getLocationFromCoordinates(
  double latitude,
  double longitude,
) async {
  await _ensureSdkLoaded();
  final result = await js_util.promiseToFuture<dynamic>(
    js_util.callMethod(_requireBridge(), 'reverseGeocode', <dynamic>[
      AppConfig.googleMapsApiKey,
      latitude,
      longitude,
    ]),
  );

  final dartified = js_util.dartify(result);
  if (dartified is Map) {
    return _convertMap(dartified as Map<dynamic, dynamic>);
  }
  return <String, dynamic>{};
}

Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
  await _ensureSdkLoaded();
  final result = await js_util.promiseToFuture<dynamic>(
    js_util.callMethod(_requireBridge(), 'searchPlaces', <dynamic>[
      AppConfig.googleMapsApiKey,
      query,
    ]),
  );

  final dartified = js_util.dartify(result);
  if (dartified is! List) {
    return [];
  }

  return dartified.map((dynamic item) {
    if (item is Map) {
      return _convertMap(item);
    }
    return <String, dynamic>{};
  }).toList();
}

Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    final stringKey = key.toString();
    if (value is Map) {
      result[stringKey] = _convertMap(value as Map<dynamic, dynamic>);
    } else if (value is List) {
      result[stringKey] = value.map((item) {
        if (item is Map) {
          return _convertMap(item as Map<dynamic, dynamic>);
        }
        return item;
      }).toList();
    } else {
      result[stringKey] = value;
    }
  });
  return result;
}

Future<Map<String, dynamic>> getDistanceMatrix(
  String origin,
  String destination,
) async {
  await _ensureSdkLoaded();
  final result = await js_util.promiseToFuture<dynamic>(
    js_util.callMethod(_requireBridge(), 'distanceMatrix', <dynamic>[
      AppConfig.googleMapsApiKey,
      origin,
      destination,
    ]),
  );

  final dartified = js_util.dartify(result);
  if (dartified is Map) {
    return _convertMap(dartified as Map<dynamic, dynamic>);
  }
  return <String, dynamic>{};
}

Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
  await _ensureSdkLoaded();
  final result = await js_util.promiseToFuture<dynamic>(
    js_util.callMethod(_requireBridge(), 'placeDetails', <dynamic>[
      AppConfig.googleMapsApiKey,
      placeId,
    ]),
  );

  final dartified = js_util.dartify(result);
  if (dartified is Map) {
    return _convertMap(dartified as Map<dynamic, dynamic>);
  }
  return <String, dynamic>{};
}
