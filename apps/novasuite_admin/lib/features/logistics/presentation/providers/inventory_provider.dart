import 'package:flutter/material.dart';

class InventoryProvider extends ChangeNotifier {
  int _activeTab = 0;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All Categories';
  String _selectedWarehouseFilter = 'All Warehouses';

  int get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedWarehouseFilter => _selectedWarehouseFilter;

  void setActiveTab(int index) {
    if (_activeTab != index) {
      _activeTab = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setWarehouseFilter(String warehouse) {
    _selectedWarehouseFilter = warehouse;
    notifyListeners();
  }
}
