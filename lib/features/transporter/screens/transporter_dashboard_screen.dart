import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/delivery_map_widget.dart';
import 'package:latlong2/latlong.dart';

class TransporterDashboardScreen extends ConsumerWidget {
  const TransporterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
              // Header
              Row(
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
                  Row(
                    children: [
                      Text(
                        "Tableau de Bord",
                        style: TextStyle(
                          color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Stack(
                            children: [
                              Icon(Icons.notifications_none_rounded, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight, size: 20),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => context.push('/notifications'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Bonjour, ${user?.fullName ?? ''}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.waving_hand, color: AppConfig.primaryColor, size: 24),
                    ],
                  ),
                  Text(
                    'Prêt pour vos livraisons d\'aujourd\'hui ?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    '3',
                    'Missions dispo',
                    Icons.local_shipping_outlined,
                    AppConfig.primaryColor,
                    isDark,
                    onTap: () => context.go('/transporter/missions'),
                  ),
                  _buildStatCard(
                    context,
                    '12',
                    'Terminées',
                    Icons.check_circle_outline,
                    Colors.blue,
                    isDark,
                    onTap: () => context.go('/transporter/deliveries'),
                  ),
                  _buildStatCard(
                    context,
                    '2',
                    'Mes Offres',
                    Icons.local_offer_outlined,
                    Colors.orange,
                    isDark,
                    onTap: () => context.push('/transporter/offers'),
                  ),
                  _buildStatCard(
                    context,
                    '37 500 F',
                    'En attente payout',
                    Icons.account_balance_wallet_outlined,
                    Colors.amber,
                    isDark,
                    isCurrency: true,
                    onTap: () => context.go('/transporter/wallet'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Current Delivery
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ma livraison en cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EN ROUTE',
                      style: TextStyle(
                        color: AppConfig.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
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
                child: Column(
                  children: [
                    const DeliveryMapWidget(
                      pickup: LatLng(12.25, -2.36), // Koudougou
                      delivery: LatLng(12.37, -1.52), // Ouaga
                      transporter: LatLng(12.30, -2.00),
                      height: 180,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInfoChip(Icons.square_foot, '98 km', isDark),
                              const SizedBox(width: 8),
                              _buildInfoChip(Icons.scale, '2.5 T', isDark),
                              const SizedBox(width: 8),
                              _buildInfoChip(Icons.inventory_2_outlined, 'Céréales', isDark),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/transporter/messages/041'),
                                  icon: const Icon(Icons.call, size: 20),
                                  label: const Text('Contacter'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context.push('/transporter/deliveries/041'),
                                  icon: const Icon(Icons.map_outlined, size: 20),
                                  label: const Text('Détails'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConfig.primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Available Missions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Missions disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/transporter/missions'),
                    child: const Text('Voir tout', style: TextStyle(color: AppConfig.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.go('/transporter/missions'),
                child: _buildMissionCard(
                  'Bobo-Dioulasso → Ouaga',
                  '45 000 FCFA',
                  'Maïs • 5 Tonnes',
                  isDark,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/transporter/missions'),
                child: _buildMissionCard(
                  'Banfora → Koudougou',
                  '62 500 FCFA',
                  'Sucre • 10 Tonnes',
                  isDark,
                ),
              ),
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color, bool isDark, {bool isCurrency = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isCurrency ? 16 : 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppConfig.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(String route, String price, String details, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppConfig.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      route,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: AppConfig.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
