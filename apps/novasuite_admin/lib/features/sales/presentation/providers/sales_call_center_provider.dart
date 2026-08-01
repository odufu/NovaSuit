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
    _orders = [
      OrderModel(
        id: 'ord-101',
        orderNumber: 'ORD-849201',
        companyId: 'tenant-novacare',
        productId: 'prod-herbal-tea',
        salesRepId: 'salesrep.john@novacare.com',
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
        id: 'ord-102',
        orderNumber: 'ORD-849202',
        companyId: 'tenant-novacare',
        productId: 'prod-herbal-tea',
        salesRepId: 'salesrep.sarah@novacare.com',
        customerName: 'Chidi Okeke',
        customerPhone: '08165119466',
        deliveryState: 'Abuja',
        deliveryCity: 'Maitama',
        deliveryAddress: '8 Gana Street, Maitama, Abuja',
        status: OrderStatus.accepted,
        quantity: 1,
        basePrice: 25000.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 25000.0,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      OrderModel(
        id: 'ord-103',
        orderNumber: 'ORD-849203',
        companyId: 'tenant-novacare',
        productId: 'prod-booster',
        salesRepId: 'salesrep.john@novacare.com',
        customerName: 'Emeka Nwosu',
        customerPhone: '08085040146',
        deliveryState: 'Rivers',
        deliveryCity: 'Port Harcourt',
        deliveryAddress: '42 GRA Phase 2, Port Harcourt',
        status: OrderStatus.inTransit,
        quantity: 3,
        basePrice: 18000.0,
        upsellAmount: 0.0,
        downsellDiscount: 2000.0,
        totalAmount: 52000.0,
        upsellStatus: UpsellStatus.approved,
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderModel(
        id: 'ord-104',
        orderNumber: 'ORD-2026-8901',
        companyId: 'tenant-novacare',
        productId: 'prod-herbal-tea',
        salesRepId: null,
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
        productId: 'prod-booster',
        salesRepId: null,
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
      OrderModel(
        id: 'ord-106',
        orderNumber: 'ORD-2026-8903',
        companyId: 'tenant-novacare',
        productId: 'prod-herbal-tea',
        salesRepId: null,
        customerName: 'Alhaji Ibrahim Danladi',
        customerPhone: '08085040146',
        deliveryState: 'Kano',
        deliveryCity: 'Nassarawa GRA',
        deliveryAddress: '7 Lamido Road',
        status: OrderStatus.newOrder,
        quantity: 1,
        basePrice: 22000.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 22000.0,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      OrderModel(
        id: 'ord-107',
        orderNumber: 'ORD-2026-8904',
        companyId: 'tenant-novacare',
        productId: 'prod-booster',
        salesRepId: null,
        customerName: 'Engineer Chidi Nnamdi',
        customerPhone: '08165119466',
        deliveryState: 'Rivers',
        deliveryCity: 'Port Harcourt',
        deliveryAddress: '88 Aba Road, Garrison',
        status: OrderStatus.newOrder,
        quantity: 1,
        basePrice: 25000.0,
        upsellAmount: 0.0,
        downsellDiscount: 0.0,
        totalAmount: 25000.0,
        upsellStatus: UpsellStatus.none,
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
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
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
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
