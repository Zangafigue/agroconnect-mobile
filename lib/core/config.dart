import 'package:flutter/material.dart';

class AppConfig {
  static const String apiBaseUrl = 'https://agroconnect-backend.up.railway.app/api';
  // Développement local :
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // Cartographie — aucune clé requise (OpenStreetMap + OSRM gratuits)
  static const String osrmUrl = 'https://router.project-osrm.org';
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org';

  static const String appName = 'AgroConnect BF';
  static const Color primaryColor = Color(0xFF16a34a);
}
