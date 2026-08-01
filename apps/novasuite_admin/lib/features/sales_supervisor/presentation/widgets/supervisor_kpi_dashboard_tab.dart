import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'package:intl/intl.dart';
import '../providers/supervisor_dashboard_provider.dart';
import 'agent_profile_modal.dart';

class SupervisorKpiDashboardTab extends StatefulWidget {
  final List<SuperviseePerformanceModel> squad;
  final List<OrderModel>? squadOrders;
  final SupervisorDailyReportModel? dailyReport;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel) onUpdateSupervisee;
  final Function(DateTime selectedDate, String timeframe)? onDateOrTimeframeChanged;
  final Function(List<String> orderIds, String targetRepId)? onReassignOrders;

  const SupervisorKpiDashboardTab({
    super.key,
    required this.squad,
    this.squadOrders,
    this.dailyReport,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onUpdateSupervisee,
    this.onDateOrTimeframeChanged,
    this.onReassignOrders,
  });

  @override
  State<SupervisorKpiDashboardTab> createState() => _SupervisorKpiDashboardTabState();
}

class _SupervisorKpiDashboardTabState extends State<SupervisorKpiDashboardTab> {
  final List<String> _availableProducts = [
    'All Products',
    'Grazer Herbal Detox Tea',
    'Herbal Vitality Booster',
    'Clear Skin Care Set',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final supervisorProvider = context.watch<SupervisorDashboardProvider>();
    final squadList = supervisorProvider.squad.isNotEmpty ? supervisorProvider.squad : widget.squad;
    final filteredSquad = squadList.where((agent) {
      final matchesSearch = agent.user.fullName.toLowerCase().contains(supervisorProvider.searchQuery.toLowerCase()) ||
          agent.user.email.toLowerCase().contains(supervisorProvider.searchQuery.toLowerCase());
      final matchesProduct = supervisorProvider.selectedProductFilter == 'All Products' ||
          agent.assignedProducts.contains(supervisorProvider.selectedProductFilter);
      return matchesSearch && matchesProduct;
    }).toList();

    final String? topPerformerId = squadList.isNotEmpty
        ? squadList.reduce((curr, next) => curr.codRevenueToday >= next.codRevenueToday ? curr : next).user.id
        : null;

    final showCards = isMobile || supervisorProvider.isCardViewMode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.dailyReport != null) ...[
            _buildOperationalReportSummary(widget.dailyReport!, theme, isDark, cardBg, textPrimary, textMuted, borderColor, isMobile),
            const SizedBox(height: 20),
          ],

          // Leaderboard Container & Controls
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Control Bar (Search + Product Filter + Timeframe + View Switcher)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🏆 Supervisee Leaderboard',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monday 27th July, 2026',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                _buildTimeframeBar(isDark, theme, borderColor, textMuted),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🏆 Supervisee Leaderboard & Daily Report',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Monday 27th July, 2026',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildTimeframeBar(isDark, theme, borderColor, textMuted),
                          ],
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Search + Product Filter + Cards/Table Switcher
                      if (isMobile) ...[
                        TextField(
                          onChanged: (val) => context.read<SupervisorDashboardProvider>().setSearchQuery(val),
                          style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search rep name...',
                            hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: borderColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: supervisorProvider.selectedProductFilter,
                                    isExpanded: true,
                                    dropdownColor: cardBg,
                                    style: GoogleFonts.inter(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600),
                                    items: _availableProducts.map((p) {
                                      return DropdownMenuItem<String>(
                                        value: p,
                                        child: Text(p, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<SupervisorDashboardProvider>().setProductFilter(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildViewSwitcher(isDark, borderColor, textMuted),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 240,
                              child: TextField(
                                onChanged: (val) => context.read<SupervisorDashboardProvider>().setSearchQuery(val),
                                style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Search rep name...',
                                  hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: supervisorProvider.selectedProductFilter,
                                  dropdownColor: cardBg,
                                  style: GoogleFonts.inter(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600),
                                  items: _availableProducts.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p,
                                      child: Text(p),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      context.read<SupervisorDashboardProvider>().setProductFilter(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            _buildViewSwitcher(isDark, borderColor, textMuted),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),

                // Table View or Cards View
                if (filteredSquad.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('No call reps found matching filter criteria', style: GoogleFonts.inter(color: textMuted)),
                    ),
                  )
                else if (showCards)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: filteredSquad.map((agent) {
                        final isTop = agent.user.id == topPerformerId;
                        return _buildMobileSuperviseeCard(agent, isTop, isDark, theme, borderColor, textPrimary, textMuted);
                      }).toList(),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 68,
                            columnSpacing: 18,
                            horizontalMargin: 16,
                            headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC)),
                            dividerThickness: 1.0,
                            border: TableBorder(
                              horizontalInside: BorderSide(color: borderColor, width: 1),
                            ),

                            // Clean uppercase text-only column headers without icons
                            columns: [
                              DataColumn(label: Text('AGENT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('ASSIGNED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('CONFIRMED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('DELIVERED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('TODAY/PREV', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('RESCHEDULED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('IN-PROGRESS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('SWITCHED-OFF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('UNANSWERED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('CANCELLED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('PENDING', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                              DataColumn(label: Text('ACTION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted, letterSpacing: 0.5))),
                            ],
                            rows: filteredSquad.asMap().entries.map((entry) {
                              final index = entry.key;
                              final agent = entry.value;
                              final isTopPerformer = agent.user.id == topPerformerId;

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (isTopPerformer) {
                                    return isDark ? const Color(0xFF1E3A2B) : const Color(0xFFECFDF5);
                                  }
                                  if (states.contains(WidgetState.hovered)) {
                                    return isDark ? const Color(0xFF13362A) : const Color(0xFFF1F5F9);
                                  }
                                  return Colors.transparent;
                                }),
                                cells: [
                                  // 1. Agent Name, Ext, and Top Performer Crown Badge
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: isTopPerformer ? Colors.amber.withValues(alpha: 0.3) : theme.primaryColor.withValues(alpha: 0.2),
                                              child: Text(
                                                agent.user.fullName[0].toUpperCase(),
                                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isTopPerformer ? Colors.amber : theme.primaryColor),
                                              ),
                                            ),
                                            if (isTopPerformer)
                                              const Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Text('👑', style: TextStyle(fontSize: 10)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  agent.user.fullName,
                                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                if (isTopPerformer) ...[
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                                    ),
                                                    child: Text('TOP', style: GoogleFonts.jetBrainsMono(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.amber)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Text(
                                              'Ext 10${index + 1}',
                                              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: textMuted),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 2. Assigned
                                  DataCell(
                                    Text('${agent.assignedCount}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ),

                                  // 3. Confirmed
                                  DataCell(
                                    Text('${agent.confirmedOrdersToday}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                  ),

                                  // 4. Delivered + untagged CRM note
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${agent.deliveredCount}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('${agent.untaggedOnCrm} untagged', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.amber)),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 5. Today / Prev
                                  DataCell(
                                    Text('${agent.deliveredTodayAssigned} / ${agent.deliveredPreviousDays}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ),

                                  // 6. Rescheduled
                                  DataCell(
                                    Text('${agent.rescheduledCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.purple)),
                                  ),

                                  // 7. In Progress
                                  DataCell(
                                    Text('${agent.inProgressCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, color: Colors.amber)),
                                  ),

                                  // 8. Switched Off
                                  DataCell(
                                    Text('${agent.switchedOffCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, color: Colors.deepOrange)),
                                  ),

                                  // 9. Unanswered (Not Picking)
                                  DataCell(
                                    Text('${agent.notPickingCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, color: Colors.redAccent)),
                                  ),

                                  // 10. Cancelled
                                  DataCell(
                                    Text('${agent.cancelledCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, color: Colors.grey)),
                                  ),

                                  // 11. Pending (Not Ready)
                                  DataCell(
                                    Text('${agent.notReadyCount}', style: GoogleFonts.jetBrainsMono(fontSize: 12.5, color: Colors.teal)),
                                  ),

                                  // 12. Actions
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.manage_accounts, color: Color(0xFF10B981), size: 20),
                                      tooltip: 'Manage Agent Profile',
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
                                            onReassignOrders: widget.onReassignOrders,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeBar(bool isDark, TenantTheme theme, Color borderColor, Color textMuted) {
    final provider = context.watch<SupervisorDashboardProvider>();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
          final isSelected = provider.selectedTimeframe == tf;
          return GestureDetector(
            onTap: () => context.read<SupervisorDashboardProvider>().setTimeframe(tf),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tf,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildViewSwitcher(bool isDark, Color borderColor, Color textMuted) {
    final provider = context.watch<SupervisorDashboardProvider>();
    final isCard = provider.isCardViewMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => context.read<SupervisorDashboardProvider>().setCardViewMode(true),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isCard ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.grid_view_rounded, size: 13, color: isCard ? const Color(0xFF10B981) : textMuted),
                  const SizedBox(width: 4),
                  Text('Cards', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: isCard ? const Color(0xFF10B981) : textMuted)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 16, color: borderColor),
          InkWell(
            onTap: () => context.read<SupervisorDashboardProvider>().setCardViewMode(false),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: !isCard ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_chart_rounded, size: 13, color: !isCard ? const Color(0xFF10B981) : textMuted),
                  const SizedBox(width: 4),
                  Text('Table', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: !isCard ? const Color(0xFF10B981) : textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSuperviseeCard(
    SuperviseePerformanceModel agent,
    bool isTopPerformer,
    bool isDark,
    TenantTheme theme,
    Color borderColor,
    Color textPrimary,
    Color textMuted,
  ) {
    final products = agent.assignedProducts.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTopPerformer
            ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTopPerformer ? Colors.amber : borderColor,
          width: isTopPerformer ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isTopPerformer ? Colors.amber.withValues(alpha: 0.3) : theme.primaryColor.withValues(alpha: 0.2),
                          child: Text(
                            agent.user.fullName[0].toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isTopPerformer ? Colors.amber : theme.primaryColor),
                          ),
                        ),
                        if (isTopPerformer)
                          const Positioned(right: -2, top: -2, child: Text('👑', style: TextStyle(fontSize: 10))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  agent.user.fullName,
                                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTopPerformer)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                  ),
                                  child: Text('TOP', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                                ),
                            ],
                          ),
                          Text(
                            'Ext 102 • ${products.isEmpty ? "GRAZER, SHAMPOO" : products}',
                            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF10B981) : const Color(0xFF86EFAC)),
                ),
                child: Text(
                  '${agent.assignedCount} Assigned',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D), fontSize: 10.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge('✅ ${agent.confirmedOrdersToday} Confirmed', const Color(0xFF10B981), isDark),
              _buildBadge('🚚 ${agent.deliveredCount} Delivered (${agent.untaggedOnCrm} untagged)', const Color(0xFF059669), isDark),
              _buildBadge('📅 ${agent.deliveredTodayAssigned} / ${agent.deliveredPreviousDays} Prev', Colors.blue, isDark),
              _buildBadge('⏰ ${agent.rescheduledCount} Rescheduled', Colors.purple, isDark),
              _buildBadge('📞 ${agent.inProgressCount} In progress', Colors.amber, isDark),
              _buildBadge('📴 ${agent.switchedOffCount} Switched off', Colors.deepOrange, isDark),
              _buildBadge('🚫 ${agent.notPickingCount} Unanswered', Colors.redAccent, isDark),
              _buildBadge('❌ ${agent.cancelledCount} Cancelled', Colors.grey, isDark),
              _buildBadge('⏸️ ${agent.notReadyCount} Pending', Colors.teal, isDark),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AgentProfileModal(
                    supervisee: agent,
                    squadOrders: widget.squadOrders,
                    activeTheme: theme,
                    isDarkMode: isDark,
                    onSave: widget.onUpdateSupervisee,
                  ),
                );
              },
              icon: const Icon(Icons.manage_accounts, size: 14),
              label: Text('Manage Agent Profile', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildOperationalReportSummary(
    SupervisorDailyReportModel r,
    TenantTheme theme,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
    Color borderColor,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Squad Operational Status',
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          DateFormat('EEE d MMM, yyyy').format(r.date),
                          style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copy Log',
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF10B981)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operational daily report summary copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '📋 Squad Operational Status Breakdown',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          DateFormat('EEEE d MMMM, yyyy').format(r.date),
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operational daily report summary copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text('Copy Log', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Balanced Medium KPI Cards Grid (5 cols desktop, 3 cols mobile with aspect ratio 1.35 for zero overflow)
          GridView.count(
            crossAxisCount: isMobile ? 3 : 5,
            childAspectRatio: isMobile ? 1.35 : 2.4,
            crossAxisSpacing: isMobile ? 6 : 10,
            mainAxisSpacing: isMobile ? 6 : 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMediumKpiCard('Total Assigned', '${r.totalAssigned}', theme.primaryColor, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Confirmed', '${r.confirmedCount}', const Color(0xFF10B981), isDark, borderColor, isMobile),
              _buildMediumKpiCard('Delivered', '${r.totalDelivered}', Colors.blue, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Rescheduled', '${r.rescheduledCount}', Colors.purple, isDark, borderColor, isMobile),
              _buildMediumKpiCard('In Progress', '${r.inProgressCount}', Colors.orange, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Switched Off', '${r.switchedOffCount}', Colors.deepOrange, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Not Picking', '${r.notPickingCount}', Colors.redAccent, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Cancelled', '${r.cancelledCount}', Colors.grey, isDark, borderColor, isMobile),
              _buildMediumKpiCard('Not Ready', '${r.notReadyCount}', Colors.teal, isDark, borderColor, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediumKpiCard(String label, String count, Color color, bool isDark, Color borderColor, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 3 : 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isMobile ? 6 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
