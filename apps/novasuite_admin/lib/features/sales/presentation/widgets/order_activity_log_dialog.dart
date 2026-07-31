import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class OrderActivityLogDialog extends StatelessWidget {
  final OrderModel order;
  final UserModel currentUser;
  final String currency;
  final List<OrderActivityModel> loggedActivities;

  const OrderActivityLogDialog({
    super.key,
    required this.order,
    required this.currentUser,
    required this.currency,
    required this.loggedActivities,
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

  List<Map<String, dynamic>> _buildTimelineItems(bool isDarkMode) {
    final badge = _getStatusBadgeConfig(order.status, isDarkMode);
    final agent = _getLogisticsAgentName(order);

    if (loggedActivities.isNotEmpty) {
      return loggedActivities.map((act) {
        IconData icon = Icons.history_toggle_off_rounded;
        Color color = const Color(0xFF0284C7);

        if (act.activityType == 'status_update') {
          icon = badge['icon'] as IconData;
          color = badge['color'] as Color;
        } else if (act.activityType == 'callback_scheduled') {
          icon = Icons.alarm_on_rounded;
          color = const Color(0xFFF59E0B);
        } else if (act.activityType == 'logistics_assigned') {
          icon = Icons.local_shipping_outlined;
          color = const Color(0xFF0284C7);
        } else if (act.activityType == 'upsell_requested') {
          icon = Icons.shopping_bag_outlined;
          color = const Color(0xFFA78BFA);
        } else if (act.activityType == 'cancelled') {
          icon = Icons.cancel_outlined;
          color = const Color(0xFFEF4444);
        } else if (act.activityType == 'order_created') {
          icon = Icons.add_shopping_cart_rounded;
          color = const Color(0xFF10B981);
        }

        return {
          'date': DateFormat('dd MMM yyyy, hh:mm a').format(act.createdAt),
          'activity': act.title,
          'details': act.details,
          'user': act.performedBy,
          'role': act.userRole,
          'icon': icon,
          'color': color,
        };
      }).toList();
    }

    return [
      if (order.scheduledCallbackAt != null)
        {
          'date': DateFormat('dd MMM yyyy, hh:mm a').format(order.updatedAt),
          'activity': 'Callback Scheduled for ${DateFormat('dd MMM, hh:mm a').format(order.scheduledCallbackAt!)}',
          'details': order.rescheduleNote ?? 'Follow-up callback timer active for Call Rep.',
          'user': '${currentUser.firstName} ${currentUser.lastName}',
          'role': 'Sales Call Rep',
          'icon': Icons.alarm_on_rounded,
          'color': const Color(0xFFF59E0B),
        },
      {
        'date': DateFormat('dd MMM yyyy, hh:mm a').format(order.updatedAt),
        'activity': 'Status updated to "${order.status.label}"',
        'details': order.upsellNotes ?? 'Pipeline stage updated via call outcome console.',
        'user': '${currentUser.firstName} ${currentUser.lastName}',
        'role': 'Sales Call Rep',
        'icon': badge['icon'] as IconData,
        'color': badge['color'] as Color,
      },
      {
        'date': DateFormat('dd MMM yyyy, hh:mm a').format(order.updatedAt.subtract(const Duration(hours: 2))),
        'activity': 'Assigned to Logistics Agent: $agent',
        'details': 'Hub location auto-matched for ${order.deliveryState} delivery dispatch.',
        'user': 'System Auto-Dispatcher',
        'role': 'Automated Workflow',
        'icon': Icons.local_shipping_outlined,
        'color': const Color(0xFF0284C7),
      },
      {
        'date': DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
        'activity': 'Order Created & Ingested into Pipeline',
        'details': 'Product: ${order.productId} (${order.quantity} units) • COD Total: $currency${order.totalAmount}',
        'user': 'Web Checkout API',
        'role': 'System Ingestion',
        'icon': Icons.add_shopping_cart_rounded,
        'color': const Color(0xFF10B981),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final agent = _getLogisticsAgentName(order);
    final badge = _getStatusBadgeConfig(order.status, isDarkMode);
    final activities = _buildTimelineItems(isDarkMode);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF0284C7), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Activity Log', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                              Text(
                                'Order #${order.orderNumber} • ${order.customerName}',
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
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

              // Current Stage Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Current Stage: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badge['bg'] as Color, borderRadius: BorderRadius.circular(14), border: Border.all(color: badge['border'] as Color)),
                          child: Text(badge['label'] as String, style: TextStyle(color: badge['color'] as Color, fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ),
                      ],
                    ),
                    Text('Assigned Agent: $agent', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Responsive Activity Log Timeline
              Text('CHRONOLOGICAL ACTIVITY TIMELINE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, letterSpacing: 0.8)),
              const SizedBox(height: 8),

              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: activities.map((act) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (act['color'] as Color).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(act['icon'] as IconData, size: 14, color: act['color'] as Color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          act['activity'] as String,
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                        ),
                                        Text(
                                          act['date'] as String,
                                          style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      act['details'] as String,
                                      style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                                    ),
                                    const SizedBox(height: 5),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(Icons.person_outline, size: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${act['user']} • ',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10, color: isDarkMode ? Colors.white70 : Colors.black87),
                                        ),
                                        Text(
                                          act['role'] as String,
                                          style: GoogleFonts.inter(fontSize: 9.5, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
