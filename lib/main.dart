import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/LatLng.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('vTools Survey iOS (Demo)'),
          backgroundColor: Colors.green,
        ),
        body: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(21.028511, 105.804817), // Tọa độ Hà Nội
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.vtools_clone',
            ),
          ],
        ),
      ),
    );
  }
}
