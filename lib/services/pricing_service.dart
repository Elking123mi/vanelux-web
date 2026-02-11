import 'dart:math';

/// Vehicle pricing tier for rate calculation
enum VehicleTier { sedan, suv, escalade, sprinter, miniCoach }

/// Route type detected from pickup/dropoff coordinates
enum RouteType {
  airportManhattanJFK,
  airportManhattanLGA,
  airportManhattanNewark,
  localCity,
  outsideCity,
}

/// Result of a price calculation
class PriceEstimate {
  final RouteType routeType;
  final String routeLabel;
  final VehicleTier tier;
  final double totalPrice;
  final double distanceMiles;
  final double? baseRate;
  final double? perMileRate;
  final bool isFlat;

  const PriceEstimate({
    required this.routeType,
    required this.routeLabel,
    required this.tier,
    required this.totalPrice,
    required this.distanceMiles,
    this.baseRate,
    this.perMileRate,
    this.isFlat = false,
  });
}

class PricingService {
  // ─── Airport coordinates ───────────────────────────────────
  static const double _jfkLat = 40.6413;
  static const double _jfkLng = -73.7781;

  static const double _lgaLat = 40.7769;
  static const double _lgaLng = -73.8740;

  static const double _ewrLat = 40.6895;
  static const double _ewrLng = -74.1745;

  // Radius in miles to consider "at" the airport
  static const double _airportRadiusMiles = 3.0;

  // ─── Manhattan bounding box (approximate) ─────────────────
  static const double _manhattanLatMin = 40.700;
  static const double _manhattanLatMax = 40.882;
  static const double _manhattanLngMin = -74.020;
  static const double _manhattanLngMax = -73.907;

  // ─── NYC bounding box (all 5 boroughs, approximate) ───────
  static const double _nycLatMin = 40.490;
  static const double _nycLatMax = 40.920;
  static const double _nycLngMin = -74.260;
  static const double _nycLngMax = -73.680;

  // ─── Flat airport rates (Manhattan ↔ Airport) ─────────────
  static const Map<RouteType, Map<VehicleTier, double>> _airportFlatRates = {
    RouteType.airportManhattanJFK: {
      VehicleTier.sedan: 140.0,
      VehicleTier.suv: 150.0,
      VehicleTier.escalade: 170.0,
      VehicleTier.sprinter: 250.0,
      VehicleTier.miniCoach: 350.0,
    },
    RouteType.airportManhattanLGA: {
      VehicleTier.sedan: 120.0,
      VehicleTier.suv: 135.0,
      VehicleTier.escalade: 155.0,
      VehicleTier.sprinter: 220.0,
      VehicleTier.miniCoach: 310.0,
    },
    RouteType.airportManhattanNewark: {
      VehicleTier.sedan: 180.0,
      VehicleTier.suv: 210.0,
      VehicleTier.escalade: 240.0,
      VehicleTier.sprinter: 320.0,
      VehicleTier.miniCoach: 420.0,
    },
  };

  // ─── Local city base rates (up to 5 miles included) ───────
  static const Map<VehicleTier, double> _localBaseRate = {
    VehicleTier.sedan: 60.0,
    VehicleTier.suv: 80.0,
    VehicleTier.escalade: 95.0,
    VehicleTier.sprinter: 140.0,
    VehicleTier.miniCoach: 200.0,
  };

  static const Map<VehicleTier, double> _localExtraMileRate = {
    VehicleTier.sedan: 3.00,
    VehicleTier.suv: 3.75,
    VehicleTier.escalade: 4.25,
    VehicleTier.sprinter: 5.50,
    VehicleTier.miniCoach: 7.00,
  };

  static const double _localBaseIncludedMiles = 5.0;

  // ─── Outside city per-mile rates ──────────────────────────
  static const Map<VehicleTier, double> _outsideCityRate = {
    VehicleTier.sedan: 2.75,
    VehicleTier.suv: 3.50,
    VehicleTier.escalade: 4.25,
    VehicleTier.sprinter: 5.50,
    VehicleTier.miniCoach: 7.00,
  };

  // ─── Vehicle name → Tier mapping ──────────────────────────
  static VehicleTier getVehicleTier(String vehicleName) {
    final name = vehicleName.toLowerCase();

    if (name.contains('escalade') ||
        name.contains('range rover') ||
        name.contains('autobiography')) {
      return VehicleTier.escalade;
    }
    if (name.contains('suburban') || name.contains('expedition')) {
      return VehicleTier.suv;
    }
    if (name.contains('sprinter')) {
      return VehicleTier.sprinter;
    }
    if (name.contains('coach') || name.contains('mini coach')) {
      return VehicleTier.miniCoach;
    }
    // Mercedes-Maybach, BMW 7 Series, Audi A8 → Sedan
    return VehicleTier.sedan;
  }

  /// Returns a human-readable tier label
  static String getTierLabel(VehicleTier tier) {
    switch (tier) {
      case VehicleTier.sedan:
        return 'Sedan';
      case VehicleTier.suv:
        return 'Luxury SUV';
      case VehicleTier.escalade:
        return 'Executive SUV';
      case VehicleTier.sprinter:
        return 'Sprinter';
      case VehicleTier.miniCoach:
        return 'Mini Coach';
    }
  }

  // ─── Geo helpers ──────────────────────────────────────────
  static double _distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Haversine formula → miles
    const double earthRadiusMiles = 3958.8;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  static bool _isNearAirport(
    double lat,
    double lng,
    double airLat,
    double airLng,
  ) {
    return _distanceBetween(lat, lng, airLat, airLng) <= _airportRadiusMiles;
  }

  static bool _isInManhattan(double lat, double lng) {
    return lat >= _manhattanLatMin &&
        lat <= _manhattanLatMax &&
        lng >= _manhattanLngMin &&
        lng <= _manhattanLngMax;
  }

  static bool _isInNYC(double lat, double lng) {
    return lat >= _nycLatMin &&
        lat <= _nycLatMax &&
        lng >= _nycLngMin &&
        lng <= _nycLngMax;
  }

  // ─── Route detection ──────────────────────────────────────
  static RouteType detectRouteType(
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) {
    final pickupManhattan = _isInManhattan(pickupLat, pickupLng);
    final dropoffManhattan = _isInManhattan(dropoffLat, dropoffLng);

    final pickupJFK = _isNearAirport(pickupLat, pickupLng, _jfkLat, _jfkLng);
    final dropoffJFK = _isNearAirport(dropoffLat, dropoffLng, _jfkLat, _jfkLng);

    final pickupLGA = _isNearAirport(pickupLat, pickupLng, _lgaLat, _lgaLng);
    final dropoffLGA = _isNearAirport(dropoffLat, dropoffLng, _lgaLat, _lgaLng);

    final pickupEWR = _isNearAirport(pickupLat, pickupLng, _ewrLat, _ewrLng);
    final dropoffEWR = _isNearAirport(dropoffLat, dropoffLng, _ewrLat, _ewrLng);

    // Manhattan ↔ JFK
    if ((pickupManhattan && dropoffJFK) || (pickupJFK && dropoffManhattan)) {
      return RouteType.airportManhattanJFK;
    }

    // Manhattan ↔ LGA
    if ((pickupManhattan && dropoffLGA) || (pickupLGA && dropoffManhattan)) {
      return RouteType.airportManhattanLGA;
    }

    // Manhattan ↔ Newark
    if ((pickupManhattan && dropoffEWR) || (pickupEWR && dropoffManhattan)) {
      return RouteType.airportManhattanNewark;
    }

    // Both within NYC → local city
    final pickupNYC = _isInNYC(pickupLat, pickupLng);
    final dropoffNYC = _isInNYC(dropoffLat, dropoffLng);

    if (pickupNYC && dropoffNYC) {
      return RouteType.localCity;
    }

    return RouteType.outsideCity;
  }

  /// Get a human-readable label for the route
  static String getRouteLabel(RouteType type) {
    switch (type) {
      case RouteType.airportManhattanJFK:
        return 'Manhattan ↔ JFK Airport';
      case RouteType.airportManhattanLGA:
        return 'Manhattan ↔ LaGuardia Airport';
      case RouteType.airportManhattanNewark:
        return 'Manhattan ↔ Newark Airport';
      case RouteType.localCity:
        return 'NYC Local';
      case RouteType.outsideCity:
        return 'Outside NYC';
    }
  }

  // ─── Price calculation ────────────────────────────────────
  static PriceEstimate calculatePrice({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required double distanceMiles,
    required String vehicleName,
    bool isReturnTrip = false,
  }) {
    final tier = getVehicleTier(vehicleName);
    final routeType = detectRouteType(
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    );
    final effectiveMiles = distanceMiles * (isReturnTrip ? 2 : 1);

    // ── Airport flat rates ──
    if (_airportFlatRates.containsKey(routeType)) {
      final flatRate = _airportFlatRates[routeType]![tier] ?? 140.0;
      final totalFlat = flatRate * (isReturnTrip ? 2 : 1);
      return PriceEstimate(
        routeType: routeType,
        routeLabel: getRouteLabel(routeType),
        tier: tier,
        totalPrice: totalFlat,
        distanceMiles: effectiveMiles,
        isFlat: true,
      );
    }

    // ── Local city ──
    if (routeType == RouteType.localCity) {
      final base = _localBaseRate[tier] ?? 60.0;
      final extraRate = _localExtraMileRate[tier] ?? 3.0;
      final extraMiles = (effectiveMiles > _localBaseIncludedMiles)
          ? effectiveMiles - _localBaseIncludedMiles
          : 0.0;
      final total = base + (extraMiles * extraRate);
      return PriceEstimate(
        routeType: routeType,
        routeLabel: getRouteLabel(routeType),
        tier: tier,
        totalPrice: total,
        distanceMiles: effectiveMiles,
        baseRate: base,
        perMileRate: extraRate,
      );
    }

    // ── Outside city ──
    final rate = _outsideCityRate[tier] ?? 2.75;
    final total = effectiveMiles * rate;
    return PriceEstimate(
      routeType: routeType,
      routeLabel: getRouteLabel(routeType),
      tier: tier,
      totalPrice: total,
      distanceMiles: effectiveMiles,
      perMileRate: rate,
    );
  }

  /// Calculate prices for all tiers at once (for the quote panel)
  static Map<VehicleTier, PriceEstimate> calculateAllTierPrices({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required double distanceMiles,
    bool isReturnTrip = false,
  }) {
    final Map<VehicleTier, PriceEstimate> results = {};
    // Use representative vehicle names for each tier
    final tierVehicles = {
      VehicleTier.sedan: 'Mercedes-Maybach S 680',
      VehicleTier.suv: 'Suburban',
      VehicleTier.escalade: 'Cadillac Escalade ESV',
      VehicleTier.sprinter: 'Mercedes-Benz Sprinter Jet',
      VehicleTier.miniCoach: 'Mini Coach 27 pax',
    };

    for (final entry in tierVehicles.entries) {
      results[entry.key] = calculatePrice(
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        distanceMiles: distanceMiles,
        vehicleName: entry.value,
        isReturnTrip: isReturnTrip,
      );
    }
    return results;
  }
}
