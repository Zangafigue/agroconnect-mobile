import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialCity;

  const MapLocationPicker({
    super.key,
    this.initialLocation,
    this.initialCity,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  LatLng _selectedLocation = const LatLng(12.3714, -1.5197); // Ouagadougou
  String _selectedCity = '';
  bool _isReverseGeocoding = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
    }
    _selectedCity = widget.initialCity ?? '';
  }

  Future<void> _reverseGeocode(LatLng location) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=10';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'AgroConnect/1.0 (contact@agroconnect.bf)',
      });
      final data = jsonDecode(response.body);
      
      String city = data['address']['city'] ?? 
                   data['address']['town'] ?? 
                   data['address']['village'] ?? 
                   data['address']['county'] ?? 
                   'Burkina Faso';
                   
      setState(() {
        _selectedCity = city;
      });
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    } finally {
      setState(() => _isReverseGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Choisir l\'emplacement'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'location': _selectedLocation,
                'city': _selectedCity,
              });
            },
            child: const Text('Valider', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.agroconnect.bf',
                maxZoom: 19,
                maxNativeZoom: 19,
                tileBuilder: (context, tileWidget, tile) => tileWidget,
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint('Tile error: $error');
                },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Ici',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_city, color: AppConfig.primaryColor),
                        const SizedBox(width: 12),
                        _isReverseGeocoding 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Expanded(child: Text(_selectedCity.isEmpty ? 'Sélectionnez un point' : _selectedCity, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
