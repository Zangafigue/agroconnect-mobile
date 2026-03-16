import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class VisitorHomeScreen extends StatelessWidget {
  const VisitorHomeScreen({super.key});

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
              "Accueil",
              style: TextStyle(
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.language, color: AppConfig.primaryColor),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCsraQ0dz_t5m8hkeuUVFkBz21-8ap29CsyH1y50jOjuSfJFC6Ih7zHwEkMdRleY4Tpyovs3JTXRsLDV2bP6ldXKV-c4mCa76ZoL23fsZ_x0wa9GNCwYmf5EOuVpvOQo3MmPlkNL0MPPhzIaf_NJu0SVGdIVoIUY6IsFyZNFpRBcQJ6ZSAMgRld6djPVZn8l2AJ-VaBZN6mhrtJIolM8lYgSZmvBtliwtOvQ5M6dMJD27CPzixSjaiw0A1R55cr5zkrSqur07BUM9s',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(178),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor.withAlpha(229),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'BURKINA FASO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  Text(
                    "L'agriculture burkinabé à portée de main",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Connectez-vous directement avec les producteurs, acheteurs et transporteurs de tout le pays pour dynamiser vos échanges agricoles.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureItem(Icons.agriculture_rounded, "Producteurs", isDark),
                  _buildFeatureItem(Icons.local_shipping_rounded, "Transport", isDark),
                  _buildFeatureItem(Icons.shopping_basket_rounded, "Marchés", isDark),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/visitor-catalogue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppConfig.primaryColor.withAlpha(102),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Parcourir le catalogue", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/login'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
                        width: 2,
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    ),
                    child: Text(
                      "Créer un compte / Se connecter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              "© 2024 AgroConnect BF. Soutenons nos agriculteurs locaux.",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppConfig.primaryColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppConfig.primaryColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
          ),
        ),
      ],
    );
  }
}
