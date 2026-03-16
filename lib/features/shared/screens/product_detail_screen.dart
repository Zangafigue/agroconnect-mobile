import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/features/shared/widgets/login_required_dialog.dart';
import 'package:agroconnect_bf/features/auth/providers/auth_provider.dart';
import '../../farmer/widgets/edit_product_modal.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../../core/models/product_model.dart';
import '../widgets/location_picker.dart';
import 'package:latlong2/latlong.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      data: (product) {
        final userId = ref.read(authProvider).user?.id;
        final isOwner = userId != null && userId == product.seller;
        return _buildContent(context, product, Theme.of(context).brightness == Brightness.dark, isOwner, ref.read(authProvider).isLoggedIn);
      },
      loading: () => Scaffold(
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Product product, bool isDark, bool isOwner, bool isLoggedIn) {
    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(isLoggedIn ? '/buyer/catalogue' : '/visitor-catalogue');
            }
          },
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                            const SizedBox(height: 4),
                            Text(product.category, style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${product.price.toInt()} F", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppConfig.primaryColor)),
                          Text("par ${product.unit}", style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stock Info
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppConfig.primaryColor, size: 20),
                        const SizedBox(width: 16),
                        Text(
                          'Stock disponible : ${product.quantity} ${product.unit}',
                          style: TextStyle(color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                // Product Location Map
                if (product.lat != null && product.lng != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Localisation du produit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 150,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(product.lat!, product.lng!),
                                initialZoom: 12,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.agroconnect.bf',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(product.lat!, product.lng!),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.blue, size: 30),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_city, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(product.city, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOwner) // Quantity and Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.grey[200],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: AppConfig.primaryColor),
                                onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                              ),
                              Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.add, color: AppConfig.primaryColor),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('${(product.price * _quantity).toInt()} F', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppConfig.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditProductModal(product: product),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier le produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        if (isLoggedIn)
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () async {
                                try {
                                  final repo = ref.read(messagingRepositoryProvider);
                                  final chat = await repo.startConversation(product.seller, productId: product.id);
                                  if (context.mounted) {
                                    context.push('/buyer/messages/${chat['_id']}');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: const BorderSide(color: AppConfig.primaryColor),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: AppConfig.primaryColor),
                            ),
                          ),
                        if (isLoggedIn) const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () => _showOrderConfirmationSheet(context, product, isDark),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Passer la commande', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationSheet(BuildContext context, Product product, bool isDark) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    if (!isLoggedIn) {
      showLoginRequiredDialog(context, featureName: 'la commande');
      return;
    }

    LatLng? selectedLocation;
    final cityController = TextEditingController(text: product.city);
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 20,
            right: 20,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Confirmer la commande', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Quantité: $_quantity ${product.unit}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              const Text('Adresse de livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Ex: Maison face à la pharmacie...',
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapLocationPicker(
                        initialLocation: selectedLocation,
                        initialCity: cityController.text,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setModalState(() {
                      selectedLocation = result['location'];
                      cityController.text = result['city'];
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppConfig.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cityController.text.isEmpty ? 'Préciser sur la carte' : cityController.text,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  if (addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez renseigner une adresse de livraison'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _placeOrder(product, addressController.text, cityController.text, selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirmer et Payer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(Product product, String address, String city, LatLng? location) async {
    try {
      final repository = ref.read(orderRepositoryProvider);
      final orderData = {
        'productId': product.id,
        'quantity': _quantity,
        'deliveryAddress': address,
        'deliveryCity': city,
        'deliveryLat': location?.latitude,
        'deliveryLng': location?.longitude,
      };
      
      await repository.createOrder(orderData);
      
      // ... same success handling as before
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande réussie !'), backgroundColor: AppConfig.success),
        );
        ref.invalidate(ordersProvider('BUYER'));
        context.go('/buyer/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
