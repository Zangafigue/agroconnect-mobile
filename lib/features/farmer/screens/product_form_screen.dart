import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config.dart';
import '../../catalogue/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedCategory = 'Légumes';
  String _selectedUnit = 'kg';
  bool _isLoading = false;
  LatLng? _selectedCoordinates;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      if (userId == null) throw Exception('Utilisateur non connecté');

      await ref.read(productRepositoryProvider).createProduct({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'unit': _selectedUnit,
        'category': _selectedCategory,
        'quantity': double.parse(_quantityController.text),
        'seller': userId,
        'imageUrl': 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=1000', // Default for now
        'city': _locationController.text.isNotEmpty ? _locationController.text : 'Bobo-Dioulasso',
        'lat': _selectedCoordinates?.latitude,
        'lng': _selectedCoordinates?.longitude,
      });

      ref.invalidate(productsProvider); // Refresh public catalogue
      ref.invalidate(myProductsProvider); // Refresh farmer's own list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit publié avec succès !')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau produit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppConfig.bgDark : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Mockup
              Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=1000'),
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48, color: isDark ? Colors.white70 : Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text('Modifier la photo', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[800], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildLabel(context, 'Nom du produit'),
              _buildTextField(
                context, 
                controller: _nameController,
                hint: 'Ex: Tomates de Bobo',
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),
              
              const SizedBox(height: 20),
              _buildLabel(context, 'Catégorie'),
              _buildDropdownField(
                context, 
                value: _selectedCategory,
                hint: 'Sélectionner une catégorie', 
                items: ['Légumes', 'Céréales', 'Fruits', 'Tubercules'],
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'Prix (FCFA)'),
                        _buildTextField(
                          context, 
                          controller: _priceController,
                          hint: 'Ex: 500', 
                          isNumber: true,
                          validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'Unité'),
                        _buildDropdownField(
                          context, 
                          value: _selectedUnit,
                          hint: 'kg', 
                          items: ['kg', 'sac', 'balle', 'unité'],
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              _buildLabel(context, 'Quantité disponible'),
              _buildTextField(
                context, 
                controller: _quantityController,
                hint: 'Ex: 100', 
                isNumber: true,
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),
              
              const SizedBox(height: 20),
              _buildLabel(context, 'Description'),
              _buildTextField(
                context, 
                controller: _descriptionController,
                hint: 'Détails sur la qualité, provenance...', 
                isMultiline: true,
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),

              const SizedBox(height: 20),
              _buildLabel(context, 'Ville / Localité'),
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapLocationPicker(
                        initialLocation: _selectedCoordinates,
                        initialCity: _locationController.text,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _selectedCoordinates = result['location'];
                      _locationController.text = result['city'];
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppConfig.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationController.text.isEmpty ? 'Sélectionner sur la carte' : _locationController.text,
                          style: TextStyle(
                            color: _locationController.text.isEmpty 
                              ? (isDark ? AppConfig.textSubDark : Colors.grey[400])
                              : (isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppConfig.primaryColor.withValues(alpha: 0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publier le produit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {
    required String hint, 
    required TextEditingController controller,
    bool isNumber = false, 
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? 4 : 1,
      style: TextStyle(color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: isDark ? Colors.white12 : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConfig.primaryColor, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, {
    required String hint, 
    required List<String> items,
    required String value,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: isDark ? AppConfig.surfaceDark : Colors.white,
      style: TextStyle(color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.white12 : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!),
        ),
      ),
      hint: Text(hint, style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[400], fontSize: 14)),
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

