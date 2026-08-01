import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String _searchQuery = '';
  String _selectedStatusFilter = 'All Statuses';
  String _selectedRepFilter = 'All Reps';
  String _selectedProductFilter = 'All Products';
  bool _isCardViewMode = false;

  final List<String> _statusOptions = [
    'All Statuses',
    'New',
    'Assigned',
    'Contacting',
    'Call Back',
    'Unreachable',
    'Confirmed',
    'Upsell Pending',
    'In Transit',
    'Delivered',
    'Cancelled',
  ];

  final List<String> _productOptions = [
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
    final isMobile = screenWidth < 800;

    final filteredOrders = widget.squadOrders.where((order) {
      final matchesSearch = order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerPhone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.deliveryState.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (order.deliveryCity ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRep = _selectedRepFilter == 'All Reps' || order.salesRepId == _selectedRepFilter;
      final matchesProduct = _selectedProductFilter == 'All Products' ||
          order.productId.toLowerCase().contains(_selectedProductFilter.toLowerCase());

      bool matchesStatus = true;
      if (_selectedStatusFilter != 'All Statuses') {
        switch (_selectedStatusFilter) {
          case 'New':
            matchesStatus = order.status == OrderStatus.newOrder;
            break;
          case 'Assigned':
            matchesStatus = order.status == OrderStatus.assignedToRep;
            break;
          case 'Contacting':
            matchesStatus = order.status == OrderStatus.contacting;
            break;
          case 'Call Back':
            matchesStatus = order.status == OrderStatus.callBack;
            break;
          case 'Unreachable':
            matchesStatus = order.status == OrderStatus.notReachable;
            break;
          case 'Confirmed':
            matchesStatus = order.status == OrderStatus.accepted;
            break;
          case 'Upsell Pending':
            matchesStatus = order.status == OrderStatus.upsellPending;
            break;
          case 'In Transit':
            matchesStatus = order.status == OrderStatus.inTransit;
            break;
          case 'Delivered':
            matchesStatus = order.status == OrderStatus.delivered;
            break;
          case 'Cancelled':
            matchesStatus = order.status == OrderStatus.cancelled;
            break;
        }
      }

      return matchesSearch && matchesRep && matchesProduct && matchesStatus;
    }).toList();

    final showCards = isMobile || _isCardViewMode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📂 Team Order Directory & Reassignment Console',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive view of all customer leads assigned across your squad. Filter, search, and bulk-reassign leads in real time.',
                      style: GoogleFonts.inter(fontSize: 12.5, color: textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filters & Control Bar Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search + Status Filter + Rep Filter + Product Filter + View Switcher
                if (isMobile) ...[
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search order #, customer, phone, city...',
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDropdownFilter(
                        value: _selectedStatusFilter,
                        items: _statusOptions,
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      _buildDropdownFilter(
                        value: _selectedRepFilter,
                        items: ['All Reps', ...widget.squad.map((s) => s.user.id)],
                        itemLabelMap: {
                          'All Reps': 'All Reps',
                          for (var s in widget.squad) s.user.id: s.user.fullName,
                        },
                        onChanged: (val) => setState(() => _selectedRepFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      _buildDropdownFilter(
                        value: _selectedProductFilter,
                        items: _productOptions,
                        onChanged: (val) => setState(() => _selectedProductFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search order #, customer name, phone, state, city...',
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
                      const SizedBox(width: 10),
                      _buildDropdownFilter(
                        value: _selectedStatusFilter,
                        items: _statusOptions,
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      _buildDropdownFilter(
                        value: _selectedRepFilter,
                        items: ['All Reps', ...widget.squad.map((s) => s.user.id)],
                        itemLabelMap: {
                          'All Reps': 'All Reps',
                          for (var s in widget.squad) s.user.id: s.user.fullName,
                        },
                        onChanged: (val) => setState(() => _selectedRepFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      _buildDropdownFilter(
                        value: _selectedProductFilter,
                        items: _productOptions,
                        onChanged: (val) => setState(() => _selectedProductFilter = val!),
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: showCards ? 'Switch to Table View' : 'Switch to Cards View',
                        icon: Icon(showCards ? Icons.table_chart : Icons.grid_view, color: theme.primaryColor),
                        onPressed: () => setState(() => _isCardViewMode = !_isCardViewMode),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 14),

                // Batch Reassignment Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: filteredOrders.isNotEmpty &&
                              filteredOrders.every((o) => _selectedOrderIds.contains(o.id)),
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedOrderIds.addAll(filteredOrders.map((o) => o.id));
                              } else {
                                _selectedOrderIds.clear();
                              }
                            });
                          },
                        ),
                        Text(
                          'Select All Filtered (${filteredOrders.length})',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTargetRepId,
                              hint: Text('Target Rep...', style: GoogleFonts.inter(color: textMuted, fontSize: 12)),
                              dropdownColor: cardBg,
                              style: GoogleFonts.inter(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                              items: widget.squad.map((rep) {
                                return DropdownMenuItem<String>(
                                  value: rep.user.id,
                                  child: Text('${rep.user.fullName} (${rep.activeLeadCount} active)'),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedTargetRepId = val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            visualDensity: VisualDensity.compact,
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
                                    const SnackBar(
                                      backgroundColor: Color(0xFF10B981),
                                      content: Text('✅ Selected squad orders reassigned successfully!'),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.swap_horiz, size: 16),
                          label: Text(
                            'Reassign (${_selectedOrderIds.length})',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Directory Results Table / Cards Container
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: filteredOrders.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('No orders found matching the filter criteria.', style: GoogleFonts.inter(color: textMuted)),
                    ),
                  )
                : showCards
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: filteredOrders.map((order) {
                            return _buildOrderMobileCard(order, isDark, theme, borderColor, textPrimary, textMuted);
                          }).toList(),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                dataRowMinHeight: 56,
                                dataRowMaxHeight: 64,
                                columnSpacing: 16,
                                horizontalMargin: 16,
                                headingRowColor: WidgetStateProperty.all(
                                  isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                                ),
                                dividerThickness: 1.0,
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: borderColor, width: 1),
                                ),
                                columns: [
                                  DataColumn(
                                    label: Checkbox(
                                      value: filteredOrders.isNotEmpty &&
                                          filteredOrders.every((o) => _selectedOrderIds.contains(o.id)),
                                      activeColor: const Color(0xFF10B981),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedOrderIds.addAll(filteredOrders.map((o) => o.id));
                                          } else {
                                            _selectedOrderIds.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  DataColumn(label: Text('ORDER #', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('CUSTOMER', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('LOCATION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('PRODUCT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('ASSIGNED REP', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('STATUS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('TOTAL', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                  DataColumn(label: Text('ACTION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted))),
                                ],
                                rows: filteredOrders.map((order) {
                                  final isSelected = _selectedOrderIds.contains(order.id);
                                  final assignedRep = widget.squad.firstWhere(
                                    (r) => r.user.id == order.salesRepId,
                                    orElse: () => SuperviseePerformanceModel(
                                      user: UserModel(
                                        id: order.salesRepId ?? 'unassigned',
                                        email: 'unassigned@novacare.com',
                                        firstName: order.salesRepId ?? 'Unassigned',
                                        lastName: 'Pool',
                                        role: UserRole.salesCallRep,
                                        companyId: widget.activeTheme.companyId,
                                        isActive: true,
                                        createdAt: DateTime.now(),
                                      ),
                                      assignedProducts: [],
                                      activeLeadCount: 0,
                                      callsPlacedToday: 0,
                                      confirmedOrdersToday: 0,
                                      confirmationRateToday: 0,
                                      codRevenueToday: 0,
                                      commissionEarnedToday: 0,
                                    ),
                                  );

                                  return DataRow(
                                    selected: isSelected,
                                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                                      if (isSelected) {
                                        return isDark ? const Color(0xFF1E3A2B) : const Color(0xFFECFDF5);
                                      }
                                      return Colors.transparent;
                                    }),
                                    cells: [
                                      DataCell(
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
                                      ),
                                      DataCell(
                                        Text(
                                          order.orderNumber,
                                          style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(order.customerName, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: textPrimary)),
                                            Text(order.customerPhone, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textMuted)),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text('${order.deliveryCity}, ${order.deliveryState}', style: GoogleFonts.inter(fontSize: 12, color: textPrimary)),
                                      ),
                                      DataCell(
                                        Text(order.productId, style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                                      ),
                                      DataCell(
                                        Text(assignedRep.user.fullName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
                                      ),
                                      DataCell(
                                        _buildStatusBadge(order.status, isDark),
                                      ),
                                      DataCell(
                                        Text(
                                          '₦${order.totalAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.jetBrainsMono(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                        ),
                                      ),
                                      DataCell(
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: borderColor),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          onPressed: () => _showQuickReassignModal(order),
                                          child: Text('Reassign', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<String> items,
    Map<String, String>? itemLabelMap,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: cardBg,
          style: GoogleFonts.inter(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600),
          items: items.map((item) {
            final label = itemLabelMap?[item] ?? item;
            return DropdownMenuItem<String>(
              value: item,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOrderMobileCard(
    OrderModel order,
    bool isDark,
    TenantTheme theme,
    Color borderColor,
    Color textPrimary,
    Color textMuted,
  ) {
    final isSelected = _selectedOrderIds.contains(order.id);
    final assignedRep = widget.squad.firstWhere(
      (r) => r.user.id == order.salesRepId,
      orElse: () => SuperviseePerformanceModel(
        user: UserModel(
          id: order.salesRepId ?? 'unassigned',
          email: 'unassigned@novacare.com',
          firstName: order.salesRepId ?? 'Unassigned',
          lastName: 'Pool',
          role: UserRole.salesCallRep,
          companyId: theme.companyId,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: [],
        activeLeadCount: 0,
        callsPlacedToday: 0,
        confirmedOrdersToday: 0,
        confirmationRateToday: 0,
        codRevenueToday: 0,
        commissionEarnedToday: 0,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF10B981) : borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Text(
                    order.orderNumber,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12.5, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ],
              ),
              _buildStatusBadge(order.status, isDark),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.customerName, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: textPrimary)),
          Text('${order.customerPhone} • ${order.deliveryCity}, ${order.deliveryState}', style: GoogleFonts.inter(fontSize: 11.5, color: textMuted)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rep: ${assignedRep.user.fullName}', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: textPrimary)),
              Text('₦${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, bool isDark) {
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
      case OrderStatus.upsellPending:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _showQuickReassignModal(OrderModel order) {
    String? selectedTarget;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF132A22) : Colors.white,
        title: Text('Reassign Order ${order.orderNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName} (${order.customerPhone})', style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setModalState) => DropdownButton<String>(
                value: selectedTarget,
                isExpanded: true,
                hint: const Text('Select Target Sales Rep...'),
                items: widget.squad.map((rep) {
                  return DropdownMenuItem<String>(
                    value: rep.user.id,
                    child: Text('${rep.user.fullName} (${rep.activeLeadCount} active leads)'),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedTarget = val),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: () {
              if (selectedTarget != null) {
                widget.onExecuteReassignment([order.id], selectedTarget!);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order reassigned successfully!')),
                );
              }
            },
            child: const Text('Confirm Reassign'),
          ),
        ],
      ),
    );
  }
}
