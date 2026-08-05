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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F261E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row 1: Order # Badge + Date + Stage Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDarkMode ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '#${order.orderNumber}',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF047857),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusDateStr,
                      style: GoogleFonts.inter(fontSize: 9.5, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge['bg'] as Color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badge['border'] as Color, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badge['icon'] as IconData, size: 11, color: badge['color'] as Color),
                      const SizedBox(width: 4),
                      Text(
                        badge['label'] as String,
                        style: TextStyle(
                          color: badge['color'] as Color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Customer Avatar + Name & Phone + Total COD Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                          : [const Color(0xFF0A2E23), const Color(0xFF059669)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 11, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                          const SizedBox(width: 4),
                          Text(
                            order.customerPhone,
                            style: GoogleFonts.jetBrainsMono(
                              color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${order.deliveryState} • ${order.deliveryAddress}',
                        style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL COD',
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF047857),
                        ),
                      ),
                      Text(
                        '$currency${order.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Product Item & Qty Breakdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 14, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                      const SizedBox(width: 6),
                      Text(
                        productName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Qty: ${order.quantity} × $currency${order.basePrice.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Row 4: Logistics Agent Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDarkMode ? const Color(0xFF0284C7).withValues(alpha: 0.3) : const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 13, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Logistics Rep: $logisticsAgent',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Row 5: Action Row 1 (Call Client + Chat / History Log)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStartCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                    label: Text(
                      'Call Client',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenActivities,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      side: BorderSide(color: isDarkMode ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC)),
                      backgroundColor: isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFF0F9FF),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.forum_outlined, size: 14),
                    label: Text(
                      'Chat / Log',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 6: Action Row 2 (View Details + Quick Menu)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDarkMode ? Colors.white70 : const Color(0xFF334155),
                      side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 13),
                    label: Text('View Details', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                quickStatusMenu,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
