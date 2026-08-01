import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class NotificationsSuitePage extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final List<OrderModel> orders;
  final Function(OrderModel) onUpdateOrder;

  const NotificationsSuitePage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    required this.orders,
    required this.onUpdateOrder,
  });

  @override
  State<NotificationsSuitePage> createState() => _NotificationsSuitePageState();
}

class _NotificationsSuitePageState extends State<NotificationsSuitePage> {
  late ValueNotifier<String> _selectedCategoryNotifier;

  @override
  void initState() {
    super.initState();
    _selectedCategoryNotifier = ValueNotifier<String>('All');
  }

  @override
  void dispose() {
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final dueCallbacks = widget.orders.where((o) {
      if (o.scheduledCallbackAt == null) return false;
      final isPending = o.status == OrderStatus.callBack || o.status == OrderStatus.rescheduled || o.status == OrderStatus.notReachable;
      return isPending && o.scheduledCallbackAt!.isBefore(DateTime.now().add(const Duration(minutes: 30)));
    }).toList();

    final pendingUpsells = widget.orders.where((o) => o.upsellStatus == UpsellStatus.pending).toList();
    final autoAssigned = widget.orders.where((o) => o.logisticsRepId != null).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications & Call Alerts Center',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Text(
                      'Dedicated notification hub for scheduled callbacks, supervisor authorizations, and hub assignments.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: theme.primaryColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${dueCallbacks.length + pendingUpsells.length} Active Alerts',
                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'All Alerts (${dueCallbacks.length + pendingUpsells.length + autoAssigned.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Callbacks', '⏰ Callback Reminders (${dueCallbacks.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Upsells', '🚀 Upsell Approvals (${pendingUpsells.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Logistics', '⚡ Logistics Assignments (${autoAssigned.length})'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification List
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _selectedCategoryNotifier,
                builder: (context, selectedCategoryVal, _) {
                  return ListView(
                    children: [
                      if (selectedCategoryVal == 'All' || selectedCategoryVal == 'Callbacks') ...[
                        if (dueCallbacks.isEmpty)
                          _buildEmptyState('No scheduled callbacks due at this moment.')
                        else
                          ...dueCallbacks.map((o) => _buildCallbackNotificationCard(o, theme)),
                      ],
                      if (selectedCategoryVal == 'All' || selectedCategoryVal == 'Upsells') ...[
                        ...pendingUpsells.map((o) => _buildUpsellNotificationCard(o, theme)),
                      ],
                      if (selectedCategoryVal == 'All' || selectedCategoryVal == 'Logistics') ...[
                        ...autoAssigned.map((o) => _buildLogisticsNotificationCard(o, theme)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String categoryKey, String label) {
    final theme = widget.activeTheme;

    return ValueListenableBuilder<String>(
      valueListenable: _selectedCategoryNotifier,
      builder: (context, selectedCategoryVal, _) {
        final isSelected = selectedCategoryVal == categoryKey;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          selectedColor: theme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          onSelected: (val) {
            if (val) _selectedCategoryNotifier.value = categoryKey;
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: widget.activeTheme.primaryColor),
          const SizedBox(width: 12),
          Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCallbackNotificationCard(OrderModel o, TenantTheme theme) {
    final timeStr = o.scheduledCallbackAt != null
        ? '${o.scheduledCallbackAt!.day}/${o.scheduledCallbackAt!.month} @ ${TimeOfDay.fromDateTime(o.scheduledCallbackAt!).format(context)}'
        : 'Due Now';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.alarm_on, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('⏰ Rescheduled Call Due • ', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 13)),
                      Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Customer: ${o.customerName} (${o.customerPhone})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Product: ${o.productId} • State: ${o.deliveryState}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: theme.primaryColor, content: Text('Calling ${o.customerName}...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.phone, size: 14),
              label: const Text('Call Client Now', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpsellNotificationCard(OrderModel o, TenantTheme theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.stars, color: Colors.purple.shade700, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🚀 Up-sell Authorization Pending', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade900, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Order #${o.orderNumber} - ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Requested Add-on: + ${theme.currencySymbol} ${o.upsellAmount} | Total: ${theme.currencySymbol} ${o.totalAmount}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text('Pending Review', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsNotificationCard(OrderModel o, TenantTheme theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.bolt, color: Colors.blue.shade700, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚡ Logistics Auto-Assigned', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Order #${o.orderNumber} routed to [${o.deliveryState}] Hub Rep (${o.logisticsRepId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Customer: ${o.customerName} • ${o.deliveryAddress}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
