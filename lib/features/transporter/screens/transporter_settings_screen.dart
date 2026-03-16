import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config.dart';
import '../../../core/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/report_issue_modal.dart';

class TransporterSettingsScreen extends ConsumerStatefulWidget {
  const TransporterSettingsScreen({super.key});

  @override
  ConsumerState<TransporterSettingsScreen> createState() => _TransporterSettingsScreenState();
}

class _TransporterSettingsScreenState extends ConsumerState<TransporterSettingsScreen> {
  bool _missionsNotify = true;
  bool _offersNotify = true;
  bool _messagesNotify = true;
  bool _paymentsNotify = true;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance
              _buildSectionHeader('Apparence'),
              _buildToggleItem(
                Icons.dark_mode_outlined, 
                'Mode sombre', 
                themeMode == ThemeMode.dark, 
                (v) => ref.read(themeProvider.notifier).toggleTheme(v),
              ),
              _buildValueItem(Icons.translate, 'Langue', 'Français', () {
                _showLanguageDialog(context);
              }),

              // Notifications
              _buildSectionHeader('Notifications'),
              _buildToggleItem(Icons.local_shipping_outlined, 'Nouvelles missions', _missionsNotify, (v) => setState(() => _missionsNotify = v)),
              _buildToggleItem(Icons.task_alt_rounded, 'Offres acceptées', _offersNotify, (v) => setState(() => _offersNotify = v)),
              _buildToggleItem(Icons.chat_bubble_outline_rounded, 'Messages', _messagesNotify, (v) => setState(() => _messagesNotify = v)),
              _buildToggleItem(Icons.payments_outlined, 'Paiements', _paymentsNotify, (v) => setState(() => _paymentsNotify = v)),

              // Security
              _buildSectionHeader('Sécurité'),
              _buildNavigationItem(Icons.lock_reset, 'Changer mon mot de passe', () {
                _showPasswordResetDialog(context);
              }),
              _buildInfoItem(Icons.verified_user_outlined, 'Email vérifié', Icons.check_circle, AppConfig.primaryColor),

              // Support
              _buildSectionHeader('Support & Aide'),
              _buildNavigationItem(Icons.help_outline, 'Centre d\'aide', () {
                _showInfoSnackbar(context, 'Ouverture du centre d\'aide...');
              }),
              _buildNavigationItem(Icons.support_agent, 'Contacter le service client', () {
                _showInfoSnackbar(context, 'Appel du service client...');
              }),
              _buildNavigationItem(Icons.report_problem_outlined, 'Signaler un problème', () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ReportIssueModal(orderId: 'GENERAL'),
                );
              }),

              // About
              _buildSectionHeader('À propos'),
              _buildSimpleItem(Icons.info_outline, 'Version', 'v1.0.0'),
              _buildNavigationItem(Icons.description_outlined, 'Conditions d\'utilisation', () {
                _showTermsOfService(context);
              }),
              _buildNavigationItem(Icons.policy_outlined, 'Politique de confidentialité', () {
                _showPrivacyPolicy(context);
              }),

              // Logout
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'AgroConnect BF © 2024 - Transporter Portal',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppConfig.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String label, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: _buildIcon(icon),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppConfig.primaryColor.withValues(alpha: 0.5),
        activeThumbColor: AppConfig.primaryColor,
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String label, String value, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: _buildIcon(icon),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: _buildIcon(icon),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, IconData trailingIcon, Color trailingColor) {
    return ListTile(
      leading: _buildIcon(icon),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Icon(trailingIcon, color: trailingColor, size: 20),
    );
  }

  Widget _buildSimpleItem(IconData icon, String label, String value) {
    return ListTile(
      leading: _buildIcon(icon),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
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
    _showPolicyModal(context, 'Conditions d\'utilisation', 'Ceci est une simulation des conditions d\'utilisation d\'AgroConnect BF. En utilisant nos services, vous acceptez que vos données de livraison soient partagées avec les expéditeurs et les destinataires concernés.');
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showPolicyModal(context, 'Politique de confidentialité', 'Votre vie privée est notre priorité. AgroConnect BF s\'engage à protéger vos données personnelles et à ne les utiliser que pour améliorer votre expérience de transporteur.');
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
          color: Theme.of(context).brightness == Brightness.dark ? AppConfig.bgDark : Colors.white,
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
