import 'package:flutter/material.dart';

class AppConfig {
  // static const String apiBaseUrl = 'https://agroconnect-backend.up.railway.app/api';
  // Développement local :
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String apiBaseUrl = 'http://localhost:3000/api'; // iOS Simulator

  // Cartographie — aucune clé requise (OpenStreetMap + OSRM gratuits)
  static const String osrmUrl = 'https://router.project-osrm.org';
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org';

  static const String appName = 'AgroConnect BF';
  
  // Couleurs principales
  static const Color primaryColor = Color(0xFF2f7f33); // Couleur verte harmonisée
  static const Color accentColor = Color(0xFF16a34a);
  
  // Couleurs de fond (Stitch designs references)
  static const Color bgLight = Color(0xFFf6f8f6);
  static const Color bgDark = Color(0xFF141e15);
  
  // Surfaces et bordures
  static const Color borderLight = Color(0xFFe2e8f0);
  static const Color borderDark = Color(0xFF1e293b);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1a241b);
  
  // Text Colors
  static const Color textMainLight = Color(0xFF0f172a);
  static const Color textSubLight = Color(0xFF64748b);
  static const Color textMainDark = Color(0xFFf8fafc);
  static const Color textSubDark = Color(0xFF94a3b8);

  // Status Colors
  static const Color success = Color(0xFF16a34a);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF3b82f6);
}
