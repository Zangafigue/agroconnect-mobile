import 'package:flutter/material.dart';
import '../../../core/config.dart';

class MissionFiltersModal extends StatefulWidget {
  const MissionFiltersModal({super.key});

  @override
  State<MissionFiltersModal> createState() => _MissionFiltersModalState();
}

class _MissionFiltersModalState extends State<MissionFiltersModal> {
  RangeValues _distanceRange = const RangeValues(0, 500);
  RangeValues _priceRange = const RangeValues(5000, 100000);
  double _weightCapacity = 5.0;

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
              Text(
                'Filtres de missions', 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _distanceRange = const RangeValues(0, 500);
                  _priceRange = const RangeValues(5000, 100000);
                  _weightCapacity = 5.0;
                }),
                child: Text('Réinitialiser', style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilterSection(
            isDark,
            'DISTANCE (KM)',
            '${_distanceRange.start.round()} - ${_distanceRange.end.round()} km',
            RangeSlider(
              values: _distanceRange,
              min: 0,
              max: 500,
              divisions: 10,
              activeColor: AppConfig.primaryColor,
              inactiveColor: AppConfig.primaryColor.withValues(alpha: 0.1),
              onChanged: (values) => setState(() => _distanceRange = values),
            ),
          ),
          const SizedBox(height: 24),
          _buildFilterSection(
            isDark,
            'TARIF (FCFA)',
            '${_priceRange.start.round()} - ${_priceRange.end.round()} F',
            RangeSlider(
              values: _priceRange,
              min: 5000,
              max: 200000,
              divisions: 20,
              activeColor: AppConfig.primaryColor,
              inactiveColor: AppConfig.primaryColor.withValues(alpha: 0.1),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
          ),
          const SizedBox(height: 24),
          _buildFilterSection(
            isDark,
            'POIDS MINIMUM (TONNES)',
            '${_weightCapacity.toStringAsFixed(1)} T',
            Slider(
              value: _weightCapacity,
              min: 0.5,
              max: 20,
              divisions: 39,
              activeColor: AppConfig.primaryColor,
              inactiveColor: AppConfig.primaryColor.withValues(alpha: 0.1),
              onChanged: (value) => setState(() => _weightCapacity = value),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Appliquer les filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark, String title, String value, Widget slider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppConfig.textSubDark : Colors.grey, 
                letterSpacing: 1.2,
              ),
            ),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConfig.primaryColor)),
          ],
        ),
        const SizedBox(height: 8),
        slider,
      ],
    );
  }
}