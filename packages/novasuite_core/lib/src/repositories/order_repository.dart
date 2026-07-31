import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/order_activity.dart';

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch orders filtered by company, sales rep, or status
  Future<List<OrderModel>> fetchOrders({
    required String companyId,
    String? salesRepId,
    OrderStatus? status,
  }) async {
    var query = _client.from('orders').select().eq('company_id', companyId);

    if (salesRepId != null && salesRepId.isNotEmpty) {
      query = query.eq('sales_rep_id', salesRepId);
    }

    if (status != null) {
      query = query.eq('status', status.dbValue);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => OrderModel.fromMap(json)).toList();
  }

  /// Update order status
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': newStatus.dbValue,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .select()
        .single();

    return OrderModel.fromMap(response);
  }

  /// Sales Rep submits Up-sell / Down-sell request
  Future<OrderModel> requestUpsell({
    required String orderId,
    required double upsellAmount,
    required double downsellDiscount,
    required String notes,
    required double newTotalAmount,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': OrderStatus.upsellPending.dbValue,
          'upsell_amount': upsellAmount,
          'downsell_discount': downsellDiscount,
          'total_amount': newTotalAmount,
          'upsell_status': UpsellStatus.pending.dbValue,
          'upsell_notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .select()
        .single();

    return OrderModel.fromMap(response);
  }

  /// Supervisor Approves Up-sell
  Future<OrderModel> approveUpsell({
    required String orderId,
    required String supervisorId,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': OrderStatus.accepted.dbValue,
          'upsell_status': UpsellStatus.approved.dbValue,
          'approved_by_supervisor_id': supervisorId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .select()
        .single();

    return OrderModel.fromMap(response);
  }

  /// Supervisor Rejects Up-sell
  Future<OrderModel> rejectUpsell({
    required String orderId,
    required String supervisorId,
    required double basePrice,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': OrderStatus.accepted.dbValue,
          'upsell_amount': 0.0,
          'downsell_discount': 0.0,
          'total_amount': basePrice,
          'upsell_status': UpsellStatus.rejected.dbValue,
          'approved_by_supervisor_id': supervisorId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .select()
        .single();

    return OrderModel.fromMap(response);
  }

  /// Subscribe to Supabase Realtime Order Channel for live supervisor updates
  RealtimeChannel subscribeToOrdersRealtime({
    required String companyId,
    required void Function(Map<String, dynamic> payload) onOrderChanged,
  }) {
    final channel = _client.channel('public:orders:$companyId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        onOrderChanged(payload.newRecord);
      },
    );
    channel.subscribe();
    return channel;
  }

  /// Log a new order activity into Supabase
  Future<OrderActivityModel?> logActivity(OrderActivityModel activity) async {
    try {
      final response = await _client
          .from('order_activities')
          .insert(activity.toMap())
          .select()
          .single();
      return OrderActivityModel.fromMap(response);
    } catch (_) {
      // Graceful fallback for offline / mock mode
      return activity;
    }
  }

  /// Fetch chronological activities for a given order
  Future<List<OrderActivityModel>> fetchOrderActivities(String orderId) async {
    try {
      final response = await _client
          .from('order_activities')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => OrderActivityModel.fromMap(json)).toList();
    } catch (_) {
      return [];
    }
  }
}
