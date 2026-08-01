import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Provider managing state for Call Rep (Supervisee) Suite & Dialer Queue
class CallRepDashboardProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;

  List<OrderModel> _myQueue = [];
  bool _isLoading = false;
  bool _isDialerActive = false;
  OrderModel? _activeCallOrder;
  double _commissionEarnedToday = 17000.0;
  int _deliveredCountToday = 17;

  CallRepDashboardProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository() {
    fetchMyCallQueue();
  }

  List<OrderModel> get myQueue => _myQueue;
  bool get isLoading => _isLoading;
  bool get isDialerActive => _isDialerActive;
  OrderModel? get activeCallOrder => _activeCallOrder;
  double get commissionEarnedToday => _commissionEarnedToday;
  int get deliveredCountToday => _deliveredCountToday;

  Future<void> fetchMyCallQueue({String repId = 'rep-01'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allOrders = await _orderRepository.fetchOrders(companyId: 'comp-101');
      _myQueue = allOrders.where((o) => o.salesRepId == repId || o.salesRepId == null).toList();
    } catch (e) {
      // Repository fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startCallSession(OrderModel order) {
    _activeCallOrder = order;
    _isDialerActive = true;
    notifyListeners();
  }

  void endCallSession() {
    _activeCallOrder = null;
    _isDialerActive = false;
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _myQueue.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _myQueue[index];
      _myQueue[index] = OrderModel(
        id: oldOrder.id,
        orderNumber: oldOrder.orderNumber,
        companyId: oldOrder.companyId,
        productId: oldOrder.productId,
        customerName: oldOrder.customerName,
        customerPhone: oldOrder.customerPhone,
        customerAltPhone: oldOrder.customerAltPhone,
        deliveryState: oldOrder.deliveryState,
        deliveryCity: oldOrder.deliveryCity,
        deliveryAddress: oldOrder.deliveryAddress,
        quantity: oldOrder.quantity,
        basePrice: oldOrder.basePrice,
        upsellAmount: oldOrder.upsellAmount,
        downsellDiscount: oldOrder.downsellDiscount,
        totalAmount: oldOrder.totalAmount,
        status: newStatus,
        upsellStatus: oldOrder.upsellStatus,
        paymentStatus: oldOrder.paymentStatus,
        salesRepId: oldOrder.salesRepId,
        crmTagged: oldOrder.crmTagged,
        createdAt: oldOrder.createdAt,
        updatedAt: DateTime.now(),
      );

      if (newStatus == OrderStatus.delivered) {
        _deliveredCountToday += 1;
        _commissionEarnedToday += 1000.0;
      }
      notifyListeners();
    }
  }
}
