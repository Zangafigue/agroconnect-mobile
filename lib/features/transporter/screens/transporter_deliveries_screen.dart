import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../shared/widgets/delivery_map_widget.dart';
import '../widgets/delivery_status_modal.dart';
import 'package:latlong2/latlong.dart';

class TransporterDeliveriesScreen extends StatefulWidget {
  const TransporterDeliveriesScreen({super.key});

  @override
  State<TransporterDeliveriesScreen> createState() => _TransporterDeliveriesScreenState();
}

class _TransporterDeliveriesScreenState extends State<TransporterDeliveriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              "Livraisons",
              style: TextStyle(
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConfig.primaryColor,
          labelColor: AppConfig.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'En cours (1)'),
            Tab(text: 'Terminées (12)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOngoingTab(isDark),
          _buildCompletedTab(isDark),
        ],
      ),
    );
  }

  Widget _buildOngoingTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Order Card
          GestureDetector(
            onTap: () => context.push('/transporter/deliveries/041'),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Commande #041', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            Text('Koudougou → Ouagadougou', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConfig.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: const Text(
                            'EN ROUTE',
                            style: TextStyle(color: AppConfig.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const DeliveryMapWidget(
                    pickup: LatLng(12.25, -2.36),
                    delivery: LatLng(12.37, -1.52),
                    transporter: LatLng(12.30, -2.00),
                    height: 180,
                  ),
                  // Trip Stats
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppConfig.primaryColor.withValues(alpha: 0.05) : Colors.grey[50],
                      border: Border.symmetric(horizontal: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight)),
                    ),
                    child: const Row(
                      children: [
                        _StatItem('Distance', '100km'),
                        _StatItem('Temps est.', '1h30'),
                        _StatItem('Poids', '200kg'),
                      ],
                    ),
                  ),
                  // Participants
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildParticipantRow('Vendeur', 'Amadou K.', '+226 70 00 00 01', Icons.person, isDark),
                        const SizedBox(height: 12),
                        _buildParticipantRow('Acheteur', 'Fatima T.', '+226 76 00 00 02', Icons.person_pin, isDark),
                        const Divider(height: 32, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RÉMUNÉRATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                Text('10 000 FCFA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppConfig.primaryColor)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('LIBÉRÉE À LA LIVRAISON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/transporter/messages/041'),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Message'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const DeliveryStatusModal(orderId: '#041'),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Confirmer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConfig.primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 56),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LIVRAISONS RÉCENTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('Voir tout', style: TextStyle(color: AppConfig.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompactHistoryItem('Commande #038', '12 Mai 2024 • Bobo → Ouaga', '15 000 F', isDark),
          const SizedBox(height: 12),
          _buildCompactHistoryItem('Commande #035', '08 Mai 2024 • Banfora → Bobo', '8 500 F', isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompletedTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCompactHistoryItem(
            'Commande #${100 - index}',
            '0${index + 1} Mai 2024 • Trajet local',
            '${(index + 5) * 1000} F',
            isDark,
          ),
        );
      },
    );
  }

  Widget _buildParticipantRow(String label, String name, String phone, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.primaryColor.withValues(alpha: 0.08) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppConfig.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(phone, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call_outlined, color: Colors.grey, size: 20),
          style: IconButton.styleFrom(
            side: const BorderSide(color: Colors.white10),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactHistoryItem(String title, String subtitle, String price, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline, color: AppConfig.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text('Terminé', style: TextStyle(color: AppConfig.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
