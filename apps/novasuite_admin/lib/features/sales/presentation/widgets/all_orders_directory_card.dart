import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class AllOrdersDirectoryCard extends StatelessWidget {
  final OrderModel order;
  final TenantTheme theme;
  final bool isDarkMode;
  final VoidCallback onOpenActivities;
  final VoidCallback onStartCall;
  final VoidCallback onOpenDetails;
  final Widget quickStatusMenu;

  const AllOrdersDirectoryCard({
    super.key,
    required this.order,
    required this.theme,
    required this.isDarkMode,
    required this.onOpenActivities,
    required this.onStartCall,
    required this.onOpenDetails,
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
    final currency = theme.currencySymbol;
    final productName = order.productId.contains('tea')
        ? 'Grazer Herbal Tea'
        : (order.productId.contains('booster') ? 'Vitality Booster' : 'Clear Skin Care');

    final nameParts = order.customerName.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (order.customerName.isNotEmpty ? order.customerName.substring(0, 2).toUpperCase() : 'CU');

    final badge = _getStatusBadgeConfig(order.status, isDarkMode);
    final logisticsAgent = _getLogisticsAgentName(order);
    final statusDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row 1: Order # Pill + Status Date + Current Stage Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${order.orderNumber}',
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          statusDateStr,
                          style: GoogleFonts.inter(fontSize: 9, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
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
                      Text(
                        badge['label'] as String,
                        style: TextStyle(
                          color: badge['color'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: Customer Avatar + Name & Phone + Address & COD Amount
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: isDarkMode ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.customerPhone,
                        style: GoogleFonts.jetBrainsMono(
                          color: isDarkMode ? const Color(0xFF10B981) : theme.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${order.deliveryState} - ${order.deliveryAddress}',
                        style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL COD',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$currency${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 3: Product Name & Quantity Price Breakdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        productName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Qty: ${order.quantity} × $currency${order.basePrice.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Row 4: Logistics Agent handling the order
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 12, color: Color(0xFF0284C7)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Logistics Rep: $logisticsAgent',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Single Unified Omnichannel Follow-Up CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenActivities,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.forum_outlined, size: 16),
                label: Text(
                  'Follow-Up & Connect 💬📞',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Secondary Quick Actions (Quick Status Dropdown & Details)
            Row(
              children: [
                Expanded(child: quickStatusMenu),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: onOpenDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.white70 : const Color(0xFF334155),
                    side: BorderSide(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
