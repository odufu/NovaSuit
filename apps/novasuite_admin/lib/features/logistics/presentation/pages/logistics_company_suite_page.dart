import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/tenant_brand_provider.dart';

/// Standalone Logistics Suite Page for Logistics Tenants (e.g. Nova Express, GIG Logistics).
/// Manages Circuit Centers (CDCs), Warehouse Stock Receiving, Hybrid Auto/Manual Order Dispatch, IDPs, and COD Remittance.
class LogisticsCompanySuitePage extends StatefulWidget {
  const LogisticsCompanySuitePage({super.key});

  @override
  State<LogisticsCompanySuitePage> createState() => _LogisticsCompanySuitePageState();
}

class _LogisticsCompanySuitePageState extends State<LogisticsCompanySuitePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock list of regional Circuit Centers (CDCs)
  final List<CircuitCenterModel> _circuitCenters = [
    CircuitCenterModel(
      id: 'cdc-ikeja-1',
      companyId: 'cmp-novaexpress-1',
      centerName: 'Ikeja Circuit Center (Lagos West Hub)',
      hubCode: 'NX-LAGOS-IKEJA',
      state: 'Lagos',
      city: 'Ikeja',
      address: '14 Allen Avenue, Ikeja, Lagos',
      managerName: 'Emmanuel Okafor',
      managerPhone: '08099887766',
      coverageZones: const ['Ikeja', 'Oregun', 'Ojodu', 'Alausa'],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    CircuitCenterModel(
      id: 'cdc-lekki-1',
      companyId: 'cmp-novaexpress-1',
      centerName: 'Lekki Circuit Center (Lagos East Hub)',
      hubCode: 'NX-LAGOS-LEKKI',
      state: 'Lagos',
      city: 'Lekki',
      address: 'Plot 8 Admiralty Way, Lekki Phase 1',
      managerName: 'Chidi Anozie',
      managerPhone: '08033445566',
      coverageZones: const ['Lekki Phase 1', 'Ikoyi', 'Victoria Island', 'Ajah'],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    CircuitCenterModel(
      id: 'cdc-abuja-1',
      companyId: 'cmp-novaexpress-1',
      centerName: 'Garki Circuit Center (Abuja FCT Hub)',
      hubCode: 'NX-ABUJA-GARKI',
      state: 'FCT Abuja',
      city: 'Abuja',
      address: 'Area 11, Garki, Abuja',
      managerName: 'Amina Yusuf',
      managerPhone: '08055667788',
      coverageZones: const ['Garki', 'Wuse 2', 'Maitama', 'Asokoro'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // Mock list of Independent Delivery Agents (IDPs / Riders)
  final List<Map<String, dynamic>> _riders = [
    {'name': 'Sunday Bamidele', 'phone': '08011223344', 'vehicle': 'Motorcycle', 'hub': 'NX-LAGOS-IKEJA', 'status': 'ONLINE', 'deliveries_today': 14, 'cod_holding': 245000.00},
    {'name': 'Kelechi Igwe', 'phone': '08022334455', 'vehicle': 'Motorcycle', 'hub': 'NX-LAGOS-IKEJA', 'status': 'IN_TRANSIT', 'deliveries_today': 9, 'cod_holding': 180000.00},
    {'name': 'Mustapha Garba', 'phone': '08033445566', 'vehicle': 'Delivery Van', 'hub': 'NX-ABUJA-GARKI', 'status': 'ONLINE', 'deliveries_today': 8, 'cod_holding': 315000.00},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandProvider = Provider.of<TenantBrandProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = brandProvider.primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_shipping_rounded, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${brandProvider.currentCompany?.name ?? 'Nova Express'} Logistics Suite',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                ),
                Text(
                  'Circuit Centers, Warehouse Stock, Hybrid Dispatch & IDP Fleet Management',
                  style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _showCreateCircuitCenterModal,
            icon: const Icon(Icons.add_location_alt_rounded, size: 18),
            label: Text('New Circuit Center', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: textMuted,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.hub_rounded, size: 18), text: 'Circuit Centers'),
            Tab(icon: Icon(Icons.warehouse_rounded, size: 18), text: 'Warehouse Stock'),
            Tab(icon: Icon(Icons.alt_route_rounded, size: 18), text: 'Hybrid Dispatch Console'),
            Tab(icon: Icon(Icons.two_wheeler_rounded, size: 18), text: 'IDP Delivery Fleet'),
            Tab(icon: Icon(Icons.payments_rounded, size: 18), text: 'COD Cash Ledger'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCircuitCentersTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildWarehouseStockTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildHybridDispatchTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildIDPFleetTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildCODLedgerTab(isDark, cardColor, textColor, textMuted, primaryColor),
        ],
      ),
    );
  }

  /// Tab 1: Circuit Centers Directory (CDCs across Nigeria)
  Widget _buildCircuitCentersTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Regional Collation & Distribution Centers (CDCs)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          const SizedBox(height: 4),
          Text('Manage regional distribution hubs, state coverage, and local warehouse managers.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: _circuitCenters.length,
            itemBuilder: (ctx, idx) {
              final hub = _circuitCenters[idx];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(hub.hubCode, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: primaryColor)),
                        ),
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(hub.centerName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    const SizedBox(height: 4),
                    Text('${hub.city}, ${hub.state}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Manager: ${hub.managerName ?? "Unassigned"}', style: GoogleFonts.inter(fontSize: 11, color: textColor)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tab 2: Warehouse Stock Holding & Receiving
  Widget _buildWarehouseStockTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Circuit Center Inventory Holding', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 4),
        Text('Physical merchant inventory stored across distribution hubs.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('MERCHANT COMPANY')),
              DataColumn(label: Text('PRODUCT NAME')),
              DataColumn(label: Text('CIRCUIT CENTER HUB')),
              DataColumn(label: Text('PHYSICAL STOCK')),
              DataColumn(label: Text('AVAILABLE STOCK')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('NovaCare Health', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
                DataCell(Text('Slim Tea Detox (Pack of 2)', style: GoogleFonts.inter(color: textColor))),
                DataCell(Text('NX-LAGOS-IKEJA', style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.bold))),
                DataCell(Text('485 units', style: GoogleFonts.inter(color: textColor))),
                DataCell(Text('480 units', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold))),
                const DataCell(Chip(label: Text('IN STOCK', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Color(0xFF10B981))),
              ]),
              DataRow(cells: [
                DataCell(Text('Leafora Organics', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
                DataCell(Text('Organic Face Serum 50ml', style: GoogleFonts.inter(color: textColor))),
                DataCell(Text('NX-ABUJA-GARKI', style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.bold))),
                DataCell(Text('300 units', style: GoogleFonts.inter(color: textColor))),
                DataCell(Text('295 units', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold))),
                const DataCell(Chip(label: Text('IN STOCK', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Color(0xFF10B981))),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 3: Hybrid Auto / Manual Order Dispatch Console
  Widget _buildHybridDispatchTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hybrid Order Dispatch Console', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                Text('Auto-proximity routing engine & manual dispatcher override board.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_mode_rounded, size: 16),
                  label: const Text('Run Auto-Dispatch Proximity'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending Waybills for Dispatch', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.local_shipping, color: Colors.white)),
                  title: const Text('Waybill #NX-WAYBILL-9912 (Order ORD-2026-8812)'),
                  subtitle: const Text('Destination: 14 Allen Avenue, Ikeja, Lagos | COD: ₦35,000'),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Assign Rider (Manual Override)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 4: Independent Delivery Agents (IDPs / Riders)
  Widget _buildIDPFleetTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Independent Delivery Agent (IDP) Fleet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 4),
        Text('Onboarded last-mile riders attached to Circuit Centers across Nigeria.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('RIDER NAME')),
              DataColumn(label: Text('PHONE')),
              DataColumn(label: Text('VEHICLE TYPE')),
              DataColumn(label: Text('ATTACHED HUB')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('DELIVERIES TODAY')),
              DataColumn(label: Text('COD CASH HOLDING')),
            ],
            rows: _riders.map((r) => DataRow(cells: [
              DataCell(Text(r['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
              DataCell(Text(r['phone'], style: GoogleFonts.inter(color: textMuted))),
              DataCell(Text(r['vehicle'], style: GoogleFonts.inter(color: textColor))),
              DataCell(Text(r['hub'], style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.bold))),
              DataCell(Chip(label: Text(r['status'], style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: r['status'] == 'ONLINE' ? Colors.green : Colors.orange)),
              DataCell(Text('${r['deliveries_today']} packages', style: GoogleFonts.inter(color: textColor))),
              DataCell(Text('₦${r['cod_holding'].toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green))),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  /// Tab 5: Cash-on-Delivery (COD) Remittance Ledger
  Widget _buildCODLedgerTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Cash-on-Delivery (COD) Collection & Remittance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 4),
        Text('Daily Cash collection deposits from riders and net merchant remittance payouts.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        const SizedBox(height: 24),
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Total COD Collected: ₦740,000', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                const SizedBox(height: 12),
                const Text('Pending Merchant Remittance to NovaCare: ₦425,000'),
                const Text('Pending Merchant Remittance to Leafora: ₦315,000'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateCircuitCenterModal() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Onboard New Circuit Center (CDC)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Center Name (e.g. Lekki CDC)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Hub Code (e.g. NX-LAGOS-LEKKI)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State (e.g. Lagos)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City (e.g. Lekki)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && codeCtrl.text.isNotEmpty) {
                setState(() {
                  _circuitCenters.add(
                    CircuitCenterModel(
                      id: 'cdc-${DateTime.now().millisecondsSinceEpoch}',
                      companyId: 'cmp-novaexpress-1',
                      centerName: nameCtrl.text,
                      hubCode: codeCtrl.text.toUpperCase().trim(),
                      state: stateCtrl.text,
                      city: cityCtrl.text,
                      address: addressCtrl.text,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully onboarded ${nameCtrl.text}!')),
                );
              }
            },
            child: const Text('Create Hub'),
          ),
        ],
      ),
    );
  }
}
