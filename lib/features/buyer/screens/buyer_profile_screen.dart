import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/edit_profile_modal.dart';

class BuyerProfileScreen extends ConsumerWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppConfig.primaryColor,
            elevation: 0,
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
                    const Text(
                      "AgroConnect BF",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Profil",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/buyer/settings'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
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
                              image: const DecorationImage(
                                image: NetworkImage('https://i.pravatar.cc/150?u=buyer1'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.fullName ?? 'Client AgroConnect',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.blue, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Acheteur Certifié',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                  // Action Buttons
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
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppConfig.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, color: AppConfig.primaryColor),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Info Section
                  _buildSectionHeader('INFORMATIONS PERSONNELLES'),
                  const SizedBox(height: 16),
                  _buildInfoCard(isDark, [
                    _buildInfoRow(context, Icons.phone_outlined, 'Téléphone', user?.phone ?? '+226 71 22 33 44'),
                    _buildDivider(context),
                    _buildInfoRow(context, Icons.email_outlined, 'Email', user?.email ?? 'moussa.diallo@agro.bf'),
                  ]),

                  const SizedBox(height: 32),

                  // Addresses Section
                  _buildSectionHeader('MES ADRESSES FAVORITES'),
                  const SizedBox(height: 16),
                  _buildAddressesList(isDark),

                  const SizedBox(height: 32),

                  // Stats / Activities
                  _buildSectionHeader('ACTIVITÉ D\'ACHAT'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBox(context, '12', 'Commandes', Icons.shopping_bag_outlined),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '450k', 'Total (FCFA)', Icons.payments_outlined),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '3', 'En attente', Icons.schedule),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Security & Preferences
                  _buildSectionHeader('PRÉFÉRENCES'),
                  const SizedBox(height: 16),
                  _buildInfoCard(isDark, [
                    _buildPreferenceRow(context, Icons.storefront_outlined, 'Mode Commerce (Vendre)', false, (v) {}),
                    _buildDivider(context),
                    _buildPreferenceRow(context, Icons.notifications_active_outlined, 'Recevoir des offres personnalisées', true, (v) {}),
                    _buildDivider(context),
                    _buildPreferenceRow(context, Icons.location_searching, 'Me suggérer des produits proches', true, (v) {}),
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

  Widget _buildAddressesList(bool isDark) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAddressCard('Maison (Principal)', 'Ouaga, Secteur 15', Icons.home, true, isDark),
          const SizedBox(width: 12),
          _buildAddressCard('Bureau', 'Ouaga, Zone d\'Activités', Icons.work, false, isDark),
          const SizedBox(width: 12),
          _buildAddressCard('Entrepôt', 'Bobo, Zone Industrielle', Icons.warehouse, false, isDark),
          const SizedBox(width: 12),
          _buildAddAddressButton(isDark),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String sub, IconData icon, bool isDefault, bool isDark) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : AppConfig.borderLight)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDefault ? AppConfig.primaryColor : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
              ],
            ),
          ),
          if (isDefault) const Icon(Icons.check_circle, color: AppConfig.primaryColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton(bool isDark) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight, style: BorderStyle.none),
      ),
      child: Material(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: const Icon(Icons.add, color: AppConfig.primaryColor),
        ),
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
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
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
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(BuildContext context, IconData icon, String label, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppConfig.primaryColor.withValues(alpha: 0.3),
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
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
