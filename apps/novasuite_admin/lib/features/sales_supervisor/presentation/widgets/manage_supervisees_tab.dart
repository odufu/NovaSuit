import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'agent_profile_modal.dart';
import 'supervisee_leaderboard_card.dart';

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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final topPerformerId = widget.squad.isNotEmpty
                            ? (widget.squad.reduce((a, b) => a.confirmedOrdersToday >= b.confirmedOrdersToday ? a : b)).user.id
                            : '';

                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 340,
                            mainAxisExtent: 470,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: filteredSquad.length,
                          itemBuilder: (context, index) {
                            final agent = filteredSquad[index];
                            final isTop = agent.user.id == topPerformerId;

                            return SuperviseeLeaderboardCard(
                              agent: agent,
                              isTopPerformer: isTop,
                              isDarkMode: isDark,
                              theme: theme,
                              onManageProfile: () {
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
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
