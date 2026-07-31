import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class AddEditProductDialog extends StatefulWidget {
  final TenantTheme activeTheme;
  final Map<String, dynamic>? productToEdit;

  const AddEditProductDialog({
    super.key,
    required this.activeTheme,
    this.productToEdit,
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _basePriceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?['name'] ?? '');
    _skuController = TextEditingController(text: p?['sku'] ?? 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _basePriceController = TextEditingController(text: (p?['basePrice'] ?? 25000.0).toString());
    _descriptionController = TextEditingController(text: p?['description'] ?? '');
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.productToEdit != null;
      final price = double.tryParse(_basePriceController.text.trim()) ?? 25000.0;

      final productData = {
        'id': isEditing ? widget.productToEdit!['id'] : 'prod-${DateTime.now().millisecondsSinceEpoch}',
        'name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'basePrice': price,
        'description': _descriptionController.text.trim(),
        'availableStock': isEditing ? widget.productToEdit!['availableStock'] ?? 1000 : 1000,
        'status': 'active',
      };

      Navigator.of(context).pop(productData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final theme = widget.activeTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.inventory_2, color: theme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Product Catalog Item' : 'Create New System Product',
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text('GM Logistics Product Management', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Product Name Field
                const Text('Product Title / Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  decoration: _inputDecoration(hint: 'e.g. Grazer Herbal Detox Tea'),
                ),
                const SizedBox(height: 16),

                // SKU & Base Price Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Product SKU *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _skuController,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(hint: 'SKU-TEA-001'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Base Price (${theme.currencySymbol}) *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _basePriceController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(hint: '25000'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description Field
                const Text('Product Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration(hint: 'Specifications, herbal active ingredients, and packaging specs.'),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: Icon(isEditing ? Icons.check : Icons.add, size: 18),
                      label: Text(isEditing ? 'Save Changes' : 'Create Product'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
