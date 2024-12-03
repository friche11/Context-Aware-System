import 'package:flutter/material.dart';
import '../models/puc_unit.dart';

class UnitsListScreen extends StatelessWidget {
  UnitsListScreen({Key? key}) : super(key: key);

  final List<PucUnit> units = [
    PucUnit(
      name: 'PUC Minas - Coração Eucarístico',
      address: 'Rua Dom José Gaspar, 500, Coração Eucarístico, Belo Horizonte - MG',
      latitude: -19.920830,
      longitude: -43.994290,
    ),
    PucUnit(
      name: 'PUC Minas - Barreiro',
      address: 'Av. Afonso Vaz de Melo, 1200, Barreiro, Belo Horizonte - MG',
      latitude: -19.977280,
      longitude: -44.015830,
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
            title: Text(unit.name),
            subtitle: Text(unit.address),
          );
        },
      ),
    );
  }
}
