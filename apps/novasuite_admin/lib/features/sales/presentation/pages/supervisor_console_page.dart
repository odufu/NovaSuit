import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../widgets/supervisor_kpi_dashboard_tab.dart';
import '../widgets/supervisor_approvals_tab.dart';
import '../widgets/supervisor_reassignment_tab.dart';
import '../widgets/manage_supervisees_tab.dart';
import '../widgets/supervisor_report_tab.dart';
import '../widgets/call_rep_dashboard_overview.dart';
import '../widgets/call_action_modal.dart';
import '../widgets/nova_dialer_floating_bar.dart';

class SupervisorConsolePage extends StatefulWidget {
  final UserModel currentUser;

  const SupervisorConsolePage({super.key, required this.currentUser});

  @override
  State<SupervisorConsolePage> createState() => _SupervisorConsolePageState();
}

class _SupervisorConsolePageState extends State<SupervisorConsolePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupervisorRepository _supervisorRepo = SupervisorRepository();
  final OrderRepository _orderRepo = OrderRepository();
  final NovaSipTelephonyService _telephonyService = NovaSipTelephonyService();
  final TextEditingController _noteController = TextEditingController();

  List<SuperviseePerformanceModel> _squad = [];
  List<OrderModel> _squadOrders = [];
  List<OrderModel> _pendingUpsells = [];
  SupervisorDailyReportModel _dailyReport = SupervisorDailyReportModel.defaultReportForJuly27();
  bool _isLoading = true;
  bool _isDarkMode = true;

  OrderModel? _activeCallOrder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSupervisorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisorData() async {
    setState(() => _isLoading = true);
    final squad = await _supervisorRepo.fetchSquadSupervisees(
      companyId: widget.currentUser.companyId,
      supervisorId: widget.currentUser.id,
    );

    final orders = await _orderRepo.fetchOrders(
      companyId: widget.currentUser.companyId,
    );

    final pending = orders.where((o) => o.status == OrderStatus.upsellPending).toList();

    setState(() {
      _squad = squad;
      _squadOrders = orders;
      _pendingUpsells = pending;
      _isLoading = false;
    });
  }

  void _handleUpdateSupervisee(SuperviseePerformanceModel updated) {
    setState(() {
      final index = _squad.indexWhere((s) => s.user.id == updated.user.id);
      if (index != -1) {
        _squad[index] = updated;
      }
    });
  }

  void _handleResolveUpsell(String orderId, bool approve) async {
    await _supervisorRepo.resolveUpsellRequest(
      orderId: orderId,
      approve: approve,
      supervisorId: widget.currentUser.id,
    );

    setState(() {
      _pendingUpsells.removeWhere((o) => o.id == orderId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Upsell Request Approved!' : 'Upsell Request Declined.')),
      );
    }
  }

  void _handleReassign(List<String> orderIds, String targetRepId) async {
    await _supervisorRepo.reassignOrders(
      orderIds: orderIds,
      targetSalesRepId: targetRepId,
      supervisorId: widget.currentUser.id,
    );
    await _loadSupervisorData();
  }

  void _startDirectCall(OrderModel order) {
    setState(() {
      _activeCallOrder = order;
    });

    _telephonyService.initiateCall(order);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CallActionModal(
        order: order,
        activeTheme: TenantTheme.defaultNovaCare(),
        currentUser: widget.currentUser,
        noteController: _noteController,
        onUpdateOrder: (updated) {
          final idx = _squadOrders.indexWhere((o) => o.id == updated.id);
          if (idx != -1) {
            setState(() => _squadOrders[idx] = updated);
          }
        },
        onRecordActivity: ({required order, required activityType, required title, required details, newStatus}) {},
        onOpenReschedule: (order) {},
        onOpenCancellationReason: (order) {},
        onShowRequestUpsell: (order) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = TenantTheme.defaultNovaCare();
    final cardBg = _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final navBg = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final textMuted = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: cardBg,
      body: Stack(
        children: [
          Column(
            children: [
              // Top Navigation Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: navBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.support_agent, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NovaSuite Sales',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'SUPERVISOR CONSOLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    if (_pendingUpsells.isNotEmpty)
                      GestureDetector(
                        onTap: () => _tabController.animateTo(1),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: Colors.amber, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${_pendingUpsells.length} UPSELL APPROVALS',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                          child: Text(
                            widget.currentUser.fullName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.currentUser.fullName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Sales Supervisor',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    IconButton(
                      icon: Icon(
                        _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                        color: textMuted,
                      ),
                      onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                    ),
                  ],
                ),
              ),

              // Tab Bar Navigation
              Container(
                color: navBg,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: textMuted,
                  indicatorColor: theme.primaryColor,
                  indicatorWeight: 3,
                  tabs: [
                    const Tab(icon: Icon(Icons.assessment), text: 'Operational Report'),
                    const Tab(icon: Icon(Icons.dashboard), text: 'Team Performance KPIs'),
                    Tab(
                      icon: Badge(
                        isLabelVisible: _pendingUpsells.isNotEmpty,
                        label: Text('${_pendingUpsells.length}'),
                        child: const Icon(Icons.bolt),
                      ),
                      text: 'Realtime Approvals',
                    ),
                    const Tab(icon: Icon(Icons.swap_horiz), text: '1-Click Lead Reassignment'),
                    const Tab(icon: Icon(Icons.manage_accounts), text: 'Manage Supervisees'),
                    const Tab(icon: Icon(Icons.phone_in_talk), text: 'My Personal Dialer'),
                  ],
                ),
              ),

              // Main Body Content
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 0: Operational Summary Report
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorReportTab(
                              report: _dailyReport,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onDateOrTimeframeChanged: (selectedDate, timeframe) async {
                                final report = await _supervisorRepo.fetchDailyOperationalReport(
                                  companyId: widget.currentUser.companyId,
                                  date: selectedDate,
                                  timeframe: timeframe,
                                );
                                setState(() => _dailyReport = report);
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorKpiDashboardTab(
                              squad: _squad,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onUpdateSupervisee: _handleUpdateSupervisee,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorApprovalsTab(
                              pendingUpsellOrders: _pendingUpsells,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onResolveUpsell: _handleResolveUpsell,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorReassignmentTab(
                              squadOrders: _squadOrders,
                              squad: _squad,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onExecuteReassignment: _handleReassign,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: ManageSuperviseesTab(
                              squad: _squad,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onUpdateSupervisee: _handleUpdateSupervisee,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: CallRepDashboardOverview(
                              currentUser: widget.currentUser,
                              myOrders: _squadOrders,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onStartCall: _startDirectCall,
                              onOpenFullQueue: () {},
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),

          // Floating Dialer Bar
          if (_activeCallOrder != null)
            Positioned(
              bottom: 24,
              right: 24,
              child: NovaDialerFloatingBar(
                activeTheme: theme,
                currentUser: widget.currentUser,
                isDarkMode: _isDarkMode,
                onOpenCallModal: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => CallActionModal(
                      order: _activeCallOrder!,
                      activeTheme: theme,
                      currentUser: widget.currentUser,
                      noteController: _noteController,
                      onUpdateOrder: (updated) {
                        final idx = _squadOrders.indexWhere((o) => o.id == updated.id);
                        if (idx != -1) {
                          setState(() => _squadOrders[idx] = updated);
                        }
                      },
                      onRecordActivity: ({required order, required activityType, required title, required details, newStatus}) {},
                      onOpenReschedule: (order) {},
                      onOpenCancellationReason: (order) {},
                      onShowRequestUpsell: (order) {},
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
