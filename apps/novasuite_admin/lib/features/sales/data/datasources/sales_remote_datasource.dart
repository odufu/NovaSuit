import 'package:novasuite_core/novasuite_core.dart';

abstract class SalesRemoteDataSource {
  Future<List<OrderModel>> fetchOrders({required String companyId, String? salesRepId, OrderStatus? statusFilter});
  Future<OrderModel> updateOrderStatus({required String orderId, required OrderStatus newStatus, String? notes});
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final OrderRepository _coreOrderRepo = OrderRepository();

  @override
  Future<List<OrderModel>> fetchOrders({required String companyId, String? salesRepId, OrderStatus? statusFilter}) {
    return _coreOrderRepo.fetchOrders(companyId: companyId, salesRepId: salesRepId, status: statusFilter);
  }

  @override
  Future<OrderModel> updateOrderStatus({required String orderId, required OrderStatus newStatus, String? notes}) {
    return _coreOrderRepo.updateOrderStatus(orderId: orderId, newStatus: newStatus);
  }
}
