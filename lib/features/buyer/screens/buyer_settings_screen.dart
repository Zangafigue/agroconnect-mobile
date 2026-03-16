import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../../core/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/report_issue_modal.dart';

class BuyerSettingsScreen extends ConsumerStatefulWidget {
  const BuyerSettingsScreen({super.key});

  @override
  ConsumerState<BuyerSettingsScreen> createState() => _BuyerSettingsScreenState();
}

class _BuyerSettingsScreenState extends ConsumerState<BuyerSettingsScreen> {
  bool _newOffersNotify = true;
  bool _shippingNotify = true;
  bool _messagesNotify = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Apparence
            _buildSectionHeader('APPARENCE'),
            _buildSettingsCard(isDark, [
              _buildToggleItem(
                context,
                Icons.dark_mode_outlined, 
                'Mode sombre', 
                themeMode == ThemeMode.dark, 
                (v) => ref.read(themeProvider.notifier).toggleTheme(v),
              ),
              _buildDivider(context),
              _buildValueItem(context, Icons.translate, 'Langue', 'Français', () => _showLanguageDialog(context)),
            ]),

            // Section: Notifications
            _buildSectionHeader('NOTIFICATIONS'),
            _buildSettingsCard(isDark, [
              _buildToggleItem(context, Icons.local_offer_outlined, 'Nouvelles offres', _newOffersNotify, (v) => setState(() => _newOffersNotify = v)),
              _buildDivider(context),
              _buildToggleItem(context, Icons.local_shipping_outlined, 'Suivi de livraison', _shippingNotify, (v) => setState(() => _shippingNotify = v)),
              _buildDivider(context),
              _buildToggleItem(context, Icons.chat_bubble_outline_rounded, 'Messages', _messagesNotify, (v) => setState(() => _messagesNotify = v)),
            ]),

            // Section: Sécurité
            _buildSectionHeader('SÉCURITÉ'),
            _buildSettingsCard(isDark, [
              _buildNavigationItem(context, Icons.lock_reset, 'Changer mon mot de passe', () => _showPasswordResetDialog(context)),
              _buildDivider(context),
              _buildInfoItem(context, Icons.verified_user_outlined, 'Email vérifié', Icons.check_circle, AppConfig.success),
            ]),

            // Section: Support
            _buildSectionHeader('SUPPORT & AIDE'),
            _buildSettingsCard(isDark, [
              _buildNavigationItem(context, Icons.help_outline, 'Centre d\'aide', () => _showInfoSnackbar(context, 'Ouverture du centre d\'aide...')),
              _buildDivider(context),
              _buildNavigationItem(context, Icons.support_agent, 'Contacter le service client', () => _showInfoSnackbar(context, 'Appel du service client...')),
              _buildDivider(context),
              _buildNavigationItem(context, Icons.report_problem_outlined, 'Signaler un problème', () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ReportIssueModal(orderId: 'GENERAL'),
                );
              }),
            ]),

            // Section: À propos
            _buildSectionHeader('À PROPOS'),
            _buildSettingsCard(isDark, [
              _buildSimpleItem(context, Icons.info_outline, 'Version', 'v1.0.1'),
              _buildDivider(context),
              _buildNavigationItem(context, Icons.description_outlined, 'Conditions d\'utilisation', () => _showTermsOfService(context)),
              _buildDivider(context),
              _buildNavigationItem(context, Icons.policy_outlined, 'Politique de confidentialité', () => _showPrivacyPolicy(context)),
            ]),

            // Logout
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.error.withValues(alpha: 0.1),
                  foregroundColor: AppConfig.error,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  side: BorderSide(color: AppConfig.error.withValues(alpha: 0.2)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'AgroConnect BF © 2024 - Buyer Portal',
                style: TextStyle(fontSize: 10, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 32, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppConfig.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _buildToggleItem(BuildContext context, IconData icon, String label, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: _buildIcon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppConfig.primaryColor.withValues(alpha: 0.3),
        activeThumbColor: AppConfig.primaryColor,
      ),
    );
  }

  Widget _buildValueItem(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: _buildIcon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, size: 20),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: _buildIcon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
      trailing: Icon(Icons.chevron_right, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, size: 20),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, IconData trailingIcon, Color trailingColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: _buildIcon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
      trailing: Icon(trailingIcon, color: trailingColor, size: 20),
    );
  }

  Widget _buildSimpleItem(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: _buildIcon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
      trailing: Text(value, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13)),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(height: 1, indent: 60, endIndent: 16, color: isDark ? AppConfig.borderDark : AppConfig.borderLight);
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppConfig.primaryColor, size: 20),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppConfig.primaryColor),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: const Text('Souhaitez-vous recevoir un lien de réinitialisation par email ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showInfoSnackbar(context, 'Lien envoyé à votre adresse email');
            },
            child: const Text('ENVOYER', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'Français', true),
            _buildLanguageOption(context, 'Mooré', false),
            _buildLanguageOption(context, 'Dioula', false),
            _buildLanguageOption(context, 'Fulfuldé', false),
            _buildLanguageOption(context, 'English', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected ? const Icon(Icons.check, color: AppConfig.primaryColor) : null,
      onTap: () {
        Navigator.pop(context);
        _showInfoSnackbar(context, 'Langue changée : $language');
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    _showPolicyModal(context, 'Conditions d\'utilisation', 'Ceci est une simulation des conditions d\'utilisation d\'AgroConnect BF pour les acheteurs. En utilisant nos services, vous acceptez que vos transactions soient traitées de manière sécurisée.');
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showPolicyModal(context, 'Politique de confidentialité', 'Votre vie privée est notre priorité. AgroConnect BF s\'engage à protéger vos données personnelles d\'acheteur.');
  }

  void _showPolicyModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
