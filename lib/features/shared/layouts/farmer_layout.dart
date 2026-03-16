import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/double_back_to_exit.dart';

class FarmerLayout extends ConsumerWidget {
  final Widget child;
  const FarmerLayout({super.key, required this.child});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      (path: '/farmer',          icon: Icons.home_outlined,         iconSelected: Icons.home_rounded,    label: 'Accueil'),
      (path: '/farmer/products', icon: Icons.inventory_2_outlined,  iconSelected: Icons.inventory_2,     label: 'Produits'),
      (path: '/farmer/orders',   icon: Icons.shopping_cart_outlined, iconSelected: Icons.shopping_cart,   label: 'Commandes'),
      (path: '/farmer/messages', icon: Icons.chat_bubble_outline,   iconSelected: Icons.chat_bubble,     label: 'Messages'),
      (path: '/farmer/profile',  icon: Icons.person_outline,        iconSelected: Icons.person,          label: 'Profil'),
    ];

    final sortedTabs = List.from(tabs)..sort((a, b) => b.path.length.compareTo(a.path.length));
    final activeIndex = tabs.indexOf(
      sortedTabs.firstWhere(
        (t) => location.startsWith(t.path),
        orElse: () => tabs[0],
      ),
    );

    return DoubleBackToExit(
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: activeIndex,
            selectedItemColor: const Color(0xFF16a34a),
            unselectedItemColor: const Color(0xFF9ca3af),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            onTap: (i) => context.go(tabs[i].path),
            items: tabs.map((t) {
              final isSelected = tabs.indexOf(t) == activeIndex;
              return BottomNavigationBarItem(
                icon: Icon(isSelected ? t.iconSelected : t.icon),
                label: t.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
