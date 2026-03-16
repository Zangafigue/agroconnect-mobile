import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class VisitorProfileScreen extends StatelessWidget {
  const VisitorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppConfig.bgDark.withAlpha(204) : AppConfig.bgLight.withAlpha(204),
        elevation: 0,
        centerTitle: true,
        leading: GoRouter.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            )
          : Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle, color: AppConfig.primaryColor),
            ),
        title: const Text('Profil Visiteur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero / Identity
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2D20) : Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(color: AppConfig.primaryColor.withAlpha(51), width: 4),
                        ),
                        child: const Icon(Icons.person_outline, size: 60, color: Color(0xFF9FBCA0)),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppConfig.bgDark : Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.no_accounts, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Bienvenue sur AgroConnect', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Connectez-vous pour accéder au marché burkinabè', style: TextStyle(color: Color(0xFF9FBCA0))),
                ],
              ),
            ),

            // CTAs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('/register'),
                    icon: const Icon(Icons.app_registration),
                    label: const Text('Créer un compte', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      backgroundColor: isDark ? const Color(0xFF1F2D20) : Colors.transparent,
                      side: BorderSide(color: isDark ? const Color(0xFF2C3F2D) : Colors.grey[300]!),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // Benefits Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2D20) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2C3F2D) : Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAxXTjNwWOUJ4NJayADtv1XgQxZhE7IgXk_aWkW3IMmcYnaFqgErODVA9Pa5ZkdPc2GTHZ7WqpEFFXWShSCt2fk735oIYo2VZ7KReStVjmvB0wZingoDFlMQcpIbibBFyY2elMMX0DL0lVyT6rg7R6-k7wbFVDQWcKpLdyKom6Kw2m2uwVumCcH28G3awXoRuD-U-mQWS779607RqiKGzmL5NeVRk321tyHdgScJU1ZuDG74A4isBKBxTbIB6OXQxk9XecHdjLA9sI',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pourquoi nous rejoindre ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildBenefitItem(Icons.storefront, 'Devenez Vendeur', 'Proposez vos récoltes directement aux acheteurs.', isDark),
                          const SizedBox(height: 12),
                          _buildBenefitItem(Icons.local_shipping, 'Suivi de Commandes', 'Gerez vos achats et livraisons en temps réel.', isDark),
                          const SizedBox(height: 12),
                          _buildBenefitItem(Icons.forum, 'Chat Direct', 'Échangez avec les agriculteurs et fournisseurs locaux.', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings List
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('PARAMÈTRES & AIDE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF9FBCA0))),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: isDark ? const Color(0xFF2C3F2D) : Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    Icons.language, 
                    'Langue', 
                    isDark, 
                    trailingText: 'Français',
                    onTap: () => _showLanguagePicker(context, isDark),
                  ),
                  _buildSettingsTile(
                    Icons.help, 
                    'Centre d\'aide', 
                    isDark,
                    onTap: () => _showHelpCenter(context, isDark),
                  ),
                  _buildSettingsTile(
                    Icons.gavel, 
                    'Conditions d\'utilisation', 
                    isDark,
                    onTap: () => _showInfoModal(context, isDark, 'Conditions d\'utilisation', 'Contenu des CGU à venir...'),
                  ),
                  _buildSettingsTile(
                    Icons.info, 
                    'À propos d\'AgroConnect BF', 
                    isDark, 
                    isLast: true,
                    onTap: () => _showAboutModal(context, isDark),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text('Version 2.4.0 • Made for Burkina Faso', style: TextStyle(fontSize: 12, color: Color(0xFF9FBCA0))),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.bgDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisir la langue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildLanguageItem(context, 'Français', '🇫🇷', true, isDark),
            _buildLanguageItem(context, 'English', '🇬🇧', false, isDark),
            _buildLanguageItem(context, 'Mooré', '🇧🇫', false, isDark),
            _buildLanguageItem(context, 'Dioula', '🇧🇫', false, isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String name, String flag, bool selected, bool isDark) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected ? const Icon(Icons.check_circle, color: AppConfig.primaryColor) : null,
      onTap: () => Navigator.pop(context),
    );
  }

  void _showHelpCenter(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.bgDark : Colors.white,
        title: const Text('Centre d\'aide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Comment passer une commande ?'), trailing: Icon(Icons.chevron_right)),
            ListTile(title: Text('Sécurité des paiements'), trailing: Icon(Icons.chevron_right)),
            ListTile(title: Text('Contacter le support'), trailing: Icon(Icons.chevron_right)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
      ),
    );
  }

  void _showAboutModal(BuildContext context, bool isDark) {
    showAboutDialog(
      context: context,
      applicationName: 'AgroConnect BF',
      applicationVersion: '2.4.0',
      applicationIcon: const Icon(Icons.grid_view_rounded, color: AppConfig.primaryColor, size: 40),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('La plateforme de référence pour connecter les agriculteurs burkinabè aux marchés nationaux et internationaux.'),
        ),
      ],
    );
  }

  void _showInfoModal(BuildContext context, bool isDark, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.bgDark : Colors.white,
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Compris'))],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConfig.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title : ',
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 13),
              children: [
                TextSpan(
                  text: subtitle,
                  style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF9FBCA0)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool isDark, {String? trailingText, bool isLast = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: isDark ? const Color(0xFF2C3F2D).withAlpha(127) : Colors.grey[100]!)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppConfig.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(color: Color(0xFF9FBCA0), fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF9FBCA0), size: 18),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}
