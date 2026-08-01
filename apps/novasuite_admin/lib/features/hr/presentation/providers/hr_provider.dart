import 'package:flutter/material.dart';

class HRProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedRoleFilter = 'All';

  final List<Map<String, dynamic>> _staffMembers = [
    {
      'id': 'usr-001',
      'name': 'John Doe',
      'email': 'john.doe@novacare.com',
      'phone': '+234 808 504 0146',
      'role': 'Sales Call Rep',
      'department': 'Sales & Telesales',
      'status': 'Active',
      'performanceRating': '94.2%',
    },
    {
      'id': 'usr-002',
      'name': 'Sarah Williams',
      'email': 'sarah.w@novacare.com',
      'phone': '+234 816 511 9466',
      'role': 'Sales Supervisor',
      'department': 'Sales Management',
      'status': 'Active',
      'performanceRating': '98.0%',
    },
    {
      'id': 'usr-003',
      'name': 'Emeka Rider',
      'email': 'emeka.logistics@novaexpress.com',
      'phone': '+234 701 223 9944',
      'role': 'Logistics Dispatch Rep',
      'department': 'Logistics & Dispatch',
      'status': 'Active',
      'performanceRating': '91.5%',
    },
  ];

  String get searchQuery => _searchQuery;
  String get selectedRoleFilter => _selectedRoleFilter;
  List<Map<String, dynamic>> get staffMembers => List.unmodifiable(_staffMembers);

  List<Map<String, dynamic>> get filteredStaff {
    return _staffMembers.where((staff) {
      final name = (staff['name'] as String).toLowerCase();
      final email = (staff['email'] as String).toLowerCase();
      final role = staff['role'] as String;
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All' || role.toLowerCase().contains(_selectedRoleFilter.toLowerCase());
      return matchesSearch && matchesRole;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  void toggleStaffActive(int index) {
    if (index >= 0 && index < _staffMembers.length) {
      final current = _staffMembers[index]['status'] as String;
      _staffMembers[index]['status'] = current == 'Active' ? 'Inactive' : 'Active';
      notifyListeners();
    }
  }

  void addStaff(Map<String, dynamic> newStaff) {
    _staffMembers.insert(0, newStaff);
    notifyListeners();
  }
}
