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

  // Lista de unidades da PUC Minas com coordenadas atualizadas
  final List<Map<String, dynamic>> pucUnits = [
    {
      'name': 'PUC Minas - Coração Eucarístico',
      'address':
          'Rua Dom José Gaspar, 500, Coração Eucarístico, Belo Horizonte - MG',
      'latitude': -19.922731053725386,
      'longitude': -43.99262719082135,
    },
    {
      'name': 'PUC Minas - Barreiro',
      'address': 'Av. Afonso Vaz de Melo, 1200, Barreiro, Belo Horizonte - MG',
      'latitude': -19.97656921140693,
      'longitude': -44.02594928927729,
    },
    {
      'name': 'PUC Minas - Lourdes (Praça da Liberdade)',
      'address': 'Rua dos Aimorés, 1451, Lourdes, Belo Horizonte - MG',
      'latitude': -19.933209369332957,
      'longitude': -43.93717174753535,
    },
    {
      'name': 'PUC Minas - São Gabriel',
      'address': 'Rua Walter Ianni, 255, São Gabriel, Belo Horizonte - MG',
      'latitude': -19.85866915592615,
      'longitude': -43.91882869193867,
    },
  ];

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
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController.move(location, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localização')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
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
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          if (_currentLocation != null)
                            Marker(
                              point: _currentLocation!,
                              builder: (context) => const Icon(
                                Icons.location_pin,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ...pucUnits.map((unit) => Marker(
                                point:
                                    LatLng(unit['latitude'], unit['longitude']),
                                builder: (context) => GestureDetector(
                                  onTap: () => _showUnitDetails(context, unit),
                                  child: const Icon(
                                    Icons.location_city,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final LatLng? selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UnitsListScreen()),
                  );
                  if (selectedLocation != null) {
                    _moveToLocation(selectedLocation);
                  }
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

  void _showUnitDetails(BuildContext context, Map<String, dynamic> unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(unit['name']),
        content: Text(unit['address']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
