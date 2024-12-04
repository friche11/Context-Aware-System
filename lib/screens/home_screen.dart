import 'dart:async'; // Para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import 'units_list_screen.dart'; 
import '../services/unit_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  late MapController _mapController;
  LatLng? _currentLocation;
  late LatLng _lastLocation;
  bool _isAppInForeground = true; // Controle para saber se o app está em primeiro plano
  Timer? _locationUpdateTimer;  // Para controlar o intervalo de atualização de localização
  Set<String> _visitedUnits = {}; // Para armazenar as unidades já visitadas
  bool _isMapInteracting = false;

  final List<Map<String, dynamic>> pucUnits = [
    {
      'name': 'PUC Minas - Coração Eucarístico',
      'address': 'Rua Dom José Gaspar, 500, Coração Eucarístico, Belo Horizonte - MG',
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

   void _moveToLocation(LatLng location) {
    _mapController.move(location, 15.0);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addObserver(this);
    _lastLocation = LatLng(0.0, 0.0);
    _getCurrentLocation();

    // Atualiza a localização a cada 5 segundos, mas apenas quando o app estiver em primeiro plano
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (_isAppInForeground) {
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationUpdateTimer?.cancel(); // Cancela o Timer quando o widget é destruído
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _isAppInForeground = true; // App voltou para o primeiro plano
      });
    } else {
      setState(() {
        _isAppInForeground = false; // App foi enviado para segundo plano
      });
    }
  }

  // Função para obter a localização atual
  Future<void> _getCurrentLocation() async {
    String location = await _locationService.getCurrentLocation();
    List<String> coordinates = location.split(", ");
    if (coordinates.length == 2) {
      LatLng newLocation = LatLng(
        double.parse(coordinates[0].split(": ")[1]),
        double.parse(coordinates[1].split(": ")[1]),
      );

      // Verifica se a nova localização é diferente da última
      if (newLocation != _lastLocation) {
        setState(() {
          _currentLocation = newLocation;
          _lastLocation = newLocation;
        });
        // Verifica a proximidade com as unidades quando a localização é atualizada
        _checkProximity(newLocation);
      }
    }
  }

  // Callback para detectar mudanças na posição do mapa
  void _onPositionChanged(MapPosition position, bool hasGesture) {
    setState(() {
      _isMapInteracting = hasGesture; // Se houver interação manual, o valor será true
    });
  }

  // Função para verificar proximidade de uma unidade e mostrar a mensagem
  void _checkProximity(LatLng location) {
    // Verifica a distância entre a posição atual do usuário e as unidades
    for (var unit in pucUnits) {
      double distanceInMeters = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        unit['latitude'],
        unit['longitude'],
      );

      // Se a distância for menor que 100 metros, e a mensagem não foi enviada
      if (distanceInMeters < 100) {
        // Verifica se já enviamos a mensagem para esta unidade
        if (!_visitedUnits.contains(unit['name'])) {
          _showWelcomeMessage(unit['name']);
          setState(() {
            _visitedUnits.add(unit['name']); // Marca a unidade como visitada
          });
        }
      }
      // Se o usuário sair da área de 100 metros, permite reenviar a mensagem
      else if (distanceInMeters >= 100) {
        if (_visitedUnits.contains(unit['name'])) {
          setState(() {
            _visitedUnits.remove(unit['name']); // Remove a unidade da lista de visitadas
          });
        }
      }
    }
  }

  void _showWelcomeMessage(String unitName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bem-vindo!'),
        content: Text('Bem-vindo à PUC Minas unidade $unitName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localização')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                _currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentLocation!,
                          zoom: 15.0,
                          onPositionChanged: _onPositionChanged,
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
                                    point: LatLng(
                                        unit['latitude'], unit['longitude']),
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
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Move o mapa para a localização do usuário ao clicar no botão
                      if (_currentLocation != null) {
                        _mapController.move(_currentLocation!, 15.0);
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
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
