import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/edit_profile_modal.dart';

class FarmerProfileScreen extends ConsumerWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppConfig.primaryColor,
            elevation: 0,
            title: const Text("Profil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/farmer/settings'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppConfig.primaryColor,
                          AppConfig.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'profile_pic',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(user?.profilePicture ?? 'https://i.pravatar.cc/150?u=${user?.id ?? 'default'}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.fullName ?? 'Agriculteur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.isVerified == true ? 'Agriculteur Vérifié' : 'Agriculteur Non Vérifié',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const EditProfileModal(),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Modifier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppConfig.borderDark : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, color: AppConfig.primaryColor),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('INFORMATIONS PERSONNELLES'),
                  const SizedBox(height: 16),
                  _buildInfoCard(isDark, [
                    _buildInfoRow(context, Icons.phone_outlined, 'Téléphone', user?.phone ?? 'Non renseigné'),
                    _buildDivider(context),
                    _buildInfoRow(context, Icons.email_outlined, 'Email', user?.email ?? 'Non renseigné'),
                    _buildDivider(context),
                    _buildInfoRow(context, Icons.location_on_outlined, 'Localisation', user?.city ?? user?.address ?? 'Non renseigné'),
                  ]),

                  const SizedBox(height: 32),

                  _buildSectionHeader('STATISTIQUES DE VENTE'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBox(context, '${user?.totalEarned.toInt() ?? 0}', 'Gains (F)', Icons.shopping_basket_outlined),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '${user?.averageRating ?? 0}', 'Note', Icons.star_outline, color: Colors.amber),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '${user?.totalRatings ?? 0}', 'Avis', Icons.chat_bubble_outline),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('MON PORTEFEUILLE'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConfig.accentColor.withValues(alpha: 0.1),
                          AppConfig.accentColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppConfig.accentColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Solde disponible', style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('${user?.walletBalance.toInt() ?? 0} FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConfig.accentColor)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppConfig.accentColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: AppConfig.accentColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWalletStat('En attente', '${user?.walletPending.toInt() ?? 0} F', isDark),
                            _buildWalletStat('Total gagné', '${user?.totalEarned.toInt() ?? 0} F', isDark, isPositive: true),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.push('/farmer/wallet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.accentColor,
                            foregroundColor: AppConfig.bgDark,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Gérer mon argent', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('PRÉFÉRENCES'),
                  const SizedBox(height: 16),
                  _buildInfoCard(isDark, [
                    _buildPreferenceRow(Icons.shopping_cart_outlined, 'Je peux aussi acheter des produits', user?.canBuy ?? true, (v) {}),
                    _buildDivider(context),
                    _buildPreferenceRow(Icons.local_shipping_outlined, 'Je peux aussi livrer des produits', user?.role == 'TRANSPORTER', (v) {}),
                  ]),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppConfig.primaryColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConfig.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppConfig.textSubDark : Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(IconData icon, String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConfig.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppConfig.primaryColor.withValues(alpha: 0.5),
            activeThumbColor: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? AppConfig.borderDark : AppConfig.borderLight);
  }

  Widget _buildStatBox(BuildContext context, String value, String label, IconData icon, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppConfig.primaryColor, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppConfig.textSubDark : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStat(String label, String value, bool isDark, {bool isPositive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : (isDark ? Colors.white : AppConfig.textMainLight),
          ),
        ),
      ],
    );
  }
}

