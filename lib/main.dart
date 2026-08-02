import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vTools Survey iOS',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(21.028511, 105.804817); // Mặc định Hà Nội
  bool _isLoading = true;
  String _locationInfo = "Đang tìm vị trí GPS...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Hàm xin quyền và lấy tọa độ GPS
  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
      _locationInfo = "Đang cập nhật vị trí...";
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _locationInfo = "Hãy bật GPS trên thiết bị!";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _locationInfo = "Quyền truy cập GPS bị từ chối.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _locationInfo = "GPS bị chặn trong Cài đặt iOS.";
      });
      return;
    }

    // Lấy vị trí thực tế
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
      _locationInfo = "Lat: ${position.latitude.toStringAsFixed(6)} | Lng: ${position.longitude.toStringAsFixed(6)}";
    });

    _mapController.move(_currentPosition, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('vTools Survey - Bản đồ GPS'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // 1. Hiển thị bản đồ OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vtools.vtoolsClone',
              ),
              // Marker Chấm xanh định vị
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Thanh hiển thị tọa độ GPS phía trên
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _locationInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Nút căn chỉnh vị trí GPS về giữa màn hình
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        backgroundColor: Colors.green,
        child: _isLoading 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Icon(Icons.gps_fixed, color: Colors.white),
      ),
    );
  }
}
