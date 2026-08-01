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

  late ValueNotifier<List<SuperviseePerformanceModel>> _squadNotifier;
  late ValueNotifier<List<OrderModel>> _squadOrdersNotifier;
  late ValueNotifier<List<OrderModel>> _pendingUpsellsNotifier;
  late ValueNotifier<SupervisorDailyReportModel> _dailyReportNotifier;
  late ValueNotifier<bool> _isLoadingNotifier;
  late ValueNotifier<bool> _isDarkModeNotifier;
  late ValueNotifier<OrderModel?> _activeCallOrderNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    _squadNotifier = ValueNotifier<List<SuperviseePerformanceModel>>([]);
    _squadOrdersNotifier = ValueNotifier<List<OrderModel>>([]);
    _pendingUpsellsNotifier = ValueNotifier<List<OrderModel>>([]);
    _dailyReportNotifier = ValueNotifier<SupervisorDailyReportModel>(SupervisorDailyReportModel.defaultReportForJuly27());
    _isLoadingNotifier = ValueNotifier<bool>(true);
    _isDarkModeNotifier = ValueNotifier<bool>(true);
    _activeCallOrderNotifier = ValueNotifier<OrderModel?>(null);

    _loadSupervisorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _squadNotifier.dispose();
    _squadOrdersNotifier.dispose();
    _pendingUpsellsNotifier.dispose();
    _dailyReportNotifier.dispose();
    _isLoadingNotifier.dispose();
    _isDarkModeNotifier.dispose();
    _activeCallOrderNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisorData() async {
    _isLoadingNotifier.value = true;
    final squad = await _supervisorRepo.fetchSquadSupervisees(
      companyId: widget.currentUser.companyId,
      supervisorId: widget.currentUser.id,
    );

    final orders = await _orderRepo.fetchOrders(
      companyId: widget.currentUser.companyId,
    );

    final pending = orders.where((o) => o.status == OrderStatus.upsellPending).toList();

    _squadNotifier.value = squad;
    _squadOrdersNotifier.value = orders;
    _pendingUpsellsNotifier.value = pending;
    _isLoadingNotifier.value = false;
  }

  void _handleUpdateSupervisee(SuperviseePerformanceModel updated) {
    final list = List<SuperviseePerformanceModel>.from(_squadNotifier.value);
    final index = list.indexWhere((s) => s.user.id == updated.user.id);
    if (index != -1) {
      list[index] = updated;
      _squadNotifier.value = list;
    }
  }

  void _handleResolveUpsell(String orderId, bool approve) async {
    await _supervisorRepo.resolveUpsellRequest(
      orderId: orderId,
      approve: approve,
      supervisorId: widget.currentUser.id,
    );

    final list = List<OrderModel>.from(_pendingUpsellsNotifier.value);
    list.removeWhere((o) => o.id == orderId);
    _pendingUpsellsNotifier.value = list;

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
    _activeCallOrderNotifier.value = order;
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
          final list = List<OrderModel>.from(_squadOrdersNotifier.value);
          final idx = list.indexWhere((o) => o.id == updated.id);
          if (idx != -1) {
            list[idx] = updated;
            _squadOrdersNotifier.value = list;
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

    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkModeNotifier,
      builder: (context, isDarkModeVal, _) {
        final cardBg = isDarkModeVal ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final navBg = isDarkModeVal ? const Color(0xFF1E293B) : Colors.white;
        final textPrimary = isDarkModeVal ? Colors.white : const Color(0xFF0F172A);
        final textMuted = isDarkModeVal ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        final borderColor = isDarkModeVal ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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

                        ValueListenableBuilder<List<OrderModel>>(
                          valueListenable: _pendingUpsellsNotifier,
                          builder: (context, pendingUpsellsVal, _) {
                            if (pendingUpsellsVal.isEmpty) return const SizedBox.shrink();
                            return GestureDetector(
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
                                      '${pendingUpsellsVal.length} UPSELL APPROVALS',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                            isDarkModeVal ? Icons.wb_sunny : Icons.nightlight_round,
                            color: textMuted,
                          ),
                          onPressed: () => _isDarkModeNotifier.value = !isDarkModeVal,
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar Navigation
                  Container(
                    color: navBg,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ValueListenableBuilder<List<OrderModel>>(
                      valueListenable: _pendingUpsellsNotifier,
                      builder: (context, pendingUpsellsVal, _) {
                        return TabBar(
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
                                isLabelVisible: pendingUpsellsVal.isNotEmpty,
                                label: Text('${pendingUpsellsVal.length}'),
                                child: const Icon(Icons.bolt),
                              ),
                              text: 'Realtime Approvals',
                            ),
                            const Tab(icon: Icon(Icons.swap_horiz), text: '1-Click Lead Reassignment'),
                            const Tab(icon: Icon(Icons.manage_accounts), text: 'Manage Supervisees'),
                            const Tab(icon: Icon(Icons.phone_in_talk), text: 'My Personal Dialer'),
                          ],
                        );
                      },
                    ),
                  ),

                  // Main Body Content
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingNotifier,
                      builder: (context, isLoadingVal, _) {
                        if (isLoadingVal) {
                          return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                        }

                        return ValueListenableBuilder<List<SuperviseePerformanceModel>>(
                          valueListenable: _squadNotifier,
                          builder: (context, squadVal, _) {
                            return ValueListenableBuilder<List<OrderModel>>(
                              valueListenable: _squadOrdersNotifier,
                              builder: (context, squadOrdersVal, _) {
                                return ValueListenableBuilder<List<OrderModel>>(
                                  valueListenable: _pendingUpsellsNotifier,
                                  builder: (context, pendingUpsellsVal, _) {
                                    return ValueListenableBuilder<SupervisorDailyReportModel>(
                                      valueListenable: _dailyReportNotifier,
                                      builder: (context, dailyReportVal, _) {
                                        return TabBarView(
                                          controller: _tabController,
                                          children: [
                                            // Tab 0: Operational Summary Report
                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: SupervisorReportTab(
                                                report: dailyReportVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onDateOrTimeframeChanged: (selectedDate, timeframe) async {
                                                  final report = await _supervisorRepo.fetchDailyOperationalReport(
                                                    companyId: widget.currentUser.companyId,
                                                    date: selectedDate,
                                                    timeframe: timeframe,
                                                  );
                                                  _dailyReportNotifier.value = report;
                                                },
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: SupervisorKpiDashboardTab(
                                                squad: squadVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onUpdateSupervisee: _handleUpdateSupervisee,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: SupervisorApprovalsTab(
                                                pendingUpsellOrders: pendingUpsellsVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onResolveUpsell: _handleResolveUpsell,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: SupervisorReassignmentTab(
                                                squadOrders: squadOrdersVal,
                                                squad: squadVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onExecuteReassignment: _handleReassign,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: ManageSuperviseesTab(
                                                squad: squadVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onUpdateSupervisee: _handleUpdateSupervisee,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: CallRepDashboardOverview(
                                                currentUser: widget.currentUser,
                                                myOrders: squadOrdersVal,
                                                activeTheme: theme,
                                                isDarkMode: isDarkModeVal,
                                                onStartCall: _startDirectCall,
                                                onOpenFullQueue: () {},
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Floating Dialer Bar
              ValueListenableBuilder<OrderModel?>(
                valueListenable: _activeCallOrderNotifier,
                builder: (context, activeCallOrderVal, _) {
                  if (activeCallOrderVal == null) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 24,
                    right: 24,
                    child: NovaDialerFloatingBar(
                      activeTheme: theme,
                      currentUser: widget.currentUser,
                      isDarkMode: isDarkModeVal,
                      onOpenCallModal: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => CallActionModal(
                            order: activeCallOrderVal,
                            activeTheme: theme,
                            currentUser: widget.currentUser,
                            noteController: _noteController,
                            onUpdateOrder: (updated) {
                              final list = List<OrderModel>.from(_squadOrdersNotifier.value);
                              final idx = list.indexWhere((o) => o.id == updated.id);
                              if (idx != -1) {
                                list[idx] = updated;
                                _squadOrdersNotifier.value = list;
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
