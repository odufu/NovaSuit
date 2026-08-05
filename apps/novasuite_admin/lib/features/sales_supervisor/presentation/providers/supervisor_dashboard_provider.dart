import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Provider managing state for Supervisor Command Suite & Supervisee Leaderboard
class SupervisorDashboardProvider extends ChangeNotifier {
  final SupervisorRepository _repository;

  List<SuperviseePerformanceModel> _squad = [];
  SupervisorDailyReportModel? _dailyReport;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedProductFilter = 'All Products';
  String _selectedTimeframe = 'Daily';
  bool _isCardViewMode = false;

  SupervisorDashboardProvider({SupervisorRepository? repository})
      : _repository = repository ?? SupervisorRepository() {
    fetchSquadData();
  }

  List<SuperviseePerformanceModel> get squad => _squad;
  SupervisorDailyReportModel? get dailyReport => _dailyReport;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedProductFilter => _selectedProductFilter;
  String get selectedTimeframe => _selectedTimeframe;
  bool get isCardViewMode => _isCardViewMode;

  /// Filtered list of supervisees based on search query and product assignment filter
  List<SuperviseePerformanceModel> get filteredSquad {
    return _squad.where((agent) {
      final matchesSearch = agent.user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          agent.user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesProduct = _selectedProductFilter == 'All Products' ||
          agent.assignedProducts.contains(_selectedProductFilter);
      return matchesSearch && matchesProduct;
    }).toList();
  }

  /// Top Performer ID based on highest COD revenue
  String? get topPerformerId {
    if (_squad.isEmpty) return null;
    return _squad.reduce((curr, next) => curr.codRevenueToday >= next.codRevenueToday ? curr : next).user.id;
  }

  Future<void> fetchSquadData({String companyId = 'comp-101', String supervisorId = 'sup-01'}) async {
    if (_squad.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fetchedSquad = await _repository.fetchSquadSupervisees(companyId: companyId, supervisorId: supervisorId);
      final fetchedReport = await _repository.fetchDailyOperationalReport(companyId: companyId, date: DateTime(2026, 7, 27));

      if (fetchedSquad.isNotEmpty) {
        _squad = fetchedSquad;
      }
      _dailyReport = fetchedReport;
    } catch (e) {
      // Repositories automatically return fallback seed data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setProductFilter(String product) {
    _selectedProductFilter = product;
    notifyListeners();
  }

  void setTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  void setCardViewMode(bool enabled) {
    _isCardViewMode = enabled;
    notifyListeners();
  }

  void updateSupervisee(SuperviseePerformanceModel updated) {
    final index = _squad.indexWhere((s) => s.user.id == updated.user.id);
    if (index != -1) {
      _squad[index] = updated;
      notifyListeners();
    }
  }
}
