import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/double_back_to_exit.dart';

class UnifiedLayout extends ConsumerWidget {
  final Widget child;
  const UnifiedLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final location = GoRouterState.of(context).matchedLocation;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<({String path, IconData icon, IconData iconSelected, String label})> tabs = [
      (path: '/buyer', icon: Icons.storefront_outlined, iconSelected: Icons.storefront, label: 'Marché'),
    ];

    if (user.canSell) {
      tabs.add((path: '/farmer', icon: Icons.agriculture_outlined, iconSelected: Icons.agriculture, label: 'Ma Ferme'));
    }

    if (user.canDeliver) {
      tabs.add((path: '/transporter', icon: Icons.local_shipping_outlined, iconSelected: Icons.local_shipping, label: 'Livraisons'));
    }

    tabs.addAll([
      (path: '/messages', icon: Icons.chat_bubble_outline, iconSelected: Icons.chat_bubble, label: 'Messages'),
      (path: '/profile', icon: Icons.person_outline, iconSelected: Icons.person, label: 'Profil'),
    ]);

    int activeIndex = tabs.indexWhere((t) => location.startsWith(t.path));
    if (activeIndex == -1) activeIndex = 0;

    return DoubleBackToExit(
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
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
