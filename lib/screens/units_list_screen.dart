import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Para LatLng
import '../models/puc_unit.dart';

class UnitsListScreen extends StatelessWidget {
  UnitsListScreen({Key? key}) : super(key: key);

  final List<PucUnit> units = [
    PucUnit(
      name: 'PUC Minas - Coração Eucarístico',
      address:
          'Rua Dom José Gaspar, 500, Coração Eucarístico, Belo Horizonte - MG',
      latitude: -19.922731053725386,
      longitude: -43.99262719082135,
    ),
    PucUnit(
      name: 'PUC Minas - Barreiro',
      address: 'Av. Afonso Vaz de Melo, 1200, Barreiro, Belo Horizonte - MG',
      latitude: -19.97656921140693,
      longitude: -44.02594928927729,
    ),
    PucUnit(
      name: 'PUC Minas - Lourdes (Praça da Liberdade)',
      address: 'Rua dos Aimorés, 1451, Lourdes, Belo Horizonte - MG',
      latitude: -19.933209369332957,
      longitude: -43.93717174753535,
    ),
    PucUnit(
      name: 'PUC Minas - São Gabriel',
      address: 'Rua Walter Ianni, 255, São Gabriel, Belo Horizonte - MG',
      latitude: -19.85866915592615,
      longitude: -43.91882869193867,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades da PUC Minas')),
      body: ListView.builder(
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return ListTile(
            leading:
                const Icon(Icons.location_city, size: 40, color: Colors.blue),
            title: Text(unit.name),
            subtitle: Text(unit.address),
            onTap: () {
              Navigator.pop(
                context,
                LatLng(unit.latitude, unit.longitude),
              );
            },
          );
        },
      ),
    );
  }
}
