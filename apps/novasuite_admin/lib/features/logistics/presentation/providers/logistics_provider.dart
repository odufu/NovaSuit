import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/usecases/fetch_inventory_usecase.dart';

class LogisticsProvider extends ChangeNotifier {
  final FetchInventoryUseCase fetchInventoryUseCase;

  List<WarehouseModel> _warehouses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Inter-Warehouse Stock Transfers List
  final List<Map<String, dynamic>> _transfers = [
    {
      'waybill': 'WB-2026-4891',
      'source': 'Lagos Central Factory Hub',
      'destination': 'Abuja Regional Hub (NovaExpress)',
      'product': 'Herbal Care Detox Tea',
      'quantity': 500,
      'status': 'dispatched',
      'date': '2026-07-24 10:30 AM',
    },
    {
      'waybill': 'WB-2026-4820',
      'source': 'Lagos Central Factory Hub',
      'destination': 'Rider Emeka Mini-Hub (Port Harcourt)',
      'product': 'Herbal Vitality Booster',
      'quantity': 50,
      'status': 'completed',
      'date': '2026-07-23 04:15 PM',
    },
  ];

  LogisticsProvider({required this.fetchInventoryUseCase});

  List<WarehouseModel> get warehouses => _warehouses;
  List<Map<String, dynamic>> get transfers => List.unmodifiable(_transfers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInventory({required String companyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _warehouses = await fetchInventoryUseCase.execute(companyId: companyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void addTransfer(Map<String, dynamic> newTransfer) {
    _transfers.insert(0, newTransfer);
    notifyListeners();
  }

  void confirmTransferReceipt(int index) {
    if (index >= 0 && index < _transfers.length) {
      _transfers[index]['status'] = 'completed';
      notifyListeners();
    }
  }
}
