import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/vehicle_info_modal.dart';

import '../../shared/widgets/edit_profile_modal.dart';

class TransporterProfileScreen extends ConsumerWidget {
  const TransporterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
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
              "Profil",
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/transporter/settings'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppConfig.primaryColor, width: 4),
                            image: const DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBkFFhKJAK4PxtrkWVpmdHoP3k26OL9zSuxryKPK2gMb0rzZEHAAlZ5ehjlYzCUwXCnEacOAAQWNIR4OtlDd5FS_4OCd1YNgYKeSSodueNQRivudHjcum8mqK9-IlRY_ChE-MD2Jsd2XRgnPvJQhiXM9LrrHp1tJ-hkscAD6bnu3Bf7DPMwVh6DaYaY6ShqkDh7q2Mw9lwnqhGTA0FiOhaENjZfcRjYYX4romkhx0X6hwB8KGBHu8hreF5UIHLDU9QT1P08MVdy978'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppConfig.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                    user?.fullName ?? 'Transporteur',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'Transporteur',
                        style: TextStyle(color: AppConfig.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '4.2/5 (12 avis)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppConfig.textSubDark : Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const EditProfileModal(),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Modifier le profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // My Wallet Snapshot
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppConfig.surfaceDark : AppConfig.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.primaryColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mon Portefeuille', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Icon(Icons.account_balance_wallet, color: AppConfig.primaryColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBalanceBox('Disponible', '25 000 F', AppConfig.primaryColor, isDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBalanceBox('En attente', '37 500 F', Colors.orange, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => context.go('/transporter/wallet'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Voir mon portefeuille complet',
                              style: TextStyle(color: AppConfig.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: AppConfig.primaryColor, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // My Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 12),
                      child: Text('Mes informations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _buildInfoTile(Icons.call, 'Numéro de téléphone', user?.phone ?? '+226 70 XX XX XX', isDark),
                    _buildInfoTile(Icons.route, 'Zone d\'activité', user?.city ?? 'Ouagadougou et environs', isDark),
                    _buildInfoTile(
                      Icons.local_shipping, 
                      'Véhicule', 
                      'Camionnette 2 tonnes', 
                      isDark,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const VehicleInfoModal(),
                        );
                      },
                    ),
                    _buildInfoTile(
                      Icons.assignment_outlined, 
                      'Mes offres', 
                      'Gérer mes propositions', 
                      isDark,
                      onTap: () => context.push('/transporter/offers'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Capacities
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 12),
                      child: Text('Mes capacités', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppConfig.surfaceDark : AppConfig.bgLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.primaryColor.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shopping_cart_checkout, color: AppConfig.primaryColor),
                              SizedBox(width: 16),
                              // The following lines are added based on the instruction, assuming ValueTile is defined elsewhere or will be.
                              // If ValueTile is not defined, this will cause a compilation error.
                              // The instruction also had an extra closing parenthesis which has been removed for syntax correctness.
                              // ValueTile(label: 'Missions', value: '28'),
                              // ValueTile(label: 'Véhicule', value: user?.vehicleType ?? 'Camion 5T'),
                              // ValueTile(label: 'Localisation', value: user?.city ?? 'Bobo-Dioulasso'),
                              Text(
                                'Je peux aussi acheter des produits',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ],
                          ),
                          Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: AppConfig.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBox(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConfig.primaryColor, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppConfig.textSubDark : Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
