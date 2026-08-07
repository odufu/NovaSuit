import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/supervisor_dashboard_provider.dart';
import '../../../sales/presentation/providers/sales_call_center_provider.dart';
import '../widgets/supervisor_kpi_dashboard_tab.dart';
import '../widgets/supervisor_approvals_tab.dart';
import '../widgets/supervisor_reassignment_tab.dart';
import '../../../sales_supervisee/presentation/widgets/call_rep_dashboard_overview.dart';
import '../../../sales_supervisee/presentation/widgets/call_action_modal.dart';
import '../../../omnichannel_chat/presentation/widgets/omnichannel_unified_chat_sheet.dart';
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
  final TextEditingController _noteController = TextEditingController();
  final ValueNotifier<OrderModel?> _activeCallOrder = ValueNotifier<OrderModel?>(null);

  @override
  void initState() {
    super.initState();
    final tabCount = widget.currentUser.canTakeCalls ? 4 : 3;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: widget.activeSubIndex.clamp(0, tabCount - 1),
    );
  }

  @override
  void didUpdateWidget(covariant SupervisorConsolePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tabCount = widget.currentUser.canTakeCalls ? 4 : 3;
    if (oldWidget.activeSubIndex != widget.activeSubIndex) {
      _tabController.animateTo(widget.activeSubIndex.clamp(0, tabCount - 1));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _activeCallOrder.dispose();
    super.dispose();
  }

  void _handleResolveUpsell(String orderId, bool approve) async {
    await _supervisorRepo.resolveUpsellRequest(
      orderId: orderId,
      approve: approve,
      supervisorId: widget.currentUser.id,
    );

    if (!mounted) return;
    context.read<SupervisorDashboardProvider>().fetchSquadData(
          companyId: widget.currentUser.companyId,
          supervisorId: widget.currentUser.id,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: approve ? const Color(0xFF10B981) : Colors.red,
        content: Text(approve ? '✅ Upsell Request Approved!' : '❌ Upsell Request Declined.'),
      ),
    );
  }

  void _handleReassign(List<String> orderIds, String targetRepId) async {
    await _supervisorRepo.reassignOrders(
      orderIds: orderIds,
      targetSalesRepId: targetRepId,
      supervisorId: widget.currentUser.id,
    );
    if (!mounted) return;
    context.read<SupervisorDashboardProvider>().fetchSquadData(
          companyId: widget.currentUser.companyId,
          supervisorId: widget.currentUser.id,
        );
  }

  void _startDirectCall(OrderModel order) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    OmnichannelUnifiedChatSheet.show(
      context,
      order: order,
      currentUser: widget.currentUser,
      activeTheme: TenantTheme.defaultNovaCare(),
      isDarkMode: isDarkMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = TenantTheme.defaultNovaCare();
    const isDarkMode = true;
    const cardBg = Color(0xFF0C1F17);

    return Scaffold(
      backgroundColor: cardBg,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Selector<SupervisorDashboardProvider, bool>(
                  selector: (_, p) => p.isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                    }

                    return Selector2<SupervisorDashboardProvider, SalesCallCenterProvider,
                        _SupervisorConsoleData>(
                      selector: (_, dashP, salesP) => _SupervisorConsoleData(
                        squad: dashP.squad,
                        orders: salesP.orders,
                        dailyReport: dashP.dailyReport,
                      ),
                      builder: (context, data, _) {
                        final squad = data.squad;
                        final squadOrders = data.orders;
                        final dailyReport = data.dailyReport ?? SupervisorDailyReportModel.defaultReportForJuly27();
                        final pendingUpsells = squadOrders.where((o) => o.status == OrderStatus.upsellPending).toList();

                        return TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Tab 0: Squad Overview & Operational KPIs
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: SupervisorKpiDashboardTab(
                                squad: squad,
                                squadOrders: squadOrders,
                                dailyReport: dailyReport,
                                activeTheme: theme,
                                isDarkMode: isDarkMode,
                                onUpdateSupervisee: (updated) {
                                  context.read<SupervisorDashboardProvider>().updateSupervisee(updated);
                                },
                                onDateOrTimeframeChanged: (selectedDate, timeframe) async {
                                  await _supervisorRepo.fetchDailyOperationalReport(
                                    companyId: widget.currentUser.companyId,
                                    date: selectedDate,
                                    timeframe: timeframe,
                                  );
                                  if (!context.mounted) return;
                                  context.read<SupervisorDashboardProvider>().setTimeframe(timeframe);
                                },
                              ),
                            ),

                            // Tab 1: Realtime Upsell Approvals
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: SupervisorApprovalsTab(
                                pendingUpsellOrders: pendingUpsells,
                                activeTheme: theme,
                                isDarkMode: isDarkMode,
                                onResolveUpsell: _handleResolveUpsell,
                              ),
                            ),

                            // Tab 2: Workload & Lead Reassignment
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: SupervisorReassignmentTab(
                                squadOrders: squadOrders,
                                squad: squad,
                                activeTheme: theme,
                                isDarkMode: isDarkMode,
                                onExecuteReassignment: _handleReassign,
                              ),
                            ),

                            // Tab 3: My Personal Dialer Queue
                            if (widget.currentUser.canTakeCalls)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: CallRepDashboardOverview(
                                  currentUser: widget.currentUser,
                                  myOrders: squadOrders,
                                  activeTheme: theme,
                                  isDarkMode: isDarkMode,
                                  onStartCall: _startDirectCall,
                                  onOpenFullQueue: () {},
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          ValueListenableBuilder<OrderModel?>(
            valueListenable: _activeCallOrder,
            builder: (context, activeOrder, _) {
              if (activeOrder == null) return const SizedBox.shrink();
              return Positioned(
                bottom: 24,
                right: 24,
                child: NovaDialerFloatingBar(
                  activeTheme: theme,
                  currentUser: widget.currentUser,
                  isDarkMode: isDarkMode,
                  onOpenCallModal: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => CallActionModal(
                        order: activeOrder,
                        activeTheme: theme,
                        currentUser: widget.currentUser,
                        noteController: _noteController,
                        onUpdateOrder: (updated) {
                          context.read<SalesCallCenterProvider>().updateOrder(updated);
                        },
                        onRecordActivity: ({required order, required activityType, required title, required details, newStatus}) {},
                        onOpenReschedule: (order) {},
                        onOpenCancellationReason: (order) {},
                        onShowRequestUpsell: (order) {},
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SupervisorConsoleData {
  final List<SuperviseePerformanceModel> squad;
  final List<OrderModel> orders;
  final SupervisorDailyReportModel? dailyReport;

  _SupervisorConsoleData({
    required this.squad,
    required this.orders,
    this.dailyReport,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SupervisorConsoleData &&
          runtimeType == other.runtimeType &&
          squad == other.squad &&
          orders == other.orders &&
          dailyReport == other.dailyReport;

  @override
  int get hashCode => squad.hashCode ^ orders.hashCode ^ dailyReport.hashCode;
}
