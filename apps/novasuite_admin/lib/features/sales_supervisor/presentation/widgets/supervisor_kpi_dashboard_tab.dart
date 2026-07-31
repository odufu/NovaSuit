import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'agent_profile_modal.dart';

class SupervisorKpiDashboardTab extends StatefulWidget {
  final List<SuperviseePerformanceModel> squad;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel) onUpdateSupervisee;

  const SupervisorKpiDashboardTab({
    super.key,
    required this.squad,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onUpdateSupervisee,
  });

  @override
  State<SupervisorKpiDashboardTab> createState() => _SupervisorKpiDashboardTabState();
}

class _SupervisorKpiDashboardTabState extends State<SupervisorKpiDashboardTab> {
  String _selectedTimeframe = 'Daily';
  String _selectedProductFilter = 'All Products';
  String _searchQuery = '';
  bool _isCardViewMode = false;

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

    final totalRevenue = widget.squad.fold<double>(0.0, (sum, sup) => sum + sup.codRevenueToday);
    final totalConfirmed = widget.squad.fold<int>(0, (sum, sup) => sum + sup.confirmedOrdersToday);
    final totalCalls = widget.squad.fold<int>(0, (sum, sup) => sum + sup.callsPlacedToday);
    final totalActiveLeads = widget.squad.fold<int>(0, (sum, sup) => sum + sup.activeLeadCount);

    final avgRate = totalCalls > 0 ? (totalConfirmed / totalCalls) * 100 : 0.0;

    // Filter squad based on search query and product filter
    final filteredSquad = widget.squad.where((agent) {
      final matchesSearch = agent.user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          agent.user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesProduct = _selectedProductFilter == 'All Products' ||
          agent.assignedProducts.contains(_selectedProductFilter);
      return matchesSearch && matchesProduct;
    }).toList();

    // Top Performer logic
    final bestPerformer = widget.squad.isNotEmpty
        ? widget.squad.reduce((curr, next) => curr.codRevenueToday >= next.codRevenueToday ? curr : next)
        : null;

    final showCards = isMobile || _isCardViewMode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Title Bar (Responsive)
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Squad Team Performance Overview',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time operational metrics for Monday 27th July, 2026.',
                  style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                ),
                const SizedBox(height: 10),
                _buildTimeframeBar(isDark, theme, borderColor, textMuted),
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
                        '📊 Squad Team Performance Overview',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time operational metrics across your supervisee squad for Monday 27th July, 2026.',
                        style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
                ),
                _buildTimeframeBar(isDark, theme, borderColor, textMuted),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // KPI Summary Cards Grid (Responsive Mobile / Desktop Layout)
          if (isMobile) ...[
            _buildKpiCard('Squad COD Revenue', '₦${(totalRevenue / 1000).toStringAsFixed(0)}k', Icons.payments_rounded, theme.primaryColor, isDark, cardBg, borderColor),
            const SizedBox(height: 12),
            _buildKpiCard('Confirmation Rate', '${avgRate.toStringAsFixed(1)}%', Icons.insights_rounded, Colors.amber, isDark, cardBg, borderColor),
            const SizedBox(height: 12),
            _buildKpiCard('Total Confirmed', '$totalConfirmed Orders', Icons.check_circle_rounded, const Color(0xFF10B981), isDark, cardBg, borderColor),
            const SizedBox(height: 12),
            _buildKpiCard('Active Squad Queue', '$totalActiveLeads Leads', Icons.queue_rounded, Colors.blue, isDark, cardBg, borderColor),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildKpiCard('Squad COD Revenue', '₦${(totalRevenue / 1000).toStringAsFixed(0)}k', Icons.payments_rounded, theme.primaryColor, isDark, cardBg, borderColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Confirmation Rate', '${avgRate.toStringAsFixed(1)}%', Icons.insights_rounded, Colors.amber, isDark, cardBg, borderColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Total Confirmed', '$totalConfirmed Orders', Icons.check_circle_rounded, const Color(0xFF10B981), isDark, cardBg, borderColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Active Squad Queue', '$totalActiveLeads Leads', Icons.queue_rounded, Colors.blue, isDark, cardBg, borderColor)),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // 🥇 Best Performer Spotlight Section (Responsive Mobile Vertical Stack / Desktop Row)
          if (bestPerformer != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E3A2B), const Color(0xFF0C1F17)]
                      : [const Color(0xFFECFDF5), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.amber, width: 1.5),
                              ),
                              child: const Text('👑', style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '🥇 TOP PERFORMER SPOTLIGHT',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.amber),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${bestPerformer.user.fullName} (Ext 102)',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revenue: ₦${bestPerformer.codRevenueToday.toStringAsFixed(0)} • ${bestPerformer.confirmedOrdersToday} Confirmed (${bestPerformer.confirmationRateToday.toStringAsFixed(1)}% Conv) • ${bestPerformer.deliveredCount} Delivered',
                          style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AgentProfileModal(
                                  supervisee: bestPerformer,
                                  activeTheme: theme,
                                  isDarkMode: isDark,
                                  onSave: widget.onUpdateSupervisee,
                                ),
                              );
                            },
                            icon: const Icon(Icons.stars, size: 16),
                            label: Text('View Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: const Text('👑', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      '🥇 TOP PERFORMER SPOTLIGHT',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Monday 27th July, 2026',
                                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${bestPerformer.user.fullName} (Ext 102)',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Top COD Revenue: ₦${bestPerformer.codRevenueToday.toStringAsFixed(0)} • ${bestPerformer.confirmedOrdersToday} Confirmed Orders (${bestPerformer.confirmationRateToday.toStringAsFixed(1)}% Conv Rate) • ${bestPerformer.deliveredCount} Delivered',
                                style: GoogleFonts.inter(fontSize: 12.5, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AgentProfileModal(
                                supervisee: bestPerformer,
                                activeTheme: theme,
                                isDarkMode: isDark,
                                onSave: widget.onUpdateSupervisee,
                              ),
                            );
                          },
                          icon: const Icon(Icons.stars, size: 16),
                          label: Text('View Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
            ),

          // Leaderboard Main Container
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container Header Controls (Responsive Mobile Stack / Desktop Row)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
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
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedProductFilter,
                                  isExpanded: true,
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
                                      setState(() => _selectedProductFilter = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 240,
                                    child: TextField(
                                      onChanged: (val) => setState(() => _searchQuery = val),
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

                                  // Product Filter Dropdown
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedProductFilter,
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
                                            setState(() => _selectedProductFilter = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Cards vs Table View Mode Switcher
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => setState(() => _isCardViewMode = true),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isCardViewMode ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.grid_view_rounded, size: 14, color: _isCardViewMode ? const Color(0xFF10B981) : textMuted),
                                          const SizedBox(width: 4),
                                          Text('Cards', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _isCardViewMode ? const Color(0xFF10B981) : textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 18, color: borderColor),
                                  InkWell(
                                    onTap: () => setState(() => _isCardViewMode = false),
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: !_isCardViewMode ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.table_chart_rounded, size: 14, color: !_isCardViewMode ? const Color(0xFF10B981) : textMuted),
                                          const SizedBox(width: 4),
                                          Text('Table', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: !_isCardViewMode ? const Color(0xFF10B981) : textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: filteredSquad.map((agent) => _buildMobileSuperviseeCard(agent, isDark, theme, borderColor, textPrimary, textMuted)).toList(),
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
                            columns: [
                              DataColumn(label: Text('👤 Agent', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('📦 Assigned', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('✅ Confirmed', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('🚚 Delivered', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('📅 Today/Prev', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('⏰ Rescheduled', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('📞 In-Progress', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('📴 Switched-Off', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('🚫 Unanswered', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('❌ Cancelled', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('⏸️ Pending', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                              DataColumn(label: Text('⚙️ Action', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                            ],
                            rows: filteredSquad.asMap().entries.map((entry) {
                              final index = entry.key;
                              final agent = entry.value;

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return isDark ? const Color(0xFF13362A) : const Color(0xFFF1F5F9);
                                  }
                                  return Colors.transparent;
                                }),
                                cells: [
                                  // 1. Agent Name & Ext
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                                          child: Text(
                                            agent.user.fullName[0].toUpperCase(),
                                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              agent.user.fullName,
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                                            ),
                                            Text(
                                              'Ext 10${index + 1}',
                                              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: textMuted),
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
                                            activeTheme: theme,
                                            isDarkMode: isDark,
                                            onSave: widget.onUpdateSupervisee,
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeframe = tf),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tf,
                style: GoogleFonts.inter(
                  fontSize: 12,
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

  Widget _buildMobileSuperviseeCard(
    SuperviseePerformanceModel agent,
    bool isDark,
    TenantTheme theme,
    Color borderColor,
    Color textPrimary,
    Color textMuted,
  ) {
    final products = agent.assignedProducts.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        agent.user.fullName[0].toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.user.fullName,
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: textPrimary),
                            overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 12),

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

  Widget _buildKpiCard(String title, String value, IconData icon, Color iconColor, bool isDark, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
