import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/sales_repository.dart';

class UpdateOrderStatusUseCase {
  final SalesRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<OrderModel> execute({required String orderId, required OrderStatus newStatus, String? notes}) {
    return repository.updateOrderStatus(orderId: orderId, newStatus: newStatus, notes: notes);
  }
}
