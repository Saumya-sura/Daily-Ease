import 'dart:math' as math;

/// Zero-cost Location Utilities using pure mathematical calculations (Haversine formula).
/// No Google Maps API or external paid services required.
class LocationUtils {
  /// Radius of Earth in Kilometers
  static const double earthRadiusKm = 6371.0;

  /// Default local matching radius in kilometers
  static const double defaultRadiusKm = 5.0;

  /// Calculate the great-circle distance between two GPS coordinates in kilometers.
  /// Uses pure trigonometric Haversine formula (100% free, zero network requests).
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Checks if a target location is within the specified radius (default 5.0 km).
  static bool isWithinRadius({
    required double consumerLat,
    required double consumerLon,
    required double providerLat,
    required double providerLon,
    double radiusKm = defaultRadiusKm,
  }) {
    final distance = calculateDistanceKm(
      lat1: consumerLat,
      lon1: consumerLon,
      lat2: providerLat,
      lon2: providerLon,
    );
    return distance <= radiusKm;
  }

  /// Format distance for UI display (e.g., '1.2 km away' or '450 m away').
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
