import 'package:flutter/material.dart';

/// Provider managing Cash-on-Delivery (COD) reconciliation balances and credit limits
class FinanceProvider extends ChangeNotifier {
  double _riderEmekaCodBalance = 125000.0;
  final double _riderEmekaMaxLimit = 150000.0;

  double get riderEmekaCodBalance => _riderEmekaCodBalance;
  double get riderEmekaMaxLimit => _riderEmekaMaxLimit;

  bool get isRiderCleared => _riderEmekaCodBalance == 0.0;

  void verifyRemittance() {
    _riderEmekaCodBalance = 0.0;
    notifyListeners();
  }

  void updateRiderBalance(double newBalance) {
    _riderEmekaCodBalance = newBalance;
    notifyListeners();
  }
}
