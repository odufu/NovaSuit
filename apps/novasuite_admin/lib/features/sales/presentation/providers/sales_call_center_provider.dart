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
    _initSeedOrders();
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

  void _initSeedOrders() {
    final historical = _repository.generateHistoricalMockOrders(companyId: 'tenant-novacare');
    _orders = [
      ...historical,
      OrderModel(
        id: 'ord-101',
        orderNumber: 'ORD-849201',
        companyId: 'tenant-novacare',
        productId: 'Grazer Herbal Detox Tea',
        salesRepId: '30000000-0000-4000-8000-000000000003',
        marketerId: 'marketer-funke',
        customerName: 'Amina Bello',
        customerPhone: '08085040146',
        deliveryState: 'Lagos',
        deliveryCity: 'Ikeja',
        deliveryAddress: '14 Allen Avenue, Ikeja, Lagos',
        status: OrderStatus.upsellPending,
        quantity: 2,
        basePrice: 25000.0,
        upsellAmount: 12000.0,
        downsellDiscount: 0.0,
        totalAmount: 62000.0,
        upsellStatus: UpsellStatus.pending,
        upsellNotes: 'Client requested 1 extra Herbal Detox Bottle',
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      OrderModel(
        id: 'ord-104',
        orderNumber: 'ORD-2026-8901',
        companyId: 'tenant-novacare',
        productId: 'Herbal Vitality Booster',
        salesRepId: '30000000-0000-4000-8000-000000000003',
        marketerId: 'marketer-funke',
        customerName: 'Chief Bartholomew Okonkwo',
        customerPhone: '08085040146',
        deliveryState: 'Lagos',
        deliveryCity: 'Ikeja GRA',
        deliveryAddress: '14 Isaac John Street',
        status: OrderStatus.newOrder,
        quantity: 2,
        basePrice: 25000.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 50000.0,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      OrderModel(
        id: 'ord-105',
        orderNumber: 'ORD-2026-8902',
        companyId: 'tenant-novacare',
        productId: 'Clear Skin Care Set',
        salesRepId: '30000000-0000-4000-8000-000000000003',
        customerName: 'Dr. Folake Adeleke',
        customerPhone: '08165119466',
        deliveryState: 'Abuja',
        deliveryCity: 'Maitama',
        deliveryAddress: 'Aso Drive Plot 402',
        status: OrderStatus.callBack,
        quantity: 1,
        basePrice: 28000.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 28000.0,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        scheduledCallbackAt: DateTime.now().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ];
  }

  Future<void> fetchOrders({String companyId = 'comp-101'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _repository.fetchOrders(companyId: companyId);
      if (fetched.isNotEmpty) {
        _orders = fetched;
      }
    } catch (e) {
      // Retain seed data on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateOrder(OrderModel updatedOrder) {
    _orders.removeWhere((o) => o.id == updatedOrder.id);
    _orders.insert(0, updatedOrder);
    notifyListeners();
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
