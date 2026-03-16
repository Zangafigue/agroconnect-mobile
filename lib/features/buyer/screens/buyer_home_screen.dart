import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/providers/order_provider.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider('BUYER'));
    final productsAsync = ref.watch(productsProvider(null));
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${user?.fullName ?? ''} ! 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ordersAsync.when(
                    data: (orders) => _buildStatsGrid(context, isDark, orders),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur stats: $e'),
                  ),
                  const SizedBox(height: 24),
                  ordersAsync.when(
                    data: (orders) {
                      final activeOrder = orders.where((o) => o.status == 'IN_TRANSIT').firstOrNull;
                      if (activeOrder == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          _buildActiveDeliveryCard(context, isDark, activeOrder),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  _buildSectionHeader(context, "Recommandations", () => context.go('/buyer/catalogue')),
                  const SizedBox(height: 12),
                  productsAsync.when(
                    data: (products) => _buildRecommendationsList(context, isDark, products.take(5).toList()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur produits: $e'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Dernières Commandes", () => context.go('/buyer/orders')),
                  const SizedBox(height: 12),
                  ordersAsync.when(
                    data: (orders) => _buildRecentOrders(context, orders.take(3).toList()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur commandes: $e'),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
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
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConfig.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                isDark ? AppConfig.bgDark : AppConfig.bgLight,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => context.push('/notifications'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark, List<OrderModel> orders) {
    final totalSpent = orders.where((o) => o.status != 'CANCELLED').fold(0.0, (sum, o) => sum + o.totalPrice);
    final inProgress = orders.where((o) => ['PENDING', 'CONFIRMED', 'IN_TRANSIT'].contains(o.status)).length;
    final delivered = orders.where((o) => o.status == 'DELIVERED').length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        _buildStatCard(context, "Total Achats", "${totalSpent.toInt()} F", Icons.shopping_bag_outlined, AppConfig.primaryColor, isDark, () => context.go('/buyer/orders')),
        _buildStatCard(context, "En cours", "$inProgress", Icons.local_shipping_outlined, AppConfig.warning, isDark, () => context.go('/buyer/orders')),
        _buildStatCard(context, "Livrés", "$delivered", Icons.check_circle_outline, AppConfig.success, isDark, () => context.go('/buyer/orders')),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveryCard(BuildContext context, bool isDark, OrderModel order) {
    return GestureDetector(
      onTap: () => context.push('/buyer/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            colors: [
              isDark ? AppConfig.surfaceDark : Colors.white,
              AppConfig.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping, color: AppConfig.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Livraison en cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Commande #${order.id.substring(order.id.length - 4)} • ${order.product?.name ?? 'Produit'}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: 150, // Simulated
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.pickupCity ?? "Origine", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(order.deliveryCity, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onSeeAll,
          child: const Text("Voir tout", style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildRecommendationsList(BuildContext context, bool isDark, List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Aucune recommandation'));
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => context.push('/product/${product.id}'),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                      ),
                    ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                        const SizedBox(height: 4),
                        Text("${product.price.toInt()} F/${product.unit}", style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Aucune commande récente'));
    }
    return Column(
      children: orders.map((order) => _buildRecentOrderTile(context, order, Theme.of(context).brightness == Brightness.dark)).toList(),
    );
  }

  Widget _buildRecentOrderTile(BuildContext context, OrderModel order, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: InkWell(
        onTap: () => context.push('/buyer/orders/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppConfig.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Commande #${order.id.substring(order.id.length - 4)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("${order.statusLabel} • ${order.createdAt.toString().split(' ')[0]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text("${order.totalPrice.toInt()} F", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
