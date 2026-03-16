import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import '../widgets/double_back_to_exit.dart';

class VisitorLayout extends StatelessWidget {
  final Widget child;

  const VisitorLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/visitor-messages')) return 2;
    if (location.startsWith('/visitor-profile')) return 3;
    if (location.startsWith('/visitor-orders')) return 1;
    return 0; // Default to 'Marché' (Home, Catalogue, Product Detail)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/visitor-orders');
        break;
      case 2:
        context.go('/visitor-messages');
        break;
      case 3:
        context.go('/visitor-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
          selectedItemColor: AppConfig.primaryColor,
          unselectedItemColor: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Marché',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Commandes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profil',
            ),
          ],
        ),
      ),
    ),
  );
}
}
