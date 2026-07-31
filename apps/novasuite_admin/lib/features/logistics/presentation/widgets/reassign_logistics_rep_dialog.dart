import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class ReassignLogisticsRepDialog extends StatefulWidget {
  final OrderModel order;
  final TenantTheme activeTheme;
  final Function(OrderModel updatedOrder) onReassigned;

  const ReassignLogisticsRepDialog({
    super.key,
    required this.order,
    required this.activeTheme,
    required this.onReassigned,
  });

  @override
  State<ReassignLogisticsRepDialog> createState() => _ReassignLogisticsRepDialogState();
}

class _ReassignLogisticsRepDialogState extends State<ReassignLogisticsRepDialog> {
  final _reasonController = TextEditingController();

  final List<Map<String, String>> _logisticsReps = [
    {'id': 'log-rep-1', 'name': 'Logistics Rep Tunde (Lagos Hub)', 'state': 'Lagos'},
    {'id': 'log-rep-2', 'name': 'Logistics Rep Fatima (Abuja Hub)', 'state': 'Abuja'},
    {'id': 'log-rep-3', 'name': 'Logistics Rep Emeka (Port Harcourt Hub)', 'state': 'Rivers'},
  ];

  late String _selectedRepId;

  @override
  void initState() {
    super.initState();
    _selectedRepId = widget.order.logisticsRepId ?? _logisticsReps.first['id']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.alt_route_rounded, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reassign Logistics Rep', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Order #${widget.order.orderNumber} • ${widget.order.deliveryState}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${widget.order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Address: ${widget.order.deliveryAddress}, ${widget.order.deliveryState}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bolt, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        widget.order.logisticsRepId != null ? 'Currently Assigned ID: ${widget.order.logisticsRepId}' : 'Auto-Assigned based on state (${widget.order.deliveryState})',
                        style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('SELECT NEW LOGISTICS REP / HUB MANAGER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedRepId,
              items: _logisticsReps.map((rep) {
                return DropdownMenuItem(
                  value: rep['id'],
                  child: Text(rep['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRepId = val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),

            const Text('REASSIGNMENT REASON (OPTIONAL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Primary hub low on stock; shifting dispatch to Lagos Central.',
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final updated = OrderModel(
              id: widget.order.id,
              orderNumber: widget.order.orderNumber,
              companyId: widget.order.companyId,
              productId: widget.order.productId,
              salesRepId: widget.order.salesRepId,
              logisticsRepId: _selectedRepId,
              deliveryAgentId: widget.order.deliveryAgentId,
              warehouseId: widget.order.warehouseId,
              customerName: widget.order.customerName,
              customerPhone: widget.order.customerPhone,
              deliveryState: widget.order.deliveryState,
              deliveryCity: widget.order.deliveryCity,
              deliveryAddress: widget.order.deliveryAddress,
              status: widget.order.status,
              quantity: widget.order.quantity,
              basePrice: widget.order.basePrice,
              upsellAmount: widget.order.upsellAmount,
              downsellDiscount: widget.order.downsellDiscount,
              totalAmount: widget.order.totalAmount,
              upsellStatus: widget.order.upsellStatus,
              upsellNotes: widget.order.upsellNotes,
              approvedBySupervisorId: widget.order.approvedBySupervisorId,
              paymentStatus: widget.order.paymentStatus,
              proofOfDeliveryUrl: widget.order.proofOfDeliveryUrl,
              deliveryNotes: _reasonController.text.isNotEmpty
                  ? 'Reassigned to $_selectedRepId: ${_reasonController.text}'
                  : widget.order.deliveryNotes,
              createdAt: widget.order.createdAt,
              updatedAt: DateTime.now(),
            );

            widget.onReassigned(updated);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Confirm Reassignment'),
        ),
      ],
    );
  }
}
