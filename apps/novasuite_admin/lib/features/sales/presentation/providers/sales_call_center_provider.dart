import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Provider managing state for Sales Call Center Directory, Filters, and Order Actions
class SalesCallCenterProvider extends ChangeNotifier {
  final OrderRepository _repository;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  int _activeTabIndex = 0;
  String _searchQuery = '';
  String _selectedStatusFilter = 'All Statuses';
  final List<String> _selectedOrderIds = [];

  SalesCallCenterProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepository() {
    fetchOrders();
  }

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  int get activeTabIndex => _activeTabIndex;
  String get searchQuery => _searchQuery;
  String get selectedStatusFilter => _selectedStatusFilter;
  List<String> get selectedOrderIds => _selectedOrderIds;

  List<OrderModel> get filteredOrders {
    return _orders.where((o) {
      final matchesSearch = o.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerPhone.contains(_searchQuery);
      final matchesStatus = _selectedStatusFilter == 'All Statuses' ||
          o.status.label.toLowerCase() == _selectedStatusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchOrders({String companyId = 'comp-101'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _repository.fetchOrders(companyId: companyId);
    } catch (e) {
      // Repository returns fallback seed data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveTabIndex(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void toggleOrderSelection(String orderId) {
    if (_selectedOrderIds.contains(orderId)) {
      _selectedOrderIds.remove(orderId);
    } else {
      _selectedOrderIds.add(orderId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedOrderIds.clear();
    notifyListeners();
  }

  Future<bool> reassignSelectedOrders(String targetRepId) async {
    if (_selectedOrderIds.isEmpty) return false;

    try {
      for (final id in _selectedOrderIds) {
        final index = _orders.indexWhere((o) => o.id == id);
        if (index != -1) {
          final old = _orders[index];
          _orders[index] = OrderModel(
            id: old.id,
            orderNumber: old.orderNumber,
            companyId: old.companyId,
            productId: old.productId,
            customerName: old.customerName,
            customerPhone: old.customerPhone,
            customerAltPhone: old.customerAltPhone,
            deliveryState: old.deliveryState,
            deliveryCity: old.deliveryCity,
            deliveryAddress: old.deliveryAddress,
            quantity: old.quantity,
            basePrice: old.basePrice,
            upsellAmount: old.upsellAmount,
            downsellDiscount: old.downsellDiscount,
            totalAmount: old.totalAmount,
            status: OrderStatus.assignedToRep,
            upsellStatus: old.upsellStatus,
            paymentStatus: old.paymentStatus,
            salesRepId: targetRepId,
            crmTagged: old.crmTagged,
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      }
      _selectedOrderIds.clear();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
