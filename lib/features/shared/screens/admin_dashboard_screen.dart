import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/features/auth/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Administration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(), 
            icon: const Icon(Icons.logout, color: Colors.redAccent)
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, size: 80, color: AppConfig.primaryColor),
              ),
              const SizedBox(height: 32),
              const Text(
                'Espace Administrateur',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenue sur l\'interface de gestion globale d\'AgroConnect BF. Ce module est actuellement en cours de développement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, height: 1.5),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConfig.primaryColor.withAlpha(51)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppConfig.primaryColor),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Pour tester les fonctionnalités principales (Catalogue, Commandes, Messagerie), veuillez utiliser un compte Agriculteur ou Acheteur.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
