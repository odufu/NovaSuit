import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/request_upsell_dialog.dart';
import '../widgets/create_call_script_dialog.dart';
import '../widgets/master_order_details_dialog.dart';
import '../widgets/all_orders_directory_card.dart';
import '../widgets/call_action_modal.dart';
import '../widgets/supervisee_quota_meter_card.dart';
import '../widgets/call_rep_dashboard_overview.dart';
import '../../../logistics/presentation/widgets/reassign_logistics_rep_dialog.dart';
import '../../../omnichannel_chat/presentation/widgets/omnichannel_unified_chat_sheet.dart';

enum CallStage {
  connectingProvider, // Stage 1: Connecting to Provider
  initiatingCall,     // Stage 2: Initiating Call (Ringing Audio Feed)
  callInProgress,     // Stage 3: Call in Progress (Active Audio Session)
  callEnded,          // Stage 4: Call Ended (Computing Billing)
  disconnected,       // Stage 5: Disconnected (Select Outcome Category)
}

class SalesCallCenterSuitePage extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final List<OrderModel> orders;
  final Function(OrderModel) onUpdateOrder;
  final Function(OrderModel) onRequestUpsell;

  final int activeSubIndex;

  const SalesCallCenterSuitePage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    required this.orders,
    required this.onUpdateOrder,
    required this.onRequestUpsell,
    this.activeSubIndex = 0,
  });

  @override
  State<SalesCallCenterSuitePage> createState() => _SalesCallCenterSuitePageState();
}

class _SalesCallCenterSuitePageState extends State<SalesCallCenterSuitePage> {
  late final ValueNotifier<int> _activeSubTabNotifier;
  late final ValueNotifier<String> _searchQueryNotifier;
  late final ValueNotifier<String> _stateFilterNotifier;
  late final ValueNotifier<String> _queueStatusFilterNotifier;
  late final ValueNotifier<bool?> _userViewModePreferenceNotifier;
  late final ValueNotifier<String> _sortOptionNotifier;

  // Filters for All Orders Master Directory
  late final ValueNotifier<String> _allOrdersSearchQueryNotifier;
  late final ValueNotifier<String> _allOrdersStatusFilterNotifier;
  late final ValueNotifier<String> _allOrdersCategoryFilterNotifier;
  late final ValueNotifier<String> _allOrdersStateFilterNotifier;
  late final ValueNotifier<bool> _showOnlyMyAssignedLeadsNotifier;

  // Product Attachment Filter for Scripts
  late final ValueNotifier<String> _selectedScriptProductFilterNotifier;
  late final ValueNotifier<UserRole> _simulatedRoleNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _customCallScriptsNotifier;
  late final ValueNotifier<Map<String, List<OrderActivityModel>>> _orderActivityStoreNotifier;

  int get _activeSubTab => _activeSubTabNotifier.value;
  set _activeSubTab(int val) => _activeSubTabNotifier.value = val;

  String get _searchQuery => _searchQueryNotifier.value;
  set _searchQuery(String val) => _searchQueryNotifier.value = val;

  String get _stateFilter => _stateFilterNotifier.value;
  set _stateFilter(String val) => _stateFilterNotifier.value = val;

  String get _queueStatusFilter => _queueStatusFilterNotifier.value;
  set _queueStatusFilter(String val) => _queueStatusFilterNotifier.value = val;

  bool? get _userViewModePreference => _userViewModePreferenceNotifier.value;
  set _userViewModePreference(bool? val) => _userViewModePreferenceNotifier.value = val;

  String get _sortOption => _sortOptionNotifier.value;
  set _sortOption(String val) => _sortOptionNotifier.value = val;

  String get _allOrdersSearchQuery => _allOrdersSearchQueryNotifier.value;
  set _allOrdersSearchQuery(String val) => _allOrdersSearchQueryNotifier.value = val;

  String get _allOrdersStatusFilter => _allOrdersStatusFilterNotifier.value;
  set _allOrdersStatusFilter(String val) => _allOrdersStatusFilterNotifier.value = val;

  String get _allOrdersCategoryFilter => _allOrdersCategoryFilterNotifier.value;
  set _allOrdersCategoryFilter(String val) => _allOrdersCategoryFilterNotifier.value = val;

  String get _allOrdersStateFilter => _allOrdersStateFilterNotifier.value;
  set _allOrdersStateFilter(String val) => _allOrdersStateFilterNotifier.value = val;

  bool get _showOnlyMyAssignedLeads => _showOnlyMyAssignedLeadsNotifier.value;
  set _showOnlyMyAssignedLeads(bool val) => _showOnlyMyAssignedLeadsNotifier.value = val;

  String get _selectedScriptProductFilter => _selectedScriptProductFilterNotifier.value;
  set _selectedScriptProductFilter(String val) => _selectedScriptProductFilterNotifier.value = val;

  UserRole get _simulatedRole => _simulatedRoleNotifier.value;
  set _simulatedRole(UserRole val) => _simulatedRoleNotifier.value = val;

  List<Map<String, dynamic>> get _customCallScripts => _customCallScriptsNotifier.value;

  late List<Map<String, dynamic>> _ahodTeams;
  final _noteController = TextEditingController();

  void _recordActivity({
    required OrderModel order,
    required String activityType,
    required String title,
    required String details,
    String? performedBy,
    String? userRole,
    DateTime? scheduledCallbackAt,
    String? oldStatus,
    String? newStatus,
    Map<String, dynamic>? metadata,
  }) {
    final currentStore = Map<String, List<OrderActivityModel>>.from(_orderActivityStoreNotifier.value);
    final list = List<OrderActivityModel>.from(currentStore[order.id] ?? []);
    final activity = OrderActivityModel(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}-${list.length}',
      orderId: order.id,
      activityType: activityType,
      title: title,
      details: details,
      performedBy: performedBy ?? '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
      userRole: userRole ?? 'Sales Call Rep',
      scheduledCallbackAt: scheduledCallbackAt,
      oldStatus: oldStatus ?? order.status.dbValue,
      newStatus: newStatus,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    list.insert(0, activity);
    currentStore[order.id] = list;
    _orderActivityStoreNotifier.value = currentStore;

    OrderRepository().logActivity(activity);
  }

  @override
  void initState() {
    super.initState();
    _activeSubTabNotifier = ValueNotifier<int>(widget.activeSubIndex);
    _searchQueryNotifier = ValueNotifier<String>('');
    _stateFilterNotifier = ValueNotifier<String>('All');
    _queueStatusFilterNotifier = ValueNotifier<String>('All');
    _userViewModePreferenceNotifier = ValueNotifier<bool?>(null);
    _sortOptionNotifier = ValueNotifier<String>('newest');

    _allOrdersSearchQueryNotifier = ValueNotifier<String>('');
    _allOrdersStatusFilterNotifier = ValueNotifier<String>('All');
    _allOrdersCategoryFilterNotifier = ValueNotifier<String>('All');
    _allOrdersStateFilterNotifier = ValueNotifier<String>('All');
    _showOnlyMyAssignedLeadsNotifier = ValueNotifier<bool>(false);

    _selectedScriptProductFilterNotifier = ValueNotifier<String>('All Assigned Products');
    _simulatedRoleNotifier = ValueNotifier<UserRole>(widget.currentUser.role == UserRole.salesCallRep ? UserRole.salesCallRep : UserRole.hod);
    _customCallScriptsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _orderActivityStoreNotifier = ValueNotifier<Map<String, List<OrderActivityModel>>>({});

    _ahodTeams = [
      {
        'id': 'ahod-1',
        'name': 'AHOD Folashade Ogundele',
        'title': 'Assistant HOD (Southern & Western Hubs)',
        'phone': '+234 803 111 2233',
        'supervisors': [
          {
            'id': 'sup-1',
            'name': 'Supervisor Emeka Okonkwo',
            'title': 'Supervisor - Lagos & Southwest Squad',
            'phone': '+234 802 333 4455',
            'supervisees': [
              {
                'id': 'usr-101',
                'name': 'Folake Adeleke',
                'extension': 'Ext 102',
                'phone': '+234 802 987 6543',
                'status': '🟢 Active On Line',
                'products': 'GRAZER HERBAL DETOX & SHAMPOO BUNDLE',
                'totalAssigned': 35,
                'confirmedOrders': 21,
                'delivered': 17,
                'untaggedOnCrm': 6,
                'rescheduled': 7,
                'inProgress': 6,
                'switchedOff': 2,
                'notPicking': 4,
                'cancelled': 0,
                'notReady': 1,
                'deliveredToday': 15,
                'deliveredPreviousDays': 2,
                'totalCalls': 45,
                'totalCod': 540000.0,
                'upsellAmount': 85000.0,
                'conversionRate': 26.7,
              },
              {
                'id': 'usr-102',
                'name': 'Engineer Chidi Nnamdi',
                'extension': 'Ext 104',
                'phone': '+234 806 777 8899',
                'status': '🟢 Active On Line',
                'products': 'VITALITY BOOSTER & CLEAR SKIN CARE',
                'totalAssigned': 28,
                'confirmedOrders': 16,
                'delivered': 12,
                'untaggedOnCrm': 4,
                'rescheduled': 5,
                'inProgress': 4,
                'switchedOff': 1,
                'notPicking': 2,
                'cancelled': 0,
                'notReady': 0,
                'deliveredToday': 10,
                'deliveredPreviousDays': 2,
                'totalCalls': 38,
                'totalCod': 380000.0,
                'upsellAmount': 45000.0,
                'conversionRate': 23.6,
              },
            ],
          },
          {
            'id': 'sup-2',
            'name': 'Supervisor Chioma Eze',
            'title': 'Supervisor - South-South & Rivers Squad',
            'phone': '+234 805 444 5566',
            'supervisees': [
              {
                'id': 'usr-103',
                'name': 'Chief Bartholomew O.',
                'extension': 'Ext 101',
                'phone': '+234 803 123 4567',
                'status': '🟢 Active On Line',
                'totalCalls': 50,
                'confirmedOrders': 15,
                'totalCod': 670000.0,
                'upsellAmount': 110000.0,
                'conversionRate': 30.0,
                'reportSubmitted': true,
                'isVerified': true,
              },
              {
                'id': 'usr-104',
                'name': 'Grace Danjuma',
                'extension': 'Ext 105',
                'phone': '+234 809 222 3344',
                'status': '🟡 On Break',
                'totalCalls': 28,
                'confirmedOrders': 6,
                'totalCod': 240000.0,
                'upsellAmount': 20000.0,
                'conversionRate': 21.4,
                'reportSubmitted': false,
                'isVerified': false,
              },
            ],
          },
        ],
      },
      {
        'id': 'ahod-2',
        'name': 'AHOD Alhaji Ibrahim Danladi',
        'title': 'Assistant HOD (Northern & Federal Capital Hubs)',
        'phone': '+234 805 555 6677',
        'supervisors': [
          {
            'id': 'sup-3',
            'name': 'Supervisor Usman Abubakar',
            'title': 'Supervisor - Abuja & Kano Squad',
            'phone': '+234 807 888 9900',
            'supervisees': [
              {
                'id': 'usr-105',
                'name': 'Amina Bello',
                'extension': 'Ext 106',
                'phone': '+234 803 444 7788',
                'status': '🟢 Active On Line',
                'totalCalls': 42,
                'confirmedOrders': 11,
                'totalCod': 490000.0,
                'upsellAmount': 60000.0,
                'conversionRate': 26.2,
                'reportSubmitted': true,
                'isVerified': true,
              },
              {
                'id': 'usr-106',
                'name': 'Kabiru Mohammed',
                'extension': 'Ext 107',
                'phone': '+234 802 111 8899',
                'status': '🟢 Active On Line',
                'totalCalls': 35,
                'confirmedOrders': 8,
                'totalCod': 320000.0,
                'upsellAmount': 35000.0,
                'conversionRate': 22.8,
                'reportSubmitted': true,
                'isVerified': false,
              },
            ],
          },
        ],
      },
    ];

    _customCallScriptsNotifier.value = [
      {
        'objection': 'Customer says: "The price is too high for 1 bottle!"',
        'product': 'Grazer Herbal Detox Tea',
        'script': 'Explain the 100% natural organic quality and Pay-on-Delivery guarantee. If client hesitates, pitch the 2-Bottle Value Bundle at 25% discount.',
        'badge': 'Price Objection',
        'color': Colors.orange,
      },
      {
        'objection': 'Customer says: "Can I inspect the box before paying?"',
        'product': 'All Assigned Products',
        'script': 'Reassure client: "Yes! Our NovaExpress dispatch rider will allow you to open and inspect the sealed box before making cash or transfer payment."',
        'badge': 'COD Inspection',
        'color': Colors.green,
      },
      {
        'objection': 'Customer asks: "How many capsules should I take daily?"',
        'product': 'Herbal Vitality Booster',
        'script': 'Dosage Playbook: Take 2 capsules in the morning after breakfast with warm water for peak daily stamina.',
        'badge': 'Dosage & Usage',
        'color': Colors.purple,
      },
      {
        'objection': 'Customer asks: "How long does delivery take to Abuja?"',
        'product': 'All Assigned Products',
        'script': 'Lagos Central Hub: 24 Hours. Abuja/Port Harcourt/Kano Hubs: 24-48 Hours. Nationwide Doorstep Delivery via NovaExpress.',
        'badge': 'Delivery Time',
        'color': Colors.blue,
      },
    ];
  }

  @override
  void dispose() {
    _activeSubTabNotifier.dispose();
    _searchQueryNotifier.dispose();
    _stateFilterNotifier.dispose();
    _queueStatusFilterNotifier.dispose();
    _userViewModePreferenceNotifier.dispose();
    _sortOptionNotifier.dispose();
    _allOrdersSearchQueryNotifier.dispose();
    _allOrdersStatusFilterNotifier.dispose();
    _allOrdersCategoryFilterNotifier.dispose();
    _allOrdersStateFilterNotifier.dispose();
    _showOnlyMyAssignedLeadsNotifier.dispose();
    _selectedScriptProductFilterNotifier.dispose();
    _simulatedRoleNotifier.dispose();
    _customCallScriptsNotifier.dispose();
    _orderActivityStoreNotifier.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SalesCallCenterSuitePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSubIndex != widget.activeSubIndex) {
      _activeSubTab = widget.activeSubIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return ValueListenableBuilder<int>(
      valueListenable: _activeSubTabNotifier,
      builder: (context, activeSubTabVal, _) {
        return IndexedStack(
          index: _activeSubTab,
          children: [
            ValueListenableBuilder(
              valueListenable: _searchQueryNotifier,
              builder: (context, _, __) => ValueListenableBuilder(
                valueListenable: _stateFilterNotifier,
                builder: (context, _, __) => ValueListenableBuilder(
                  valueListenable: _queueStatusFilterNotifier,
                  builder: (context, _, __) => ValueListenableBuilder(
                    valueListenable: _userViewModePreferenceNotifier,
                    builder: (context, _, __) => _buildLiveDialerQueueTab(isMobile),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _allOrdersSearchQueryNotifier,
              builder: (context, _, __) => ValueListenableBuilder(
                valueListenable: _allOrdersStatusFilterNotifier,
                builder: (context, _, __) => ValueListenableBuilder(
                  valueListenable: _allOrdersStateFilterNotifier,
                  builder: (context, _, __) => ValueListenableBuilder(
                    valueListenable: _allOrdersCategoryFilterNotifier,
                    builder: (context, _, __) => ValueListenableBuilder(
                      valueListenable: _showOnlyMyAssignedLeadsNotifier,
                      builder: (context, _, __) => ValueListenableBuilder(
                        valueListenable: _sortOptionNotifier,
                        builder: (context, _, __) => ValueListenableBuilder(
                          valueListenable: _userViewModePreferenceNotifier,
                          builder: (context, _, __) => _buildAllOrdersDirectoryTab(isMobile),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildConfirmedOrdersTab(isMobile),
            _buildUpsellApprovalsTab(isMobile),
            _buildPerformanceMetricsTab(isMobile),
            ValueListenableBuilder(
              valueListenable: _selectedScriptProductFilterNotifier,
              builder: (context, _, __) => ValueListenableBuilder(
                valueListenable: _customCallScriptsNotifier,
                builder: (context, _, __) => _buildCallScriptsTab(isMobile),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _simulatedRoleNotifier,
              builder: (context, _, __) => _buildOrganogramConsoleTab(isMobile),
            ),
          ],
        );
      },
    );
  }



  Widget _buildResponsiveOrderCardsList(List<OrderModel> orders, TenantTheme theme, bool isDarkMode, bool isMobile) {
    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildMobileOrderCard(orders[index], theme, isDarkMode);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 360).floor().clamp(1, 4);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 245,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildMobileOrderCard(orders[index], theme, isDarkMode);
            },
          );
        },
      ),
    );
  }

  Widget _buildResponsiveDirectoryCardsList(List<OrderModel> orders, TenantTheme theme, bool isDarkMode, bool isMobile) {
    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildAllOrdersDirectoryCard(orders[index], isDarkMode);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 380).floor().clamp(1, 3);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 350,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildAllOrdersDirectoryCard(orders[index], isDarkMode);
            },
          );
        },
      ),
    );
  }


  Widget _buildMobileOrderCard(OrderModel order, TenantTheme theme, bool isDarkMode) {
    final currency = theme.currencySymbol;
    final productName = order.productId.contains('tea')
        ? 'Grazer Herbal Tea'
        : (order.productId.contains('booster') ? 'Vitality Booster' : 'Clear Skin Care');

    final nameParts = order.customerName.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (order.customerName.isNotEmpty ? order.customerName.substring(0, 2).toUpperCase() : 'CU');

    final badge = _getStatusBadgeConfig(order.status, isDarkMode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Order # Pill + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge['bg'] as Color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badge['border'] as Color, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badge['icon'] as IconData, size: 12, color: badge['color'] as Color),
                      const SizedBox(width: 4),
                      Text(
                        badge['label'] as String,
                        style: TextStyle(
                          color: badge['color'] as Color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Customer Avatar + Name & Phone + COD Amount
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDarkMode ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.customerPhone,
                        style: GoogleFonts.jetBrainsMono(
                          color: isDarkMode ? const Color(0xFF10B981) : theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL COD',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$currency ${order.totalAmount}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Product Name & Delivery Location
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 13, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(
                        productName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${order.deliveryState} (${order.deliveryCity})',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Row 4: Action Buttons (Call Client & View)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openCallActionModal(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.phone, size: 14),
                    label: const Text('Call Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _openOrderDetailsModal(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.white70 : const Color(0xFF0F172A),
                    side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TAB 0: LIVE DIALER QUEUE
  Widget _buildLiveDialerQueueTab(bool isMobile) {
    final currency = widget.activeTheme.currencySymbol;
    final theme = widget.activeTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final pendingOrders = widget.orders.where((o) => o.status == OrderStatus.newOrder || o.status == OrderStatus.contacting || o.status == OrderStatus.callBack || o.status == OrderStatus.notReachable || o.status == OrderStatus.onHold).toList();

    final filteredOrders = pendingOrders.where((o) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          o.orderNumber.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.customerPhone.toLowerCase().contains(q) ||
          o.deliveryState.toLowerCase().contains(q);
      final matchesState = _stateFilter == 'All' || o.deliveryState.toLowerCase() == _stateFilter.toLowerCase();
      final matchesStatus = _queueStatusFilter == 'All' || o.status.dbValue == _queueStatusFilter;
      return matchesSearch && matchesState && matchesStatus;
    }).toList();

    final pageItems = filteredOrders;
    final isCardViewMode = _userViewModePreference ?? isMobile;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationReminderBanner(widget.orders),

          // Header Bar with Title & Top Metric Stat Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Live Call Queue', style: GoogleFonts.inter(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                        const SizedBox(width: 8),
                        Text('(${filteredOrders.length} Pending)', style: GoogleFonts.inter(fontSize: isMobile ? 16 : 20, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confirm orders · Verify delivery address · Pitch upsell bundles',
                      style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Top Right Metric Stat Boxes (Horizontal Row of 3 Cards)
              if (!isMobile)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text('₦125k', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF10B981), fontSize: 14)),
                          Text('Total Pipeline', style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text('3', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontSize: 14)),
                          Text('New Leads', style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text('1', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B), fontSize: 14)),
                          Text('Call Backs', style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Filter Controls Bar (Responsive 2-Row on Mobile to Prevent 22px Overflow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
            ),
            child: isMobile
                ? Column(
                    children: [
                      TextField(
                        onChanged: (val) => _searchQuery = val,
                        style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search customer, phone, or order #...',
                          hintStyle: TextStyle(fontSize: 13, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                          prefixIcon: Icon(Icons.search, size: 18, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // State Filter Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _stateFilter,
                                  dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                                  icon: Icon(Icons.keyboard_arrow_down, size: 16, color: isDarkMode ? Colors.white70 : Colors.grey),
                                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                                  items: const [
                                    DropdownMenuItem(value: 'All', child: Text('All States')),
                                    DropdownMenuItem(value: 'Lagos', child: Text('Lagos')),
                                    DropdownMenuItem(value: 'Abuja', child: Text('Abuja')),
                                    DropdownMenuItem(value: 'Rivers', child: Text('Rivers')),
                                    DropdownMenuItem(value: 'Kano', child: Text('Kano')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _stateFilter = val;
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Filter Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _queueStatusFilter,
                                  dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                                  icon: Icon(Icons.keyboard_arrow_down, size: 16, color: isDarkMode ? Colors.white70 : Colors.grey),
                                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                                  items: const [
                                    DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                                    DropdownMenuItem(value: 'new', child: Text('New Leads')),
                                    DropdownMenuItem(value: 'call_back', child: Text('Call Backs')),
                                    DropdownMenuItem(value: 'contacting', child: Text('Contacting')),
                                    DropdownMenuItem(value: 'not_reachable', child: Text('Not Reachable')),
                                    DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _queueStatusFilter = val;
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Layout View Mode Switcher
                            Container(
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _userViewModePreference = true,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.grid_view_rounded, size: 15, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                          const SizedBox(width: 4),
                                          Text('Cards', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 20, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                                  InkWell(
                                    onTap: () => _userViewModePreference = false,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: !isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.table_chart_rounded, size: 15, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                          const SizedBox(width: 4),
                                          Text('Table', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
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
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => _searchQuery = val,
                          style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search customer, phone, or order #...',
                            hintStyle: TextStyle(fontSize: 13, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                            prefixIcon: Icon(Icons.search, size: 18, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),

                      // State Filter Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _stateFilter,
                            dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: isDarkMode ? Colors.white70 : Colors.grey),
                            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All States')),
                              DropdownMenuItem(value: 'Lagos', child: Text('Lagos')),
                              DropdownMenuItem(value: 'Abuja', child: Text('Abuja')),
                              DropdownMenuItem(value: 'Rivers', child: Text('Rivers')),
                              DropdownMenuItem(value: 'Kano', child: Text('Kano')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                _stateFilter = val;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Status Filter Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _queueStatusFilter,
                            dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: isDarkMode ? Colors.white70 : Colors.grey),
                            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                              DropdownMenuItem(value: 'new', child: Text('New Leads')),
                              DropdownMenuItem(value: 'call_back', child: Text('Call Backs')),
                              DropdownMenuItem(value: 'contacting', child: Text('Contacting')),
                              DropdownMenuItem(value: 'not_reachable', child: Text('Not Reachable')),
                              DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                _queueStatusFilter = val;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Layout View Mode Switcher (Card Grid vs Table View)
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _userViewModePreference = true,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.grid_view_rounded, size: 15, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                    const SizedBox(width: 4),
                                    Text('Cards', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
                                  ],
                                ),
                              ),
                            ),
                            Container(width: 1, height: 20, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                            InkWell(
                              onTap: () => _userViewModePreference = false,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: !isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.table_chart_rounded, size: 15, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                    const SizedBox(width: 4),
                                    Text('Table', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
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
          const SizedBox(height: 16),

          // Clean Organized DataTable / Card Grid Body Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              child: filteredOrders.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_paused_rounded, size: 48, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No pending orders in call queue!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDarkMode ? Colors.white70 : Colors.grey)),
                            Text('All assigned leads have been processed for confirmation.', style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    )
                  : isCardViewMode
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildResponsiveOrderCardsList(pageItems, theme, isDarkMode, isMobile),
                              const SizedBox(height: 120),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                      child: DataTable(
                                        dataRowMinHeight: 64,
                                        dataRowMaxHeight: 74,
                                        columnSpacing: 24,
                                        headingRowColor: WidgetStateProperty.all(isDarkMode ? const Color(0xFF0C1F17) : Colors.transparent),
                                        dividerThickness: 1.0,
                                        border: TableBorder(
                                          horizontalInside: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200, width: 1),
                                        ),
                                        columns: [
                                          DataColumn(label: Text('ORDER', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                          DataColumn(label: Text('CUSTOMER', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                          DataColumn(label: Text('PRODUCT & LOCATION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                          DataColumn(label: Text('COD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                          DataColumn(label: Text('STATUS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                          DataColumn(label: Text('ACTIONS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                        ],
                                        rows: pageItems.map((o) {
                                          final productName = o.productId.contains('tea')
                                              ? 'Grazer Herbal Tea'
                                              : (o.productId.contains('booster') ? 'Vitality Booster' : 'Clear Skin Care');

                                          final nameParts = o.customerName.trim().split(' ');
                                          final initials = nameParts.length >= 2
                                              ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                                              : (o.customerName.isNotEmpty ? o.customerName.substring(0, 2).toUpperCase() : 'CU');

                                          return DataRow(
                                            color: WidgetStateProperty.resolveWith<Color?>((states) {
                                              return _getStatusRowColor(o.status, states.contains(WidgetState.hovered), isDarkMode);
                                            }),
                                            cells: [
                                              // 1. Order # Pill
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                                  child: Text('#${o.orderNumber}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32), fontSize: 11)),
                                                ),
                                              ),

                                              // 2. Customer Avatar + Name & Phone (Constrained to prevent overflow & add ...)
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: isDarkMode ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                                                      child: Text(initials, style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 11)),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 170,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            o.customerName,
                                                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            o.customerPhone,
                                                            style: GoogleFonts.jetBrainsMono(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // 3. Product & Location (Constrained to prevent overflow & add ...)
                                              DataCell(
                                                SizedBox(
                                                  width: 220,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.inventory_2_outlined, size: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              productName,
                                                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A)),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.location_on_outlined, size: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              '${o.deliveryState} - ${o.deliveryAddress}',
                                                              style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 11),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // 4. Total COD Amount
                                              DataCell(
                                                Text(
                                                  '$currency ${o.totalAmount}',
                                                  style: GoogleFonts.jetBrainsMono(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ),

                                              // 5. Queue Status Pill (Dynamic status badge color & icon)
                                              DataCell(
                                                Builder(
                                                  builder: (context) {
                                                    final badge = _getStatusBadgeConfig(o.status, isDarkMode);
                                                    return Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: badge['bg'] as Color,
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(
                                                          color: badge['border'] as Color,
                                                          width: 1.2,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            badge['icon'] as IconData,
                                                            size: 12,
                                                            color: badge['color'] as Color,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            badge['label'] as String,
                                                            style: TextStyle(
                                                              color: badge['color'] as Color,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // 6. Action Button (Single View Button)
                                              DataCell(
                                                ElevatedButton.icon(
                                                  onPressed: () => _openOrderDetailsModal(o),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                    visualDensity: VisualDensity.compact,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  icon: const Icon(Icons.visibility_outlined, size: 14),
                                                  label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

                            // Table Footer Row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Showing ${filteredOrders.length} of ${widget.orders.length} orders',
                                    style: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Last updated: just now',
                                        style: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _openInboundRoutingSimulatorModal() {
    final theme = widget.activeTheme;
    OrderModel selectedOrder = widget.orders.first;
    bool isAssignedRepBusyOrOffline = true; // Default test: Fallback to Central Queue

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.alt_route, color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('Inbound Call Sticky Routing Test', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SIMULATE CLIENT CALLING 0700-NOVACARE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<OrderModel>(
                      initialValue: selectedOrder,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: widget.orders.map((o) {
                        return DropdownMenuItem(
                          value: o,
                          child: Text('${o.customerName} (${o.customerPhone}) - #${o.orderNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedOrder = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text('ASSIGNED REP STATUS (Ext 102 - Folake):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('🟢 Online & Free', style: TextStyle(fontSize: 11)),
                          icon: Icon(Icons.check_circle_outline, size: 14),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('🔴 Busy / Offline', style: TextStyle(fontSize: 11)),
                          icon: Icon(Icons.do_not_disturb_on_outlined, size: 14),
                        ),
                      ],
                      selected: {isAssignedRepBusyOrOffline},
                      onSelectionChanged: (set) {
                        setModalState(() => isAssignedRepBusyOrOffline = set.first);
                      },
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAssignedRepBusyOrOffline ? Colors.orange.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isAssignedRepBusyOrOffline ? Colors.orange.shade200 : Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(isAssignedRepBusyOrOffline ? Icons.warning_amber_rounded : Icons.verified_user, color: isAssignedRepBusyOrOffline ? Colors.orange.shade800 : Colors.green.shade800, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAssignedRepBusyOrOffline
                                  ? '⚠️ Assigned Rep (Folake - Ext 102) is Busy/Offline. Inbound call will FALL BACK to Central Queue for any online rep!'
                                  : '✅ Assigned Rep (Folake - Ext 102) is Available. Call will Sticky-Route DIRECTLY to Rep Folake!',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAssignedRepBusyOrOffline ? Colors.orange.shade900 : Colors.green.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (isAssignedRepBusyOrOffline) {
                      // Trigger Central Line Fallback
                      _openCallActionModal(selectedOrder);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orange.shade800,
                          content: Text('⚠️ Fallback Triggered! Client ${selectedOrder.customerName} callback routed to Central Queue. Opening Order #${selectedOrder.orderNumber}!'),
                        ),
                      );
                    } else {
                      // Trigger Direct Sticky Routing
                      _openCallActionModal(selectedOrder);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: theme.primaryColor,
                          content: Text('🟢 Sticky Routing Success! Client ${selectedOrder.customerName} callback connected directly to Rep Folake (Ext 102)!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAssignedRepBusyOrOffline ? Colors.orange.shade800 : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.phone_callback, size: 16),
                  label: Text(isAssignedRepBusyOrOffline ? 'Simulate Central Fallback' : 'Simulate Direct Sticky Route'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openUpdateStatusOnlyModal(OrderModel order) {
    final theme = widget.activeTheme;
    final List<OrderStatus> validStatuses = [
      OrderStatus.newOrder,
      OrderStatus.accepted,
      OrderStatus.contacting,
      OrderStatus.callBack,
      OrderStatus.notReachable,
      OrderStatus.onHold,
      OrderStatus.upsellPending,
      OrderStatus.cancelled,
    ];
    OrderStatus selectedStatus = validStatuses.contains(order.status)
        ? order.status
        : OrderStatus.newOrder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Order Status #${order.orderNumber}',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Customer: ${order.customerName} • ${order.customerPhone}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 16),

                    const Text('SELECT ORDER STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<OrderStatus>(
                      initialValue: selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: OrderStatus.newOrder,
                          child: Text('🆕 New Lead (Unprocessed)', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: OrderStatus.accepted,
                          child: Text('✅ Confirmed (Send to Dispatch)', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor), overflow: TextOverflow.ellipsis),
                        ),
                        const DropdownMenuItem(
                          value: OrderStatus.contacting,
                          child: Text('📞 Contacting Client', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                        ),
                        const DropdownMenuItem(
                          value: OrderStatus.callBack,
                          child: Text('⏰ Call Back Requested', style: TextStyle(color: Colors.purple), overflow: TextOverflow.ellipsis),
                        ),
                        const DropdownMenuItem(
                          value: OrderStatus.notReachable,
                          child: Text('📵 Not Reachable (No Answer)', style: TextStyle(color: Colors.amber), overflow: TextOverflow.ellipsis),
                        ),
                        const DropdownMenuItem(
                          value: OrderStatus.onHold,
                          child: Text('⏸️ Put On Hold', style: TextStyle(color: Colors.orange), overflow: TextOverflow.ellipsis),
                        ),
                        const DropdownMenuItem(
                          value: OrderStatus.cancelled,
                          child: Text('❌ Cancelled (Client declined purchase)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text('STATUS NOTES & REASON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Client requested callback or declined due to price.',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final updated = OrderModel(
                              id: order.id,
                              orderNumber: order.orderNumber,
                              companyId: order.companyId,
                              productId: order.productId,
                              salesRepId: widget.currentUser.id,
                              customerName: order.customerName,
                              customerPhone: order.customerPhone,
                              deliveryState: order.deliveryState,
                              deliveryCity: order.deliveryCity,
                              deliveryAddress: order.deliveryAddress,
                              status: selectedStatus,
                              quantity: order.quantity,
                              basePrice: order.basePrice,
                              upsellAmount: order.upsellAmount,
                              downsellDiscount: order.downsellDiscount,
                              totalAmount: order.totalAmount,
                              upsellStatus: order.upsellStatus,
                              upsellNotes: _noteController.text.isNotEmpty ? _noteController.text : order.upsellNotes,
                              paymentStatus: order.paymentStatus,
                              createdAt: order.createdAt,
                              updatedAt: DateTime.now(),
                            );
                            widget.onUpdateOrder(updated);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: selectedStatus == OrderStatus.cancelled ? Colors.red : theme.primaryColor,
                                content: Text('Order Status updated to ${selectedStatus.label}'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedStatus == OrderStatus.cancelled ? Colors.red : theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Save Status'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusRowColor(OrderStatus status, bool isHovered, bool isDarkMode) {
    Color baseColor;
    if (isDarkMode) {
      switch (status) {
        case OrderStatus.newOrder:
          baseColor = const Color(0xFF11261D);
          break;
        case OrderStatus.accepted:
        case OrderStatus.inTransit:
        case OrderStatus.delivered:
          baseColor = const Color(0xFF0C382A);
          break;
        case OrderStatus.upsellPending:
          baseColor = const Color(0xFF2E1065);
          break;
        case OrderStatus.agentNotified:
        case OrderStatus.dispatchAssigned:
        case OrderStatus.orderAccepted:
          baseColor = const Color(0xFF0C2A38);
          break;
        case OrderStatus.callBack:
        case OrderStatus.notReady:
          baseColor = const Color(0xFF38260D);
          break;
        case OrderStatus.deliveryRescheduled:
        case OrderStatus.rescheduled:
          baseColor = const Color(0xFF2E1065);
          break;
        case OrderStatus.notPicking:
        case OrderStatus.switchedOff:
        case OrderStatus.notReachable:
          baseColor = const Color(0xFF0D2538);
          break;
        case OrderStatus.onHold:
        case OrderStatus.noProduct:
          baseColor = const Color(0xFF381F0D);
          break;
        case OrderStatus.cancelled:
        case OrderStatus.rejected:
        case OrderStatus.failedDelivery:
        case OrderStatus.returned:
        case OrderStatus.deliveredOrderCancelled:
          baseColor = const Color(0xFF380C0C);
          break;
        default:
          baseColor = const Color(0xFF132A22);
      }
      if (isHovered) {
        return Color.alphaBlend(Colors.white.withValues(alpha: 0.08), baseColor);
      }
      return baseColor;
    } else {
      switch (status) {
        case OrderStatus.newOrder:
          baseColor = AppColors.backgroundLight;
          break;
        case OrderStatus.accepted:
        case OrderStatus.inTransit:
        case OrderStatus.delivered:
          baseColor = const Color(0xFFF0FDF4);
          break;
        case OrderStatus.upsellPending:
          baseColor = const Color(0xFFF3E8FF);
          break;
        case OrderStatus.agentNotified:
        case OrderStatus.dispatchAssigned:
        case OrderStatus.orderAccepted:
          baseColor = const Color(0xFFF0F9FF);
          break;
        case OrderStatus.callBack:
        case OrderStatus.notReady:
          baseColor = const Color(0xFFFEF3C7);
          break;
        case OrderStatus.deliveryRescheduled:
        case OrderStatus.rescheduled:
          baseColor = const Color(0xFFEDE9FE);
          break;
        case OrderStatus.notPicking:
        case OrderStatus.switchedOff:
        case OrderStatus.notReachable:
          baseColor = const Color(0xFFEFF6FF);
          break;
        case OrderStatus.onHold:
        case OrderStatus.noProduct:
          baseColor = const Color(0xFFFFEDD5);
          break;
        case OrderStatus.cancelled:
        case OrderStatus.rejected:
        case OrderStatus.failedDelivery:
        case OrderStatus.returned:
        case OrderStatus.deliveredOrderCancelled:
          baseColor = const Color(0xFFFEF2F2);
          break;
        default:
          baseColor = AppColors.surfaceWhite;
      }
      if (isHovered) {
        return Color.alphaBlend(Colors.black.withValues(alpha: 0.04), baseColor);
      }
      return baseColor;
    }
  }

  Map<String, dynamic> _getStatusBadgeConfig(OrderStatus status, bool isDarkMode) {
    if (isDarkMode) {
      switch (status) {
        case OrderStatus.newOrder:
          return {'label': 'New Lead', 'bg': const Color(0xFF064E3B), 'border': const Color(0xFF10B981), 'color': const Color(0xFF34D399), 'icon': Icons.fiber_new_rounded};
        case OrderStatus.accepted:
          return {'label': 'Confirmed', 'bg': const Color(0xFF064E3B), 'border': const Color(0xFF059669), 'color': const Color(0xFF34D399), 'icon': Icons.check_circle_outline};
        case OrderStatus.upsellPending:
          return {'label': 'Upsell Pending', 'bg': const Color(0xFF4C1D95), 'border': const Color(0xFF8B5CF6), 'color': const Color(0xFFC084FC), 'icon': Icons.trending_up_rounded};
        case OrderStatus.agentNotified:
        case OrderStatus.dispatchAssigned:
          return {'label': 'Agent Notified', 'bg': const Color(0xFF0C4A6E), 'border': const Color(0xFF0284C7), 'color': const Color(0xFF38BDF8), 'icon': Icons.mark_email_unread_rounded};
        case OrderStatus.callBack:
          return {'label': 'Call Back', 'bg': const Color(0xFF78350F), 'border': const Color(0xFFD97706), 'color': const Color(0xFFFBBF24), 'icon': Icons.schedule_rounded};
        case OrderStatus.deliveryRescheduled:
        case OrderStatus.rescheduled:
          return {'label': 'Rescheduled', 'bg': const Color(0xFF4C1D95), 'border': const Color(0xFFA855F7), 'color': const Color(0xFFE9D5FF), 'icon': Icons.event_repeat_rounded};
        case OrderStatus.notPicking:
          return {'label': 'Not Picking', 'bg': const Color(0xFF1E293B), 'border': const Color(0xFF64748B), 'color': const Color(0xFFCBD5E1), 'icon': Icons.phone_missed_rounded};
        case OrderStatus.switchedOff:
          return {'label': 'Switched Off', 'bg': const Color(0xFF7C2D12), 'border': const Color(0xFFEA580C), 'color': const Color(0xFFFDBA74), 'icon': Icons.power_settings_new_rounded};
        case OrderStatus.notReachable:
          return {'label': 'Not Reachable', 'bg': const Color(0xFF1E3A8A), 'border': const Color(0xFF2563EB), 'color': const Color(0xFF60A5FA), 'icon': Icons.phone_disabled_rounded};
        case OrderStatus.notReady:
          return {'label': 'Not Ready', 'bg': const Color(0xFF78350F), 'border': const Color(0xFFB45309), 'color': const Color(0xFFFDE68A), 'icon': Icons.hourglass_empty_rounded};
        case OrderStatus.onHold:
          return {'label': 'On Hold', 'bg': const Color(0xFF7C2D12), 'border': const Color(0xFFEA580C), 'color': const Color(0xFFFB923C), 'icon': Icons.pause_circle_outline};
        case OrderStatus.cancelled:
        case OrderStatus.rejected:
          return {'label': status.label, 'bg': const Color(0xFF7F1D1D), 'border': const Color(0xFFDC2626), 'color': const Color(0xFFFCA5A5), 'icon': Icons.cancel_outlined};
        case OrderStatus.inTransit:
          return {'label': 'In Transit', 'bg': const Color(0xFF064E3B), 'border': const Color(0xFF10B981), 'color': const Color(0xFF6EE7B7), 'icon': Icons.local_shipping_outlined};
        case OrderStatus.delivered:
          return {'label': 'Delivered', 'bg': const Color(0xFF064E3B), 'border': const Color(0xFF059669), 'color': const Color(0xFF34D399), 'icon': Icons.verified_rounded};
        default:
          return {'label': status.label, 'bg': Colors.grey.shade900, 'border': Colors.grey.shade700, 'color': Colors.grey.shade300, 'icon': Icons.info_outline};
      }
    } else {
      switch (status) {
        case OrderStatus.newOrder:
          return {'label': 'New Lead', 'bg': const Color(0xFFF0FDF4), 'border': const Color(0xFF86EFAC), 'color': const Color(0xFF059669), 'icon': Icons.fiber_new_rounded};
        case OrderStatus.accepted:
          return {'label': 'Confirmed', 'bg': AppColors.statusConfirmedBg, 'border': const Color(0xFF6EE7B7), 'color': AppColors.statusConfirmed, 'icon': Icons.check_circle_outline};
        case OrderStatus.upsellPending:
          return {'label': 'Upsell Pending', 'bg': const Color(0xFFF3E8FF), 'border': const Color(0xFFD8B4FE), 'color': const Color(0xFF7E22CE), 'icon': Icons.trending_up_rounded};
        case OrderStatus.agentNotified:
        case OrderStatus.dispatchAssigned:
          return {'label': 'Agent Notified', 'bg': const Color(0xFFF0F9FF), 'border': const Color(0xFF7DD3FC), 'color': const Color(0xFF0284C7), 'icon': Icons.mark_email_unread_rounded};
        case OrderStatus.callBack:
          return {'label': 'Call Back', 'bg': AppColors.statusCallBackBg, 'border': const Color(0xFFFDE68A), 'color': AppColors.statusCallBack, 'icon': Icons.schedule_rounded};
        case OrderStatus.deliveryRescheduled:
        case OrderStatus.rescheduled:
          return {'label': 'Rescheduled', 'bg': const Color(0xFFEDE9FE), 'border': const Color(0xFFC4B5FD), 'color': const Color(0xFF6D28D9), 'icon': Icons.event_repeat_rounded};
        case OrderStatus.notPicking:
          return {'label': 'Not Picking', 'bg': const Color(0xFFF1F5F9), 'border': const Color(0xFFCBD5E1), 'color': const Color(0xFF475569), 'icon': Icons.phone_missed_rounded};
        case OrderStatus.switchedOff:
          return {'label': 'Switched Off', 'bg': const Color(0xFFFFEDD5), 'border': const Color(0xFFFDBA74), 'color': const Color(0xFFC2410C), 'icon': Icons.power_settings_new_rounded};
        case OrderStatus.notReachable:
          return {'label': 'Not Reachable', 'bg': AppColors.statusNoAnswerBg, 'border': const Color(0xFFBFDBFE), 'color': AppColors.statusNoAnswer, 'icon': Icons.phone_disabled_rounded};
        case OrderStatus.notReady:
          return {'label': 'Not Ready', 'bg': const Color(0xFFFEF3C7), 'border': const Color(0xFFFDE68A), 'color': const Color(0xFFB45309), 'icon': Icons.hourglass_empty_rounded};
        case OrderStatus.onHold:
          return {'label': 'On Hold', 'bg': AppColors.statusOnHoldBg, 'border': const Color(0xFFFDBA74), 'color': AppColors.statusOnHold, 'icon': Icons.pause_circle_outline};
        case OrderStatus.cancelled:
        case OrderStatus.rejected:
          return {'label': status.label, 'bg': AppColors.statusCancelledBg, 'border': const Color(0xFFFCA5A5), 'color': AppColors.statusCancelled, 'icon': Icons.cancel_outlined};
        case OrderStatus.inTransit:
          return {'label': 'In Transit', 'bg': const Color(0xFFECFDF5), 'border': const Color(0xFFA7F3D0), 'color': const Color(0xFF047857), 'icon': Icons.local_shipping_outlined};
        case OrderStatus.delivered:
          return {'label': 'Delivered', 'bg': const Color(0xFFDCFCE7), 'border': const Color(0xFF86EFAC), 'color': const Color(0xFF15803D), 'icon': Icons.verified_rounded};
        default:
          return {'label': status.label, 'bg': Colors.grey.shade100, 'border': Colors.grey.shade300, 'color': AppColors.textMuted, 'icon': Icons.info_outline};
      }
    }
  }

  void _openRescheduleModal(OrderModel order) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final noteController = TextEditingController();

    final recommendations = [
      {'label': '⚡ In 3 Hours', 'days': 0, 'hour': (DateTime.now().hour + 3) % 24, 'minute': 0},
      {'label': '🌅 Tomorrow 9 AM', 'days': 1, 'hour': 9, 'minute': 0},
      {'label': '🌇 Tomorrow 2 PM', 'days': 1, 'hour': 14, 'minute': 0},
      {'label': '📅 In 2 Days 10 AM', 'days': 2, 'hour': 10, 'minute': 0},
      {'label': '📆 Next Monday 10 AM', 'days': (8 - DateTime.now().weekday) % 7, 'hour': 10, 'minute': 0},
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final formattedDate = DateFormat('EEE, MMM d, yyyy').format(selectedDate);
            final formattedTime = selectedTime.format(context);

            return Dialog(
              backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669), size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Reschedule Call',
                                style: GoogleFonts.outfit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, size: 20),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.orderNumber} • ${order.customerName}',
                        style: GoogleFonts.jetBrainsMono(color: isDarkMode ? Colors.white60 : Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // Recommendations Chips
                      Text('POPULAR SCHEDULE RECOMMENDATIONS', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recommendations.map((rec) {
                          final recLabel = rec['label'] as String;
                          final recDays = rec['days'] as int;
                          final recHour = rec['hour'] as int;
                          final recMinute = rec['minute'] as int;

                          final targetDate = DateTime.now().add(Duration(days: recDays));
                          final targetTime = TimeOfDay(hour: recHour, minute: recMinute);

                          final isSelected = selectedDate.year == targetDate.year &&
                              selectedDate.month == targetDate.month &&
                              selectedDate.day == targetDate.day &&
                              selectedTime.hour == targetTime.hour;

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setDialogState(() {
                                selectedDate = targetDate;
                                selectedTime = targetTime;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFF0A2E23))
                                    : (isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : (isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFCBD5E1)),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                recLabel,
                                style: GoogleFonts.inter(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Custom Date & Time Picker Buttons
                      Text('CUSTOM DATE & TIME', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDarkMode
                                            ? const ColorScheme.dark(
                                                primary: Color(0xFF10B981),
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF0C1F17),
                                                onSurface: Colors.white,
                                              )
                                            : const ColorScheme.light(
                                                primary: Color(0xFF0A2E23),
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF0F172A),
                                              ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) setDialogState(() => selectedDate = picked);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF10B981), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: GoogleFonts.inter(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDarkMode
                                            ? const ColorScheme.dark(
                                                primary: Color(0xFF10B981),
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF0C1F17),
                                                onSurface: Colors.white,
                                              )
                                            : const ColorScheme.light(
                                                primary: Color(0xFF0A2E23),
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF0F172A),
                                              ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) setDialogState(() => selectedTime = picked);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, color: Color(0xFF10B981), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formattedTime,
                                        style: GoogleFonts.inter(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Callback Notes Field
                      TextField(
                        controller: noteController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Add note (e.g. Call after 3 PM meeting)...',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey.shade500, fontSize: 12),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final scheduledDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            final updated = OrderModel(
                              id: order.id,
                              orderNumber: order.orderNumber,
                              companyId: order.companyId,
                              productId: order.productId,
                              salesRepId: widget.currentUser.id,
                              customerName: order.customerName,
                              customerPhone: order.customerPhone,
                              deliveryState: order.deliveryState,
                              deliveryCity: order.deliveryCity,
                              deliveryAddress: order.deliveryAddress,
                              status: OrderStatus.callBack,
                              quantity: order.quantity,
                              basePrice: order.basePrice,
                              upsellAmount: order.upsellAmount,
                              downsellDiscount: order.downsellDiscount,
                              totalAmount: order.totalAmount,
                              upsellStatus: order.upsellStatus,
                              upsellNotes: order.upsellNotes,
                              paymentStatus: order.paymentStatus,
                              scheduledCallbackAt: scheduledDateTime,
                              rescheduleNote: noteController.text.isNotEmpty ? noteController.text : order.rescheduleNote,
                              createdAt: order.createdAt,
                              updatedAt: DateTime.now(),
                            );
                            widget.onUpdateOrder(updated);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF10B981),
                                content: Text('⏰ Call rescheduled for #${order.orderNumber} on $formattedDate at $formattedTime'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Confirm Reschedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCancellationReasonModal(OrderModel order) {
    CancellationReason selectedReason = CancellationReason.noMoney;
    DateTime followUpDate = DateTime.now().add(const Duration(days: 7));
    final noteController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final formattedDate = DateFormat('EEE, MMM d, yyyy').format(followUpDate);

            return Dialog(
              backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Cancel Order Reason',
                                  style: GoogleFonts.outfit(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, size: 20),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderNumber} • ${order.customerName}',
                          style: GoogleFonts.jetBrainsMono(color: isDarkMode ? Colors.white60 : Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 16),

                        // Structured Reasons List
                        Text(
                          'SELECT CANCELLATION REASON FOR FOLLOW-UP',
                          style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: CancellationReason.values.map((reason) {
                            final isSelected = selectedReason == reason;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => setDialogState(() => selectedReason = reason),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFEF4444).withValues(alpha: isDarkMode ? 0.2 : 0.12)
                                        : (isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFEF4444)
                                          : (isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(reason.emoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          reason.label,
                                          style: GoogleFonts.inter(
                                            color: isSelected
                                                ? (isDarkMode ? Colors.white : const Color(0xFF7F1D1D))
                                                : (isDarkMode ? Colors.white70 : const Color(0xFF1E293B)),
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle, color: Color(0xFFEF4444), size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Follow-up Recovery Date Picker
                        if (selectedReason == CancellationReason.noMoney ||
                            selectedReason == CancellationReason.traveling ||
                            selectedReason == CancellationReason.tooExpensive) ...[
                          Text(
                            'AUTOMATED FOLLOW-UP RECOVERY DATE',
                            style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: followUpDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 180)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: isDarkMode
                                          ? const ColorScheme.dark(
                                              primary: Color(0xFF10B981),
                                              onPrimary: Colors.white,
                                              surface: Color(0xFF0C1F17),
                                              onSurface: Colors.white,
                                            )
                                          : const ColorScheme.light(
                                              primary: Color(0xFF0A2E23),
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Color(0xFF0F172A),
                                            ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) setDialogState(() => followUpDate = picked);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_calendar_rounded, color: Color(0xFF10B981), size: 16),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Follow-up On', style: GoogleFonts.inter(color: isDarkMode ? Colors.white38 : Colors.grey.shade600, fontSize: 10)),
                                        Text(formattedDate, style: GoogleFonts.inter(color: isDarkMode ? Colors.white : const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: isDarkMode ? Colors.white38 : Colors.grey.shade400, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Notes Field
                        TextField(
                          controller: noteController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Add recovery notes (e.g. Salary enters on 25th)...',
                            hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey.shade500, fontSize: 12),
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0))),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final updated = OrderModel(
                                id: order.id,
                                orderNumber: order.orderNumber,
                                companyId: order.companyId,
                                productId: order.productId,
                                salesRepId: widget.currentUser.id,
                                customerName: order.customerName,
                                customerPhone: order.customerPhone,
                                deliveryState: order.deliveryState,
                                deliveryCity: order.deliveryCity,
                                deliveryAddress: order.deliveryAddress,
                                status: OrderStatus.cancelled,
                                quantity: order.quantity,
                                basePrice: order.basePrice,
                                upsellAmount: order.upsellAmount,
                                downsellDiscount: order.downsellDiscount,
                                totalAmount: order.totalAmount,
                                upsellStatus: order.upsellStatus,
                                upsellNotes: noteController.text.isNotEmpty ? noteController.text : order.upsellNotes,
                                cancellationReason: selectedReason,
                                cancellationFollowUpAt: followUpDate,
                                paymentStatus: order.paymentStatus,
                                createdAt: order.createdAt,
                                updatedAt: DateTime.now(),
                              );

                              widget.onUpdateOrder(updated);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFEF4444),
                                  content: Text('❌ Order #${order.orderNumber} cancelled. Reason: ${selectedReason.label}'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Confirm Cancellation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStatusMenu(OrderModel order) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      tooltip: 'Quick Actions Menu',
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDarkMode ? const Color(0xFFD97706) : const Color(0xFFFDE68A)),
        ),
        child: Icon(Icons.more_vert_rounded, size: 18, color: isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
      ),
      onSelected: (val) {
        Navigator.pop(context);
        if (val == 'status') {
          _openUpdateStatusOnlyModal(order);
        } else if (val == 'reschedule') {
          _showScheduleCallbackDialog(order);
        } else if (val == 'cancel') {
          _handleCancelOrder(order);
        } else if (val == 'sticky_routing') {
          _openInboundRoutingSimulatorModal();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'status',
          child: Row(children: [Icon(Icons.edit_note, size: 16), SizedBox(width: 8), Text('Update Status Only')]),
        ),
        const PopupMenuItem(
          value: 'reschedule',
          child: Row(children: [Icon(Icons.schedule, size: 16), SizedBox(width: 8), Text('Schedule Callback')]),
        ),
        const PopupMenuItem(
          value: 'cancel',
          child: Row(children: [Icon(Icons.cancel_outlined, size: 16, color: Colors.red), SizedBox(width: 8), Text('Quick Cancel Order', style: TextStyle(color: Colors.red))]),
        ),
        const PopupMenuItem(
          value: 'sticky_routing',
          child: Row(children: [Icon(Icons.alt_route, size: 16, color: Colors.blue), SizedBox(width: 8), Text('Test Inbound Sticky Route')]),
        ),
      ],
    );
  }

  void _openOrderDetailsModal(OrderModel order) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => MasterOrderDetailsDialog(
        order: order,
        currentUser: widget.currentUser,
        currency: widget.activeTheme.currencySymbol,
        onStartCall: () {
          Navigator.pop(context);
          _openCallActionModal(order);
        },
        onOpenTimeline: () {
          Navigator.pop(context);
          _openOrderActivitiesModal(order, isDarkMode);
        },
        quickStatusMenu: _buildQuickStatusMenu(order),
      ),
    );
  }

  void _openCallActionModal(OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => CallActionModal(
        order: order,
        activeTheme: widget.activeTheme,
        currentUser: widget.currentUser,
        noteController: _noteController,
        onUpdateOrder: widget.onUpdateOrder,
        onRecordActivity: _recordActivity,
        onOpenReschedule: _openRescheduleModal,
        onOpenCancellationReason: _openCancellationReasonModal,
        onShowRequestUpsell: _showRequestUpsellModal,
      ),
    );
  }

  void _showRequestUpsellModal(OrderModel order) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RequestUpsellDialog(
        order: order,
        activeTheme: widget.activeTheme,
      ),
    );

    if (result != null) {
      final upsellQty = (result['upsell_quantity'] as int?) ?? 0;
      final unitPrice = (result['upsell_unit_price'] as double?) ?? 0.0;
      final newTotal = (result['new_total_amount'] as double?) ?? order.totalAmount;

      // New total quantity reflects added/removed units
      final newQuantity = (order.quantity + upsellQty).clamp(1, 9999);

      final updated = OrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        companyId: order.companyId,
        productId: order.productId,
        salesRepId: widget.currentUser.id,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        deliveryState: order.deliveryState,
        deliveryCity: order.deliveryCity,
        deliveryAddress: order.deliveryAddress,
        status: OrderStatus.upsellPending,
        quantity: newQuantity,
        basePrice: order.basePrice,
        upsellAmount: (result['upsell_amount'] as double?) ?? 0.0,
        downsellDiscount: (result['downsell_discount'] as double?) ?? 0.0,
        totalAmount: newTotal,
        upsellQuantity: upsellQty,
        upsellUnitPrice: unitPrice,
        upsellStatus: UpsellStatus.pending,
        upsellNotes: result['notes'] as String?,
        paymentStatus: order.paymentStatus,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      widget.onRequestUpsell(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF8B5CF6),
            content: Text(
              '🟣 ${upsellQty > 0 ? "Up-sell" : "Down-sell"} request (${upsellQty > 0 ? "+" : ""}$upsellQty units × ${widget.activeTheme.currencySymbol}${unitPrice.toStringAsFixed(0)}) submitted for Supervisor approval!',
            ),
          ),
        );
      }
    }
  }

  void _openReassignLogisticsModal(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => ReassignLogisticsRepDialog(
        order: order,
        activeTheme: widget.activeTheme,
        onReassigned: (updatedOrder) {
          widget.onUpdateOrder(updatedOrder);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.blue, content: Text('Logistics Rep successfully reassigned!')),
          );
        },
      ),
    );
  }

  void _handleCancelOrder(OrderModel order) {
    final updated = OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      companyId: order.companyId,
      productId: order.productId,
      salesRepId: widget.currentUser.id,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      deliveryState: order.deliveryState,
      deliveryCity: order.deliveryCity,
      deliveryAddress: order.deliveryAddress,
      status: OrderStatus.cancelled,
      quantity: order.quantity,
      basePrice: order.basePrice,
      upsellAmount: 0.0,
      downsellDiscount: 0.0,
      totalAmount: order.totalAmount,
      upsellStatus: UpsellStatus.none,
      paymentStatus: order.paymentStatus,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );
    widget.onUpdateOrder(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.red, content: Text('Order marked as Cancelled.')),
    );
  }

  void _showScheduleCallbackDialog(OrderModel order) async {
    DateTime initialDate = order.scheduledCallbackAt ?? DateTime.now().add(const Duration(hours: 2));
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select Rescheduled Call Date',
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select Rescheduled Call Time',
    );

    if (pickedTime == null || !mounted) return;

    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final updated = OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      companyId: order.companyId,
      productId: order.productId,
      salesRepId: widget.currentUser.id,
      logisticsRepId: order.logisticsRepId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      deliveryState: order.deliveryState,
      deliveryCity: order.deliveryCity,
      deliveryAddress: order.deliveryAddress,
      status: OrderStatus.callBack,
      quantity: order.quantity,
      basePrice: order.basePrice,
      upsellAmount: order.upsellAmount,
      downsellDiscount: order.downsellDiscount,
      totalAmount: order.totalAmount,
      upsellStatus: order.upsellStatus,
      upsellNotes: '⏰ Rescheduled callback set for ${pickedDate.day}/${pickedDate.month}/${pickedDate.year} at ${pickedTime.format(context)}',
      paymentStatus: order.paymentStatus,
      scheduledCallbackAt: scheduledDateTime,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );

    widget.onUpdateOrder(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.purple,
        content: Text('⏰ Call Rescheduled for ${order.customerName} at ${pickedTime.format(context)}! Notification active.'),
      ),
    );
  }

  Widget _buildNotificationReminderBanner(List<OrderModel> orders) {
    final theme = widget.activeTheme;
    final dueCallbacks = orders.where((o) {
      if (o.scheduledCallbackAt == null) return false;
      final isPendingStatus = o.status == OrderStatus.callBack || o.status == OrderStatus.rescheduled || o.status == OrderStatus.notReachable;
      final isDue = o.scheduledCallbackAt!.isBefore(DateTime.now().add(const Duration(minutes: 30)));
      return isPendingStatus && isDue;
    }).toList();

    if (dueCallbacks.isEmpty) return const SizedBox.shrink();

    final firstDue = dueCallbacks.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm_on, color: theme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⏰ CALLBACK REMINDER: ${dueCallbacks.length} Rescheduled Call(s) Due!',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12),
                ),
                Text(
                  'Due client: ${firstDue.customerName} (${firstDue.customerPhone}) • State: ${firstDue.deliveryState}',
                  style: TextStyle(color: theme.primaryColor.withValues(alpha: 0.8), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openCallActionModal(firstDue),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.phone, size: 13),
            label: const Text('Call Client Now', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // TAB 1: ALL ORDERS MASTER DIRECTORY (Category & Status Filters + Activities Log + Logistics Agent)
  Widget _buildAllOrdersDirectoryTab(bool isMobile) {
    final currency = widget.activeTheme.currencySymbol;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filtered = widget.orders.where((o) {
      final q = _allOrdersSearchQuery.toLowerCase();
      final agent = _getLogisticsAgentName(o).toLowerCase();
      final matchesSearch = q.isEmpty ||
          o.orderNumber.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.customerPhone.toLowerCase().contains(q) ||
          o.deliveryState.toLowerCase().contains(q) ||
          o.productId.toLowerCase().contains(q) ||
          agent.contains(q);

      final matchesStatus = _allOrdersStatusFilter == 'All' || o.status.dbValue == _allOrdersStatusFilter;
      final matchesState = _allOrdersStateFilter == 'All' || o.deliveryState.toLowerCase() == _allOrdersStateFilter.toLowerCase();
      final matchesCategory = _allOrdersCategoryFilter == 'All' || o.productId.toLowerCase().contains(_allOrdersCategoryFilter.toLowerCase());

      final isCallRep = widget.currentUser.role == UserRole.salesCallRep;
      final matchesMyAssigned = isCallRep
          ? (o.salesRepId == widget.currentUser.id)
          : (!_showOnlyMyAssignedLeads || o.salesRepId == widget.currentUser.id);

      return matchesSearch && matchesStatus && matchesState && matchesCategory && matchesMyAssigned;
    }).toList();

    filtered.sort((a, b) {
      if (_sortOption == 'oldest') {
        return a.createdAt.compareTo(b.createdAt);
      } else if (_sortOption == 'cod_desc') {
        return b.totalAmount.compareTo(a.totalAmount);
      } else if (_sortOption == 'cod_asc') {
        return a.totalAmount.compareTo(b.totalAmount);
      } else if (_sortOption == 'customer_asc') {
        return a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
      } else if (_sortOption == 'order_asc') {
        return a.orderNumber.compareTo(b.orderNumber);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    final isCardViewMode = _userViewModePreference ?? isMobile;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 10 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Supervisee Daily Quota Progress & Commission Meter
            SuperviseeQuotaMeterCard(
              currentUser: widget.currentUser,
              myOrders: widget.orders.where((o) => o.salesRepId == widget.currentUser.id).toList(),
              activeTheme: widget.activeTheme,
              isDarkMode: isDarkMode,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),

            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_showOnlyMyAssignedLeads ? 'My Call Queue' : 'Order Directories', style: GoogleFonts.inter(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                          const SizedBox(width: 8),
                          Text('(${filtered.length} Orders)', style: GoogleFonts.inter(fontSize: isMobile ? 14 : 20, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Master order database · Pipeline stages · Logistics agents · Realtime activity log',
                          style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                // Queue Mode Segmented Toggle for Supervisory/Management Roles ("All Leads" vs "My Queue Only")
                if (widget.currentUser.role != UserRole.salesCallRep)
                  Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showOnlyMyAssignedLeads = false,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: !_showOnlyMyAssignedLeads ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                          ),
                          child: Text(
                            'All Leads',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: !_showOnlyMyAssignedLeads ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 18, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                      InkWell(
                        onTap: () => _showOnlyMyAssignedLeads = true,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _showOnlyMyAssignedLeads ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_pin_circle_rounded, size: 14, color: _showOnlyMyAssignedLeads ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                              const SizedBox(width: 4),
                              Text(
                                'My Queue Only',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _showOnlyMyAssignedLeads ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 16),

            // Search & Filter Controls Bar (Ultra-Compact Mobile 2-Row Layout)
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        // Mobile Row 1: Search Input + View Mode Switcher
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 36,
                                child: TextField(
                                  onChanged: (val) => _allOrdersSearchQuery = val,
                                  style: TextStyle(fontSize: 12.5, color: isDarkMode ? Colors.white : Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Search order #, customer, phone...',
                                    hintStyle: TextStyle(fontSize: 11.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                    prefixIcon: Icon(Icons.search, size: 15, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                    filled: true,
                                    isDense: true,
                                    fillColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23))),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Layout View Mode Switcher (Cards | Table)
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _userViewModePreference = true,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                      ),
                                      child: Icon(Icons.grid_view_rounded, size: 15, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                    ),
                                  ),
                                  Container(width: 1, height: 18, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                                  InkWell(
                                    onTap: () => _userViewModePreference = false,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: !isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                      ),
                                      child: Icon(Icons.table_chart_rounded, size: 15, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Mobile Row 2: Horizontal Scrolling Filter Chips & Sort
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildCompactDropdownFilter(_allOrdersStatusFilter, (val) {
                                if (val != null) _allOrdersStatusFilter = val;
                              }, const [
                                DropdownMenuItem(value: 'All', child: Text('All Stages')),
                                DropdownMenuItem(value: 'new', child: Text('🌱 New Lead')),
                                DropdownMenuItem(value: 'accepted', child: Text('✅ Confirmed')),
                                DropdownMenuItem(value: 'upsell_pending', child: Text('🟣 Upsell')),
                                DropdownMenuItem(value: 'agent_notified', child: Text('🔵 Agent Notified')),
                                DropdownMenuItem(value: 'call_back', child: Text('⏰ Call Back')),
                                DropdownMenuItem(value: 'delivery_rescheduled', child: Text('📅 Rescheduled')),
                                DropdownMenuItem(value: 'not_picking', child: Text('📴 Not Picking')),
                                DropdownMenuItem(value: 'in_transit', child: Text('🚚 In Transit')),
                                DropdownMenuItem(value: 'delivered', child: Text('🎉 Delivered')),
                                DropdownMenuItem(value: 'cancelled', child: Text('❌ Cancelled')),
                              ], isDarkMode),
                              const SizedBox(width: 6),
                              _buildCompactDropdownFilter(_allOrdersStateFilter, (val) {
                                if (val != null) _allOrdersStateFilter = val;
                              }, const [
                                DropdownMenuItem(value: 'All', child: Text('All States')),
                                DropdownMenuItem(value: 'Lagos', child: Text('Lagos')),
                                DropdownMenuItem(value: 'Abuja', child: Text('Abuja')),
                                DropdownMenuItem(value: 'Rivers', child: Text('Rivers')),
                                DropdownMenuItem(value: 'Kano', child: Text('Kano')),
                                DropdownMenuItem(value: 'Oyo', child: Text('Oyo')),
                              ], isDarkMode),
                              const SizedBox(width: 6),
                              _buildCompactDropdownFilter(_allOrdersCategoryFilter, (val) {
                                if (val != null) _allOrdersCategoryFilter = val;
                              }, const [
                                DropdownMenuItem(value: 'All', child: Text('All Products')),
                                DropdownMenuItem(value: 'Tea', child: Text('🍵 Tea')),
                                DropdownMenuItem(value: 'Booster', child: Text('⚡ Booster')),
                                DropdownMenuItem(value: 'Skin', child: Text('✨ Skin Care')),
                              ], isDarkMode),
                              const SizedBox(width: 6),
                              _buildCompactDropdownFilter(_sortOption, (val) {
                                if (val != null) _sortOption = val;
                              }, const [
                                DropdownMenuItem(value: 'newest', child: Text('📅 Newest')),
                                DropdownMenuItem(value: 'oldest', child: Text('⏳ Oldest')),
                                DropdownMenuItem(value: 'cod_desc', child: Text('💰 High COD')),
                                DropdownMenuItem(value: 'cod_asc', child: Text('💵 Low COD')),
                                DropdownMenuItem(value: 'customer_asc', child: Text('👤 Name A-Z')),
                                DropdownMenuItem(value: 'order_asc', child: Text('📦 Order #')),
                              ], isDarkMode, isSort: true),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          child: TextField(
                            onChanged: (val) => _allOrdersSearchQuery = val,
                            style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Search order #, customer, phone, driver...',
                              hintStyle: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                              prefixIcon: Icon(Icons.search, size: 16, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23))),
                            ),
                          ),
                        ),
                        _buildCompactDropdownFilter(_allOrdersStatusFilter, (val) {
                          if (val != null) _allOrdersStatusFilter = val;
                        }, const [
                          DropdownMenuItem(value: 'All', child: Text('All Pipeline Stages')),
                          DropdownMenuItem(value: 'new', child: Text('🌱 New Lead')),
                          DropdownMenuItem(value: 'accepted', child: Text('✅ Confirmed')),
                          DropdownMenuItem(value: 'upsell_pending', child: Text('🟣 Upsell Pending')),
                          DropdownMenuItem(value: 'agent_notified', child: Text('🔵 Agent Notified')),
                          DropdownMenuItem(value: 'call_back', child: Text('⏰ Call Back Requested')),
                          DropdownMenuItem(value: 'delivery_rescheduled', child: Text('📅 Delivery Rescheduled')),
                          DropdownMenuItem(value: 'not_picking', child: Text('📴 Not Picking')),
                          DropdownMenuItem(value: 'in_transit', child: Text('🚚 Delivery In Progress')),
                          DropdownMenuItem(value: 'delivered', child: Text('🎉 Delivered')),
                          DropdownMenuItem(value: 'cancelled', child: Text('❌ Cancelled')),
                        ], isDarkMode),
                        _buildCompactDropdownFilter(_allOrdersStateFilter, (val) {
                          if (val != null) _allOrdersStateFilter = val;
                        }, const [
                          DropdownMenuItem(value: 'All', child: Text('All States')),
                          DropdownMenuItem(value: 'Lagos', child: Text('Lagos State')),
                          DropdownMenuItem(value: 'Abuja', child: Text('Abuja FCT')),
                          DropdownMenuItem(value: 'Rivers', child: Text('Rivers State')),
                          DropdownMenuItem(value: 'Kano', child: Text('Kano State')),
                          DropdownMenuItem(value: 'Oyo', child: Text('Oyo State')),
                        ], isDarkMode),
                        _buildCompactDropdownFilter(_allOrdersCategoryFilter, (val) {
                          if (val != null) _allOrdersCategoryFilter = val;
                        }, const [
                          DropdownMenuItem(value: 'All', child: Text('All Products')),
                          DropdownMenuItem(value: 'Tea', child: Text('🍵 Grazer Herbal Tea')),
                          DropdownMenuItem(value: 'Booster', child: Text('⚡ Vitality Booster')),
                          DropdownMenuItem(value: 'Skin', child: Text('✨ Clear Skin Care')),
                        ], isDarkMode),
                        _buildCompactDropdownFilter(_sortOption, (val) {
                          if (val != null) _sortOption = val;
                        }, const [
                          DropdownMenuItem(value: 'newest', child: Text('📅 Newest First')),
                          DropdownMenuItem(value: 'oldest', child: Text('⏳ Oldest First')),
                          DropdownMenuItem(value: 'cod_desc', child: Text('💰 Highest COD')),
                          DropdownMenuItem(value: 'cod_asc', child: Text('💵 Lowest COD')),
                          DropdownMenuItem(value: 'customer_asc', child: Text('👤 Customer (A-Z)')),
                          DropdownMenuItem(value: 'order_asc', child: Text('📦 Order # (Asc)')),
                        ], isDarkMode, isSort: true),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _userViewModePreference = true,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.grid_view_rounded, size: 15, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                      const SizedBox(width: 4),
                                      Text('Cards', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 20, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              InkWell(
                                onTap: () => _userViewModePreference = false,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: !isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.table_chart_rounded, size: 15, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)) : (isDarkMode ? Colors.white38 : Colors.grey)),
                                      const SizedBox(width: 4),
                                      Text('Table', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isCardViewMode ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDarkMode ? Colors.white38 : Colors.grey))),
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
            const SizedBox(height: 16),

            // Orders Data Table / Cards Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                ),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('No matching orders found in directory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDarkMode ? Colors.white70 : Colors.grey)),
                              Text('Try adjusting your search query or pipeline status filter.', style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      )
                    : isCardViewMode
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                _buildResponsiveDirectoryCardsList(filtered, widget.activeTheme, isDarkMode, isMobile),
                                const SizedBox(height: 120),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            dataRowMinHeight: 68,
                                            dataRowMaxHeight: 78,
                                            columnSpacing: isMobile ? 12 : 20,
                                            headingRowColor: WidgetStateProperty.all(isDarkMode ? const Color(0xFF0C1F17) : Colors.transparent),
                                            dividerThickness: 1.0,
                                            border: TableBorder(
                                              horizontalInside: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200, width: 1),
                                            ),
                                            columns: [
                                              DataColumn(label: Text('ORDER # & DATE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                              DataColumn(label: Text('CUSTOMER & LOCATION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                              DataColumn(label: Text('PRODUCT, QTY & PRICE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                              DataColumn(label: Text('CURRENT STAGE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                              DataColumn(label: Text('LOGISTICS AGENT / DRIVER', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                              DataColumn(label: Text('ACTIVITIES & ACTIONS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8))),
                                            ],
                                            rows: filtered.map((o) {
                                              final productName = o.productId.contains('tea')
                                                  ? 'Grazer Herbal Tea'
                                                  : (o.productId.contains('booster') ? 'Vitality Booster' : 'Clear Skin Care');

                                              final nameParts = o.customerName.trim().split(' ');
                                              final initials = nameParts.length >= 2
                                                  ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                                                  : (o.customerName.isNotEmpty ? o.customerName.substring(0, 2).toUpperCase() : 'CU');

                                              final statusBadge = _getStatusBadgeConfig(o.status, isDarkMode);
                                              final statusDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(o.updatedAt);
                                              final logisticsAgent = _getLogisticsAgentName(o);

                                              return DataRow(
                                                color: WidgetStateProperty.resolveWith<Color?>((states) {
                                                  return _getStatusRowColor(o.status, states.contains(WidgetState.hovered), isDarkMode);
                                                }),
                                                cells: [
                                                  // 1. ORDER # & DATE
                                                  DataCell(
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                          decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                                          child: Text('#${o.orderNumber}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32), fontSize: 11)),
                                                        ),
                                                        const SizedBox(height: 3),
                                                        Text(statusDateStr, style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                                      ],
                                                    ),
                                                  ),

                                                  // 2. CUSTOMER & LOCATION
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor: isDarkMode ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                                                          child: Text(initials, style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 11)),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        SizedBox(
                                                          width: 170,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(o.customerName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis, maxLines: 1),
                                                              Text(o.customerPhone, style: GoogleFonts.jetBrainsMono(color: isDarkMode ? const Color(0xFF10B981) : widget.activeTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1),
                                                              Text('${o.deliveryState} - ${o.deliveryAddress}', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // 3. PRODUCT, QTY & PRICE
                                                  DataCell(
                                                    SizedBox(
                                                      width: 180,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(productName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis, maxLines: 1),
                                                          Text('Qty: ${o.quantity} × $currency${o.basePrice.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                                          Text('COD: $currency${o.totalAmount}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 11.5, color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669))),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  // 4. CURRENT STAGE
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: statusBadge['bg'] as Color,
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: statusBadge['border'] as Color, width: 1),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(statusBadge['icon'] as IconData, size: 12, color: statusBadge['color'] as Color),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            statusBadge['label'] as String,
                                                            style: TextStyle(color: statusBadge['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  // 5. LOGISTICS AGENT / DRIVER
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF0284C7)),
                                                        const SizedBox(width: 6),
                                                        SizedBox(
                                                          width: 140,
                                                          child: Text(
                                                            logisticsAgent,
                                                            style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : const Color(0xFF0F172A)),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // 6. ACTIVITIES & ACTIONS
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        OutlinedButton.icon(
                                                          onPressed: () => _openOrderActivitiesModal(o, isDarkMode),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                                            side: BorderSide(color: isDarkMode ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC)),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                            visualDensity: VisualDensity.compact,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                          ),
                                                          icon: const Icon(Icons.history_toggle_off_rounded, size: 12),
                                                          label: const Text('Activities', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        ElevatedButton.icon(
                                                          onPressed: () => _openCallActionModal(o),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                                                            foregroundColor: Colors.white,
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                            visualDensity: VisualDensity.compact,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                          ),
                                                          icon: const Icon(Icons.phone, size: 12),
                                                          label: const Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        _buildQuickStatusMenu(o),
                                                        IconButton(
                                                          icon: const Icon(Icons.visibility_outlined, size: 16),
                                                          onPressed: () => _openOrderMasterDetailsModal(o),
                                                          tooltip: 'View Full Order Details',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Table Footer Row
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Showing ${filtered.length} of ${widget.orders.length} total orders in database',
                                      style: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.sync_rounded, size: 12, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Realtime Sync Active',
                                          style: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF34D399) : Colors.green.shade700, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildCompactDropdownFilter<T>(
    T value,
    ValueChanged<T?> onChanged,
    List<DropdownMenuItem<T>> items,
    bool isDarkMode, {
    bool isSort = false,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
          icon: Icon(isSort ? Icons.swap_vert_rounded : Icons.keyboard_arrow_down, size: 14, color: isDarkMode ? const Color(0xFF10B981) : Colors.grey.shade700),
          style: TextStyle(fontSize: 11.5, color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper method to get the Logistics Agent handling the order
  String _getLogisticsAgentName(OrderModel order) {
    final state = order.deliveryState.toLowerCase();
    if (state.contains('lagos')) {
      return 'Tunde Bakare (Ext 402)';
    } else if (state.contains('abuja')) {
      return 'Musa Ibrahim (Ext 205)';
    } else if (state.contains('rivers') || state.contains('port')) {
      return 'Chidi Nnamdi (Ext 309)';
    } else if (state.contains('kano')) {
      return 'Usman Bello (Ext 501)';
    } else if (state.contains('oyo') || state.contains('ibadan')) {
      return 'Bayo Adeyemi (Ext 114)';
    }
    return 'Kefas Danjuma (Ext 108)';
  }

  Widget _buildAllOrdersDirectoryCard(OrderModel order, bool isDarkMode) {
    return AllOrdersDirectoryCard(
      order: order,
      theme: widget.activeTheme,
      isDarkMode: isDarkMode,
      onOpenActivities: () => _openOrderActivitiesModal(order, isDarkMode),
      onStartCall: () => _openCallActionModal(order),
      onOpenDetails: () => _openOrderDetailsModal(order),
      quickStatusMenu: _buildQuickStatusMenu(order),
    );
  }

  void _openOrderActivitiesModal(OrderModel order, bool isDarkMode) {
    OmnichannelUnifiedChatSheet.show(
      context,
      order: order,
      currentUser: widget.currentUser,
      activeTheme: widget.activeTheme,
      isDarkMode: isDarkMode,
    );
  }

  // TAB 2: CONFIRMED ORDERS LOG
  Widget _buildConfirmedOrdersTab(bool isMobile) {
    final confirmed = widget.orders.where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.delivered).toList();
    final currency = widget.activeTheme.currencySymbol;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirmed Orders Log (${confirmed.length})', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('All orders confirmed by Call Reps & assigned to logistics hubs.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Delivery State & Address', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total COD Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Assigned Logistics Rep', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Upsell Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: confirmed.map((o) {
                    return DataRow(cells: [
                      DataCell(Text('#${o.orderNumber}', style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
                      DataCell(Text(o.customerName, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${o.deliveryState} • ${o.deliveryAddress}', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('$currency ${o.totalAmount}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            o.logisticsRepId != null ? 'Rep ID: ${o.logisticsRepId}' : 'Auto-Assigned (${o.deliveryState})',
                            style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: o.upsellStatus == UpsellStatus.approved ? Colors.green.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            o.upsellStatus.label,
                            style: TextStyle(
                              color: o.upsellStatus == UpsellStatus.approved ? Colors.green.shade800 : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Text(o.status.label, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      DataCell(
                        OutlinedButton.icon(
                          onPressed: () => _openReassignLogisticsModal(o),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                          icon: const Icon(Icons.swap_horiz, size: 14),
                          label: const Text('Reassign Rep', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: UPSELL APPROVALS HUB
  Widget _buildUpsellApprovalsTab(bool isMobile) {
    final upsellOrders = widget.orders.where((o) => o.upsellStatus != UpsellStatus.none).toList();
    final currency = widget.activeTheme.currencySymbol;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Up-sell & Discount Approvals Hub', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('Track supervisor authorization statuses for special client add-on packages.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: upsellOrders.length,
              itemBuilder: (context, index) {
                final o = upsellOrders[index];
                final isApproved = o.upsellStatus == UpsellStatus.approved;
                final isPending = o.upsellStatus == UpsellStatus.pending;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Text('Order #${o.orderNumber} - ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isApproved ? Colors.green.shade50 : (isPending ? Colors.purple.shade50 : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                o.upsellStatus.label,
                                style: TextStyle(
                                  color: isApproved ? Colors.green.shade800 : (isPending ? Colors.purple.shade800 : Colors.red.shade800),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text('Base Price: $currency ${o.basePrice}', style: const TextStyle(fontSize: 13)),
                            Text('Requested Add-on: + $currency ${o.upsellAmount}', style: const TextStyle(fontSize: 13, color: Colors.purple, fontWeight: FontWeight.w600)),
                            Text('Total: $currency ${o.totalAmount}', style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (o.upsellNotes != null) ...[
                          const SizedBox(height: 6),
                          Text('Rep Note: ${o.upsellNotes}', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)),
                        ],
                      ],
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

  // TAB 3: REP PERFORMANCE & DASHBOARD OVERVIEW
  Widget _buildPerformanceMetricsTab(bool isMobile) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CallRepDashboardOverview(
      currentUser: widget.currentUser,
      myOrders: widget.orders.where((o) => o.salesRepId == widget.currentUser.id).toList(),
      activeTheme: widget.activeTheme,
      isDarkMode: isDarkMode,
      isMobile: isMobile,
      onStartCall: (order) => _openCallActionModal(order),
      onOpenFullQueue: () {
        _activeSubTab = 0;
      },
    );
  }

  void _handleCreateCallScript() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateCallScriptDialog(activeTheme: widget.activeTheme),
    );

    if (result != null) {
      _customCallScriptsNotifier.value = [result, ..._customCallScriptsNotifier.value];

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.activeTheme.primaryColor,
          content: Text('Call Script "${result['objection']}" created and attached to ${result['product']}!'),
        ),
      );
    }
  }

  void _openReassignOrderDialog(OrderModel order) {
    String? selectedRepId;
    final availableReps = [
      {'id': 'rep_001', 'name': 'Tunde Bakare (Ext 402)', 'squad': 'Lagos Squad Alpha'},
      {'id': 'rep_002', 'name': 'Musa Ibrahim (Ext 205)', 'squad': 'Abuja Squad Beta'},
      {'id': 'rep_003', 'name': 'Chidi Nnamdi (Ext 309)', 'squad': 'Rivers Squad Gamma'},
      {'id': 'rep_004', 'name': 'Usman Bello (Ext 501)', 'squad': 'Kano Squad Delta'},
      {'id': 'rep_005', 'name': 'Bayo Adeyemi (Ext 114)', 'squad': 'Oyo Squad Epsilon'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text('Reassign Order #${order.orderNumber}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the new Sales Call Rep to take ownership of this lead. The order will immediately transfer to the new Rep\'s queue.',
                    style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRepId,
                    dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Select New Call Rep',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50,
                    ),
                    items: availableReps.map((r) {
                      return DropdownMenuItem<String>(
                        value: r['id'],
                        child: Text('${r['name']} — ${r['squad']}', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedRepId = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedRepId != null
                      ? () {
                          final chosenRep = availableReps.firstWhere((r) => r['id'] == selectedRepId);
                          final chosenName = chosenRep['name']!;

                          final updated = OrderModel(
                            id: order.id,
                            orderNumber: order.orderNumber,
                            companyId: order.companyId,
                            productId: order.productId,
                            salesRepId: selectedRepId,
                            logisticsRepId: order.logisticsRepId,
                            deliveryAgentId: order.deliveryAgentId,
                            warehouseId: order.warehouseId,
                            customerName: order.customerName,
                            customerPhone: order.customerPhone,
                            customerAltPhone: order.customerAltPhone,
                            deliveryState: order.deliveryState,
                            deliveryCity: order.deliveryCity,
                            deliveryAddress: order.deliveryAddress,
                            status: OrderStatus.assignedToRep,
                            quantity: order.quantity,
                            basePrice: order.basePrice,
                            upsellAmount: order.upsellAmount,
                            downsellDiscount: order.downsellDiscount,
                            totalAmount: order.totalAmount,
                            upsellQuantity: order.upsellQuantity,
                            upsellUnitPrice: order.upsellUnitPrice,
                            upsellStatus: order.upsellStatus,
                            upsellNotes: order.upsellNotes,
                            paymentStatus: order.paymentStatus,
                            createdAt: order.createdAt,
                            updatedAt: DateTime.now(),
                          );

                          widget.onUpdateOrder(updated);

                          _recordActivity(
                            order: updated,
                            activityType: 'reassigned',
                            title: 'Order Reassigned to $chosenName',
                            details: 'Order transferred to $chosenName by ${widget.currentUser.fullName}.',
                            newStatus: OrderStatus.assignedToRep.dbValue,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                              content: Text('Order #${order.orderNumber} successfully reassigned to $chosenName!'),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Reassignment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openOrderMasterDetailsModal(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => MasterOrderDetailsDialog(
        order: order,
        currentUser: widget.currentUser,
        currency: widget.activeTheme.currencySymbol,
        onStartCall: () {
          Navigator.pop(context);
          _openCallActionModal(order);
        },
        onOpenTimeline: () {
          Navigator.pop(context);
          _openOrderActivitiesModal(order, Theme.of(context).brightness == Brightness.dark);
        },
        onReassignOrder: () {
          Navigator.pop(context);
          _openReassignOrderDialog(order);
        },
        quickStatusMenu: _buildQuickStatusMenu(order),
      ),
    );
  }

  // TAB 4: CALL SCRIPTS & OBJECTION HANDLING ASSISTANT
  Widget _buildCallScriptsTab(bool isMobile) {
    final filteredScripts = _customCallScripts.where((item) {
      final p = item['product'] as String;
      return _selectedScriptProductFilter == 'All Assigned Products' ||
          p == 'All Assigned Products' ||
          p == _selectedScriptProductFilter;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Call Scripts & Objections', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Product-attached playbooks for closing sales & handling doubts.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _handleCreateCallScript,
                      style: ElevatedButton.styleFrom(backgroundColor: widget.activeTheme.primaryColor, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Call Script'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Call Scripts & Objection Handling Playbooks', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Attach custom closing scripts and objection responses directly to your assigned products.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleCreateCallScript,
                      style: ElevatedButton.styleFrom(backgroundColor: widget.activeTheme.primaryColor, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create Product Call Script'),
                    ),
                  ],
                ),
          const SizedBox(height: 16),

          // Filter by Product Bar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Filter by Product:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedScriptProductFilter,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'All Assigned Products', child: Text('All Assigned Products')),
                          DropdownMenuItem(value: 'Grazer Herbal Detox Tea', child: Text('Grazer Herbal Detox Tea')),
                          DropdownMenuItem(value: 'Herbal Vitality Booster', child: Text('Herbal Vitality Booster')),
                          DropdownMenuItem(value: 'Clear Skin Herbal Care', child: Text('Clear Skin Herbal Care')),
                        ],
                        onChanged: (val) {
                          if (val != null) _selectedScriptProductFilter = val;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (filteredScripts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.style_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No call scripts found for this product filter.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            ...filteredScripts.map((item) {
              final color = item['color'] as Color;
              final product = item['product'] as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item['objection'] as String, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: Text(item['badge'] as String, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Product Attachment Badge
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Attached Product: $product',
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: Text(item['script'] as String, style: const TextStyle(fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // TAB 6: TEAM ORGANOGRAM & HIERARCHY OVERSIGHT
  Widget _buildOrganogramConsoleTab(bool isMobile) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currency = widget.activeTheme.currencySymbol;
    final theme = widget.activeTheme;

    // Calculate aggregated department metrics
    int totalCalls = 0;
    int totalConfirmed = 0;
    double totalCod = 0;
    int submittedReports = 0;
    int totalReps = 0;

    for (var ahod in _ahodTeams) {
      final sups = ahod['supervisors'] as List;
      for (var sup in sups) {
        final reps = sup['supervisees'] as List;
        for (var rep in reps) {
          totalReps++;
          totalCalls += (rep['totalCalls'] as int);
          totalConfirmed += (rep['confirmedOrders'] as int);
          totalCod += (rep['totalCod'] as double);
          if (rep['reportSubmitted'] == true) submittedReports++;
        }
      }
    }

    final avgConversion = totalCalls > 0 ? ((totalConfirmed / totalCalls) * 100).toStringAsFixed(1) : '0.0';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Role Simulation Switcher & WhatsApp Report Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree_rounded, color: theme.primaryColor, size: isMobile ? 22 : 26),
                        const SizedBox(width: 8),
                        Text(
                          'Team Organogram & Hierarchy',
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Multi-tier sales department command: HOD ➔ AHOD ➔ Supervisor ➔ Supervisee',
                      style: GoogleFonts.inter(
                        color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Automated CRM Daily Console',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Role Simulation Bar (Demo Filter)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, size: 16, color: isDarkMode ? const Color(0xFF34D399) : theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Hierarchy View Level:',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRolePill(UserRole.hod, '🏛️ HOD View (Full Dept)', isDarkMode),
                        const SizedBox(width: 6),
                        _buildRolePill(UserRole.assistantHod, '🏢 AHOD View (Divisions)', isDarkMode),
                        const SizedBox(width: 6),
                        _buildRolePill(UserRole.supervisor, '👨‍💼 Supervisor View (Supervisees Table)', isDarkMode),
                        const SizedBox(width: 6),
                        _buildRolePill(UserRole.salesCallRep, '👤 Supervisee View (My Daily CRM Table)', isDarkMode),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Department Overview Stat Cards
          Row(
            children: [
              Expanded(child: _buildOrganogramStatCard('Total COD Revenue', '$currency ${(totalCod / 1000).toStringAsFixed(0)}k', 'Across all divisions', Icons.payments_rounded, const Color(0xFF10B981), isDarkMode)),
              const SizedBox(width: 10),
              Expanded(child: _buildOrganogramStatCard('Confirmed Orders', '$totalConfirmed', '$totalCalls total calls', Icons.check_circle_rounded, const Color(0xFF3B82F6), isDarkMode)),
              if (!isMobile) ...[
                const SizedBox(width: 10),
                Expanded(child: _buildOrganogramStatCard('Avg Conversion', '$avgConversion%', 'Target: 25%+', Icons.trending_up_rounded, const Color(0xFFF59E0B), isDarkMode)),
                const SizedBox(width: 10),
                Expanded(child: _buildOrganogramStatCard('WhatsApp Reports', '$submittedReports / $totalReps', 'Submitted today', Icons.mark_chat_read_rounded, const Color(0xFF25D366), isDarkMode)),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Organogram Tree Accordion / Drilldown List
          if (_simulatedRole == UserRole.salesCallRep)
            _buildRepPersonalDashboard(isDarkMode, currency)
          else
            ..._ahodTeams.map((ahod) {
              return _buildAhodNodeCard(ahod, isDarkMode, currency);
            }),
        ],
      ),
    );
  }

  Widget _buildRolePill(UserRole role, String label, bool isDarkMode) {
    final isSelected = _simulatedRole == role;
    return InkWell(
      onTap: () => _simulatedRole = role,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.activeTheme.primaryColor
              : (isDarkMode ? const Color(0xFF0E2419) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : (isDarkMode ? const Color(0xFF94A3B8) : Colors.black87),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganogramStatCard(String title, String value, String subtitle, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
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
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAhodNodeCard(Map<String, dynamic> ahod, bool isDarkMode, String currency) {
    final supervisors = ahod['supervisors'] as List;
    double ahodCod = 0;
    int ahodConfirmed = 0;

    for (var sup in supervisors) {
      final reps = sup['supervisees'] as List;
      for (var rep in reps) {
        ahodCod += (rep['totalCod'] as double);
        ahodConfirmed += (rep['confirmedOrders'] as int);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.corporate_fare_rounded, color: Color(0xFF10B981), size: 20),
        ),
        title: Text(
          ahod['name'] as String,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
        ),
        subtitle: Text(
          '${ahod['title']} • ${supervisors.length} Supervisors • $ahodConfirmed Confirmed Orders',
          style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Text(
            '$currency ${(ahodCod / 1000).toStringAsFixed(0)}k COD',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: const Color(0xFF10B981), fontSize: 12),
          ),
        ),
        children: supervisors.map((sup) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: _buildSupervisorNodeCard(sup, isDarkMode, currency),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSupervisorNodeCard(Map<String, dynamic> sup, bool isDarkMode, String currency) {
    final reps = sup['supervisees'] as List;
    double supCod = 0;
    int supCalls = 0;
    int supConfirmed = 0;
    int supSubmitted = 0;

    for (var r in reps) {
      supCod += (r['totalCod'] as double);
      supCalls += (r['totalCalls'] as int);
      supConfirmed += (r['confirmedOrders'] as int);
      if (r['reportSubmitted'] == true) supSubmitted++;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.supervisor_account_rounded, color: Color(0xFF3B82F6), size: 18),
        ),
        title: Text(
          sup['name'] as String,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
        ),
        subtitle: Text(
          '${sup['title']} • ${reps.length} Call Reps • $supConfirmed Confirmed ($supCalls Calls) • $supSubmitted/${reps.length} Reports In',
          style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
        ),
        trailing: Text(
          '$currency ${(supCod / 1000).toStringAsFixed(0)}k',
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6), fontSize: 12),
        ),
        children: [
          // Live Pending Upsell Approval Alert Banner for Supervisor
          if (sup['id'] == 'sup-1')
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF8B5CF6), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🟣 LIVE UPSELL REQUEST • Rep Folake Adeleke',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF8B5CF6)),
                        ),
                        Text(
                          '+1x Extra Grazer Herbal Tea (+₦15,000) • New Total COD: $currency 555,000',
                          style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFFE9D5FF) : const Color(0xFF581C87), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.red, content: Text('❌ Upsell request declined.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('✅ Upsell request APPROVED! Order updated in database.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ...reps.map((rep) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              child: _buildSuperviseeRepCard(rep, isDarkMode, currency),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuperviseeRepCard(Map<String, dynamic> rep, bool isDarkMode, String currency) {
    final products = rep['products'] as String? ?? 'GRAZER HERBAL DETOX & SHAMPOO BUNDLE';
    final totalAssigned = rep['totalAssigned'] as int? ?? 35;
    final confirmed = rep['confirmedOrders'] as int? ?? 21;
    final delivered = rep['delivered'] as int? ?? 17;
    final untaggedOnCrm = rep['untaggedOnCrm'] as int? ?? 6;
    final rescheduled = rep['rescheduled'] as int? ?? 7;
    final inProgress = rep['inProgress'] as int? ?? 6;
    final switchedOff = rep['switchedOff'] as int? ?? 2;
    final notPicking = rep['notPicking'] as int? ?? 4;
    final cancelled = rep['cancelled'] as int? ?? 0;
    final notReady = rep['notReady'] as int? ?? 1;
    final deliveredToday = rep['deliveredToday'] as int? ?? 15;
    final deliveredPrev = rep['deliveredPreviousDays'] as int? ?? 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Rep Info & Total Assigned Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.activeTheme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      (rep['name'] as String).substring(0, 1).toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: widget.activeTheme.primaryColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rep['name'] as String,
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            rep['extension'] as String,
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📦 Products: $products',
                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF86EFAC)),
                ),
                child: Text(
                  '$totalAssigned Total Assigned',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF15803D), fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Breakdown Status Chips (Exact Supervisee Table Breakdown)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDailyMetricBadge('✅ $confirmed Confirmed', const Color(0xFF10B981), isDarkMode),
              _buildDailyMetricBadge('🚚 $delivered Delivered ($untaggedOnCrm untagged on CRM)', const Color(0xFF059669), isDarkMode),
              _buildDailyMetricBadge('⏰ $rescheduled Rescheduled', const Color(0xFF8B5CF6), isDarkMode),
              _buildDailyMetricBadge('🔄 $inProgress In Progress', const Color(0xFF3B82F6), isDarkMode),
              _buildDailyMetricBadge('📴 $switchedOff Switched Off', const Color(0xFFF97316), isDarkMode),
              _buildDailyMetricBadge('📵 $notPicking Not Picking', const Color(0xFF64748B), isDarkMode),
              _buildDailyMetricBadge('❌ $cancelled Cancelled', const Color(0xFFEF4444), isDarkMode),
              _buildDailyMetricBadge('⏸️ $notReady Not Ready', const Color(0xFFF59E0B), isDarkMode),
            ],
          ),
          const SizedBox(height: 10),

          // Delivery Sourcing Footer Line
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📦 $deliveredToday delivered from today\'s assigned, $deliveredPrev from previous days',
                  style: GoogleFonts.inter(fontSize: 10.5, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                Text(
                  '*Total delivered: $delivered*',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF065F46)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMetricBadge(String label, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRepPersonalDashboard(bool isDarkMode, String currency) {
    final myRepData = {
      'name': widget.currentUser.fullName,
      'extension': 'Ext 102',
      'products': 'GRAZER HERBAL DETOX & SHAMPOO BUNDLE',
      'totalAssigned': 35,
      'confirmedOrders': 21,
      'delivered': 17,
      'untaggedOnCrm': 6,
      'rescheduled': 7,
      'inProgress': 6,
      'switchedOff': 2,
      'notPicking': 4,
      'cancelled': 0,
      'notReady': 1,
      'deliveredToday': 15,
      'deliveredPreviousDays': 2,
      'totalCalls': 45,
      'totalCod': 540000.0,
      'upsellAmount': 85000.0,
      'conversionRate': 26.7,
    };

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY DAILY AUTOMATED CRM BREAKDOWN TABLE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981), letterSpacing: 0.8),
            ),
            Text(
              'Date: $dateStr',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildSuperviseeRepCard(myRepData, isDarkMode, currency),
      ],
    );
  }
}

class _RescheduledCountdownCard extends StatefulWidget {
  final DateTime scheduledCallbackAt;
  final bool isDarkMode;

  const _RescheduledCountdownCard({
    required this.scheduledCallbackAt,
    required this.isDarkMode,
  });

  @override
  State<_RescheduledCountdownCard> createState() => _RescheduledCountdownCardState();
}

class _RescheduledCountdownCardState extends State<_RescheduledCountdownCard> {
  Timer? _timer;
  late final ValueNotifier<Duration> _remainingNotifier;

  @override
  void initState() {
    super.initState();
    _remainingNotifier = ValueNotifier<Duration>(widget.scheduledCallbackAt.difference(DateTime.now()));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _remainingNotifier.value = widget.scheduledCallbackAt.difference(DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _remainingNotifier,
      builder: (context, remainingVal, _) {
        final isOverdue = remainingVal.isNegative;
        final absRemaining = remainingVal.abs();

        final hours = absRemaining.inHours;
        final minutes = absRemaining.inMinutes.remainder(60);
        final seconds = absRemaining.inSeconds.remainder(60);
        final days = absRemaining.inDays;

    String countdownStr;
    if (days > 0) {
      countdownStr = '${days}d ${hours.remainder(24)}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      countdownStr = '${hours}h ${minutes}m ${seconds}s';
    } else {
      countdownStr = '${minutes}m ${seconds}s';
    }

    final formattedDate = DateFormat('EEE, MMM d, yyyy @ h:mm a').format(widget.scheduledCallbackAt);

    final cardBg = isOverdue
        ? (widget.isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
        : (widget.isDarkMode ? const Color(0xFF38260D) : const Color(0xFFFFFBEB));

    final borderColor = isOverdue
        ? (widget.isDarkMode ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
        : (widget.isDarkMode ? const Color(0xFFD97706) : const Color(0xFFFDE68A));

    final badgeColor = isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final badgeText = isOverdue ? '🚨 OVERDUE CALLBACK' : '⏰ SCHEDULED CALLBACK';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: widget.isDarkMode ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                isOverdue ? 'LATE BY' : 'COUNTDOWN',
                style: GoogleFonts.inter(
                  color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? const Color(0xFFEF4444)
                      : (widget.isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOverdue ? '-$countdownStr' : countdownStr,
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
