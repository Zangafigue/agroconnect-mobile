import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../shared/widgets/delivery_map_widget.dart';
import '../widgets/submit_offer_modal.dart';
import '../widgets/mission_filters_modal.dart';
import 'package:latlong2/latlong.dart';

class MissionsMarketScreen extends StatefulWidget {
  const MissionsMarketScreen({super.key});

  @override
  State<MissionsMarketScreen> createState() => _MissionsMarketScreenState();
}

class _MissionsMarketScreenState extends State<MissionsMarketScreen> {
  String _selectedFilter = 'Toutes';
  final List<String> _filters = [
    'Toutes',
    '< 100 km',
    '100-300 km',
    '> 300 km',
    'Céréales',
    'Légumes'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "AgroConnect BF",
                  style: TextStyle(
                    color: isDark ? Colors.white : AppConfig.textMainLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              "Missions",
              style: TextStyle(
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'Mes Offres',
            onPressed: () => context.push('/transporter/offers'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher une mission...',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: AppConfig.primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppConfig.primaryColor),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const MissionFiltersModal(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                        },
                        selectedColor: AppConfig.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(
                          color: isSelected ? AppConfig.primaryColor : (isDark ? Colors.white10 : Colors.grey[300]!),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Missions Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Missions disponibles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Missions Feed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMissionCard(
                    id: '#045',
                    date: '11 mars 2026',
                    pickup: 'Bobo-Dioulasso, Secteur 22',
                    delivery: 'Ouagadougou, Secteur 15',
                    product: 'Maïs sec • 500 kg • 50 sacs',
                    value: '250 000 FCFA',
                    distance: '360 km',
                    duration: '4h30',
                    weight: '500 kg',
                    points: const [LatLng(11.18, -4.29), LatLng(12.37, -1.52)],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildMissionCard(
                    id: '#048',
                    date: '12 mars 2026',
                    pickup: 'Koudougou, Secteur 5',
                    delivery: 'Ouagadougou, Marché de Gounghin',
                    product: 'Tomates • 120 kg',
                    value: '45 000 FCFA',
                    distance: '100 km',
                    duration: '1h15',
                    weight: '120 kg',
                    points: const [LatLng(12.25, -2.36), LatLng(12.37, -1.52)],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  // Assigned mission
                  Opacity(
                    opacity: 0.6,
                    child: _buildMissionCard(
                      id: '#039',
                      date: '08 mars 2026',
                      pickup: 'Banfora',
                      delivery: 'Bobo-Dioulasso',
                      product: 'Sucre • 2 Tonnes',
                      value: '1 200 000 FCFA',
                      distance: '85 km',
                      duration: '1h10',
                      weight: '2 T',
                      status: 'Mission attribuée',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({
    required String id,
    required String date,
    required String pickup,
    required String delivery,
    required String product,
    required String value,
    required String distance,
    required String duration,
    required String weight,
    List<LatLng>? points,
    String? status,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande $id',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                    ),
                  ],
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppConfig.surfaceDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const Icon(Icons.more_vert, color: AppConfig.primaryColor),
              ],
            ),
          ),
          if (points != null)
            DeliveryMapWidget(
              pickup: points[0],
              delivery: points[1],
              height: 180,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoChip(Icons.straighten, distance, isDark),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.schedule, duration, isDark),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.agriculture, weight, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.inventory_2_outlined, product, isDark),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.payments_outlined, 'Valeur : $value', isDark, isBold: true),
                const SizedBox(height: 12),
                _buildLocationRow(Icons.trip_origin, 'Collecte', pickup, Colors.green, isDark),
                const SizedBox(height: 8),
                _buildLocationRow(Icons.location_on, 'Livraison', delivery, Colors.red, isDark),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coordonnées complètes révélées après acceptation de votre offre',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.amber[200] : Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: status == null ? () => context.push('/transporter/messages/${id.replaceAll('#', '')}') : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Poser une question', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: status == null ? () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SubmitOfferModal(orderId: id, initialPrice: value),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Faire une offre', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppConfig.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConfig.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConfig.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String address, Color iconColor, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
