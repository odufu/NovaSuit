import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class MasterOrderDetailsDialog extends StatelessWidget {
  final OrderModel order;
  final UserModel currentUser;
  final String currency;
  final VoidCallback onStartCall;
  final VoidCallback onOpenTimeline;
  final VoidCallback? onReassignOrder;
  final Widget quickStatusMenu;

  const MasterOrderDetailsDialog({
    super.key,
    required this.order,
    required this.currentUser,
    required this.currency,
    required this.onStartCall,
    required this.onOpenTimeline,
    this.onReassignOrder,
    required this.quickStatusMenu,
  });

  String _getLogisticsAgentName(OrderModel order) {
    final state = order.deliveryState.toLowerCase();
    if (state.contains('lagos')) {
      return 'Tunde Bakare (Ext 402)';
    } else if (state.contains('abuja')) {
      return 'Musa Ibrahim (Ext 205)';
    } else if (state.contains('rivers') || state.contains('port')) {
      return 'Chidi Nnamdi (Ext 309)';
    } else if (state.contains('kano')) {
      return 'Usman Bello (Ext 501)';
    } else if (state.contains('oyo') || state.contains('ibadan')) {
      return 'Bayo Adeyemi (Ext 114)';
    }
    return 'Kefas Danjuma (Ext 108)';
  }

  Map<String, dynamic> _getStatusBadgeConfig(OrderStatus status, bool isDarkMode) {
    switch (status) {
      case OrderStatus.newOrder:
        return {
          'label': 'New Lead',
          'bg': isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
          'color': isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
          'border': isDarkMode ? const Color(0xFF059669) : const Color(0xFFA5D6A7),
          'icon': Icons.fiber_new_rounded,
        };
      case OrderStatus.callBack:
      case OrderStatus.rescheduled:
      case OrderStatus.deliveryRescheduled:
        return {
          'label': status.label,
          'bg': isDarkMode ? const Color(0xFF451A03) : const Color(0xFFFFF7ED),
          'color': isDarkMode ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
          'border': isDarkMode ? const Color(0xFFEA580C) : const Color(0xFFFFEDD5),
          'icon': Icons.schedule_rounded,
        };
      case OrderStatus.upsellPending:
        return {
          'label': 'Upsell Pending',
          'bg': isDarkMode ? const Color(0xFF3B0764) : const Color(0xFFF3E8FF),
          'color': isDarkMode ? const Color(0xFFD8B4FE) : const Color(0xFF7E22CE),
          'border': isDarkMode ? const Color(0xFFA855F7) : const Color(0xFFE9D5FF),
          'icon': Icons.trending_up_rounded,
        };
      case OrderStatus.accepted:
      case OrderStatus.delivered:
        return {
          'label': status.label,
          'bg': isDarkMode ? const Color(0xFF022C22) : const Color(0xFFECFDF5),
          'color': isDarkMode ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
          'border': isDarkMode ? const Color(0xFF10B981) : const Color(0xFFA7F3D0),
          'icon': Icons.check_circle_outline_rounded,
        };
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.failedDelivery:
        return {
          'label': status.label,
          'bg': isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
          'color': isDarkMode ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
          'border': isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFFECACA),
          'icon': Icons.cancel_outlined,
        };
      default:
        return {
          'label': status.label,
          'bg': isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          'color': isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          'border': isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          'icon': Icons.info_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final productName = order.productId.contains('tea')
        ? 'Grazer Herbal Detox Tea'
        : (order.productId.contains('booster') ? 'Herbal Vitality Booster' : 'Clear Skin Care Set');

    final badge = _getStatusBadgeConfig(order.status, isDarkMode);
    final agent = _getLogisticsAgentName(order);
    final createdDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    final updatedDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.updatedAt);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${order.orderNumber}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: badge['bg'] as Color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: badge['border'] as Color, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badge['icon'] as IconData, size: 11, color: badge['color'] as Color),
                                    const SizedBox(width: 3),
                                    Text(badge['label'] as String, style: TextStyle(color: badge['color'] as Color, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Created: $createdDateStr • Updated: $updatedDateStr',
                            style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Section 1: Customer Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 15, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                          const SizedBox(width: 5),
                          Text('CUSTOMER PROFILE & ADDRESS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SelectableText(
                            order.customerPhone,
                            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDarkMode ? const Color(0xFF10B981) : Colors.green.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${order.deliveryAddress}, ${order.deliveryCity ?? ""}, ${order.deliveryState}',
                              style: GoogleFonts.inter(fontSize: 11.5, color: isDarkMode ? const Color(0xFFCBD5E1) : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Section 2: Order & Pricing Itemization
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 15, color: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                          const SizedBox(width: 5),
                          Text('PRODUCT & PAYABLE COD BREAKDOWN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            'Qty: ${order.quantity} × $currency${order.basePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(fontSize: 11.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (order.upsellAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🟣 Up-sell Addition:', style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? const Color(0xFFA78BFA) : Colors.purple)),
                            Text('+$currency${order.upsellAmount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                          ],
                        ),
                      ],
                      if (order.downsellDiscount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🟢 Down-sell Discount:', style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? const Color(0xFF34D399) : Colors.green)),
                            Text('-$currency${order.downsellDiscount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                      const Divider(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('TOTAL CASH ON DELIVERY (COD):', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                          ),
                          Text(
                            '$currency ${order.totalAmount}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Section 3: Logistics Agent
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDarkMode ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ASSIGNED LOGISTICS AGENT / DRIVER', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 9.5, color: const Color(0xFF0284C7), letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(agent, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                            Text('Fulfillment Hub matched for ${order.deliveryState} door-step dispatch.', style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Section 4: Assigned Sales Call Rep & Supervisor Reassign Action
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.headset_mic_outlined, size: 18, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ASSIGNED SALES CALL REP', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 9.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(
                              order.salesRepId != null ? 'Call Rep (ID: ${order.salesRepId})' : 'Unassigned / Auto-Routing',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                      if (onReassignOrder != null && currentUser.role != UserRole.salesCallRep)
                        ElevatedButton.icon(
                          onPressed: onReassignOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                            foregroundColor: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                          label: const Text('Reassign', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Footer
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStartCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Start Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onOpenTimeline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        side: BorderSide(color: isDarkMode ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.history_toggle_off_rounded, size: 16),
                      label: const Text('Timeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    quickStatusMenu,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
