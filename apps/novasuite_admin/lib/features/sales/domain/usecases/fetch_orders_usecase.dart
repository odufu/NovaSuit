import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/sales_repository.dart';

class FetchOrdersUseCase {
  final SalesRepository repository;

  FetchOrdersUseCase(this.repository);

  Future<List<OrderModel>> execute({required String companyId, String? salesRepId, OrderStatus? statusFilter}) {
    return repository.fetchOrders(companyId: companyId, salesRepId: salesRepId, statusFilter: statusFilter);
  }
}
