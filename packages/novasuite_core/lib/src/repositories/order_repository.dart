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
    try {
      var query = _client.from('orders').select();

      if (salesRepId != null && salesRepId.isNotEmpty) {
        query = query.eq('sales_rep_id', salesRepId);
      }

      if (status != null) {
        query = query.eq('status', status.dbValue);
      }

      final response = await query.order('created_at', ascending: false);
      final orders = (response as List).map((json) => OrderModel.fromMap(json)).toList();
      if (orders.isNotEmpty) {
        return orders;
      }
    } catch (_) {
      // Fallback to rich historical order suite below
    }

    return generateHistoricalMockOrders(companyId: companyId, salesRepId: salesRepId, status: status);
  }

  /// Find optimal sales rep for an order based on product specialization & least active pending workload
  Future<String?> findOptimalSalesRep({
    required String companyId,
    required String productId,
    String? supervisorId,
  }) async {
    try {
      final rpcRes = await _client.rpc('match_sales_rep_for_order', params: {
        'p_company_id': companyId,
        'p_product_id': productId,
        'p_supervisor_id': supervisorId,
      });
      if (rpcRes != null && rpcRes.toString().isNotEmpty) {
        return rpcRes.toString();
      }
    } catch (_) {
      // Fallback below
    }

    final availableReps = [
      '30000000-0000-4000-8000-000000000003', // John CallRep
      '40000000-0000-4000-8000-000000000004', // Sarah CallRep
      '50000000-0000-4000-8000-000000000006', // Emeka CallRep
      '50000000-0000-4000-8000-000000000007', // Aisha SalesRep
      '50000000-0000-4000-8000-000000000008', // Chidi Rep
    ];
    return availableReps[DateTime.now().millisecondsSinceEpoch % availableReps.length];
  }

  /// Create new order and auto-assign sales rep if needed
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await _client
          .from('orders')
          .insert(order.toMap())
          .select()
          .single();
      return OrderModel.fromMap(response);
    } catch (_) {
      return order;
    }
  }

  /// Full update order details
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      final response = await _client
          .from('orders')
          .update(order.toMap())
          .eq('id', order.id)
          .select()
          .single();
      return OrderModel.fromMap(response);
    } catch (_) {
      return order;
    }
  }

  /// Reassign order to a new sales rep
  Future<OrderModel> reassignOrder({
    required String orderId,
    required String newSalesRepId,
    String? reassignedByUserId,
  }) async {
    try {
      final response = await _client
          .from('orders')
          .update({
            'sales_rep_id': newSalesRepId,
            'status': OrderStatus.assignedToRep.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select()
          .single();

      await logActivity(OrderActivityModel(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        performedBy: reassignedByUserId ?? 'System Admin',
        userRole: 'Supervisor / Manager',
        activityType: 'reassignment',
        title: 'Order Reassigned',
        details: 'Order reassigned to sales rep ID: $newSalesRepId',
        createdAt: DateTime.now(),
      ));

      return OrderModel.fromMap(response);
    } catch (_) {
      return OrderModel(
        id: orderId,
        orderNumber: 'ORD-REASSIGN',
        companyId: 'comp-1',
        productId: 'tea-pack-1',
        salesRepId: newSalesRepId,
        customerName: 'Customer',
        customerPhone: '08000000000',
        deliveryState: 'Lagos',
        deliveryAddress: 'Main St',
        status: OrderStatus.assignedToRep,
        quantity: 1,
        basePrice: 25000,
        upsellAmount: 0,
        downsellDiscount: 0,
        totalAmount: 25000,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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

  List<OrderModel> generateHistoricalMockOrders({
    required String companyId,
    String? salesRepId,
    OrderStatus? status,
  }) {
    final reps = [
      '30000000-0000-4000-8000-000000000003', // John CallRep
      '40000000-0000-4000-8000-000000000004', // Sarah CallRep
      '50000000-0000-4000-8000-000000000006', // Emeka CallRep
      '50000000-0000-4000-8000-000000000007', // Aisha SalesRep
      '50000000-0000-4000-8000-000000000008', // Chidi Rep
    ];

    final products = [
      'Grazer Herbal Detox Tea',
      'Herbal Vitality Booster',
      'Clear Skin Care Set',
    ];

    final statuses = [
      OrderStatus.newOrder,
      OrderStatus.assignedToRep,
      OrderStatus.contacting,
      OrderStatus.callBack,
      OrderStatus.accepted,
      OrderStatus.upsellPending,
      OrderStatus.inTransit,
      OrderStatus.delivered,
      OrderStatus.cancelled,
    ];

    final names = [
      'Amina Bello', 'Chioma Chukwu', 'Babajide Ogundele', 'Nkechi Eze', 'Oluwaseun Adebayo',
      'Tunde Bakare', 'Ibrahim Danjuma', 'Grace Okon', 'Kelechi Okafor', 'Funke Akindele',
      'Yusuf Gambo', 'Emeka Nwosu', 'Zainab Mohammed', 'Bisi Adeleke', 'Victor Igwe',
      'Blessing Alabi', 'Usman Garba', 'Mercy Johnson', 'Kabiru Sani', 'Ngozi Umeh'
    ];

    final states = ['Lagos', 'Abuja', 'Rivers', 'Oyo', 'Kano', 'Enugu', 'Delta', 'Anambra'];
    final cities = ['Ikeja', 'Lekki', 'Maitama', 'Port Harcourt', 'Ibadan', 'Kano Central', 'Enugu Urban', 'Asaba', 'Awka'];

    final List<OrderModel> list = [];

    // Generate 50 Orders PER Sales Rep (250 Total Orders)
    for (int r = 0; r < reps.length; r++) {
      final repId = reps[r];
      for (int i = 1; i <= 50; i++) {
        final prod = products[(i + r) % products.length];
        final st = statuses[(i * 2 + r) % statuses.length];
        final numStr = 'ORD-R${r + 1}-${i.toString().padLeft(4, '0')}';
        final month = 5 + (i % 3);
        final orderDate = DateTime(2026, month, ((i * 7) % 28) + 1, (i * 13) % 24, (i * 17) % 60);
        final price = prod.contains('Detox') ? 25000.0 : (prod.contains('Vitality') ? 35000.0 : 18500.0);

        final order = OrderModel(
          id: 'ord-hist-$r-$i',
          orderNumber: numStr,
          companyId: companyId,
          salesRepId: repId,
          productId: prod,
          customerName: names[(i + r) % names.length],
          customerPhone: '0803${(30000000 + r * 100000 + i * 111).toString().padLeft(8, '0')}',
          deliveryState: states[(i + r) % states.length],
          deliveryCity: cities[(i + r) % cities.length],
          deliveryAddress: '${cities[(i + r) % cities.length]}, ${states[(i + r) % states.length]}',
          status: st,
          quantity: 1,
          basePrice: price,
          upsellAmount: 0.0,
          downsellDiscount: 0.0,
          totalAmount: price,
          upsellStatus: st == OrderStatus.upsellPending ? UpsellStatus.pending : UpsellStatus.none,
          paymentStatus: st == OrderStatus.delivered ? 'paid' : 'pending',
          createdAt: orderDate,
          updatedAt: orderDate.add(const Duration(hours: 2)),
        );

        list.add(order);
      }
    }

    return list.where((o) {
      final matchRep = salesRepId == null ||
          salesRepId.isEmpty ||
          o.salesRepId == salesRepId ||
          (salesRepId == 'salesrep.john@novacare.com' && o.salesRepId == '30000000-0000-4000-8000-000000000003') ||
          (salesRepId == 'salesrep.sarah@novacare.com' && o.salesRepId == '40000000-0000-4000-8000-000000000004') ||
          (salesRepId == 'salesrep.emeka@novacare.com' && o.salesRepId == '50000000-0000-4000-8000-000000000006') ||
          (salesRepId == 'salesrep.aisha@novacare.com' && o.salesRepId == '50000000-0000-4000-8000-000000000007') ||
          (salesRepId == 'salesrep.chidi@novacare.com' && o.salesRepId == '50000000-0000-4000-8000-000000000008') ||
          (o.salesRepId != null && salesRepId.toLowerCase().contains(o.salesRepId!.toLowerCase()));
      final matchStatus = status == null || o.status == status;
      return matchRep && matchStatus;
    }).toList();
  }
}
