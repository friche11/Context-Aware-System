import 'package:geolocator/geolocator.dart';

class LocationService {
  // Método para verificar se o serviço de localização está habilitado
  Future<bool> isServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  // Método para verificar a permissão de localização
  Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission;
  }

  // Método para solicitar permissão de localização
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission;
  }

  // Método para obter a localização atual
  Future<String> getCurrentLocation() async {
    bool serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      return 'Serviço de localização desativado.';
    }

    // Verificar permissão
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Permissão de localização negada.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Permissão de localização negada permanentemente.';
    }

    // Obter a posição atual
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  }
}
