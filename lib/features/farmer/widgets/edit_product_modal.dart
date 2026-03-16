import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config.dart';
import '../../../../core/models/product_model.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../shared/widgets/location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class EditProductModal extends ConsumerStatefulWidget {
  final Product product;
  const EditProductModal({super.key, required this.product});

  @override
  ConsumerState<EditProductModal> createState() => _EditProductModalState();
}

class _EditProductModalState extends ConsumerState<EditProductModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  String? _selectedCategory;
  String? _selectedUnit;
  bool _isLoading = false;
  LatLng? _selectedCoordinates;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toInt().toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _cityController = TextEditingController(text: widget.product.city);
    _selectedCategory = widget.product.category;
    _selectedUnit = widget.product.unit;
    if (widget.product.lat != null && widget.product.lng != null) {
      _selectedCoordinates = LatLng(widget.product.lat!, widget.product.lng!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      final data = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? widget.product.price,
        'quantity': int.tryParse(_quantityController.text) ?? widget.product.quantity,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'unit': _selectedUnit,
        'city': _cityController.text,
        'lat': _selectedCoordinates?.latitude,
        'lng': _selectedCoordinates?.longitude,
      };
      
      await repository.updateProduct(widget.product.id, data);
      
      if (mounted) {
        ref.invalidate(productDetailProvider(widget.product.id));
        ref.invalidate(productsProvider(null));
        ref.invalidate(myProductsProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour'), backgroundColor: AppConfig.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer?'),
        content: const Text('Voulez-vous vraiment supprimer ce produit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.deleteProduct(widget.product.id);
      
      if (mounted) {
        ref.invalidate(productsProvider(null));
        Navigator.pop(context); // Close modal
        Navigator.pop(context); // Go back from detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit supprimé'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Modifier le produit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Nom'),
            _buildTextField(_nameController, 'Nom'),
            
            const SizedBox(height: 16),
            _buildLabel('Catégorie'),
            _buildDropdown(
              value: _selectedCategory,
              items: ['Légumes', 'Céréales', 'Fruits', 'Tubercules', 'Autres'],
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Prix (F)'),
                      _buildTextField(_priceController, 'Prix', isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Unité'),
                      _buildTextField(_selectedUnit == null ? TextEditingController() : TextEditingController(text: _selectedUnit), 'kg, sac...', onChanged: (v) => _selectedUnit = v),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel('Stock'),
            _buildTextField(_quantityController, 'Quantité', isNumber: true),

            const SizedBox(height: 16),
            _buildLabel('Description'),
            _buildTextField(_descriptionController, 'Description', isMultiline: true),

            const SizedBox(height: 16),
            _buildLabel('Ville / Localité'),
            if (_selectedCoordinates != null)
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedCoordinates!,
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.agroconnect.bf',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedCoordinates!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            InkWell(
              onTap: () async {
                final result = await Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => MapLocationPicker(
                      initialLocation: _selectedCoordinates,
                      initialCity: _cityController.text,
                    ),
                  ),
                );
                if (result != null && result is Map) {
                  setState(() {
                    _selectedCoordinates = result['location'];
                    _cityController.text = result['city'];
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: AppConfig.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cityController.text.isEmpty ? 'Sélectionner sur la carte' : _cityController.text,
                        style: TextStyle(
                          color: _cityController.text.isEmpty 
                            ? (isDark ? Colors.white38 : Colors.grey[400])
                            : (isDark ? Colors.white : Colors.black),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _handleDelete,
                    child: const Text('Supprimer ce produit', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isMultiline = false, Function(String)? onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({required String? value, required List<String> items, required Function(String?) onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
