import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderModel>> fetchOrders({required String companyId, String? salesRepId, OrderStatus? statusFilter}) {
    return remoteDataSource.fetchOrders(companyId: companyId, salesRepId: salesRepId, statusFilter: statusFilter);
  }

  @override
  Future<OrderModel> updateOrderStatus({required String orderId, required OrderStatus newStatus, String? notes}) {
    return remoteDataSource.updateOrderStatus(orderId: orderId, newStatus: newStatus, notes: notes);
  }
}
