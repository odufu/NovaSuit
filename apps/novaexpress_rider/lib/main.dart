import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'presentation/providers/rider_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await SupabaseConfig.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => RiderProvider(),
      child: const NovaExpressRiderApp(),
    ),
  );
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

class RiderMainShell extends StatelessWidget {
  const RiderMainShell({super.key});

  void _handleUploadDepositReceipt(BuildContext context) async {
    final riderProvider = context.read<RiderProvider>();
    final amountController = TextEditingController(text: riderProvider.currentCodBalance.toStringAsFixed(0));

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
      if (!context.mounted) return;
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
    final riderProvider = context.watch<RiderProvider>();
    final isOnline = riderProvider.isOnline;
    final currentTab = riderProvider.currentTab;

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
                    color: isOnline ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Online - Receiving Jobs' : 'Offline',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Switch(
            value: isOnline,
            activeThumbColor: const Color(0xFFD4AF37),
            onChanged: (val) => context.read<RiderProvider>().setOnline(val),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          child: IndexedStack(
            index: currentTab,
            children: [
              _buildJobsTab(context),
              _buildInventoryTab(),
              _buildRemittanceTab(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        selectedItemColor: const Color(0xFF1B4D3E),
        unselectedItemColor: Colors.grey,
        onTap: (index) => context.read<RiderProvider>().setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler_rounded), label: 'Active Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'My Mini-Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'COD Cash'),
        ],
      ),
    );
  }

  Widget _buildJobsTab(BuildContext context) {
    final riderProvider = context.watch<RiderProvider>();
    final assignedJobs = riderProvider.assignedJobs;

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
                      '₦ ${riderProvider.currentCodBalance.toStringAsFixed(0)} / ₦ ${riderProvider.maxCreditLimit.toStringAsFixed(0)} Max Limit',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Assigned Deliveries (${assignedJobs.length})', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...assignedJobs.map((job) => _buildJobCard(context, job)),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, OrderModel job) {
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
                onPressed: () => _showPODModal(context, job),
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

  Widget _buildRemittanceTab(BuildContext context) {
    final riderProvider = context.watch<RiderProvider>();
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
                Text('₦ ${riderProvider.currentCodBalance.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleUploadDepositReceipt(context),
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

  void _showPODModal(BuildContext context, OrderModel job) {
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
                    context.read<RiderProvider>().completeJobAndCollectCash(job.id, job.totalAmount);
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
