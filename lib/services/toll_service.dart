/// Service to estimate toll costs for NYC routes
class TollService {
  // ─── NYC Common Toll Costs (2026) ─────────────────────────
  static const double _gwBridge = 17.00;          // George Washington Bridge
  static const double _lincolnTunnel = 17.00;     // Lincoln Tunnel  
  static const double _hollandTunnel = 17.00;     // Holland Tunnel
  static const double _queensMidtown = 11.19;     // Queens Midtown Tunnel
  static const double _verrazzano = 14.00;        // Verrazano-Narrows Bridge
  static const double _rfkBridge = 11.19;         // RFK/Triborough Bridge
  static const double _throgs =11.19;         // Throgs Neck Bridge
  static const double _whitestoneBridge = 11.19;  // Whitestone Bridge
  
  // Airport tolls
  static const double _jfkAirtrain = 8.50;        // JFK AirTrain fee

  /// Estimate toll cost based on route detection
  /// Returns toll amount in USD
  static double estimateTollCost({
    required String origin,
    required String destination,
    required String routePolyline,
    required bool hasTolls,
  }) {
    if (!hasTolls) return 0.0;

    final originLower = origin.toLowerCase();
    final destLower = destination.toLowerCase();
    final combined = '$originLower $destLower';

    double totalTolls = 0.0;

    // JFK routes (AirTrain + likely bridge/tunnel)
    if (combined.contains('jfk') || combined.contains('kennedy')) {
      totalTolls += _jfkAirtrain;
      // Most JFK routes from Manhattan use Queens Midtown or similar
      if (combined.contains('manhattan')) {
        totalTolls += _queensMidtown;
      }
      return totalTolls;
    }

    // Newark routes (Holland/Lincoln Tunnel likely)
    if (combined.contains('newark') || combined.contains('ewr')) {
      totalTolls += _lincolnTunnel; // Most common route
      return totalTolls;
    }

    // LaGuardia routes
    if (combined.contains('laguardia') || combined.contains('lga')) {
      if (combined.contains('manhattan')) {
        totalTolls += _queensMidtown;
      }
      return totalTolls;
    }

    // Manhattan <-> Outer boroughs/NJ
    if (combined.contains('manhattan')) {
      if (combined.contains('new jersey') || combined.contains('nj') || 
          combined.contains('jersey city') || combined.contains('hoboken')) {
        totalTolls += _lincolnTunnel; // Most common
        return totalTolls;
      }
      
      if (combined.contains('brooklyn') || combined.contains('staten island')) {
        totalTolls += _queensMidtown; // Average tunnel cost
        return totalTolls;
      }

      if (combined.contains('bronx')) {
        totalTolls += _rfkBridge;
        return totalTolls;
      }
    }

    // If tolls detected but no specific route match, use average
    if (hasTolls) {
      return 12.00; // Average NYC toll
    }

    return 0.0;
  }

  /// Get detailed toll breakdown as string
  static String getTollBreakdown(double tollAmount) {
    if (tollAmount == 0) return '';
    return 'Tolls included: \$$tollAmount';
  }
}
