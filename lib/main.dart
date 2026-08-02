import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package0geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vTools Survey Full',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MeasureMode { none, distance, area }

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(21.028511, 105.804817);
  bool _isLoading = true;

  // VN-2000
  double _vn2000X = 0;
  double _vn2000Y = 0;
  double _meridian = 105.0; // Kinh tuyến trục mặc định

  // Bản đồ nền
  String _mapTileUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
  String _currentMapName = 'Google Vệ Tinh';

  // Chức năng Đo đạc & Điểm
  MeasureMode _measureMode = MeasureMode.none;
  final List<LatLng> _measurePoints = [];
  final List<Marker> _customMarkers = [];
  List<Polyline> _importedPolylines = [];

  double _calculatedDistance = 0.0;
  double _calculatedArea = 0.0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Chuyển đổi WGS84 -> VN-2000
  void _convertToVN2000(double lat, double lng) {
    try {
      var wgs84 = proj4.Projection.get('EPSG:4326') ??
          proj4.Projection.add('EPSG:4326', '+proj=longlat +datum=WGS84 +no_defs');

      var vn2000Def = '+proj=tmerc +lat_0=0 +lon_0=$_meridian +k=0.9999 +x_0=500000 +y_0=0 +ellps=WGS84 +units=m +no_defs';
      var vn2000 = proj4.Projection.add('VN2000', vn2000Def);

      var point = proj4.Point(x: lng, y: lat);
      var result = wgs84.transform(vn2000, point);

      setState(() {
        _vn2000X = result.y; // X trong VN-2000
        _vn2000Y = result.x; // Y trong VN-2000
      });
    } catch (_) {}
  }

  // Định vị GPS
  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    _convertToVN2000(position.latitude, position.longitude);
    _mapController.move(_currentPosition, 16.5);
  }

  // Tính khoảng cách (Mét)
  void _calculateDistance() {
    double total = 0.0;
    const Distance distance = Distance();
    for (int i = 0; i < _measurePoints.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, _measurePoints[i], _measurePoints[i + 1]);
    }
    setState(() => _calculatedDistance = total);
  }

  // Tính diện tích (m²) theo công thức Shoelace
  void _calculateArea() {
    if (_measurePoints.length < 3) {
      setState(() => _calculatedArea = 0.0);
      return;
    }
    double area = 0;
    for (int i = 0; i < _measurePoints.length; i++) {
      var p1 = _measurePoints[i];
      var p2 = _measurePoints[(i + 1) % _measurePoints.length];
      area += (p1.longitude * p2.latitude) - (p2.longitude * p1.latitude);
    }
    // Quy đổi ra mét vuông tương đối
    area = (area.abs() * 111319.9 * 111319.9) / 2;
    setState(() => _calculatedArea = area);
  }

  // Nhập file KML / GeoJSON
  Future<void> _importMapFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kml', 'json', 'geojson'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();

      try {
        var geojson = jsonDecode(content);
        List<Polyline> newLines = [];
        if (geojson['features'] != null) {
          for (var feature in geojson['features']) {
            var geometry = feature['geometry'];
            if (geometry != null && geometry['type'] == 'LineString') {
              List<LatLng> points = [];
              for (var coord in geometry['coordinates']) {
                points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
              }
              newLines.add(Polyline(points: points, strokeWidth: 3.0, color: Colors.redAccent));
            }
          }
        }
        setState(() => _importedPolylines = newLines);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã nạp ${newLines.length} ranh giới từ file!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa hỗ trợ đọc định dạng file này!')),
        );
      }
    }
  }

  // Đổi Kinh tuyến trục VN-2000
  void _showMeridianDialog() {
    TextEditingController controller = TextEditingController(text: _meridian.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cấu hình Kinh Tỉnh (KT Trục)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Kinh tuyến trục (Ví dụ: 105.0, 108.0)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _meridian = double.tryParse(controller.text) ?? 105.0;
                _convertToVN2000(_currentPosition.latitude, _currentPosition.longitude);
              });
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }

  // Chọn Bản đồ nền
  void _showMapTypeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(15),
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Text('Chọn bản đồ nền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.satellite_alt, color: Colors.blue),
              title: const Text('Google Satellite (Ảnh vệ tinh)'),
              onTap: () {
                setState(() {
                  _mapTileUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
                  _currentMapName = 'Google Vệ Tinh';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.green),
              title: const Text('Google Hybrid (Vệ tinh + Tên đường)'),
              onTap: () {
                setState(() {
                  _mapTileUrl = 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
                  _currentMapName = 'Google Hybrid';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain, color: Colors.orange),
              title: const Text('OpenStreetMap (Giao thông)'),
              onTap: () {
                setState(() {
                  _mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
                  _currentMapName = 'OpenStreetMap';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('vTools Survey GIS'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Đổi Kinh tuyến trục',
            onPressed: _showMeridianDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Nhập file bản đồ',
            onPressed: _importMapFile,
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Lớp bản đồ',
            onPressed: _showMapTypeSelector,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 16.0,
              onTap: (tapPosition, point) {
                if (_measureMode != MeasureMode.none) {
                  setState(() {
                    _measurePoints.add(point);
                    if (_measureMode == MeasureMode.distance) _calculateDistance();
                    if (_measureMode == MeasureMode.area) _calculateArea();
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _mapTileUrl,
                userAgentPackageName: 'com.vtools.vtoolsClone',
              ),
              PolylineLayer(polylines: _importedPolylines),

              // Vẽ đường đo khoảng cách
              if (_measurePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _measurePoints,
                      strokeWidth: 3.5,
                      color: Colors.yellow,
                    ),
                  ],
                ),

              // Vẽ vùng đo diện tích
              if (_measureMode == MeasureMode.area && _measurePoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _measurePoints,
                      color: Colors.red.withOpacity(0.3),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Marker hiển thị các điểm đo & điểm GPS
              MarkerLayer(
                markers: [
                  ..._measurePoints.map(
                    (p) => Marker(
                      point: p,
                      width: 15,
                      height: 15,
                      child: const Icon(Icons.circle, color: Colors.yellow, size: 12),
                    ),
                  ),
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.cyanAccent, size: 32),
                  ),
                ],
              ),
            ],
          ),

          // 2. Bảng Tọa độ VN-2000 & WGS84
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.black.withOpacity(0.8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nền: $_currentMapName', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('KT Trục: ${_meridian.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('VN2000 X: ${_vn2000X.toStringAsFixed(3)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Y: ${_vn2000Y.toStringAsFixed(3)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'WGS84: ${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Kết quả đo đạc thực địa
          if (_measureMode != MeasureMode.none)
            Positioned(
              bottom: 80,
              left: 15,
              right: 15,
              child: Card(
                color: Colors.amber[800],
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _measureMode == MeasureMode.distance
                            ? 'Khoảng cách: ${_calculatedDistance.toStringAsFixed(2)} m'
                            : 'Diện tích: ${_calculatedArea.toStringAsFixed(2)} m²',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _measurePoints.clear();
                            _calculatedDistance = 0;
                            _calculatedArea = 0;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // 4. Thanh công cụ Đo đạc & GPS bên dưới
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'btn1',
            backgroundColor: _measureMode == MeasureMode.distance ? Colors.orange : Colors.white,
            onPressed: () {
              setState(() {
                _measureMode = _measureMode == MeasureMode.distance ? MeasureMode.none : MeasureMode.distance;
                _measurePoints.clear();
              });
            },
            child: Icon(Icons.straighten, color: _measureMode == MeasureMode.distance ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'btn2',
            backgroundColor: _measureMode == MeasureMode.area ? Colors.orange : Colors.white,
            onPressed: () {
              setState(() {
                _measureMode = _measureMode == MeasureMode.area ? MeasureMode.none : MeasureMode.area;
                _measurePoints.clear();
              });
            },
            child: Icon(Icons.square_foot, color: _measureMode == MeasureMode.area ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'btn3',
            onPressed: _determinePosition,
            backgroundColor: Colors.green[700],
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.gps_fixed, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
