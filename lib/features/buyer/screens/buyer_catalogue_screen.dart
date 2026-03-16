import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../../core/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BuyerCatalogueScreen extends ConsumerStatefulWidget {
  const BuyerCatalogueScreen({super.key});

  @override
  ConsumerState<BuyerCatalogueScreen> createState() => _BuyerCatalogueScreenState();
}

class _BuyerCatalogueScreenState extends ConsumerState<BuyerCatalogueScreen> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
            elevation: 0,
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
                  "Catalogue",
                  style: TextStyle(
                    color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => context.push('/notifications'),
              ),
              const SizedBox(width: 8),
            ],
            foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppConfig.bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, size: 20),
                      hintText: 'Rechercher un produit...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      _buildCategoryItem('Tous', isActive: _selectedCategory == 'Tous', isDark: isDark),
                      _buildCategoryItem('Céréales', isActive: _selectedCategory == 'Céréales', isDark: isDark),
                      _buildCategoryItem('Légumes', isActive: _selectedCategory == 'Légumes', isDark: isDark),
                      _buildCategoryItem('Fruits', isActive: _selectedCategory == 'Fruits', isDark: isDark),
                      _buildCategoryItem('Tubercules', isActive: _selectedCategory == 'Tubercules', isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          productsAsync.when(
            data: (products) {
              final filteredProducts = _searchQuery.isEmpty 
                  ? products 
                  : products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              
              if (filteredProducts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Aucun produit trouvé')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product, isDark);
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Erreur: $err')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, {bool isActive = false, required bool isDark}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppConfig.primaryColor : (isDark ? AppConfig.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : (isDark ? AppConfig.borderDark : AppConfig.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.price.toInt()} FCFA / ${product.unit}',
                    style: const TextStyle(
                      color: AppConfig.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.category,
                          style: TextStyle(fontSize: 11, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/product/${product.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
                        foregroundColor: AppConfig.primaryColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Commander', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
