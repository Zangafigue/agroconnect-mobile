import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class VisitorPlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String? buttonText;
  final bool isLocked;

  const VisitorPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.buttonText,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        elevation: 0,
        leading: GoRouter.of(context).canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            )
          : null,
        actions: [
          if (title == "Messages")
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline, color: AppConfig.primaryColor, size: 20),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative Icon
              Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withAlpha(12),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConfig.primaryColor.withAlpha(51),
                          AppConfig.primaryColor.withAlpha(12),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConfig.primaryColor.withAlpha(25)),
                    ),
                    child: Icon(icon, size: 64, color: AppConfig.primaryColor),
                  ),
                  if (isLocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppConfig.bgDark : Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                title == "Messages" ? "Négociez en direct" : "Suivez vos commandes",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(buttonText ?? "S'inscrire / Se connecter", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.login),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "L'inscription est rapide et gratuite.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              
              const SizedBox(height: 40),
              // Footer info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: AppConfig.primaryColor.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConfig.primaryColor.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppConfig.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pourquoi nous rejoindre ?',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppConfig.primaryColor, fontSize: 13),
                          ),
                          Text(
                            title == "Messages" 
                              ? "Accédez aux prix du marché en temps réel et gérez vos livraisons."
                              : "Gérez vos achats agricoles et consultez l'historique de paiement.",
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
    );
  }
}
