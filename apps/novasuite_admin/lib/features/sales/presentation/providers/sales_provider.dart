import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/usecases/fetch_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

class SalesProvider extends ChangeNotifier {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  SalesProvider({
    required this.fetchOrdersUseCase,
    required this.updateOrderStatusUseCase,
  });

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setOrders(List<OrderModel> initialOrders) {
    _orders = List.from(initialOrders);
    notifyListeners();
  }

  Future<void> fetchOrders({required String companyId, String? salesRepId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await fetchOrdersUseCase.execute(companyId: companyId, salesRepId: salesRepId);
      if (result.isNotEmpty) {
        _orders = result;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void updateLocalOrder(OrderModel updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    } else {
      _orders.insert(0, updatedOrder);
    }
    notifyListeners();
  }
}
