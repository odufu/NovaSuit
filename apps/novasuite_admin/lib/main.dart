import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/sales/presentation/providers/sales_provider.dart';
import 'features/logistics/presentation/providers/logistics_provider.dart';
import 'features/marketing/presentation/providers/marketing_provider.dart';
import 'features/finance/presentation/providers/finance_provider.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/sales/presentation/pages/sales_call_center_suite_page.dart';
import 'features/sales_supervisor/presentation/pages/supervisor_console_page.dart';
import 'features/marketing/presentation/widgets/fund_marketer_dialog.dart';
import 'features/marketing/presentation/pages/digital_marketing_suite_page.dart';
import 'features/hr/presentation/pages/hr_staff_management_page.dart';
import 'features/logistics/presentation/pages/gm_inventory_suite_page.dart';
import 'features/logistics/presentation/widgets/create_transfer_dialog.dart';
import 'features/notifications/presentation/pages/notifications_suite_page.dart';
import 'features/sales/presentation/widgets/nova_dialer_floating_bar.dart';
import 'features/finance/presentation/widgets/verify_remittance_dialog.dart';

import 'features/navigation/providers/app_navigation_provider.dart';
import 'features/sales_supervisor/presentation/providers/supervisor_dashboard_provider.dart';
import 'features/sales/presentation/providers/sales_call_center_provider.dart';
import 'features/sales_supervisee/presentation/providers/call_rep_dashboard_provider.dart';
import 'features/hr/presentation/providers/hr_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'features/logistics/presentation/providers/inventory_provider.dart';
import 'features/marketing/presentation/providers/campaign_form_builder_provider.dart';

class NovaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB Max Memory Cache
  PaintingBinding.instance.imageCache.maximumSize = 100;

  if (!kIsWeb) {
    HttpOverrides.global = NovaHttpOverrides();
  }
  GoogleFonts.config.allowRuntimeFetching = true;
  await SupabaseConfig.init();
  await initDi();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SalesProvider>()),
        ChangeNotifierProvider(create: (_) => sl<LogisticsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<MarketingProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FinanceProvider>()),
        ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
        ChangeNotifierProvider(create: (_) => SupervisorDashboardProvider()),
        ChangeNotifierProvider(create: (_) => SalesCallCenterProvider()),
        ChangeNotifierProvider(create: (_) => CallRepDashboardProvider()),
        ChangeNotifierProvider(create: (_) => sl<HRProvider>()),
        ChangeNotifierProvider(create: (_) => sl<InventoryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CampaignFormBuilderProvider>()),
      ],
      child: const NovaSuiteAdminApp(),
    ),
  );
}

class NovaSuiteAdminApp extends StatelessWidget {
  const NovaSuiteAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector2<AuthProvider, ThemeProvider, _AppShellData>(
      selector: (_, auth, theme) => _AppShellData(
        currentUser: auth.currentUser,
        themeMode: theme.themeMode,
      ),
      builder: (context, data, _) {
        final activeTheme = context.read<AppNavigationProvider>().activeTheme;

        return MaterialApp(
          title: activeTheme.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: data.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: data.currentUser == null
              ? LoginScreen(
                  activeTheme: activeTheme,
                  onLoginSuccess: (user) {
                    context.read<AuthProvider>().setCurrentUser(user);
                  },
                )
              : AdminMainShell(
                  activeTheme: activeTheme,
                  currentUser: data.currentUser!,
                  onThemeChanged: (newTheme) {
                    context.read<AppNavigationProvider>().setActiveTheme(newTheme);
                  },
                  onSignOut: () {
                    context.read<AuthProvider>().logout();
                  },
                ),
        );
      },
    );
  }
}

class AdminMainShell extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final ValueChanged<TenantTheme> onThemeChanged;
  final VoidCallback onSignOut;

  const AdminMainShell({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  final String _selectedTenant = 'Nova Care Herbal';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = context.read<AppNavigationProvider>();
      final role = widget.currentUser.role;
      if (role == UserRole.digitalMarketer) {
        navProvider.setNavIndex(3);
      } else if (role == UserRole.salesCallRep) {
        navProvider.setNavIndex(1);
      } else if (role == UserRole.supervisor) {
        navProvider.setNavIndex(2);
      } else if (role == UserRole.logisticsCallRep) {
        navProvider.setNavIndex(4);
      } else if (role == UserRole.financeManager) {
        navProvider.setNavIndex(5);
      } else {
        navProvider.setNavIndex(0);
      }
    });
  }

  void _handleVerifyRemittance() async {
    final financeProvider = context.read<FinanceProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => VerifyRemittanceDialog(
        riderName: 'Rider Emeka (Independent)',
        currentBalance: financeProvider.riderEmekaCodBalance,
        maxCreditLimit: financeProvider.riderEmekaMaxLimit,
        remittedAmount: 125000.0,
        activeTheme: widget.activeTheme,
      ),
    );

    if (result == true) {
      financeProvider.verifyRemittance();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Bank Deposit Verified! Rider Emeka COD holding balance cleared.'),
        ),
      );
    }
  }

  void _handleCreateTransfer() async {
    final logisticsProvider = context.read<LogisticsProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateTransferDialog(activeTheme: widget.activeTheme),
    );

    if (result != null) {
      logisticsProvider.addTransfer({
        'waybill': result['waybill_number'],
        'source': result['source'],
        'destination': result['destination'],
        'product': result['product'],
        'quantity': result['quantity'],
        'status': 'dispatched',
        'date': 'Just now',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.activeTheme.primaryColor,
          content: Text('Waybill ${result['waybill_number']} dispatched to ${result['destination']}!'),
        ),
      );
    }
  }

  void _handleConfirmTransferReceipt(int index) {
    final logisticsProvider = context.read<LogisticsProvider>();
    final waybill = logisticsProvider.transfers[index]['waybill'];
    logisticsProvider.confirmTransferReceipt(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Stock Transfer Waybill $waybill confirmed & restocked successfully!'),
      ),
    );
  }

  void _handleFundMarketer() async {
    final marketingProvider = context.read<MarketingProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FundMarketerDialog(activeTheme: widget.activeTheme),
    );

    if (result != null) {
      final amount = result['amount'] as double;
      marketingProvider.fundMarketerBudget(amount);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Funded ${widget.activeTheme.currencySymbol} $amount to ${result['marketer_email']}!'),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<AppNavigationProvider>();
    final salesProvider = context.watch<SalesCallCenterProvider>();
    final logisticsProvider = context.watch<LogisticsProvider>();
    final marketingProvider = context.watch<MarketingProvider>();
    final financeProvider = context.watch<FinanceProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isSidebarCollapsed = navProvider.isSidebarCollapsed;
    final sidebarWidth = isDesktop ? (isSidebarCollapsed ? 74.0 : 260.0) : 260.0;
    final selectedIndex = navProvider.currentNavIndex;
    final orders = salesProvider.orders;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(child: _buildSidebarContent(context, isDrawer: true)),
      body: Row(
        children: [
          if (isDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sidebarWidth,
              child: _buildSidebarContent(context, isDrawer: false),
            ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(context, isDesktop: isDesktop),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: [
                          _buildDashboardView(context, screenWidth, orders, marketingProvider.totalMarketerBudget, financeProvider.riderEmekaCodBalance, financeProvider.riderEmekaMaxLimit, logisticsProvider.transfers),
                          SalesCallCenterSuitePage(
                            activeTheme: widget.activeTheme,
                            currentUser: widget.currentUser,
                            orders: orders,
                            activeSubIndex: navProvider.salesSubNavIndex,
                            onUpdateOrder: (updatedOrder) {
                              context.read<SalesCallCenterProvider>().updateOrder(updatedOrder);
                            },
                            onRequestUpsell: (updatedOrder) {
                              context.read<SalesCallCenterProvider>().updateOrder(updatedOrder);
                            },
                          ),
                          SupervisorConsolePage(
                            currentUser: widget.currentUser,
                            activeSubIndex: navProvider.supervisorSubNavIndex,
                          ),
                          _buildMarketingMainView(screenWidth, navProvider.marketingSubNavIndex),
                          _buildLogisticsWarehousesView(context, screenWidth, logisticsProvider.transfers),
                          _buildCODReconciliationView(context, screenWidth, financeProvider.riderEmekaCodBalance, financeProvider.riderEmekaMaxLimit),
                          _buildWhitelabelSettingsView(context, screenWidth),
                          HRStaffManagementPage(
                            activeTheme: widget.activeTheme,
                            currentUser: widget.currentUser,
                          ),
                          GMInventorySuitePage(
                            activeTheme: widget.activeTheme,
                            currentUser: widget.currentUser,
                            activeSubIndex: navProvider.inventorySubNavIndex,
                          ),
                          NotificationsSuitePage(
                            activeTheme: widget.activeTheme,
                            currentUser: widget.currentUser,
                            orders: orders,
                            onUpdateOrder: (updated) {
                              context.read<SalesCallCenterProvider>().updateOrder(updated);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Floating WebRTC NovaDialer Bar
                NovaDialerFloatingBar(
                  activeTheme: widget.activeTheme,
                  currentUser: widget.currentUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool isDrawer}) {
    final theme = widget.activeTheme;
    final user = widget.currentUser;
    final navProvider = context.watch<AppNavigationProvider>();
    final salesProvider = context.watch<SalesCallCenterProvider>();
    final orders = salesProvider.orders;
    final isSidebarCollapsed = navProvider.isSidebarCollapsed;
    final isCollapsed = !isSidebarCollapsed && !isDrawer ? false : (isSidebarCollapsed && !isDrawer);

    return Container(
      color: theme.primaryColor,
      child: Column(
        children: [
          // Sidebar Header (Fixed Collapsed Overflow)
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16, vertical: 16),
            alignment: Alignment.center,
            child: isCollapsed
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
                    ),
                    onPressed: () => context.read<AppNavigationProvider>().setSidebarCollapsed(false),
                    tooltip: 'Expand Sidebar',
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.appTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'White-Label Suite',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isDrawer)
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                          onPressed: () => context.read<AppNavigationProvider>().setSidebarCollapsed(true),
                          tooltip: 'Collapse Sidebar',
                        ),
                    ],
                  ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // Sidebar Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                if (user.role == UserRole.superAdmin || user.role == UserRole.agm) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('SALES & DIALER QUEUE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(1, 0, navProvider.salesSubNavIndex, Icons.phone_callback_rounded, 'Live Dialer Queue', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 1, navProvider.salesSubNavIndex, Icons.format_list_bulleted_rounded, 'All Orders Directory', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 2, navProvider.salesSubNavIndex, Icons.forum_rounded, 'Omnichannel Conversations', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 3, navProvider.salesSubNavIndex, Icons.stars_rounded, 'Upsell Approvals Hub', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 4, navProvider.salesSubNavIndex, Icons.auto_graph_rounded, 'Rep Performance', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 5, navProvider.salesSubNavIndex, Icons.record_voice_over_rounded, 'Call Scripts & Objections', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 6, navProvider.salesSubNavIndex, Icons.account_tree_rounded, 'Team Organogram & Hierarchy', isCollapsed: isCollapsed),
                  _sidebarNavItem(
                    2,
                    Icons.verified_user_rounded,
                    'Supervisor Approvals',
                    badgeCount: orders.where((o) => o.upsellStatus == UpsellStatus.pending).length,
                    isCollapsed: isCollapsed,
                  ),
                  _sidebarNavItem(
                    9,
                    Icons.notifications_active_rounded,
                    'Notifications Center',
                    badgeCount: orders.where((o) => o.scheduledCallbackAt != null && o.scheduledCallbackAt!.isBefore(DateTime.now().add(const Duration(minutes: 30)))).length,
                    isCollapsed: isCollapsed,
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('MARKETING SUITE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(3, 0, navProvider.marketingSubNavIndex, Icons.auto_graph_rounded, 'Ad Performance', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 1, navProvider.marketingSubNavIndex, Icons.dynamic_form_rounded, 'Lead Forms', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 2, navProvider.marketingSubNavIndex, Icons.build_circle_rounded, 'Form Builder Wizard', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 3, navProvider.marketingSubNavIndex, Icons.assignment_turned_in_rounded, 'Submissions Log', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 4, navProvider.marketingSubNavIndex, Icons.campaign_rounded, 'SMS & Broadcasts', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 5, navProvider.marketingSubNavIndex, Icons.webhook_rounded, 'FB CAPI & Pixel', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('LOGISTICS & WAREHOUSES', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _sidebarNavItem(4, Icons.local_shipping_rounded, 'Logistics Hubs', isCollapsed: isCollapsed),
                  _featureDirectNavItem(8, 0, navProvider.inventorySubNavIndex, Icons.shopping_bag_rounded, 'Products Catalog', isCollapsed: isCollapsed),
                  _featureDirectNavItem(8, 1, navProvider.inventorySubNavIndex, Icons.domain_rounded, 'Warehouse Matrix', isCollapsed: isCollapsed),
                  _featureDirectNavItem(8, 2, navProvider.inventorySubNavIndex, Icons.alt_route_rounded, 'Stock Transfers (IWT)', isCollapsed: isCollapsed),
                  _sidebarNavItem(5, Icons.payments_rounded, 'COD Reconciliation', isCollapsed: isCollapsed),
                  _sidebarNavItem(7, Icons.badge_rounded, 'HR Staff Directory', isCollapsed: isCollapsed),
                  _sidebarNavItem(6, Icons.palette_rounded, 'Whitelabel Branding', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.digitalMarketer) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('MARKETING SUITE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(3, 0, navProvider.marketingSubNavIndex, Icons.auto_graph_rounded, 'Ad Performance', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 1, navProvider.marketingSubNavIndex, Icons.dynamic_form_rounded, 'Lead Forms', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 2, navProvider.marketingSubNavIndex, Icons.build_circle_rounded, 'Form Builder Wizard', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 3, navProvider.marketingSubNavIndex, Icons.assignment_turned_in_rounded, 'Submissions Log', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 4, navProvider.marketingSubNavIndex, Icons.campaign_rounded, 'SMS & Broadcasts', isCollapsed: isCollapsed),
                  _featureDirectNavItem(3, 5, navProvider.marketingSubNavIndex, Icons.webhook_rounded, 'FB CAPI & Pixel', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.salesCallRep) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('SALES DIALER SUITE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(1, 0, navProvider.salesSubNavIndex, Icons.phone_callback_rounded, 'Live Dialer Queue', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 1, navProvider.salesSubNavIndex, Icons.format_list_bulleted_rounded, 'All Orders Directory', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 2, navProvider.salesSubNavIndex, Icons.forum_rounded, 'Omnichannel Conversations', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 3, navProvider.salesSubNavIndex, Icons.stars_rounded, 'Upsell Approvals Hub', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 4, navProvider.salesSubNavIndex, Icons.auto_graph_rounded, 'Rep Performance', isCollapsed: isCollapsed),
                  _featureDirectNavItem(1, 5, navProvider.salesSubNavIndex, Icons.record_voice_over_rounded, 'Call Scripts & Objections', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.supervisor) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('SUPERVISOR COMMAND SUITE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(2, 0, navProvider.supervisorSubNavIndex, Icons.dashboard_rounded, 'Squad Overview & KPIs', isCollapsed: isCollapsed),
                  _featureDirectNavItem(2, 1, navProvider.supervisorSubNavIndex, Icons.bolt_rounded, 'Realtime Approvals', isCollapsed: isCollapsed),
                  _featureDirectNavItem(2, 2, navProvider.supervisorSubNavIndex, Icons.folder_shared_rounded, 'Team Order Directory', isCollapsed: isCollapsed),
                  if (user.canTakeCalls)
                    _featureDirectNavItem(2, 3, navProvider.supervisorSubNavIndex, Icons.phone_in_talk_rounded, 'My Dialer Queue', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.logisticsCallRep) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  _sidebarNavItem(4, Icons.local_shipping_rounded, 'Logistics & Hubs', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.inventoryManager) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  const Divider(color: Colors.white24, height: 20),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('INVENTORY & WAREHOUSES', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  _featureDirectNavItem(8, 0, navProvider.inventorySubNavIndex, Icons.shopping_bag_rounded, 'Products Catalog', isCollapsed: isCollapsed),
                  _featureDirectNavItem(8, 1, navProvider.inventorySubNavIndex, Icons.domain_rounded, 'Warehouse Matrix', isCollapsed: isCollapsed),
                  _featureDirectNavItem(8, 2, navProvider.inventorySubNavIndex, Icons.alt_route_rounded, 'Stock Transfers (IWT)', isCollapsed: isCollapsed),
                  _sidebarNavItem(4, Icons.local_shipping_rounded, 'Logistics Hubs', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.financeManager) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  _sidebarNavItem(5, Icons.payments_rounded, 'COD Reconciliation', isCollapsed: isCollapsed),
                ] else if (user.role == UserRole.hrManager) ...[
                  _sidebarNavItem(0, Icons.dashboard_rounded, 'Dashboard Overview', isCollapsed: isCollapsed),
                  _sidebarNavItem(7, Icons.badge_rounded, 'HR Staff Directory', isCollapsed: isCollapsed),
                ],
              ],
            ),
          ),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black.withValues(alpha: 0.15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.secondaryColor,
                  child: Text(
                    user.firstName.isNotEmpty ? user.firstName.substring(0, 1) : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.role.label,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onSignOut,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Sign Out',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureDirectNavItem(int targetIndex, int subIndex, int currentSubIndex, IconData icon, String label, {bool isCollapsed = false}) {
    final navProvider = context.watch<AppNavigationProvider>();
    final isSelected = navProvider.currentNavIndex == targetIndex && currentSubIndex == subIndex;
    final theme = widget.activeTheme;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Tooltip(
          message: label,
          child: Material(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.read<AppNavigationProvider>().setDirectFeatureNav(
                      targetIndex: targetIndex,
                      subIndex: subIndex,
                    );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: isSelected ? theme.secondaryColor : Colors.white70,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.read<AppNavigationProvider>().setDirectFeatureNav(
                  targetIndex: targetIndex,
                  subIndex: subIndex,
                );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? theme.secondaryColor : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarNavItem(int index, IconData icon, String label, {int badgeCount = 0, bool isCollapsed = false}) {
    final navProvider = context.watch<AppNavigationProvider>();
    final isSelected = navProvider.currentNavIndex == index;
    final theme = widget.activeTheme;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Tooltip(
          message: label,
          child: Material(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.read<AppNavigationProvider>().setNavIndex(index);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: isSelected ? theme.secondaryColor : Colors.white70,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.read<AppNavigationProvider>().setNavIndex(index);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? theme.secondaryColor : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isDesktop}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final searchFill = isDark ? const Color(0xFF0E2419) : const Color(0xFFF1F5F9);
    final searchBorderColor = isDark ? const Color(0xFF1E3E33) : Colors.transparent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 12 : 10),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.activeTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.flash_on_rounded, color: widget.activeTheme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.activeTheme.appTitle,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: widget.activeTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Search Field
                    SizedBox(
                      width: 260,
                      height: 38,
                      child: TextField(
                        style: TextStyle(fontSize: 13, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search orders, leads, reps...',
                          hintStyle: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: searchFill,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: searchBorderColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: searchBorderColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: widget.activeTheme.primaryColor.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notifications Bell
                    IconButton(
                      onPressed: () => context.read<AppNavigationProvider>().setNavIndex(9),
                      tooltip: 'View Notifications Center',
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            size: 24,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: widget.activeTheme.secondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: headerBg, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Dark/Light Mode Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        final isThemeDark = themeProvider.isDarkMode;
                        return Tooltip(
                          message: isThemeDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                          child: InkWell(
                            onTap: () => themeProvider.toggleTheme(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: searchFill,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isThemeDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: isThemeDark ? Colors.amber : cs.onSurface.withValues(alpha: 0.7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isThemeDark ? 'Light' : 'Dark',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // User Avatar
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.activeTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          widget.currentUser.firstName.isNotEmpty
                              ? widget.currentUser.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu_rounded, size: 24, color: cs.onSurface),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.activeTheme.appTitle,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: widget.activeTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, tp, _) => IconButton(
                            onPressed: () => tp.toggleTheme(),
                            icon: Icon(
                              tp.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: tp.isDarkMode ? Colors.amber : cs.onSurface.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.read<AppNavigationProvider>().setNavIndex(9),
                          icon: Stack(
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 22, color: cs.onSurface.withValues(alpha: 0.7)),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: widget.activeTheme.secondaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: headerBg, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 38,
                  child: TextField(
                    style: TextStyle(fontSize: 12, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search orders, leads, reps...',
                      hintStyle: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                      prefixIcon: Icon(Icons.search, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: searchFill,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: searchBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: searchBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: widget.activeTheme.primaryColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashboardView(
    BuildContext context,
    double screenWidth,
    List<OrderModel> orders,
    double totalMarketerBudget,
    double riderEmekaCodBalance,
    double riderEmekaMaxLimit,
    List<Map<String, dynamic>> transfers,
  ) {
    final currency = widget.activeTheme.currencySymbol;
    final role = widget.currentUser.role;
    final pendingUpsellsCount = orders.where((o) => o.upsellStatus == UpsellStatus.pending).length;
    final isMobile = screenWidth < 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${role.label} Dashboard', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Department KPI metrics for $_selectedTenant', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                if (role == UserRole.agm || role == UserRole.superAdmin)
                  ElevatedButton.icon(
                    onPressed: _handleFundMarketer,
                    style: ElevatedButton.styleFrom(backgroundColor: widget.activeTheme.primaryColor),
                    icon: const Icon(Icons.account_balance_wallet, size: 16),
                    label: const Text('Fund Marketer Budget'),
                  ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${role.label} Dashboard', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Department KPI metrics for $_selectedTenant', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    if (role == UserRole.agm || role == UserRole.superAdmin) ...[
                      ElevatedButton.icon(
                        onPressed: _handleFundMarketer,
                        style: ElevatedButton.styleFrom(backgroundColor: widget.activeTheme.primaryColor),
                        icon: const Icon(Icons.account_balance_wallet, size: 16),
                        label: const Text('Fund Marketer Budget'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.activeTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: widget.activeTheme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: widget.activeTheme.primaryColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'KPI Mode: ${role.label}',
                            style: TextStyle(color: widget.activeTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Department-Tailored KPI Cards Grid
          if (role == UserRole.digitalMarketer) ...[
            if (isMobile) ...[
              _statCard('SPEND (Ad Spend)', '$currency 3,500,000', '142 Lead Submissions', Icons.ads_click, Colors.blue),
              const SizedBox(height: 12),
              _statCard('GENERATED LEADS', '142 Leads', '84.5% Delivery Rate', Icons.shopping_bag_outlined, Colors.orange),
              const SizedBox(height: 12),
              _statCard('DELIVERED REVENUE', '$currency 14,850,000', '4.24x ROAS Multiplier', Icons.auto_graph, Colors.green),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('SPEND (Ad Spend)', '$currency 3,500,000', '142 Lead Submissions', Icons.ads_click, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('GENERATED LEADS', '142 Leads', '84.5% Delivery Rate', Icons.shopping_bag_outlined, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('DELIVERED REVENUE', '$currency 14,850,000', '4.24x ROAS Multiplier', Icons.auto_graph, Colors.green)),
                ],
              ),
            ],
          ] else if (role == UserRole.supervisor) ...[
            if (isMobile) ...[
              _statCard('Supervisor Team Override', '₦145,000', 'Team Override Incentive', Icons.payments, Colors.green),
              const SizedBox(height: 12),
              _statCard('Active Squad Queue', '142 Orders', 'Auto Round-Robin Active', Icons.group_work, Colors.orange),
              const SizedBox(height: 12),
              _statCard('Upsells Pending Approval', '$pendingUpsellsCount Request(s)', 'Realtime Squad Alert', Icons.bolt, Colors.purple),
              const SizedBox(height: 12),
              _statCard('Squad Confirmation Rate', '78.4%', '+5.2% vs last week', Icons.trending_up, Colors.blue),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('Supervisor Team Override', '₦145,000', 'Team Override Incentive', Icons.payments, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Active Squad Queue', '142 Orders', 'Auto Round-Robin Active', Icons.group_work, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Upsells Pending Approval', '$pendingUpsellsCount Request(s)', 'Realtime Squad Alert', Icons.bolt, Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Squad Confirmation Rate', '78.4%', '+5.2% vs last week', Icons.trending_up, Colors.blue)),
                ],
              ),
            ],
          ] else if (role == UserRole.salesCallRep) ...[
            if (isMobile) ...[
              _statCard('My Call Queue', '35 Orders', 'Auto Distribution Active', Icons.phone_in_talk, Colors.orange),
              const SizedBox(height: 12),
              _statCard('My Commission Earned', '₦17,000', '17 Delivered Units (₦1k/unit)', Icons.payments, Colors.green),
              const SizedBox(height: 12),
              _statCard('Upsells Pending Approval', '$pendingUpsellsCount Request(s)', 'Realtime Supervisor Alert', Icons.verified, Colors.purple),
              const SizedBox(height: 12),
              _statCard('My Conversion Rate', '78.4%', '+5.2% vs last week', Icons.trending_up, Colors.blue),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('My Call Queue', '35 Orders', 'Auto Distribution Active', Icons.phone_in_talk, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('My Commission Earned', '₦17,000', '17 Delivered Units (₦1k/unit)', Icons.payments, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Upsells Pending Approval', '$pendingUpsellsCount Request(s)', 'Realtime Supervisor Alert', Icons.verified, Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('My Conversion Rate', '78.4%', '+5.2% vs last week', Icons.trending_up, Colors.blue)),
                ],
              ),
            ],
          ] else if (role == UserRole.logisticsCallRep) ...[
            if (isMobile) ...[
              _statCard('Central Factory Stock', '4,500 units', '320 Allocated', Icons.inventory, Colors.blue),
              const SizedBox(height: 12),
              _statCard('Active Waybills In-Transit', '${transfers.where((t) => t["status"] == "dispatched").length} Waybill(s)', 'Nationwide Dispatch', Icons.local_shipping, Colors.orange),
              const SizedBox(height: 12),
              _statCard('Delivery Success Rate', '94.2%', 'Rider Mini-Hubs Active', Icons.check_circle, Colors.green),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('Central Factory Stock', '4,500 units', '320 Allocated', Icons.inventory, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Active Waybills In-Transit', '${transfers.where((t) => t["status"] == "dispatched").length} Waybill(s)', 'Nationwide Dispatch', Icons.local_shipping, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Delivery Success Rate', '94.2%', 'Rider Mini-Hubs Active', Icons.check_circle, Colors.green)),
                ],
              ),
            ],
          ] else if (role == UserRole.financeManager) ...[
            if (isMobile) ...[
              _statCard('Holding Cash with Riders', '$currency ${riderEmekaCodBalance.toStringAsFixed(0)}', 'Max Limit: $currency ${riderEmekaMaxLimit.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.amber.shade800),
              const SizedBox(height: 12),
              _statCard('Pending Deposit Receipts', '1 Receipt', 'Verification Needed', Icons.receipt_long, Colors.purple),
              const SizedBox(height: 12),
              _statCard('Total Verified COD', '$currency 14,850,000', 'Cleared to Bank Account', Icons.verified_user, Colors.green),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('Holding Cash with Riders', '$currency ${riderEmekaCodBalance.toStringAsFixed(0)}', 'Max Limit: $currency ${riderEmekaMaxLimit.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.amber.shade800)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Pending Deposit Receipts', '1 Receipt', 'Verification Needed', Icons.receipt_long, Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Total Verified COD', '$currency 14,850,000', 'Cleared to Bank Account', Icons.verified_user, Colors.green)),
                ],
              ),
            ],
          ] else ...[
            // Default Executive / AGM Overview
            if (isMobile) ...[
              _statCard('Delivered Revenue', '$currency 14,850,000', '+18.4% vs last week', Icons.trending_up, Colors.green),
              const SizedBox(height: 12),
              _statCard('Pending Orders', '142 Orders', 'Auto Round-Robin Active', Icons.phone_in_talk, Colors.orange),
              const SizedBox(height: 12),
              _statCard('Upsells Pending', '$pendingUpsellsCount Request(s)', 'Supervisor Action Needed', Icons.verified, Colors.purple),
              const SizedBox(height: 12),
              _statCard('Ad Spend Budget', '$currency ${totalMarketerBudget.toStringAsFixed(0)}', '4.2x ROAS Multiplier', Icons.ads_click, Colors.blue),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _statCard('Delivered Revenue', '$currency 14,850,000', '+18.4% vs last week', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Pending Orders', '142 Orders', 'Auto Round-Robin Active', Icons.phone_in_talk, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Upsells Pending', '$pendingUpsellsCount Request(s)', 'Supervisor Action Needed', Icons.verified, Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Ad Spend Budget', '$currency ${totalMarketerBudget.toStringAsFixed(0)}', '4.2x ROAS Multiplier', Icons.ads_click, Colors.blue)),
                ],
              ),
            ],
          ],
          const SizedBox(height: 24),

          // Analytics Tools Section: Trend Chart & Distribution Bars
          _buildPerformanceTrendChart(isDark, widget.activeTheme, cardBg, borderColor, textPrimary, textMuted, isMobile),
          const SizedBox(height: 16),
          _buildAnalyticsDistributionSection(isDark, widget.activeTheme, cardBg, borderColor, textPrimary, textMuted, isMobile),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrendChart(bool isDark, TenantTheme theme, Color cardBg, Color borderColor, Color textPrimary, Color textMuted, bool isMobile) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final commissions = [12.0, 15.0, 14.0, 18.0, 17.0, 22.0, 25.0];
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📈 Weekly Commission & Call Volume Trends', style: GoogleFonts.outfit(fontSize: isMobile ? 13.5 : 16, fontWeight: FontWeight.bold, color: textPrimary), overflow: TextOverflow.ellipsis),
                    Text('7-day commission performance trajectory across active calls', style: GoogleFonts.inter(fontSize: 10.5, color: textMuted), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('₦123k Commission', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final heightFactor = commissions[index] / 30.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('₦${commissions[index].toInt()}k', style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      width: isMobile ? 18 : 28,
                      height: 110 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.primaryColor,
                            const Color(0xFF10B981),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[index], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDistributionSection(bool isDark, TenantTheme theme, Color cardBg, Color borderColor, Color textPrimary, Color textMuted, bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildProductRevenueDistribution(isDark, theme, cardBg, borderColor, textPrimary, textMuted),
          const SizedBox(height: 12),
          _buildCallOutcomeDistribution(isDark, theme, cardBg, borderColor, textPrimary, textMuted),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProductRevenueDistribution(isDark, theme, cardBg, borderColor, textPrimary, textMuted)),
              const SizedBox(width: 14),
              Expanded(child: _buildCallOutcomeDistribution(isDark, theme, cardBg, borderColor, textPrimary, textMuted)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductRevenueDistribution(bool isDark, TenantTheme theme, Color cardBg, Color borderColor, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🛍️ Product Revenue Share', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 4),
          Text('Revenue breakdown across active product lines', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(height: 14),

          _buildProgressBar('Grazer Herbal Detox Tea', 0.48, '₦ 1,680,000', const Color(0xFF10B981), textPrimary, textMuted),
          const SizedBox(height: 10),
          _buildProgressBar('Herbal Vitality Booster', 0.32, '₦ 1,120,000', Colors.blue, textPrimary, textMuted),
          const SizedBox(height: 10),
          _buildProgressBar('Clear Skin Care Set', 0.20, '₦ 700,000', Colors.purple, textPrimary, textMuted),
        ],
      ),
    );
  }

  Widget _buildCallOutcomeDistribution(bool isDark, TenantTheme theme, Color cardBg, Color borderColor, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📞 Squad Call Outcomes Share', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 4),
          Text('Proportional status breakdown for daily calls', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(height: 14),

          _buildProgressBar('Confirmed Orders', 0.60, '60%', const Color(0xFF10B981), textPrimary, textMuted),
          const SizedBox(height: 10),
          _buildProgressBar('Delivered Orders', 0.25, '25%', Colors.blue, textPrimary, textMuted),
          const SizedBox(height: 10),
          _buildProgressBar('Rescheduled / Call Back', 0.10, '10%', Colors.amber, textPrimary, textMuted),
          const SizedBox(height: 10),
          _buildProgressBar('Unanswered / Cancelled', 0.05, '5%', Colors.redAccent, textPrimary, textMuted),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percent, String valText, Color color, Color textPrimary, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
            Text(valText, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketingMainView(double screenWidth, int activeSubIndex) {
    return DigitalMarketingSuitePage(
      activeTheme: widget.activeTheme,
      currentUser: widget.currentUser,
      activeSubIndex: activeSubIndex,
    );
  }

  Widget _buildLogisticsWarehousesView(BuildContext context, double screenWidth, List<Map<String, dynamic>> transfers) {
    final isMobile = screenWidth < 900;
    final theme = widget.activeTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logistics & Multi-Warehouse Management', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Track stock across Central Warehouses, Agency Hubs, and Independent Rider Mini-Hubs', style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _handleCreateTransfer,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                icon: const Icon(Icons.local_shipping, size: 18),
                label: const Text('Dispatch Stock Transfer (IWT Waybill)'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isMobile)
            Column(
              children: [
                _warehouseCard('Lagos Central Factory Hub', 'Available Stock: 4,500 units', 'Allocated: 320 units', 'In-Transit: 500 units'),
                const SizedBox(height: 12),
                _warehouseCard('Abuja Regional Hub (NovaExpress)', 'Available Stock: 1,800 units', 'Allocated: 110 units', 'In-Transit: 200 units'),
                const SizedBox(height: 12),
                _warehouseCard('Rider Emeka Mini-Hub (Port Harcourt)', 'Available Stock: 45 units', 'Allocated: 12 units', 'Type: Independent Direct Rider'),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _warehouseCard('Lagos Central Factory Hub', 'Available Stock: 4,500 units', 'Allocated: 320 units', 'In-Transit: 500 units')),
                const SizedBox(width: 12),
                Expanded(child: _warehouseCard('Abuja Regional Hub (NovaExpress)', 'Available Stock: 1,800 units', 'Allocated: 110 units', 'In-Transit: 200 units')),
                const SizedBox(width: 12),
                Expanded(child: _warehouseCard('Rider Emeka Mini-Hub (Port Harcourt)', 'Available Stock: 45 units', 'Allocated: 12 units', 'Type: Independent Direct Rider')),
              ],
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inter-Warehouse Transfers (IWT Waybills)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final cs = Theme.of(context).colorScheme;
                    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? const Color(0xFF0E2419) : const Color(0xFFF8FAFC),
                        ),
                        columns: [
                          DataColumn(label: Text('Waybill #', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                          DataColumn(label: Text('Origin Warehouse', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                          DataColumn(label: Text('Destination', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                          DataColumn(label: Text('Product / Qty', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                          DataColumn(label: Text('Status', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                          DataColumn(label: Text('Action', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: mutedColor))),
                        ],
                        rows: transfers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isDispatched = item['status'] == 'dispatched';
                          final chipFg = isDispatched ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
                          final chipBg = isDark
                              ? chipFg.withValues(alpha: 0.15)
                              : (isDispatched ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
                          final chipBorder = chipFg.withValues(alpha: isDark ? 0.4 : 0.25);

                          return DataRow(cells: [
                            DataCell(Text(item['waybill'], style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: cs.onSurface))),
                            DataCell(Text(item['source'], style: GoogleFonts.outfit(fontSize: 13, color: cs.onSurface))),
                            DataCell(Text(item['destination'], style: GoogleFonts.outfit(fontSize: 13, color: cs.onSurface))),
                            DataCell(Text('${item['product']} (${item['quantity']} units)', style: GoogleFonts.outfit(fontSize: 13, color: cs.onSurface))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: chipBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: chipBorder, width: 1),
                                ),
                                child: Text(
                                  isDispatched ? 'In-Transit' : 'Restocked & Completed',
                                  style: GoogleFonts.outfit(
                                    color: chipFg,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              isDispatched
                                  ? ElevatedButton.icon(
                                      onPressed: () => _handleConfirmTransferReceipt(index),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                      icon: const Icon(Icons.check_rounded, size: 14),
                                      label: Text('Confirm Receipt', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                                    )
                                  : Text('Verified ✓', style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ]);
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warehouseCard(String title, String line1, String line2, String line3) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(builder: (context) {
          final cs = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warehouse_rounded, color: Color(0xFF10B981), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _warehouseStatRow(Icons.inventory_2_rounded, line1, subtitleColor),
              const SizedBox(height: 4),
              _warehouseStatRow(Icons.check_circle_outline_rounded, line2, subtitleColor),
              const SizedBox(height: 4),
              _warehouseStatRow(Icons.local_shipping_outlined, line3, subtitleColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _warehouseStatRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 12, color: color))),
      ],
    );
  }

  Widget _buildCODReconciliationView(
    BuildContext context,
    double screenWidth,
    double riderEmekaCodBalance,
    double riderEmekaMaxLimit,
  ) {
    final currency = widget.activeTheme.currencySymbol;
    final isCleared = riderEmekaCodBalance == 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash-on-Delivery (COD) Reconciliation & Credit Limits', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Monitor pending cash held by riders, enforce credit thresholds, and verify deposit receipts', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: isCleared ? Colors.green : Colors.amber.shade700,
                        child: Icon(isCleared ? Icons.check : Icons.two_wheeler, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Agent: Rider Emeka (Independent)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            'Holding Cash Balance: $currency ${riderEmekaCodBalance.toStringAsFixed(0)} / Max Credit Limit: $currency ${riderEmekaMaxLimit.toStringAsFixed(0)}',
                            style: TextStyle(color: isCleared ? Colors.green.shade800 : Colors.grey, fontSize: 13, fontWeight: isCleared ? FontWeight.bold : FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: isCleared ? null : _handleVerifyRemittance,
                    style: ElevatedButton.styleFrom(backgroundColor: isCleared ? Colors.grey : Colors.green),
                    icon: Icon(isCleared ? Icons.verified : Icons.receipt_long, size: 18),
                    label: Text(isCleared ? 'Balance Cleared' : 'Verify Deposit Receipt'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhitelabelSettingsView(BuildContext context, double screenWidth) {
    final theme = widget.activeTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Whitelabel Brand Settings', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Customize the brand identity, logo, colors, and currency for your sub-company', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Presets Theme Selector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          widget.onThemeChanged(TenantTheme.defaultNovaCare());
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
                        child: const Text('Emerald Green (Nova Care)'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onThemeChanged(
                            const TenantTheme(
                              companyId: 'herbal-life',
                              appTitle: 'Herbal Life CRM',
                              logoUrl: '',
                              faviconUrl: '',
                              primaryColor: Color(0xFF0F4C81),
                              secondaryColor: Color(0xFFF5A623),
                              accentColor: Color(0xFF2ECC71),
                              backgroundColor: Color(0xFFF4F6F9),
                              fontFamily: 'Outfit',
                              currencyCode: 'NGN',
                              currencySymbol: '₦',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81)),
                        child: const Text('Royal Blue (Herbal Life)'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onThemeChanged(
                            const TenantTheme(
                              companyId: 'apex-health',
                              appTitle: 'Apex Health Logistics',
                              logoUrl: '',
                              faviconUrl: '',
                              primaryColor: Color(0xFFD35400),
                              secondaryColor: Color(0xFF2C3E50),
                              accentColor: Color(0xFF27AE60),
                              backgroundColor: Color(0xFFFAFBFD),
                              fontFamily: 'Outfit',
                              currencyCode: 'USD',
                              currencySymbol: '\$',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD35400)),
                        child: const Text('Deep Orange (Apex)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Current Active Company: ${theme.appTitle}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Currency Symbol: ${theme.currencySymbol} (${theme.currencyCode})'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String subtitle, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor = cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: titleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppShellData {
  final UserModel? currentUser;
  final ThemeMode themeMode;

  _AppShellData({
    this.currentUser,
    required this.themeMode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AppShellData &&
          runtimeType == other.runtimeType &&
          currentUser == other.currentUser &&
          themeMode == other.themeMode;

  @override
  int get hashCode => currentUser.hashCode ^ themeMode.hashCode;
}
