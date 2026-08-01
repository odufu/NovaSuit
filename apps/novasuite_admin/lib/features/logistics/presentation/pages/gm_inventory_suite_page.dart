import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/logistics_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/add_edit_product_dialog.dart';
import '../widgets/create_transfer_dialog.dart';

class GMInventorySuitePage extends StatelessWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final int activeSubIndex;

  const GMInventorySuitePage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    this.activeSubIndex = 0,
  });

  // System Products Catalog Static Seed Data
  static final List<Map<String, dynamic>> _products = [
    {
      'id': 'prod-1',
      'name': 'Grazer Herbal Detox Tea',
      'sku': 'SKU-TEA-001',
      'basePrice': 25000.0,
      'description': 'Natural herbal tea blend for deep digestive detox.',
      'availableStock': 4500,
      'status': 'active',
    },
    {
      'id': 'prod-2',
      'name': 'Herbal Vitality Booster',
      'sku': 'SKU-BOOST-002',
      'basePrice': 18000.0,
      'description': 'Daily stamina and immune vitality capsules.',
      'availableStock': 1800,
      'status': 'active',
    },
    {
      'id': 'prod-3',
      'name': 'Clear Skin Herbal Care',
      'sku': 'SKU-SKIN-003',
      'basePrice': 22000.0,
      'description': 'Organic herbal topical care for glowing skin.',
      'availableStock': 950,
      'status': 'active',
    },
  ];

  void _handleCreateProduct(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditProductDialog(activeTheme: activeTheme),
    );

    if (result != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Product "${result['name']}" created and available in system catalog!'),
        ),
      );
    }
  }

  void _handleEditProduct(BuildContext context, Map<String, dynamic> product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditProductDialog(
        activeTheme: activeTheme,
        productToEdit: product,
      ),
    );

    if (result != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: activeTheme.primaryColor,
          content: Text('Updated product specifications for ${result['name']}!'),
        ),
      );
    }
  }

  void _handleDispatchTransfer(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateTransferDialog(activeTheme: activeTheme),
    );

    if (result != null) {
      if (!context.mounted) return;
      context.read<LogisticsProvider>().addTransfer({
        'waybill': result['waybill_number'],
        'source': result['source'],
        'destination': result['destination'],
        'product': result['product'],
        'quantity': result['quantity'],
        'status': 'dispatched',
        'date': 'Just now',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: activeTheme.primaryColor,
          content: Text('Waybill ${result['waybill_number']} dispatched to ${result['destination']}!'),
        ),
      );
    }
  }

  void _handleConfirmTransferReceipt(BuildContext context, int index) {
    final logisticsProvider = context.read<LogisticsProvider>();
    final waybill = logisticsProvider.transfers[index]['waybill'];
    logisticsProvider.confirmTransferReceipt(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Stock Transfer Waybill $waybill confirmed & restocked!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final logisticsProvider = context.watch<LogisticsProvider>();
    final theme = activeTheme;
    final currency = theme.currencySymbol;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final activeTab = inventoryProvider.activeTab;
    final transfers = logisticsProvider.transfers;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GM Logistics & Inventory Hub', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Manage system products catalog, nationwide warehouses, and stock transfer waybills.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleCreateProduct(context),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Create Product'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _handleDispatchTransfer(context),
                          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                          icon: const Icon(Icons.local_shipping, size: 16),
                          label: const Text('Dispatch Waybill'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GM Logistics & Inventory Hub', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Manage system products catalog, nationwide warehouses, and stock transfer waybills.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleCreateProduct(context),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Create New Product'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _handleDispatchTransfer(context),
                          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                          icon: const Icon(Icons.local_shipping, size: 18),
                          label: const Text('Dispatch Stock Transfer'),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // GM Logistics Metric Cards
          if (isMobile) ...[
            _metricCard('CENTRAL FACTORY STOCK', '4,500 Units', 'Lagos Hub Ready', Icons.inventory, Colors.blue),
            const SizedBox(height: 12),
            _metricCard('REGIONAL HUB STOCK', '1,800 Units', 'Abuja Hub Ready', Icons.warehouse, Colors.purple),
            const SizedBox(height: 12),
            _metricCard('ACTIVE WAYBILLS', '${transfers.where((t) => t["status"] == "dispatched").length} In-Transit', 'Nationwide Dispatch', Icons.local_shipping, Colors.orange),
            const SizedBox(height: 12),
            _metricCard('PRODUCTS CATALOG', '${_products.length} SKUs Active', 'System Available', Icons.category, Colors.green),
          ] else ...[
            Row(
              children: [
                Expanded(child: _metricCard('CENTRAL FACTORY STOCK', '4,500 Units', 'Lagos Hub Ready', Icons.inventory, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _metricCard('REGIONAL HUB STOCK', '1,800 Units', 'Abuja Hub Ready', Icons.warehouse, Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _metricCard('ACTIVE WAYBILLS', '${transfers.where((t) => t["status"] == "dispatched").length} In-Transit', 'Nationwide Dispatch', Icons.local_shipping, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _metricCard('PRODUCTS CATALOG', '${_products.length} SKUs Active', 'System Available', Icons.category, Colors.green)),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Sub-Tab Switcher (Products Catalog | Multi-Warehouse Matrix | Stock Transfers)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _subTabChip(context, 0, Icons.shopping_bag_rounded, 'Products Catalog (${_products.length})'),
                _subTabChip(context, 1, Icons.domain_rounded, 'Multi-Warehouse Matrix'),
                _subTabChip(context, 2, Icons.alt_route_rounded, 'Inter-Warehouse Transfers (IWT)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sub-Tab Content
          if (activeTab == 0) _buildProductsCatalogTab(context, currency),
          if (activeTab == 1) _buildMultiWarehouseMatrixTab(),
          if (activeTab == 2) _buildStockTransfersTab(context, transfers),
        ],
      ),
    );
  }

  Widget _subTabChip(BuildContext context, int index, IconData icon, String label) {
    final activeTab = context.watch<InventoryProvider>().activeTab;
    final isActive = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<InventoryProvider>().setActiveTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsCatalogTab(BuildContext context, String currency) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product Title', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('SKU Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Base Price', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Central Factory Stock', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _products.map((product) {
            return DataRow(cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(product['description'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              DataCell(Text(product['sku'], style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text('$currency ${product['basePrice']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
              DataCell(Text('${product['availableStock']} units')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('Active Product', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  onPressed: () => _handleEditProduct(context, product),
                  tooltip: 'Edit Specs',
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMultiWarehouseMatrixTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _warehouseCard('Lagos Central Factory Hub', 'Available Stock: 4,500 units', 'Allocated Stock: 320 units', 'Type: Primary Factory Warehouse')),
            const SizedBox(width: 16),
            Expanded(child: _warehouseCard('Abuja Regional Hub (NovaExpress)', 'Available Stock: 1,800 units', 'Allocated Stock: 110 units', 'Type: Regional Distribution Hub')),
            const SizedBox(width: 16),
            Expanded(child: _warehouseCard('Rider Emeka Mini-Hub (Port Harcourt)', 'Available Stock: 45 units', 'Allocated Stock: 12 units', 'Type: Independent Direct Rider Trunk')),
          ],
        ),
      ],
    );
  }

  Widget _buildStockTransfersTab(BuildContext context, List<Map<String, dynamic>> transfers) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inter-Warehouse Transfers (IWT Waybills)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Waybill #', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Origin Warehouse', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Destination', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Product / Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: transfers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isDispatched = item['status'] == 'dispatched';

                  return DataRow(cells: [
                    DataCell(Text(item['waybill'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item['source'])),
                    DataCell(Text(item['destination'])),
                    DataCell(Text('${item['product']} (${item['quantity']} units)')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDispatched ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDispatched ? 'In-Transit' : 'Restocked & Completed',
                          style: TextStyle(
                            color: isDispatched ? Colors.orange.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      isDispatched
                          ? ElevatedButton.icon(
                              onPressed: () => _handleConfirmTransferReceipt(context, index),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Confirm Receipt'),
                            )
                          : const Text('Verified', style: TextStyle(color: Colors.grey)),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _warehouseCard(String title, String line1, String line2, String line3) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text(line1),
            Text(line2),
            Text(line3, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
