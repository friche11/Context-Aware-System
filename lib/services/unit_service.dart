import '../utils/distance_calculator.dart';

class UnitService {
  // Lista de unidades da PUC Minas
  static final List<Map<String, dynamic>> pucUnits = [
    {
      'name': 'PUC Minas - Coração Eucarístico',
      'latitude': -19.922731053725386,
      'longitude': -43.99262719082135,
    },
    {
      'name': 'PUC Minas - Barreiro',
      'latitude': -19.97656921140693,
      'longitude': -44.02594928927729,
    },
    {
      'name': 'PUC Minas - Lourdes (Praça da Liberdade)',
      'latitude': -19.933209369332957,
      'longitude': -43.93717174753535,
    },
    {
      'name': 'PUC Minas - São Gabriel',
      'latitude': -19.85866915592615,
      'longitude': -43.91882869193867,
    },
  ];

  static Map<String, dynamic>? getNearestUnit(double latitude, double longitude) {
    double minDistance = double.infinity;
    Map<String, dynamic>? nearestUnit;

    for (var unit in pucUnits) {
      double distance = DistanceService.calculateDistance(
        latitude, longitude,
        unit['latitude'], unit['longitude'],
      );

      if (distance < minDistance && distance <= 100.0) {
        minDistance = distance;
        nearestUnit = unit;
      }
    }

    return nearestUnit;
  }
}
