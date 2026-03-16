import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/double_back_to_exit.dart';

class TransporterLayout extends ConsumerWidget {
  final Widget child;
  const TransporterLayout({super.key, required this.child});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      (path: '/transporter',            icon: Icons.home_rounded,    iconSelected: Icons.home_rounded,    label: 'Accueil'),
      (path: '/transporter/missions',   icon: Icons.map_outlined,    iconSelected: Icons.map,             label: 'Missions'),
      (path: '/transporter/offers',     icon: Icons.local_offer_outlined, iconSelected: Icons.local_offer, label: 'Offres'),
      (path: '/transporter/deliveries', icon: Icons.local_shipping_outlined, iconSelected: Icons.local_shipping, label: 'Livraisons'),
      (path: '/transporter/messages',   icon: Icons.chat_bubble_outline, iconSelected: Icons.chat_bubble,     label: 'Messages'),
      (path: '/transporter/profile',    icon: Icons.person_outline,  iconSelected: Icons.person,          label: 'Profil'),
    ];

    // Better highlighting logic: find the tab that is a prefix of the current path
    // We sort by length descending to match the most specific path first (e.g., /transporter/missions before /transporter)
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
