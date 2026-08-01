import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Top-Level Application Navigation & Layout Theme State Provider
class AppNavigationProvider extends ChangeNotifier {
  int _currentNavIndex = 0;
  bool _isDarkMode = true;
  bool _isSidebarCollapsed = false;
  TenantTheme _activeTheme = TenantTheme.defaultNovaCare();

  int get currentNavIndex => _currentNavIndex;
  bool get isDarkMode => _isDarkMode;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  TenantTheme get activeTheme => _activeTheme;

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setActiveTheme(TenantTheme theme) {
    _activeTheme = theme;
    notifyListeners();
  }
}
