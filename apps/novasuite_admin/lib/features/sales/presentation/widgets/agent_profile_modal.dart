import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

class AgentProfileModal extends StatefulWidget {
  final SuperviseePerformanceModel supervisee;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel updated) onSave;

  const AgentProfileModal({
    super.key,
    required this.supervisee,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onSave,
  });

  @override
  State<AgentProfileModal> createState() => _AgentProfileModalState();
}

class _AgentProfileModalState extends State<AgentProfileModal> {
  late List<String> _assignedProducts;
  late int _maxLeadCap;
  late bool _autoAssignEnabled;
  String _selectedTimeframe = 'Daily';

  final List<String> _allAvailableProducts = [
    'Grazer Herbal Detox Tea',
    'Herbal Vitality Booster',
    'Clear Skin Care Set',
  ];

  @override
  void initState() {
    super.initState();
    _assignedProducts = List.from(widget.supervisee.assignedProducts);
    _maxLeadCap = widget.supervisee.maxLeadCap;
    _autoAssignEnabled = widget.supervisee.autoAssignmentEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 750,
        constraints: const BoxConstraints(maxHeight: 820),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      widget.supervisee.user.fullName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.supervisee.user.fullName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Active Online',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.supervisee.user.email} • Sales Call Rep',
                          style: TextStyle(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: textMuted),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🛍️ Supervisor Product Assignment Authority', textPrimary),
                    const SizedBox(height: 6),
                    Text(
                      'Select products this agent is licensed to receive in automatic round-robin queue distribution:',
                      style: TextStyle(fontSize: 13, color: textMuted),
                    ),
                    const SizedBox(height: 14),

                    Column(
                      children: _allAvailableProducts.map((prod) {
                        final isAssigned = _assignedProducts.contains(prod);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? theme.primaryColor.withValues(alpha: 0.08)
                                : isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAssigned ? theme.primaryColor.withValues(alpha: 0.4) : borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAssigned ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                                color: isAssigned ? theme.primaryColor : textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  prod,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              Switch.adaptive(
                                value: isAssigned,
                                activeTrackColor: theme.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    if (val) {
                                      _assignedProducts.add(prod);
                                    } else {
                                      _assignedProducts.remove(prod);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('⚡ Capacity & Auto-Assignment Settings', textPrimary),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Max Active Lead Cap',
                                        style: TextStyle(fontSize: 13, color: textMuted)),
                                    Text('$_maxLeadCap Leads',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor)),
                                  ],
                                ),
                                Slider(
                                  value: _maxLeadCap.toDouble(),
                                  min: 5,
                                  max: 50,
                                  divisions: 9,
                                  activeColor: theme.primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      _maxLeadCap = val.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Auto Round-Robin',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary)),
                                      const SizedBox(height: 4),
                                      Text('Deliver incoming leads',
                                          style: TextStyle(fontSize: 12, color: textMuted)),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _autoAssignEnabled,
                                  activeTrackColor: const Color(0xFF10B981),
                                  onChanged: (val) {
                                    setState(() {
                                      _autoAssignEnabled = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('📊 Performance Metrics', textPrimary),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
                              final isSelected = _selectedTimeframe == tf;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTimeframe = tf),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tf,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        _buildMetricCard('Calls Made', '${widget.supervisee.callsPlacedToday}', Icons.phone, Colors.blue, isDark, borderColor),
                        const SizedBox(width: 12),
                        _buildMetricCard('Confirmed', '${widget.supervisee.confirmedOrdersToday}', Icons.check_circle, const Color(0xFF10B981), isDark, borderColor),
                        const SizedBox(width: 12),
                        _buildMetricCard('Conv. Rate', '${widget.supervisee.confirmationRateToday.toStringAsFixed(1)}%', Icons.insights, Colors.amber, isDark, borderColor),
                        const SizedBox(width: 12),
                        _buildMetricCard('COD Revenue', '₦${(widget.supervisee.codRevenueToday / 1000).toStringAsFixed(0)}k', Icons.payments, theme.primaryColor, isDark, borderColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All active leads reassigned to queue overflow.')),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, color: Colors.amber),
                    label: const Text('Reassign All Leads', style: TextStyle(color: Colors.amber)),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        onPressed: () {
                          final updated = widget.supervisee.copyWith(
                            assignedProducts: _assignedProducts,
                            maxLeadCap: _maxLeadCap,
                            autoAssignmentEnabled: _autoAssignEnabled,
                          );
                          widget.onSave(updated);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save Agent Profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textPrimary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}
