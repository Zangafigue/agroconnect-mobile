import 'package:flutter/material.dart';
import '../../../core/config.dart';

class VehicleInfoModal extends StatelessWidget {
  const VehicleInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Détails du véhicule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1519003722824-194d4455a60c?q=80&w=2075&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('MODÈLE', 'Mercedes Sprinter 2022', Icons.directions_car_filled_outlined, isDark),
          _buildDetailRow('IMMATRICULATION', 'BF 1234 XY', Icons.badge_outlined, isDark),
          _buildDetailRow('CAPACITÉ MAX', '2.5 Tonnes', Icons.scale_outlined, isDark),
          _buildDetailRow('TYPE DE CORPS', 'Frigorifique', Icons.ac_unit_outlined, isDark),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Colors.green, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Véhicule Vérifié', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Tous les documents (Assurance, Visite) sont à jour.', style: TextStyle(color: Colors.green, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: AppConfig.primaryColor.withValues(alpha: 0.5)),
            ),
            child: const Text('Modifier les informations', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, letterSpacing: 1)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
