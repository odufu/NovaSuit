import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Top-Level Application Navigation & Layout Theme State Provider
class AppNavigationProvider extends ChangeNotifier {
  int _currentNavIndex = 0;
  int _marketingSubNavIndex = 0;
  int _salesSubNavIndex = 0;
  int _supervisorSubNavIndex = 0;
  int _inventorySubNavIndex = 0;
  int _essSubNavIndex = 0;
  bool _isDarkMode = true;
  bool _isSidebarCollapsed = false;
  TenantTheme _activeTheme = TenantTheme.defaultNovaCare();

  int get currentNavIndex => _currentNavIndex;
  int get marketingSubNavIndex => _marketingSubNavIndex;
  int get salesSubNavIndex => _salesSubNavIndex;
  int get supervisorSubNavIndex => _supervisorSubNavIndex;
  int get inventorySubNavIndex => _inventorySubNavIndex;
  int get essSubNavIndex => _essSubNavIndex;
  bool get isDarkMode => _isDarkMode;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  TenantTheme get activeTheme => _activeTheme;

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  void setEssSubNavIndex(int index) {
    if (_essSubNavIndex != index) {
      _essSubNavIndex = index;
      notifyListeners();
    }
  }

  void setMarketingSubNavIndex(int index) {
    if (_marketingSubNavIndex != index) {
      _marketingSubNavIndex = index;
      notifyListeners();
    }
  }

  void setSalesSubNavIndex(int index) {
    if (_salesSubNavIndex != index) {
      _salesSubNavIndex = index;
      notifyListeners();
    }
  }

  void setSupervisorSubNavIndex(int index) {
    if (_supervisorSubNavIndex != index) {
      _supervisorSubNavIndex = index;
      notifyListeners();
    }
  }

  void setInventorySubNavIndex(int index) {
    if (_inventorySubNavIndex != index) {
      _inventorySubNavIndex = index;
      notifyListeners();
    }
  }

  void setDirectFeatureNav({required int targetIndex, required int subIndex}) {
    _currentNavIndex = targetIndex;
    if (targetIndex == 1) _salesSubNavIndex = subIndex;
    if (targetIndex == 2) _supervisorSubNavIndex = subIndex;
    if (targetIndex == 3) _marketingSubNavIndex = subIndex;
    if (targetIndex == 8) _inventorySubNavIndex = subIndex;
    if (targetIndex == 10) _essSubNavIndex = subIndex;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSidebarCollapsed(bool collapsed) {
    if (_isSidebarCollapsed != collapsed) {
      _isSidebarCollapsed = collapsed;
      notifyListeners();
    }
  }

  void setActiveTheme(TenantTheme theme) {
    _activeTheme = theme;
    notifyListeners();
  }
}
