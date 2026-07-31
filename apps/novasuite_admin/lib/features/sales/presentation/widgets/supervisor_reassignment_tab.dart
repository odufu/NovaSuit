import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

class SupervisorReassignmentTab extends StatefulWidget {
  final List<OrderModel> squadOrders;
  final List<SuperviseePerformanceModel> squad;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(List<String> orderIds, String targetRepId) onExecuteReassignment;

  const SupervisorReassignmentTab({
    super.key,
    required this.squadOrders,
    required this.squad,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onExecuteReassignment,
  });

  @override
  State<SupervisorReassignmentTab> createState() => _SupervisorReassignmentTabState();
}

class _SupervisorReassignmentTabState extends State<SupervisorReassignmentTab> {
  final Set<String> _selectedOrderIds = {};
  String? _selectedTargetRepId;

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final uncalledOrders = widget.squadOrders.where((o) =>
        o.status != OrderStatus.accepted &&
        o.status != OrderStatus.cancelled &&
        o.status != OrderStatus.delivered).toList();

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
                  '🔄 1-Click Lead Re-Assignment Console',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transfer carry-over or uncalled leads from overloaded or absent reps to active call reps.',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
              ],
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedTargetRepId,
                  hint: Text('Select Target Rep...', style: TextStyle(color: textMuted, fontSize: 13)),
                  dropdownColor: cardBg,
                  style: TextStyle(color: textPrimary, fontSize: 13),
                  items: widget.squad.map((rep) {
                    return DropdownMenuItem<String>(
                      value: rep.user.id,
                      child: Text('${rep.user.fullName} (${rep.activeLeadCount} leads)'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTargetRepId = val),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: (_selectedOrderIds.isNotEmpty && _selectedTargetRepId != null)
                      ? () {
                          widget.onExecuteReassignment(
                            _selectedOrderIds.toList(),
                            _selectedTargetRepId!,
                          );
                          setState(() {
                            _selectedOrderIds.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Leads reassigned successfully!')),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: Text('Reassign (${_selectedOrderIds.length}) Leads'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedOrderIds.length == uncalledOrders.length && uncalledOrders.isNotEmpty,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedOrderIds.addAll(uncalledOrders.map((o) => o.id));
                            } else {
                              _selectedOrderIds.clear();
                            }
                          });
                        },
                      ),
                      Text('Select All Uncalled Leads (${uncalledOrders.length})',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),

                Expanded(
                  child: ListView.separated(
                    itemCount: uncalledOrders.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                    itemBuilder: (context, index) {
                      final order = uncalledOrders[index];
                      final isSelected = _selectedOrderIds.contains(order.id);
                      final assignedRep = widget.squad.firstWhere(
                        (r) => r.user.id == order.salesRepId,
                        orElse: () => widget.squad.first,
                      );

                      return ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedOrderIds.add(order.id);
                              } else {
                                _selectedOrderIds.remove(order.id);
                              }
                            });
                          },
                        ),
                        title: Row(
                          children: [
                            Text(order.customerName,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                            const SizedBox(width: 8),
                            Text('(${order.customerPhone})', style: TextStyle(fontSize: 13, color: textMuted)),
                          ],
                        ),
                        subtitle: Text(
                          'Product: ${order.productId} • Currently assigned to: ${assignedRep.user.fullName}',
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                        trailing: Text(
                          '₦${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
