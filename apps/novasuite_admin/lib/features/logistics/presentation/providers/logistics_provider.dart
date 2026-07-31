import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/usecases/fetch_inventory_usecase.dart';

class LogisticsProvider extends ChangeNotifier {
  final FetchInventoryUseCase fetchInventoryUseCase;

  List<WarehouseModel> _warehouses = [];
  bool _isLoading = false;
  String? _errorMessage;

  LogisticsProvider({required this.fetchInventoryUseCase});

  List<WarehouseModel> get warehouses => _warehouses;
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
}
