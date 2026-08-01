import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class CreateTransferDialog extends StatefulWidget {
  final TenantTheme activeTheme;

  const CreateTransferDialog({
    super.key,
    required this.activeTheme,
  });

  @override
  State<CreateTransferDialog> createState() => _CreateTransferDialogState();
}

class _CreateTransferDialogState extends State<CreateTransferDialog> {
  final _quantityController = TextEditingController(text: '200');
  final _notesController = TextEditingController(text: 'Weekly Hub Stock Replenishment');
  late ValueNotifier<String> _sourceWarehouse;
  late ValueNotifier<String> _destinationWarehouse;
  late ValueNotifier<String> _selectedProduct;
  late String _waybillNumber;

  @override
  void initState() {
    super.initState();
    _sourceWarehouse = ValueNotifier<String>('Lagos Central Factory Hub');
    _destinationWarehouse = ValueNotifier<String>('Abuja Regional Hub (NovaExpress)');
    _selectedProduct = ValueNotifier<String>('Herbal Care Detox Tea');
    _waybillNumber = 'WB-2026-${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _sourceWarehouse.dispose();
    _destinationWarehouse.dispose();
    _selectedProduct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_shipping, color: Colors.orange.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Inter-Warehouse Transfer (IWT)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Waybill #$_waybillNumber',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Source Warehouse Dropdown
              const Text('Source Warehouse (Origin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ValueListenableBuilder<String>(
                valueListenable: _sourceWarehouse,
                builder: (context, sourceVal, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: sourceVal,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Lagos Central Factory Hub', child: Text('🏭 Lagos Central Factory Hub')),
                      DropdownMenuItem(value: 'Abuja Regional Hub (NovaExpress)', child: Text('🏢 Abuja Regional Hub')),
                    ],
                    onChanged: (val) {
                      if (val != null) _sourceWarehouse.value = val;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Destination Warehouse Dropdown
              const Text('Destination Warehouse (Target)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ValueListenableBuilder<String>(
                valueListenable: _destinationWarehouse,
                builder: (context, destVal, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: destVal,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Abuja Regional Hub (NovaExpress)', child: Text('🏢 Abuja Regional Hub (NovaExpress)')),
                      DropdownMenuItem(value: 'Rider Emeka Mini-Hub (Port Harcourt)', child: Text('🏍️ Rider Emeka Mini-Hub (Port Harcourt)')),
                      DropdownMenuItem(value: 'Lagos Central Factory Hub', child: Text('🏭 Lagos Central Factory Hub')),
                    ],
                    onChanged: (val) {
                      if (val != null) _destinationWarehouse.value = val;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Product & Quantity Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Product to Ship', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<String>(
                          valueListenable: _selectedProduct,
                          builder: (context, prodVal, _) {
                            return DropdownButtonFormField<String>(
                              initialValue: prodVal,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Herbal Care Detox Tea', child: Text('Herbal Care Detox Tea')),
                                DropdownMenuItem(value: 'Herbal Vitality Booster', child: Text('Herbal Vitality Booster')),
                              ],
                              onChanged: (val) {
                                if (val != null) _selectedProduct.value = val;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              const Text('Waybill Manifest Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Driver name, truck details, or notes...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
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
            final qty = int.tryParse(_quantityController.text) ?? 100;
            Navigator.pop(context, {
              'waybill_number': _waybillNumber,
              'source': _sourceWarehouse.value,
              'destination': _destinationWarehouse.value,
              'product': _selectedProduct.value,
              'quantity': qty,
              'notes': _notesController.text,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Dispatch Waybill & Stock'),
        ),
      ],
    );
  }
}
