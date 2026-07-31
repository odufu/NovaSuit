import 'package:novasuite_core/novasuite_core.dart';

abstract class SalesRepository {
  Future<List<OrderModel>> fetchOrders({required String companyId, String? salesRepId, OrderStatus? statusFilter});
  Future<OrderModel> updateOrderStatus({required String orderId, required OrderStatus newStatus, String? notes});
}
