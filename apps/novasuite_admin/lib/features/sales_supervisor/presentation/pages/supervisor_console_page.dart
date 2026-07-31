import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../widgets/supervisor_kpi_dashboard_tab.dart';
import '../widgets/supervisor_approvals_tab.dart';
import '../widgets/supervisor_reassignment_tab.dart';
import '../widgets/manage_supervisees_tab.dart';
import '../widgets/supervisor_report_tab.dart';
import '../../../sales_supervisee/presentation/widgets/call_rep_dashboard_overview.dart';
import '../../../sales_supervisee/presentation/widgets/call_action_modal.dart';
import '../../../sales_supervisee/presentation/widgets/nova_dialer_floating_bar.dart';

class SupervisorConsolePage extends StatefulWidget {
  final UserModel currentUser;
  final int activeSubIndex;

  const SupervisorConsolePage({
    super.key,
    required this.currentUser,
    this.activeSubIndex = 0,
  });

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
  final bool _isDarkMode = true;

  OrderModel? _activeCallOrder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.activeSubIndex.clamp(0, 5),
    );
    _loadSupervisorData();
  }

  @override
  void didUpdateWidget(covariant SupervisorConsolePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSubIndex != widget.activeSubIndex) {
      _tabController.animateTo(widget.activeSubIndex.clamp(0, 5));
    }
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
        SnackBar(
          backgroundColor: approve ? const Color(0xFF10B981) : Colors.red,
          content: Text(approve ? '✅ Upsell Request Approved!' : '❌ Upsell Request Declined.'),
        ),
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
    final cardBg = _isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: cardBg,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                    : TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Tab 0: Team Performance KPIs & Dashboard Overview (Whole Squad Context)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorKpiDashboardTab(
                              squad: _squad,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onUpdateSupervisee: _handleUpdateSupervisee,
                            ),
                          ),

                          // Tab 1: Operational Daily Summary Report
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

                          // Tab 2: Realtime Upsell Approvals
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SupervisorApprovalsTab(
                              pendingUpsellOrders: _pendingUpsells,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onResolveUpsell: _handleResolveUpsell,
                            ),
                          ),

                          // Tab 3: 1-Click Lead Reassignment
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

                          // Tab 4: Manage Supervisees Roster
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: ManageSuperviseesTab(
                              squad: _squad,
                              activeTheme: theme,
                              isDarkMode: _isDarkMode,
                              onUpdateSupervisee: _handleUpdateSupervisee,
                            ),
                          ),

                          // Tab 5: My Personal Dialer Queue
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
