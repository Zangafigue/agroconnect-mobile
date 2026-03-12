import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config.dart';

class DeliveryMapWidget extends StatefulWidget {
  final LatLng pickup;
  final LatLng delivery;
  final LatLng? transporter;
  final double height;

  const DeliveryMapWidget({
    super.key,
    required this.pickup,
    required this.delivery,
    this.transporter,
    this.height = 220,
  });

  @override State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  List<LatLng> _route = [];
  String _distance = '';
  String _duration = '';

  @override void initState() { super.initState(); _fetchRoute(); }

  Future<void> _fetchRoute() async {
    try {
      final url = '${AppConfig.osrmUrl}/route/v1/driving/'
          '${widget.pickup.longitude},${widget.pickup.latitude};'
          '${widget.delivery.longitude},${widget.delivery.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      final route = data['routes'][0];

      final coords = (route['geometry']['coordinates'] as List)
          .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      final distKm = (route['legs'][0]['distance'] / 1000).toStringAsFixed(0);
      final durMin = (route['legs'][0]['duration'] / 60).toInt();
      final durStr = durMin > 60 ? '${durMin ~/ 60}h${durMin % 60}min' : '${durMin}min';

      setState(() { _route = coords; _distance = '$distKm km'; _duration = durStr; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (widget.pickup.latitude  + widget.delivery.latitude)  / 2,
      (widget.pickup.longitude + widget.delivery.longitude) / 2,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 7),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agroconnect.bf', // Requis par OpenStreetMap
                ),
                if (_route.isNotEmpty) PolylineLayer(polylines: [
                  Polyline(points: _route, color: const Color(0xFF16a34a), strokeWidth: 4),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: widget.pickup, width: 36, height: 36,
                    child: Icon(Icons.location_on, color: Colors.green[700], size: 36),
                  ),
                  Marker(
                    point: widget.delivery, width: 36, height: 36,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
                  if (widget.transporter != null) Marker(
                    point: widget.transporter!, width: 36, height: 36,
                    child: const Icon(Icons.local_shipping, color: Colors.blue, size: 30),
                  ),
                ]),
              ],
            ),
          ),
        ),
        if (_distance.isNotEmpty)
          Container(
            color: const Color(0xFFf0fdf4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip('📏 $_distance'),
                const SizedBox(width: 8),
                _Chip('⏱ $_duration'),
              ],
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFbbf7d0)),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}
