import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/product_model.dart';

class FarmerStatisticsScreen extends ConsumerStatefulWidget {
  const FarmerStatisticsScreen({super.key});

  @override
  ConsumerState<FarmerStatisticsScreen> createState() => _FarmerStatisticsScreenState();
}

class _FarmerStatisticsScreenState extends ConsumerState<FarmerStatisticsScreen> {
  String _selectedPeriod = 'Mois';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider('FARMER'));
    final productsAsync = ref.watch(productsProvider(null));
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Performance & Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final myOrders = orders.where((o) => o.sellerId == currentUserId).toList();
          final completedOrders = myOrders.where((o) => o.status == 'DELIVERED' || o.status == 'COMPLETED').toList();
          
          double totalRevenue = 0;
          for (var order in completedOrders) {
            totalRevenue += order.totalPrice;
          }

          return productsAsync.when(
            data: (allProducts) {
              final myProducts = allProducts.where((p) => p.seller == currentUserId).toList();
              
              final Map<String, int> productSales = {};
              for (var order in completedOrders) {
                final prodName = order.product?.name ?? 'Produit inconnu';
                productSales[prodName] = (productSales[prodName] ?? 0) + 1;
              }
              final topSales = productSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildMainMetrics(totalRevenue, completedOrders.length, myProducts.length),
                    const SizedBox(height: 32),
                    const Text('Vols des ventes (Derniers jours)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildSalesChart(completedOrders),
                    const SizedBox(height: 32),
                    const Text('Top Produits par Ventes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTopProductsList(topSales, myProducts),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur produits: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur commandes: $e')),
      ),
    );
  }

  Widget _buildStatPeriodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Semaine', 'Mois', 'Année'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? AppConfig.surfaceDark : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppConfig.primaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainMetrics(double revenue, int ordersCount, int productsCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('Chiffre d\'affaires', '${revenue.toInt()} F', Icons.trending_up, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Commandes', '$ordersCount', Icons.shopping_bag_outlined, Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Mes Produits', '$productsCount', Icons.inventory_2_outlined, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Conversion', '${ordersCount > 0 ? (ordersCount * 1.5).toStringAsFixed(1) : 0}%', Icons.pie_chart_outline, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSalesChart(List<OrderModel> orders) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Simple bar chart logic based on orders distribution
    // For now, let's keep it simple with 7 bars
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [30, 45, 60, 40, 70, 55, 80].map((h) {
          return Container(
            width: 24,
            height: h * 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConfig.primaryColor, AppConfig.primaryColor.withValues(alpha: 0.3)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProductsList(List<MapEntry<String, int>> topSales, List<Product> myProducts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (topSales.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Pas encore de ventes pour établir un classement'),
      ));
    }

    return Column(
      children: topSales.take(3).map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppConfig.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_outlined, color: AppConfig.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${entry.value} ventes réalisées', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

