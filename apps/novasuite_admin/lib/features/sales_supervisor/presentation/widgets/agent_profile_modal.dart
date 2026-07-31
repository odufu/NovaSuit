import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 20),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 700,
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
            // Modal Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 22 : 26,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      widget.supervisee.user.fullName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.supervisee.user.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.supervisee.user.email} • Sales Call Rep',
                          style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                          overflow: TextOverflow.ellipsis,
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

            // Modal Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🛍️ Supervisor Product Assignment', textPrimary),
                    const SizedBox(height: 4),
                    Text(
                      'Select products this agent is licensed to receive in round-robin queue distribution:',
                      style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                    ),
                    const SizedBox(height: 12),

                    Column(
                      children: _allAvailableProducts.map((prod) {
                        final isAssigned = _assignedProducts.contains(prod);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : isDark
                                    ? const Color(0xFF0C1F17)
                                    : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAssigned ? const Color(0xFF10B981).withValues(alpha: 0.4) : borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAssigned ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                                color: isAssigned ? const Color(0xFF10B981) : textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  prod,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch.adaptive(
                                value: isAssigned,
                                activeTrackColor: const Color(0xFF10B981),
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

                    const SizedBox(height: 20),

                    _buildSectionHeader('⚡ Capacity & Auto-Assignment Settings', textPrimary),
                    const SizedBox(height: 12),

                    if (isMobile) ...[
                      _buildLeadCapBox(isDark, borderColor, textMuted),
                      const SizedBox(height: 10),
                      _buildAutoAssignBox(isDark, borderColor, textPrimary, textMuted),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _buildLeadCapBox(isDark, borderColor, textMuted)),
                          const SizedBox(width: 14),
                          Expanded(child: _buildAutoAssignBox(isDark, borderColor, textPrimary, textMuted)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Performance Metrics Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('📊 Performance Metrics', textPrimary),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
                              final isSelected = _selectedTimeframe == tf;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTimeframe = tf),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tf,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
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
                    const SizedBox(height: 12),

                    if (isMobile) ...[
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Calls Made', '${widget.supervisee.callsPlacedToday}', Icons.phone, Colors.blue, isDark, borderColor)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('Confirmed', '${widget.supervisee.confirmedOrdersToday}', Icons.check_circle, const Color(0xFF10B981), isDark, borderColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Conv. Rate', '${widget.supervisee.confirmationRateToday.toStringAsFixed(1)}%', Icons.insights, Colors.amber, isDark, borderColor)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('COD Revenue', '₦${(widget.supervisee.codRevenueToday / 1000).toStringAsFixed(0)}k', Icons.payments, const Color(0xFF10B981), isDark, borderColor)),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Calls Made', '${widget.supervisee.callsPlacedToday}', Icons.phone, Colors.blue, isDark, borderColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard('Confirmed', '${widget.supervisee.confirmedOrdersToday}', Icons.check_circle, const Color(0xFF10B981), isDark, borderColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard('Conv. Rate', '${widget.supervisee.confirmationRateToday.toStringAsFixed(1)}%', Icons.insights, Colors.amber, isDark, borderColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard('COD Revenue', '₦${(widget.supervisee.codRevenueToday / 1000).toStringAsFixed(0)}k', Icons.payments, const Color(0xFF10B981), isDark, borderColor)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Modal Footer Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                            icon: const Icon(Icons.check, size: 16),
                            label: Text('Save Agent Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Leads reassigned to queue overflow.')),
                                  );
                                },
                                icon: const Icon(Icons.swap_horiz, color: Colors.amber, size: 14),
                                label: Text('Reassign Leads', style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All active leads reassigned to queue overflow.')),
                            );
                          },
                          icon: const Icon(Icons.swap_horiz, color: Colors.amber),
                          label: Text('Reassign All Leads', style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
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
                              label: Text('Save Agent Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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

  Widget _buildLeadCapBox(bool isDark, Color borderColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Active Lead Cap', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
              Text('$_maxLeadCap Leads',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981))),
            ],
          ),
          Slider(
            value: _maxLeadCap.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) {
              setState(() {
                _maxLeadCap = val.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutoAssignBox(bool isDark, Color borderColor, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
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
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                const SizedBox(height: 2),
                Text('Deliver incoming leads',
                    style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
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
    );
  }

  Widget _buildSectionHeader(String title, Color textPrimary) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
