import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/supervisor_dashboard_provider.dart';

class AgentProfileModal extends StatefulWidget {
  final SuperviseePerformanceModel supervisee;
  final List<OrderModel>? squadOrders;
  final List<SuperviseePerformanceModel>? squadReps;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel updated) onSave;
  final Function(List<String> orderIds, String targetRepId)? onReassignOrders;

  const AgentProfileModal({
    super.key,
    required this.supervisee,
    this.squadOrders,
    this.squadReps,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onSave,
    this.onReassignOrders,
  });

  @override
  State<AgentProfileModal> createState() => _AgentProfileModalState();
}

class _AgentProfileModalState extends State<AgentProfileModal> {
  late List<String> _assignedProducts;
  late int _maxLeadCap;
  late bool _autoAssignEnabled;

  String _selectedTimeframe = 'Daily';
  int _selectedTabIndex = 0;

  // Rep Orders Tab State (Search, Date Filter, Sorting, Selection & Local List)
  String _orderSearchQuery = '';
  String _orderDateFilter = 'All Time';
  String _orderSortOption = 'Newest First';
  final Set<String> _selectedOrderIds = {};
  late List<OrderModel> _localRepOrders;

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

    final allOrders = widget.squadOrders ??
        OrderRepository().generateHistoricalMockOrders(
          companyId: widget.supervisee.user.companyId,
        );
    _localRepOrders = allOrders
        .where((o) => o.salesRepId == widget.supervisee.user.id)
        .toList();
  }

  List<SuperviseePerformanceModel> _getAvailableTargetReps() {
    if (widget.squadReps != null && widget.squadReps!.isNotEmpty) {
      return widget.squadReps!
          .where((r) => r.user.id != widget.supervisee.user.id)
          .toList();
    }
    // Default fallback squad reps if none provided
    return [
      SuperviseePerformanceModel(
        user: UserModel(
          id: '40000000-0000-4000-8000-000000000004',
          companyId: widget.supervisee.user.companyId,
          role: UserRole.salesCallRep,
          firstName: 'Sarah',
          lastName: 'CallRep',
          email: 'salesrep.sarah@novacare.com',
          phone: '+2348034445566',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: const ['Grazer Herbal Detox Tea', 'Herbal Vitality Booster'],
        activeLeadCount: 15,
        callsPlacedToday: 35,
        confirmedOrdersToday: 18,
        confirmationRateToday: 51.4,
        codRevenueToday: 450000,
        commissionEarnedToday: 18000,
        deliveredCount: 18,
        rescheduledCount: 4,
        inProgressCount: 5,
        switchedOffCount: 2,
        notPickingCount: 3,
        cancelledCount: 1,
        notReadyCount: 0,
        assignedCount: 45,
        maxLeadCap: 50,
        autoAssignmentEnabled: true,
      ),
      SuperviseePerformanceModel(
        user: UserModel(
          id: '50000000-0000-4000-8000-000000000006',
          companyId: widget.supervisee.user.companyId,
          role: UserRole.salesCallRep,
          firstName: 'Emeka',
          lastName: 'CallRep',
          email: 'salesrep.emeka@novacare.com',
          phone: '+2348035556677',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: const ['Clear Skin Care Set'],
        activeLeadCount: 10,
        callsPlacedToday: 28,
        confirmedOrdersToday: 14,
        confirmationRateToday: 50.0,
        codRevenueToday: 320000,
        commissionEarnedToday: 14000,
        deliveredCount: 14,
        rescheduledCount: 3,
        inProgressCount: 4,
        switchedOffCount: 1,
        notPickingCount: 2,
        cancelledCount: 1,
        notReadyCount: 1,
        assignedCount: 40,
        maxLeadCap: 40,
        autoAssignmentEnabled: true,
      ),
      SuperviseePerformanceModel(
        user: UserModel(
          id: '50000000-0000-4000-8000-000000000007',
          companyId: widget.supervisee.user.companyId,
          role: UserRole.salesCallRep,
          firstName: 'Aisha',
          lastName: 'SalesRep',
          email: 'salesrep.aisha@novacare.com',
          phone: '+2348036667788',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: const ['Grazer Herbal Detox Tea'],
        activeLeadCount: 12,
        callsPlacedToday: 32,
        confirmedOrdersToday: 16,
        confirmationRateToday: 50.0,
        codRevenueToday: 380000,
        commissionEarnedToday: 16000,
        deliveredCount: 16,
        rescheduledCount: 5,
        inProgressCount: 3,
        switchedOffCount: 2,
        notPickingCount: 2,
        cancelledCount: 0,
        notReadyCount: 0,
        assignedCount: 42,
        maxLeadCap: 45,
        autoAssignmentEnabled: true,
      ),
      SuperviseePerformanceModel(
        user: UserModel(
          id: '50000000-0000-4000-8000-000000000008',
          companyId: widget.supervisee.user.companyId,
          role: UserRole.salesCallRep,
          firstName: 'Chidi',
          lastName: 'Rep',
          email: 'salesrep.chidi@novacare.com',
          phone: '+2348037778899',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: const ['Herbal Vitality Booster'],
        activeLeadCount: 11,
        callsPlacedToday: 30,
        confirmedOrdersToday: 15,
        confirmationRateToday: 50.0,
        codRevenueToday: 360000,
        commissionEarnedToday: 15000,
        deliveredCount: 15,
        rescheduledCount: 4,
        inProgressCount: 5,
        switchedOffCount: 1,
        notPickingCount: 3,
        cancelledCount: 1,
        notReadyCount: 0,
        assignedCount: 41,
        maxLeadCap: 45,
        autoAssignmentEnabled: true,
      ),
    ];
  }

  Future<void> _executeReassignment(List<String> orderIds, String targetRepId) async {
    final repo = SupervisorRepository();
    await repo.reassignOrders(
      orderIds: orderIds,
      targetSalesRepId: targetRepId,
      supervisorId: widget.supervisee.user.companyId,
    );

    if (widget.onReassignOrders != null) {
      widget.onReassignOrders!(orderIds, targetRepId);
    }

    final targetReps = _getAvailableTargetReps();
    final targetRepName = targetReps
        .firstWhere((r) => r.user.id == targetRepId, orElse: () => widget.supervisee)
        .user
        .fullName;

    setState(() {
      _localRepOrders.removeWhere((o) => orderIds.contains(o.id));
      _selectedOrderIds.removeAll(orderIds);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          content: Text('✅ Reassigned ${orderIds.length} order(s) to $targetRepName!'),
        ),
      );
    }
  }

  void _showReassignModal(List<String> orderIds) {
    final availableReps = _getAvailableTargetReps();
    if (availableReps.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedTargetRepId = availableReps.first.user.id;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: widget.isDarkMode ? const Color(0xFF132A22) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: Color(0xFF10B981), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reassign ${orderIds.length} Order${orderIds.length > 1 ? 's' : ''}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a team call rep to receive ${orderIds.length} order(s) from ${widget.supervisee.user.fullName}:',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTargetRepId,
                        dropdownColor: widget.isDarkMode ? const Color(0xFF132A22) : Colors.white,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                        items: availableReps.map((rep) {
                          return DropdownMenuItem<String>(
                            value: rep.user.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  child: Text(
                                    rep.user.fullName[0],
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${rep.user.fullName} (${rep.assignedCount} orders)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedTargetRepId = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _executeReassignment(orderIds, selectedTargetRepId);
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(
                    'Confirm Reassign',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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

    // Filter & Sort rep's orders dynamically
    final filteredRepOrders = _localRepOrders.where((o) {
      final matchesQuery = o.orderNumber.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.customerPhone.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.deliveryState.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          (o.deliveryCity ?? '').toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.productId.toLowerCase().contains(_orderSearchQuery.toLowerCase());

      if (!matchesQuery) return false;

      final now = DateTime.now();
      switch (_orderDateFilter) {
        case 'Today':
          return o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day;
        case 'This Week':
          return o.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case 'This Month':
          return o.createdAt.year == now.year && o.createdAt.month == now.month;
        case 'May 2026':
          return o.createdAt.year == 2026 && o.createdAt.month == 5;
        case 'June 2026':
          return o.createdAt.year == 2026 && o.createdAt.month == 6;
        case 'July 2026':
          return o.createdAt.year == 2026 && o.createdAt.month == 7;
        case 'All Time':
        default:
          return true;
      }
    }).toList();

    filteredRepOrders.sort((a, b) {
      switch (_orderSortOption) {
        case 'Oldest First':
          return a.createdAt.compareTo(b.createdAt);
        case 'Highest Amount':
          return b.totalAmount.compareTo(a.totalAmount);
        case 'Lowest Amount':
          return a.totalAmount.compareTo(b.totalAmount);
        case 'Status':
          return a.status.label.compareTo(b.status.label);
        case 'Newest First':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20, vertical: 16),
      child: Container(
        width: isMobile ? screenWidth * 0.96 : 760,
        constraints: const BoxConstraints(maxHeight: 860),
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
                    radius: isMobile ? 20 : 24,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      widget.supervisee.user.fullName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 16 : 20,
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
                                  fontSize: isMobile ? 15 : 17,
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
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                ),
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

            // Tab Selection Bar (Overview & Settings vs Rep Orders)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, '⚙️ Overview & Settings', _selectedTabIndex == 0, theme, textPrimary, textMuted),
                  const SizedBox(width: 16),
                  _buildTabButton(
                    1,
                    '📋 Rep Orders (${_localRepOrders.length})',
                    _selectedTabIndex == 1,
                    theme,
                    textPrimary,
                    textMuted,
                  ),
                ],
              ),
            ),

            // Modal Body Content
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildOverviewTab(isMobile, isDark, theme, textPrimary, textMuted, borderColor)
                  : _buildRepOrdersTab(filteredRepOrders, isMobile, isDark, theme, textPrimary, textMuted, borderColor),
            ),

            // Modal Footer (Save Button for Settings tab)
            if (_selectedTabIndex == 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: GoogleFonts.inter(color: textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        final updated = widget.supervisee.copyWith(
                          assignedProducts: _assignedProducts,
                          maxLeadCap: _maxLeadCap,
                          autoAssignmentEnabled: _autoAssignEnabled,
                        );
                        widget.onSave(updated);
                        try {
                          context.read<SupervisorDashboardProvider>().updateSupervisee(updated);
                        } catch (_) {}
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF10B981),
                            content: Text('Saved settings for ${widget.supervisee.user.fullName}!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text('Save Rep Configuration', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, bool isSelected, TenantTheme theme, Color textPrimary, Color textMuted) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF10B981) : textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    bool isMobile,
    bool isDark,
    TenantTheme theme,
    Color textPrimary,
    Color textMuted,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
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
                Expanded(child: _buildMetricCard('Commission Earned', '₦${(widget.supervisee.commissionEarnedToday / 1000).toStringAsFixed(0)}k', Icons.payments, const Color(0xFF10B981), isDark, borderColor)),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildMetricCard('Calls Placed', '${widget.supervisee.callsPlacedToday}', Icons.phone, Colors.blue, isDark, borderColor)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Confirmed', '${widget.supervisee.confirmedOrdersToday}', Icons.check_circle, const Color(0xFF10B981), isDark, borderColor)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Conv. Rate', '${widget.supervisee.confirmationRateToday.toStringAsFixed(1)}%', Icons.insights, Colors.amber, isDark, borderColor)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Commission Earned', '₦${widget.supervisee.commissionEarnedToday.toStringAsFixed(0)}', Icons.payments, const Color(0xFF10B981), isDark, borderColor)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepOrdersTab(
    List<OrderModel> filteredOrders,
    bool isMobile,
    bool isDark,
    TenantTheme theme,
    Color textPrimary,
    Color textMuted,
    Color borderColor,
  ) {
    // Rep KPI Card Summary Computations
    final totalCount = filteredOrders.length;
    final confirmedDeliveredCount = filteredOrders.where((o) =>
        o.status == OrderStatus.delivered ||
        o.status == OrderStatus.accepted ||
        o.status == OrderStatus.logisticsConfirmed).length;
    final conversionRate = totalCount > 0 ? (confirmedDeliveredCount / totalCount * 100) : 0.0;
    final pendingActionCount = filteredOrders.where((o) =>
        o.status == OrderStatus.assignedToRep ||
        o.status == OrderStatus.contacting ||
        o.status == OrderStatus.callBack ||
        o.status == OrderStatus.newOrder).length;

    final dateOptions = ['All Time', 'Today', 'This Week', 'This Month', 'May 2026', 'June 2026', 'July 2026'];
    final sortOptions = ['Newest First', 'Oldest First', 'Highest Amount', 'Lowest Amount', 'Status'];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Rep Performance Summary KPI Cards
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildRepMiniKpi('Total Orders', '$totalCount', Icons.assignment, Colors.blue, isDark)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildRepMiniKpi('Confirmed / Deliv.', '$confirmedDeliveredCount (${conversionRate.toStringAsFixed(0)}%)', Icons.check_circle, const Color(0xFF10B981), isDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildRepMiniKpi('Commission Earned', '₦${((confirmedDeliveredCount * 1000) / 1000).toStringAsFixed(0)}k', Icons.payments, const Color(0xFF10B981), isDark)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildRepMiniKpi('Pending Calls', '$pendingActionCount', Icons.phone_callback, Colors.amber, isDark)),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildRepMiniKpi('Total Orders', '$totalCount orders', Icons.assignment, Colors.blue, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildRepMiniKpi('Confirmed / Deliv.', '$confirmedDeliveredCount (${conversionRate.toStringAsFixed(1)}%)', Icons.check_circle, const Color(0xFF10B981), isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildRepMiniKpi('Commission Earned', '₦${(confirmedDeliveredCount * 1000).toStringAsFixed(0)}', Icons.payments, const Color(0xFF10B981), isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildRepMiniKpi('Pending Calls', '$pendingActionCount pending', Icons.phone_callback, Colors.amber, isDark)),
                    ],
                  ),
          ),

          // 2. Search Bar + Date Filter + Sorting Controls Row
          if (isMobile) ...[
            TextField(
              onChanged: (val) => setState(() => _orderSearchQuery = val),
              style: GoogleFonts.inter(fontSize: 12.5, color: textPrimary),
              decoration: InputDecoration(
                hintText: "Search orders by #, customer, phone...",
                hintStyle: GoogleFonts.inter(fontSize: 11.5, color: textMuted),
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _orderDateFilter,
                        icon: const Icon(Icons.calendar_today, size: 13, color: Color(0xFF10B981)),
                        dropdownColor: isDark ? const Color(0xFF132A22) : Colors.white,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary),
                        items: dateOptions.map((d) => DropdownMenuItem(value: d, child: Text('📅 $d'))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _orderDateFilter = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _orderSortOption,
                        icon: const Icon(Icons.sort, size: 13, color: Color(0xFF10B981)),
                        dropdownColor: isDark ? const Color(0xFF132A22) : Colors.white,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary),
                        items: sortOptions.map((s) => DropdownMenuItem(value: s, child: Text('↕️ $s'))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _orderSortOption = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => setState(() => _orderSearchQuery = val),
                    style: GoogleFonts.inter(fontSize: 12.5, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: "Search orders by #, customer, phone, city...",
                      hintStyle: GoogleFonts.inter(fontSize: 11.5, color: textMuted),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _orderDateFilter,
                      icon: const Icon(Icons.calendar_today, size: 13, color: Color(0xFF10B981)),
                      dropdownColor: isDark ? const Color(0xFF132A22) : Colors.white,
                      style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: textPrimary),
                      items: dateOptions.map((d) => DropdownMenuItem(value: d, child: Text('📅 $d'))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _orderDateFilter = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _orderSortOption,
                      icon: const Icon(Icons.sort, size: 13, color: Color(0xFF10B981)),
                      dropdownColor: isDark ? const Color(0xFF132A22) : Colors.white,
                      style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: textPrimary),
                      items: sortOptions.map((s) => DropdownMenuItem(value: s, child: Text('↕️ $s'))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _orderSortOption = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // 3. Orders List with Individual Reassign Control
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      'No orders found matching criteria for ${widget.supervisee.user.fullName}',
                      style: GoogleFonts.inter(color: textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final isSelected = _selectedOrderIds.contains(order.id);

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF10B981) : borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF10B981),
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
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order.orderNumber,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusBadge(order.status),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('d MMM').format(order.createdAt),
                                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.customerName,
                                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                                  ),
                                  Text(
                                    '${order.customerPhone} • ${order.deliveryCity}, ${order.deliveryState}',
                                    style: GoogleFonts.inter(fontSize: 11.5, color: textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₦${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.productId,
                                  style: GoogleFonts.inter(fontSize: 10.5, color: textMuted),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    side: BorderSide(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => _showReassignModal([order.id]),
                                  icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF10B981)),
                                  label: Text(
                                    'Reassign',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 4. Batch Reassignment Action Floating Bar
          if (_selectedOrderIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_box_rounded, color: Color(0xFF10B981), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedOrderIds.length} orders selected',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () => _showReassignModal(_selectedOrderIds.toList()),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text('Reassign Selected', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRepMiniKpi(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg = Colors.grey.withValues(alpha: 0.15);
    Color fg = Colors.grey;

    switch (status) {
      case OrderStatus.newOrder:
      case OrderStatus.assignedToRep:
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue;
        break;
      case OrderStatus.contacting:
      case OrderStatus.callBack:
        bg = Colors.purple.withValues(alpha: 0.15);
        fg = Colors.purple;
        break;
      case OrderStatus.accepted:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        break;
      case OrderStatus.inTransit:
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFF10B981).withValues(alpha: 0.2);
        fg = const Color(0xFF10B981);
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red;
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
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
              Text('Max Daily Lead Cap:', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$_maxLeadCap leads', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ),
            ],
          ),
          Slider(
            value: _maxLeadCap.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) => setState(() => _maxLeadCap = val.toInt()),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Round-Robin Distribution:', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: textPrimary)),
                Text('Include in automatic lead routing', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _autoAssignEnabled,
            activeTrackColor: const Color(0xFF10B981),
            onChanged: (val) => setState(() => _autoAssignEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: isDark ? Colors.white60 : Colors.black54), overflow: TextOverflow.ellipsis),
                Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
