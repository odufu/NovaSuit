import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class SupervisorApprovalsTab extends StatefulWidget {
  final List<OrderModel> pendingUpsellOrders;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(String orderId, bool approve) onResolveUpsell;

  const SupervisorApprovalsTab({
    super.key,
    required this.pendingUpsellOrders,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onResolveUpsell,
  });

  @override
  State<SupervisorApprovalsTab> createState() => _SupervisorApprovalsTabState();
}

class _SupervisorApprovalsTabState extends State<SupervisorApprovalsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ Realtime Upsell & Discount Approval Queue',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Approve or decline high-margin upsells and custom discount requests submitted by squad call reps in real time.',
                  style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.pendingUpsellOrders.isNotEmpty
                    ? Colors.amber.withValues(alpha: 0.15)
                    : const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.pendingUpsellOrders.isNotEmpty
                      ? Colors.amber.withValues(alpha: 0.3)
                      : const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.pendingUpsellOrders.isNotEmpty ? Icons.pending_actions : Icons.check_circle,
                    color: widget.pendingUpsellOrders.isNotEmpty ? Colors.amber : const Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.pendingUpsellOrders.length} Pending Approval',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.pendingUpsellOrders.isNotEmpty ? Colors.amber : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Expanded(
          child: widget.pendingUpsellOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 64, color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'All Upsells Processed!',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'There are no pending upsell or discount requests awaiting supervisor approval.',
                        style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.pendingUpsellOrders.length,
                  itemBuilder: (context, index) {
                    final order = widget.pendingUpsellOrders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.trending_up, color: theme.primaryColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'UPSELL REQUESTED',
                                            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Customer: ${order.customerName} (${order.customerPhone})',
                                      style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                DateTime.now().difference(order.createdAt).inMinutes < 60
                                    ? '${DateTime.now().difference(order.createdAt).inMinutes}m ago'
                                    : '${DateTime.now().difference(order.createdAt).inHours}h ago',
                                style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Divider(height: 1, color: borderColor),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Base Product', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                                    const SizedBox(height: 2),
                                    Text(order.productId, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Base Package Price', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                                    const SizedBox(height: 2),
                                    Text('₦${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Requested Total', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₦${(order.totalAmount + 10000).toStringAsFixed(0)}',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () {
                                  widget.onResolveUpsell(order.id, false);
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: Text('Decline Request', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  widget.onResolveUpsell(order.id, true);
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: Text('Approve Upsell (+₦10,000)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
