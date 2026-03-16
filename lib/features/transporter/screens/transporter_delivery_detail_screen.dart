import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config.dart';
import '../../shared/widgets/report_issue_modal.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../orders/providers/order_provider.dart';

class TransporterDeliveryDetailScreen extends ConsumerWidget {
  final String orderId;
  const TransporterDeliveryDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      body: orderAsync.when(
        data: (order) {
          final pickup = LatLng(order.pickupLat ?? 12.25, order.pickupLng ?? -2.36);
          final destination = LatLng(order.deliveryLat ?? 12.37, order.deliveryLng ?? -1.52);
          final truckPos = LatLng(order.transporterLat ?? 12.30, order.transporterLng ?? -2.00);

          return Stack(
            children: [
              // Full Screen Map
              FlutterMap(
                options: MapOptions(
                  initialCenter: truckPos,
                  initialZoom: 9.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.agroconnect.app',
                    tileBuilder: (context, tileWidget, tile) {
                      return isDark 
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              -1.0, 0.0, 0.0, 0.0, 255.0,
                              0.0, -1.0, 0.0, 0.0, 255.0,
                              0.0, 0.0, -1.0, 0.0, 255.0,
                              0.0, 0.0, 0.0, 1.0, 0.0,
                            ]),
                            child: tileWidget,
                          )
                        : tileWidget;
                    },
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [pickup, destination],
                        strokeWidth: 4,
                        color: AppConfig.primaryColor,
                        isDotted: true,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pickup,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.radio_button_checked, color: AppConfig.primaryColor, size: 24),
                        ),
                      ),
                      Marker(
                        point: destination,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 24),
                        ),
                      ),
                      Marker(
                        point: truckPos,
                        width: 60,
                        height: 60,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(color: AppConfig.primaryColor.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2),
                                ],
                              ),
                              child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Floating Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppConfig.surfaceDark : Colors.white).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIVRAISON ${order.id.substring(order.id.length - 6).toUpperCase()} — ${order.statusLabel.toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const Text(
                                'Temps réel activé',
                                style: TextStyle(color: AppConfig.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'report') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ReportIssueModal(orderId: orderId),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  Icon(Icons.report_problem, color: Colors.red, size: 20),
                                  SizedBox(width: 12),
                                  Text('Signaler un problème'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Map Controls
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    _buildMapControl(Icons.add, () {}),
                    const SizedBox(height: 1),
                    _buildMapControl(Icons.remove, () {}),
                    const SizedBox(height: 12),
                    _buildMapControl(Icons.my_location, () {}, color: AppConfig.primaryColor),
                  ],
                ),
              ),

              // Bottom Info Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                  decoration: BoxDecoration(
                    color: isDark ? AppConfig.surfaceDark : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.radio_button_checked, color: AppConfig.primaryColor, size: 18),
                                Container(width: 1, height: 30, color: AppConfig.primaryColor.withValues(alpha: 0.2)),
                                const Icon(Icons.location_on, color: Colors.red, size: 18),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRoutePoint('ORIGINE', '${order.pickupCity}, ${order.pickupAddress}'),
                                  const SizedBox(height: 16),
                                  _buildRoutePoint('DESTINATION', '${order.deliveryCity}, ${order.deliveryAddress}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildChip(Icons.straighten, 'Calcul...'),
                            const SizedBox(width: 8),
                            _buildChip(Icons.schedule, 'Estimation...'),
                            const SizedBox(width: 8),
                            _buildChip(Icons.monitor_weight_outlined, '${order.quantity} ${order.product?.unit ?? "unité(s)"}'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildParticipantCard(
                          isDark,
                          icon: Icons.store_outlined,
                          title: 'Expéditeur (Agriculteur)',
                          name: order.seller != null ? '${order.seller!.firstName} ${order.seller!.lastName}' : 'Vendeur inconnu',
                          location: order.pickupAddress ?? 'Adresse inconnue',
                          onMessage: () async {
                            try {
                              final recipientId = order.sellerId;
                              final repo = ref.read(messagingRepositoryProvider);
                              final chat = await repo.startConversation(recipientId, orderId: order.id);
                              if (context.mounted) {
                                context.push('/transporter/messages/${chat['_id']}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildParticipantCard(
                          isDark,
                          icon: Icons.person_outline,
                          title: 'Destinataire (Acheteur)',
                          name: order.buyer != null ? '${order.buyer!.firstName} ${order.buyer!.lastName}' : 'Client inconnu',
                          location: order.deliveryAddress,
                          onMessage: () async {
                            try {
                              final recipientId = order.buyerId;
                              final repo = ref.read(messagingRepositoryProvider);
                              final chat = await repo.startConversation(recipientId, orderId: order.id);
                              if (context.mounted) {
                                context.push('/transporter/messages/${chat['_id']}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.sync, size: 18),
                                label: const Text('Mise à jour position'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppConfig.primaryColor.withValues(alpha: 0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: AppConfig.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Confirmer livraison'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConfig.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF141e15).withValues(alpha: 0.9),
          border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
    );
  }

  Widget _buildRoutePoint(String label, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppConfig.primaryColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String name,
    required String location,
    VoidCallback? onMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppConfig.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (onMessage != null)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppConfig.primaryColor, size: 20),
              onPressed: onMessage,
            ),
        ],
      ),
    );
  }
}
