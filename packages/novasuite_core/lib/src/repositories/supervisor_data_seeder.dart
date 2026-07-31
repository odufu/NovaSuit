import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

/// Database seeding engine for Supervisor & Squad test datasets for Monday 27th July, 2026
class SupervisorDataSeeder {
  final SupabaseClient _client;

  SupervisorDataSeeder({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  /// Seeds 35 orders matching the exact operational report for Monday 27th July 2026
  Future<List<OrderModel>> seedJuly27ReportData({required String companyId}) async {
    final DateTime july27 = DateTime(2026, 7, 27, 9, 30);
    final List<OrderModel> seededOrders = [];

    OrderModel createOrder({
      required String id,
      required String orderNumber,
      required String customerName,
      required String phone,
      required String product,
      required OrderStatus status,
      required double amount,
      String? repId,
      DateTime? created,
      bool crmTagged = true,
    }) {
      return OrderModel(
        id: id,
        orderNumber: orderNumber,
        companyId: companyId,
        productId: product,
        salesRepId: repId ?? 'rep-01',
        customerName: customerName,
        customerPhone: phone,
        deliveryState: 'Lagos',
        deliveryCity: 'Ikeja',
        deliveryAddress: 'Lagos, Nigeria',
        status: status,
        quantity: 1,
        basePrice: amount,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: amount,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        crmTagged: crmTagged,
        createdAt: created ?? july27,
        updatedAt: july27,
      );
    }

    // 15 Delivered today (July 27)
    for (int i = 1; i <= 15; i++) {
      seededOrders.add(createOrder(
        id: 'ord-del-today-$i',
        orderNumber: 'ORD-2026-DEL-$i',
        customerName: 'Delivered Customer $i',
        phone: '080311100$i',
        product: i % 2 == 0 ? 'GRAZER HERBAL DETOX TEA' : 'HERBAL SHAMPOO & VITALITY BOOSTER',
        status: OrderStatus.delivered,
        amount: 25000.0,
        crmTagged: i <= 9, // 6 untagged CRM orders (15 - 9 = 6 untagged)
      ));
    }

    // 2 Delivered from previous days (July 25/26)
    seededOrders.add(createOrder(
      id: 'ord-del-prev-1',
      orderNumber: 'ORD-2026-PREV-1',
      customerName: 'Previous Day Customer A',
      phone: '0803222001',
      product: 'GRAZER HERBAL DETOX TEA',
      status: OrderStatus.delivered,
      amount: 30000.0,
      created: DateTime(2026, 7, 25, 14, 0),
    ));

    seededOrders.add(createOrder(
      id: 'ord-del-prev-2',
      orderNumber: 'ORD-2026-PREV-2',
      customerName: 'Previous Day Customer B',
      phone: '0803222002',
      product: 'HERBAL SHAMPOO & VITALITY BOOSTER',
      status: OrderStatus.delivered,
      amount: 28000.0,
      created: DateTime(2026, 7, 26, 11, 30),
    ));

    // 6 Confirmed orders sitting in accepted
    for (int i = 1; i <= 6; i++) {
      seededOrders.add(createOrder(
        id: 'ord-conf-$i',
        orderNumber: 'ORD-2026-CONF-$i',
        customerName: 'Confirmed Customer $i',
        phone: '080333300$i',
        product: 'GRAZER HERBAL DETOX TEA',
        status: OrderStatus.accepted,
        amount: 25000.0,
      ));
    }

    // 7 Rescheduled callbacks
    for (int i = 1; i <= 7; i++) {
      seededOrders.add(createOrder(
        id: 'ord-resched-$i',
        orderNumber: 'ORD-2026-RESCHED-$i',
        customerName: 'Rescheduled Customer $i',
        phone: '080344400$i',
        product: 'HERBAL SHAMPOO & VITALITY BOOSTER',
        status: OrderStatus.callBack,
        amount: 20000.0,
      ));
    }

    // 2 Switched Off (unreachable callbacks)
    for (int i = 1; i <= 2; i++) {
      seededOrders.add(createOrder(
        id: 'ord-off-$i',
        orderNumber: 'ORD-2026-OFF-$i',
        customerName: 'Switched Off Customer $i',
        phone: '080355500$i',
        product: 'GRAZER HERBAL DETOX TEA',
        status: OrderStatus.callBack,
        amount: 25000.0,
      ));
    }

    // 3 Not Picking
    for (int i = 1; i <= 3; i++) {
      seededOrders.add(createOrder(
        id: 'ord-nopick-$i',
        orderNumber: 'ORD-2026-NOPICK-$i',
        customerName: 'Not Picking Customer $i',
        phone: '080366600$i',
        product: 'HERBAL SHAMPOO & VITALITY BOOSTER',
        status: OrderStatus.notPicking,
        amount: 22000.0,
      ));
    }

    // 1 Not Ready
    seededOrders.add(createOrder(
      id: 'ord-notready-1',
      orderNumber: 'ORD-2026-NOTREADY-1',
      customerName: 'Not Ready Customer',
      phone: '0803777001',
      product: 'GRAZER HERBAL DETOX TEA',
      status: OrderStatus.newOrder,
      amount: 25000.0,
    ));

    return seededOrders;
  }

  /// Upserts all 35 operational report orders directly into Supabase 'orders' database table
  Future<bool> seedToSupabaseDatabase({required String companyId}) async {
    try {
      final orders = await seedJuly27ReportData(companyId: companyId);
      final maps = orders.map((o) => o.toMap()).toList();

      await _client.from('orders').upsert(maps, onConflict: 'order_number');
      return true;
    } catch (e) {
      return false;
    }
  }
}
