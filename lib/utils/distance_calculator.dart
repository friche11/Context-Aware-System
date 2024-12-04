import 'dart:math';

class DistanceService {

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3;
    final double phi1 = lat1 * (pi / 180);
    final double phi2 = lat2 * (pi / 180);
    final double deltaPhi = (lat2 - lat1) * (pi / 180);
    final double deltaLambda = (lon2 - lon1) * (pi / 180);

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
  
}
