import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await SupabaseConfig.init();
  runApp(const NovaExpressRiderApp());
}

class NovaExpressRiderApp extends StatelessWidget {
  const NovaExpressRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaExpress Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B4D3E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          primary: const Color(0xFF1B4D3E),
          secondary: const Color(0xFFD4AF37),
        ),
        fontFamily: 'Outfit',
      ),
      home: const RiderMainShell(),
    );
  }
}

class RiderMainShell extends StatefulWidget {
  const RiderMainShell({super.key});

  @override
  State<RiderMainShell> createState() => _RiderMainShellState();
}

class _RiderMainShellState extends State<RiderMainShell> {
  int _currentTab = 0;
  bool _isOnline = true;
  double _currentCodBalance = 125000.0;
  final double _maxCreditLimit = 150000.0;

  final List<OrderModel> _assignedJobs = [
    OrderModel(
      id: 'job-101',
      orderNumber: 'ORD-849201',
      companyId: 'tenant-novacare',
      productId: 'prod-herbal-tea',
      customerName: 'Amina Bello',
      customerPhone: '+234 803 123 4567',
      deliveryState: 'Lagos',
      deliveryCity: 'Ikeja',
      deliveryAddress: '14 Allen Avenue, Ikeja, Lagos State',
      status: OrderStatus.agentNotified,
      quantity: 2,
      basePrice: 25000.0,
      upsellAmount: 12000.0,
      downsellDiscount: 0.0,
      totalAmount: 62000.0,
      upsellStatus: UpsellStatus.approved,
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    OrderModel(
      id: 'job-102',
      orderNumber: 'ORD-849203',
      companyId: 'tenant-novacare',
      productId: 'prod-booster',
      customerName: 'Emeka Nwosu',
      customerPhone: '+234 701 555 8899',
      deliveryState: 'Lagos',
      deliveryCity: 'Lekki',
      deliveryAddress: 'Block 4, Admiralty Way, Lekki Phase 1, Lagos',
      status: OrderStatus.inTransit,
      quantity: 3,
      basePrice: 18000.0,
      upsellAmount: 0.0,
      downsellDiscount: 2000.0,
      totalAmount: 52000.0,
      upsellStatus: UpsellStatus.none,
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  void _handleUploadDepositReceipt() async {
    final amountController = TextEditingController(text: _currentCodBalance.toStringAsFixed(0));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.upload_file, color: Color(0xFF1B4D3E)),
              const SizedBox(width: 10),
              Text('Upload Bank Deposit Receipt', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deposit Amount (₦)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₦ ',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Attach Bank Teller / Receipt Screenshot'),
              ),
            ],
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
              child: const Text('Submit for Finance Clearance'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Bank Deposit Receipt submitted! Pending Finance Manager verification.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D3E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NovaExpress Rider', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online - Receiving Jobs' : 'Offline',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Switch(
            value: _isOnline,
            activeThumbColor: const Color(0xFFD4AF37),
            onChanged: (val) => setState(() => _isOnline = val),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650), // Responsive max width for tablet screens
          child: IndexedStack(
            index: _currentTab,
            children: [
              _buildJobsTab(),
              _buildInventoryTab(),
              _buildRemittanceTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        selectedItemColor: const Color(0xFF1B4D3E),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler_rounded), label: 'Active Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'My Mini-Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'COD Cash'),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Credit Balance Alert Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COD Unremitted Cash Holding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '₦ ${_currentCodBalance.toStringAsFixed(0)} / ₦ ${_maxCreditLimit.toStringAsFixed(0)} Max Limit',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Assigned Deliveries (${_assignedJobs.length})', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ..._assignedJobs.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(OrderModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1B4D3E).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(job.orderNumber, style: const TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Text('COD: ₦ ${job.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(job.deliveryAddress, style: const TextStyle(color: Colors.grey, fontSize: 13))),
              ],
            ),
            const Divider(height: 24),

            // Action Buttons (Dial & Map)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call Client'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Navigate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPODModal(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text('Complete & Collect COD Cash', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mini-Hub Stock (Car/Trunk)', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Inventory loaded in your possession ready for delivery', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.local_pharmacy, color: Color(0xFF1B4D3E), size: 32),
              title: const Text('Herbal Care Detox Tea', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Available: 18 units | Allocated: 2 units'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('In Stock', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemittanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('COD Cash Reconciliation', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('Remit collected cash to clear your credit balance', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Holding Cash', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('₦ ${_currentCodBalance.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleUploadDepositReceipt,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Bank Deposit Receipt'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPODModal(OrderModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Proof of Delivery (POD)', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Order #${job.orderNumber} - Cash to collect: ₦ ${job.totalAmount}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Delivery Photo / Customer Signature'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _assignedJobs.removeWhere((j) => j.id == job.id);
                      _currentCodBalance += job.totalAmount;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order marked Delivered! Cash added to COD holding balance.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Confirm Delivery & Cash Received'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
