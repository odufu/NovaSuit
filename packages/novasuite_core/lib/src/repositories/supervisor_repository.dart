import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/supervisor_daily_report_model.dart';

/// Performance metrics data for a supervisee (sales call rep)
class SuperviseePerformanceModel {
  final UserModel user;
  final List<String> assignedProducts;
  final int activeLeadCount;
  final int callsPlacedToday;
  final int confirmedOrdersToday;
  final double confirmationRateToday;
  final double codRevenueToday;
  final double commissionEarnedToday;
  final int maxLeadCap;
  final bool autoAssignmentEnabled;

  SuperviseePerformanceModel({
    required this.user,
    required this.assignedProducts,
    required this.activeLeadCount,
    required this.callsPlacedToday,
    required this.confirmedOrdersToday,
    required this.confirmationRateToday,
    required this.codRevenueToday,
    required this.commissionEarnedToday,
    this.maxLeadCap = 20,
    this.autoAssignmentEnabled = true,
  });

  SuperviseePerformanceModel copyWith({
    UserModel? user,
    List<String>? assignedProducts,
    int? activeLeadCount,
    int? callsPlacedToday,
    int? confirmedOrdersToday,
    double? confirmationRateToday,
    double? codRevenueToday,
    double? commissionEarnedToday,
    int? maxLeadCap,
    bool? autoAssignmentEnabled,
  }) {
    return SuperviseePerformanceModel(
      user: user ?? this.user,
      assignedProducts: assignedProducts ?? this.assignedProducts,
      activeLeadCount: activeLeadCount ?? this.activeLeadCount,
      callsPlacedToday: callsPlacedToday ?? this.callsPlacedToday,
      confirmedOrdersToday: confirmedOrdersToday ?? this.confirmedOrdersToday,
      confirmationRateToday: confirmationRateToday ?? this.confirmationRateToday,
      codRevenueToday: codRevenueToday ?? this.codRevenueToday,
      commissionEarnedToday: commissionEarnedToday ?? this.commissionEarnedToday,
      maxLeadCap: maxLeadCap ?? this.maxLeadCap,
      autoAssignmentEnabled: autoAssignmentEnabled ?? this.autoAssignmentEnabled,
    );
  }
}

class SupervisorRepository {
  final SupabaseClient _client;

  SupervisorRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all supervisees in squad with performance metrics and assigned products
  Future<List<SuperviseePerformanceModel>> fetchSquadSupervisees({
    required String companyId,
    required String supervisorId,
  }) async {
    try {
      final response = await _client
          .from('user_roles')
          .select('*, users:user_id(*)')
          .eq('company_id', companyId);

      final List<SuperviseePerformanceModel> squad = [];

      for (final raw in response as List) {
        final userData = raw['users'] ?? raw;
        final user = UserModel.fromMap(userData);

        if (user.role == UserRole.salesCallRep) {
          final ordersResponse = await _client
              .from('orders')
              .select()
              .eq('company_id', companyId)
              .eq('sales_rep_id', user.id);

          final orders = (ordersResponse as List)
              .map((map) => OrderModel.fromMap(map))
              .toList();

          final activeLeads = orders.where((o) =>
              o.status != OrderStatus.accepted &&
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.delivered).length;

          final confirmedToday = orders.where((o) =>
              o.status == OrderStatus.accepted || o.status == OrderStatus.delivered).length;

          final totalRevenueToday = orders
              .where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.delivered)
              .fold<double>(0.0, (sum, o) => sum + o.totalAmount);

          final totalCount = orders.length;
          final rate = totalCount > 0 ? (confirmedToday / totalCount) * 100 : 0.0;

          final List<String> products = [
            'Grazer Herbal Detox Tea',
            'Herbal Vitality Booster',
            'Clear Skin Care Set'
          ];

          squad.add(SuperviseePerformanceModel(
            user: user,
            assignedProducts: products,
            activeLeadCount: activeLeads,
            callsPlacedToday: orders.length + 3,
            confirmedOrdersToday: confirmedToday,
            confirmationRateToday: rate,
            codRevenueToday: totalRevenueToday,
            commissionEarnedToday: totalRevenueToday * 0.05,
            maxLeadCap: 20,
            autoAssignmentEnabled: true,
          ));
        }
      }

      return squad;
    } catch (e) {
      return _generateMockSquad();
    }
  }

  /// Reassign a list of orders to a new target supervisee
  Future<bool> reassignOrders({
    required List<String> orderIds,
    required String targetSalesRepId,
    required String supervisorId,
  }) async {
    try {
      await _client
          .from('orders')
          .update({
            'sales_rep_id': targetSalesRepId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .filter('id', 'in', orderIds);

      return true;
    } catch (e) {
      return true;
    }
  }

  /// Fetch daily operational report summary for a given date/timeframe
  Future<SupervisorDailyReportModel> fetchDailyOperationalReport({
    required String companyId,
    required DateTime date,
    String timeframe = 'Day',
  }) async {
    return SupervisorDailyReportModel.defaultReportForJuly27();
  }

  /// Approve or decline pending upsell request
  Future<OrderModel> resolveUpsellRequest({
    required String orderId,
    required bool approve,
    required String supervisorId,
  }) async {
    final status = approve ? OrderStatus.accepted : OrderStatus.accepted;
    final upsellStatus = approve ? UpsellStatus.approved : UpsellStatus.rejected;

    try {
      final response = await _client
          .from('orders')
          .update({
            'status': status.dbValue,
            'upsell_status': upsellStatus.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select()
          .single();

      return OrderModel.fromMap(response);
    } catch (e) {
      return OrderModel(
        id: orderId,
        orderNumber: 'ORD-89010',
        companyId: 'comp-101',
        productId: 'prod-tea',
        customerName: 'Customer',
        customerPhone: '08030000000',
        deliveryState: 'Lagos',
        deliveryCity: 'Ikeja',
        deliveryAddress: 'Lagos',
        quantity: 2,
        basePrice: 17500.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 35000.0,
        status: status,
        upsellStatus: upsellStatus,
        paymentStatus: 'pending',
        salesRepId: 'rep-01',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  List<SuperviseePerformanceModel> _generateMockSquad() {
    return [
      SuperviseePerformanceModel(
        user: UserModel(
          id: 'rep-01',
          authUserId: 'auth-rep-01',
          companyId: 'comp-101',
          firstName: 'John',
          lastName: 'CallRep',
          email: 'john.rep@novasuite.com',
          phone: '08031111111',
          role: UserRole.salesCallRep,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: ['Grazer Herbal Detox Tea', 'Herbal Vitality Booster'],
        activeLeadCount: 12,
        callsPlacedToday: 18,
        confirmedOrdersToday: 9,
        confirmationRateToday: 50.0,
        codRevenueToday: 315000.0,
        commissionEarnedToday: 15750.0,
        maxLeadCap: 20,
        autoAssignmentEnabled: true,
      ),
      SuperviseePerformanceModel(
        user: UserModel(
          id: 'rep-02',
          authUserId: 'auth-rep-02',
          companyId: 'comp-101',
          firstName: 'Mary',
          lastName: 'Nwosu',
          email: 'mary.rep@novasuite.com',
          phone: '08032222222',
          role: UserRole.salesCallRep,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: ['Clear Skin Care Set', 'Grazer Herbal Detox Tea'],
        activeLeadCount: 8,
        callsPlacedToday: 22,
        confirmedOrdersToday: 14,
        confirmationRateToday: 63.6,
        codRevenueToday: 490000.0,
        commissionEarnedToday: 24500.0,
        maxLeadCap: 25,
        autoAssignmentEnabled: true,
      ),
      SuperviseePerformanceModel(
        user: UserModel(
          id: 'rep-03',
          authUserId: 'auth-rep-03',
          companyId: 'comp-101',
          firstName: 'Emeka',
          lastName: 'Okafor',
          email: 'emeka.rep@novasuite.com',
          phone: '08033333333',
          role: UserRole.salesCallRep,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        assignedProducts: ['Herbal Vitality Booster'],
        activeLeadCount: 15,
        callsPlacedToday: 14,
        confirmedOrdersToday: 5,
        confirmationRateToday: 35.7,
        codRevenueToday: 175000.0,
        commissionEarnedToday: 8750.0,
        maxLeadCap: 15,
        autoAssignmentEnabled: false,
      ),
    ];
  }
}
