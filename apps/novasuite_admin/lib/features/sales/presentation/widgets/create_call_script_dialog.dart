import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class CreateCallScriptDialog extends StatefulWidget {
  final TenantTheme activeTheme;
  final List<String> availableProducts;

  const CreateCallScriptDialog({
    super.key,
    required this.activeTheme,
    this.availableProducts = const [
      'Grazer Herbal Detox Tea',
      'Herbal Vitality Booster',
      'Clear Skin Herbal Care',
    ],
  });

  @override
  State<CreateCallScriptDialog> createState() => _CreateCallScriptDialogState();
}

class _CreateCallScriptDialogState extends State<CreateCallScriptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _scriptController = TextEditingController();
  late ValueNotifier<String> _selectedProduct;
  late ValueNotifier<String> _selectedCategory;

  final List<String> _categories = [
    'Price Objection',
    'NAFDAC / Safety',
    'COD Inspection',
    'Delivery Time',
    'Dosage & Usage',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProduct = ValueNotifier<String>('All Assigned Products');
    _selectedCategory = ValueNotifier<String>('Price Objection');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scriptController.dispose();
    _selectedProduct.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final productOptions = ['All Assigned Products', ...widget.availableProducts];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.record_voice_over_rounded, color: theme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Create Product Call Script',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attach custom sales scripts and objection handling playbooks directly to your assigned products.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),

                // Script Title
                const Text('SCRIPT / OBJECTION TITLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g. Customer asks: "Is this product NAFDAC approved?"',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                // Product Dropdown
                const Text('ATTACH TO PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                ValueListenableBuilder<String>(
                  valueListenable: _selectedProduct,
                  builder: (context, prodVal, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: prodVal,
                      items: productOptions.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _selectedProduct.value = val;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Category Dropdown
                const Text('OBJECTION CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                ValueListenableBuilder<String>(
                  valueListenable: _selectedCategory,
                  builder: (context, catVal, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: catVal,
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _selectedCategory.value = val;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Script Text
                const Text('RECOMMENDED CLOSING RESPONSE & PLAYBOOK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _scriptController,
                  maxLines: 4,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter the response script' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter exact pitch wording, reassurance details, or downsell option...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'objection': _titleController.text.trim(),
                'product': _selectedProduct.value,
                'badge': _selectedCategory.value,
                'script': _scriptController.text.trim(),
                'color': _selectedCategory.value == 'Price Objection' ? Colors.orange : Colors.blue,
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Save Script'),
        ),
      ],
    );
  }
}
