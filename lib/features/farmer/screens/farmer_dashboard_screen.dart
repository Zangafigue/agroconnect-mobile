import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config.dart';
import '../../orders/providers/order_provider.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/order_model.dart';
import '../../farmer/widgets/order_action_sheets.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider('FARMER'));
    final productsAsync = ref.watch(productsProvider(null));
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text("AgroConnect BF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => productsAsync.when(
          data: (products) => _buildContent(context, orders, products, isDark, user),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur produits: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur commandes: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<OrderModel> orders, List<dynamic> products, bool isDark, User? user) {
    final totalRevenue = orders
        .where((o) => o.status == 'DELIVERED')
        .fold(0.0, (sum, o) => sum + o.totalPrice);
    final activeOrders = orders.where((o) => o.status == 'PENDING' || o.status == 'CONFIRMED' || o.status == 'IN_TRANSIT').length;
    final urgentOrder = orders.where((o) => o.status == 'PENDING').firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bonjour, ${user?.fullName ?? ''} ! 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  label: 'Revenus (F)',
                  value: '${totalRevenue.toInt()}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppConfig.primaryColor,
                  onTap: () => context.push('/farmer/wallet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  label: 'Actives',
                  value: '$activeOrders',
                  icon: Icons.inventory_2_outlined,
                  color: AppConfig.warning,
                  onTap: () => context.push('/farmer/orders'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildAddProductBanner(context),
          const SizedBox(height: 32),
          
          const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildQuickActionTile(
            context,
            icon: Icons.shopping_basket_outlined,
            title: 'Mes produits',
            subtitle: 'Gérer vos articles',
            count: products.length.toString(),
            color: Colors.blue,
            onTap: () => context.push('/farmer/products'),
          ),
          _buildQuickActionTile(
            context,
            icon: Icons.list_alt,
            title: 'Toutes les commandes',
            subtitle: '${orders.length} au total',
            count: orders.length.toString(),
            color: Colors.orange,
            onTap: () => context.push('/farmer/orders'),
          ),
          const SizedBox(height: 32),
          
          if (urgentOrder != null) ...[
            const Text('Commande en attente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildUrgentOrderCard(context, urgentOrder, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgentOrderCard(BuildContext context, OrderModel order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('COMMANDE #${order.id.substring(order.id.length - 4)}', 
                style: TextStyle(
                  color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                )
              ),
              Text('${order.totalPrice.toInt()} F', style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(context, Icons.inventory_2_outlined, 'Produit', isDark),
              const SizedBox(width: 8),
              _buildInfoChip(context, Icons.scale_outlined, '${order.quantity}', isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => OrderActionSheets.showRefusalSheet(context, orderId: order.id, buyerName: 'Client'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.error,
                    side: const BorderSide(color: AppConfig.error),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => OrderActionSheets.showConfirmationSheet(context, orderId: order.id, buyerName: 'Client', product: 'Produit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String label, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prêt à vendre ?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Publiez un nouveau produit et atteignez des milliers d\'acheteurs.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/farmer/products/new'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConfig.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ajouter un produit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, String? count, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
        ),
        tileColor: isDark ? AppConfig.surfaceDark : Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[600], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: isDark ? AppConfig.textSubDark : Colors.grey),
          ],
        ),
      ),
    );
  }
}
