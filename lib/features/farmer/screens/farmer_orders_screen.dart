import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config.dart';
import '../../orders/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../widgets/order_action_sheets.dart';

class FarmerOrdersScreen extends ConsumerWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider('FARMER'));

    return ordersAsync.when(
      data: (orders) {
        final activeOrders = orders.where((o) => ['PENDING', 'CONFIRMED', 'IN_TRANSIT'].contains(o.status)).toList();
        final completedOrders = orders.where((o) => ['DELIVERED', 'CANCELLED', 'DISPUTED'].contains(o.status)).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
            appBar: AppBar(
              centerTitle: false,
              title: const Text("Mes Commandes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => context.push('/notifications'),
                ),
                const SizedBox(width: 8),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: TabBar(
                labelColor: AppConfig.primaryColor,
                unselectedLabelColor: isDark ? AppConfig.textSubDark : Colors.grey,
                indicatorColor: AppConfig.primaryColor,
                tabs: [
                  Tab(text: 'Actives (${activeOrders.length})'),
                  Tab(text: 'Historique (${completedOrders.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildOrdersList(context, activeOrders),
                _buildOrdersList(context, completedOrders),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Aucune commande trouvée'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(context, order);
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPending = order.status == 'PENDING';
    
    Color statusColor;
    switch (order.status) {
      case 'PENDING': statusColor = AppConfig.warning; break;
      case 'CONFIRMED': statusColor = Colors.blue; break;
      case 'IN_TRANSIT': statusColor = Colors.orange; break;
      case 'DELIVERED': statusColor = AppConfig.success; break;
      case 'CANCELLED': statusColor = AppConfig.error; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: InkWell(
        onTap: () => context.push('/farmer/orders/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Commande #${order.id.substring(order.id.length - 4)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, color: AppConfig.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.buyer?.fullName ?? 'Client inconnu', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(order.product?.name ?? 'Produit inconnu', 
                          style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('${order.totalPrice.toInt()} F', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppConfig.primaryColor)),
                       Text('Qté: ${order.quantity}', 
                        style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => OrderActionSheets.showRefusalSheet(
                          context, 
                          orderId: order.id, 
                          buyerName: order.buyer?.fullName ?? 'Client'
                        ),
                        style: TextButton.styleFrom(foregroundColor: AppConfig.error),
                        child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => OrderActionSheets.showConfirmationSheet(
                          context, 
                          orderId: order.id, 
                          buyerName: order.buyer?.fullName ?? 'Client', 
                          product: order.product?.name ?? 'Produit'
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

