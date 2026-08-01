import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

class RiderProvider extends ChangeNotifier {
  int _currentTab = 0;
  bool _isOnline = true;
  double _currentCodBalance = 125000.0;
  final double _maxCreditLimit = 150000.0;

  final List<OrderModel> _assignedJobs = [
    OrderModel(
      id: 'job-101',
      orderNumber: 'ORD-849201',
      companyId: 'tenant-novacare',
      productId: 'prod-herbal-tea',
      customerName: 'Amina Bello',
      customerPhone: '+234 803 123 4567',
      deliveryState: 'Lagos',
      deliveryCity: 'Ikeja',
      deliveryAddress: '14 Allen Avenue, Ikeja, Lagos State',
      status: OrderStatus.agentNotified,
      quantity: 2,
      basePrice: 25000.0,
      upsellAmount: 12000.0,
      downsellDiscount: 0.0,
      totalAmount: 62000.0,
      upsellStatus: UpsellStatus.approved,
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    OrderModel(
      id: 'job-102',
      orderNumber: 'ORD-849203',
      companyId: 'tenant-novacare',
      productId: 'prod-booster',
      customerName: 'Emeka Nwosu',
      customerPhone: '+234 701 555 8899',
      deliveryState: 'Lagos',
      deliveryCity: 'Lekki',
      deliveryAddress: 'Block 4, Admiralty Way, Lekki Phase 1, Lagos',
      status: OrderStatus.inTransit,
      quantity: 3,
      basePrice: 18000.0,
      upsellAmount: 0.0,
      downsellDiscount: 2000.0,
      totalAmount: 52000.0,
      upsellStatus: UpsellStatus.none,
      paymentStatus: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  int get currentTab => _currentTab;
  bool get isOnline => _isOnline;
  double get currentCodBalance => _currentCodBalance;
  double get maxCreditLimit => _maxCreditLimit;
  List<OrderModel> get assignedJobs => List.unmodifiable(_assignedJobs);

  void setTab(int index) {
    if (_currentTab != index) {
      _currentTab = index;
      notifyListeners();
    }
  }

  void setOnline(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  void completeJobAndCollectCash(String jobId, double cashAmount) {
    _assignedJobs.removeWhere((j) => j.id == jobId);
    _currentCodBalance += cashAmount;
    notifyListeners();
  }
}
