import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'agent_profile_modal.dart';

class ManageSuperviseesTab extends StatefulWidget {
  final List<SuperviseePerformanceModel> squad;
  final List<OrderModel>? squadOrders;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel) onUpdateSupervisee;
  final Function(List<String> orderIds, String targetRepId)? onExecuteReassignment;

  const ManageSuperviseesTab({
    super.key,
    required this.squad,
    this.squadOrders,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onUpdateSupervisee,
    this.onExecuteReassignment,
  });

  @override
  State<ManageSuperviseesTab> createState() => _ManageSuperviseesTabState();
}

class _ManageSuperviseesTabState extends State<ManageSuperviseesTab> {
  late ValueNotifier<String> _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, queryVal, _) {
        final filteredSquad = widget.squad.where((sup) {
          final name = sup.user.fullName.toLowerCase();
          final email = sup.user.email.toLowerCase();
          return name.contains(queryVal.toLowerCase()) || email.contains(queryVal.toLowerCase());
        }).toList();

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
                      '👥 Squad Supervisee Management Hub',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage squad call reps, assign product licenses for auto-distribution, and configure lead caps.',
                      style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                    ),
                  ],
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    onChanged: (val) => _searchQuery.value = val,
                    style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search supervisee...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: filteredSquad.isEmpty
                  ? Center(
                      child: Text('No supervisees found matching "$queryVal"',
                          style: GoogleFonts.inter(color: textMuted)),
                    )
                  : ListView.builder(
                      itemCount: filteredSquad.length,
                      itemBuilder: (context, index) {
                        final agent = filteredSquad[index];
                        final products = agent.assignedProducts.join(', ');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                                        child: Text(
                                          agent.user.fullName[0].toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                agent.user.fullName,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Ext 10${index + 1} • ${agent.user.email}',
                                                style: GoogleFonts.jetBrainsMono(
                                                  fontSize: 11,
                                                  color: textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '📦 Licensed Products: $products',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF0A2E23),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDark ? const Color(0xFF10B981) : const Color(0xFF86EFAC)),
                                        ),
                                        child: Text(
                                          '35 Total Assigned',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: theme.primaryColor),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AgentProfileModal(
                                              supervisee: agent,
                                              squadOrders: widget.squadOrders,
                                              squadReps: widget.squad,
                                              activeTheme: theme,
                                              isDarkMode: isDark,
                                              onSave: widget.onUpdateSupervisee,
                                              onReassignOrders: widget.onExecuteReassignment,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.manage_accounts, size: 16),
                                        label: Text('Manage Agent Profile', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildMetricBadge('✅ 21 Confirmed', const Color(0xFF10B981), isDark),
                                  _buildMetricBadge('🚚 17 Delivered (6 untagged on CRM)', const Color(0xFF059669), isDark),
                                  _buildMetricBadge('⏰ 7 Rescheduled', const Color(0xFF8B5CF6), isDark),
                                  _buildMetricBadge('📞 6 In progress', Colors.amber, isDark),
                                  _buildMetricBadge('📴 2 Switched off', Colors.deepOrange, isDark),
                                  _buildMetricBadge('🚫 4 Not picking', Colors.redAccent, isDark),
                                  _buildMetricBadge('❌ 0 Cancelled', Colors.grey, isDark),
                                  _buildMetricBadge('⏸️ 1 Not ready', Colors.teal, isDark),
                                  _buildMetricBadge('📦 15 delivered today, 2 prev', Colors.blue, isDark),
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
      },
    );
  }

  Widget _buildMetricBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
