import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart'; // API do plugin para map_controller
import 'package:latlong2/latlong.dart'; // Para LatLng
import '../services/location_service.dart';
import 'units_list_screen.dart'; // Página de lista das unidades da PUC Minas

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  late MapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    String location = await _locationService.getCurrentLocation();
    List<String> coordinates = location.split(", ");
    if (coordinates.length == 2) {
      setState(() {
        _currentLocation = LatLng(
          double.parse(coordinates[0].split(": ")[1]),
          double.parse(coordinates[1].split(": ")[1]),
        );
      });
      _mapController.move(_currentLocation!, 15.0); // Move o mapa para a localização
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localização')),
      body: Column(
        children: [
          Expanded(
            flex: 3, // Ocupa 3 partes da tela
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currentLocation!,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            builder: (context) => const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: 1, // Ocupa 1 parte da tela
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UnitsListScreen()),
                  );
                },
                child: const Text('Ver Unidades da PUC Minas'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
