import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../widgets/add_edit_staff_dialog.dart';

class HRStaffManagementPage extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;

  const HRStaffManagementPage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
  });

  @override
  State<HRStaffManagementPage> createState() => _HRStaffManagementPageState();
}

class _HRStaffManagementPageState extends State<HRStaffManagementPage> {
  String _selectedRoleFilter = 'All Roles';
  String _searchQuery = '';

  // Sample Supervisors List
  final List<UserModel> _supervisors = [
    UserModel(
      id: '20000000-0000-4000-8000-000000000002',
      companyId: '11111111-1111-4111-8111-111111111111',
      role: UserRole.supervisor,
      firstName: 'Samuel',
      lastName: 'Supervisor',
      email: 'supervisor@novacare.com',
      phone: '+234 803 222 3344',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: '10000000-0000-4000-8000-000000000001',
      companyId: '11111111-1111-4111-8111-111111111111',
      role: UserRole.agm,
      firstName: 'Alex',
      lastName: 'General Manager',
      email: 'agm@novacare.com',
      phone: '+234 803 111 2233',
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  // Company Staff Members Directory
  late List<Map<String, dynamic>> _staffMembers;

  @override
  void initState() {
    super.initState();
    _staffMembers = [
      {
        'id': '30000000-0000-4000-8000-000000000003',
        'first_name': 'John',
        'last_name': 'SalesRep',
        'email': 'salesrep.john@novacare.com',
        'phone': '+234 803 333 4455',
        'role': UserRole.salesCallRep,
        'department': 'Sales Call Center',
        'supervisor_name': 'Samuel Supervisor',
        'is_active': true,
      },
      {
        'id': '40000000-0000-4000-8000-000000000004',
        'first_name': 'Sarah',
        'last_name': 'SalesRep',
        'email': 'salesrep.sarah@novacare.com',
        'phone': '+234 803 444 5566',
        'role': UserRole.salesCallRep,
        'department': 'Sales Call Center',
        'supervisor_name': 'Samuel Supervisor',
        'is_active': true,
      },
      {
        'id': '50000000-0000-4000-8000-000000000005',
        'first_name': 'David',
        'last_name': 'Marketer',
        'email': 'marketer.david@novacare.com',
        'phone': '+234 803 555 6677',
        'role': UserRole.digitalMarketer,
        'department': 'Digital Marketing',
        'supervisor_name': 'Alex General Manager',
        'is_active': true,
      },
      {
        'id': '60000000-0000-4000-8000-000000000006',
        'first_name': 'Leonard',
        'last_name': 'LogisticsRep',
        'email': 'logisticsrep@novaexpress.com',
        'phone': '+234 803 666 7788',
        'role': UserRole.logisticsCallRep,
        'department': 'Logistics Operations',
        'supervisor_name': 'Alex General Manager',
        'is_active': true,
      },
      {
        'id': '70000000-0000-4000-8000-000000000007',
        'first_name': 'Emeka',
        'last_name': 'Rider',
        'email': 'rider.emeka@novaexpress.com',
        'phone': '+234 803 777 8899',
        'role': UserRole.deliveryAgent,
        'department': 'Logistics Operations',
        'supervisor_name': 'Leonard LogisticsRep',
        'is_active': true,
      },
      {
        'id': '80000000-0000-4000-8000-000000000008',
        'first_name': 'Fiona',
        'last_name': 'FinanceManager',
        'email': 'finance@novacare.com',
        'phone': '+234 803 888 9900',
        'role': UserRole.financeManager,
        'department': 'Finance & Reconciliation',
        'supervisor_name': 'Alex General Manager',
        'is_active': true,
      },
    ];
  }

  void _handleAddStaff() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditStaffDialog(
        activeTheme: widget.activeTheme,
        availableSupervisors: _supervisors,
      ),
    );

    if (result != null) {
      final roleObj = result['role'] as UserRole;
      final supId = result['supervisor_id'] as String?;
      final supervisorObj = _supervisors.firstWhere((s) => s.id == supId, orElse: () => _supervisors.first);

      setState(() {
        _staffMembers.insert(0, {
          'id': result['id'],
          'first_name': result['first_name'],
          'last_name': result['last_name'],
          'email': result['email'],
          'phone': result['phone'],
          'role': roleObj,
          'department': result['department'],
          'supervisor_name': supervisorObj.fullName,
          'is_active': result['is_active'],
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Onboarded ${result['first_name']} ${result['last_name']} as ${roleObj.label}!'),
        ),
      );
    }
  }

  void _handleEditStaff(Map<String, dynamic> staff) async {
    final userModel = UserModel(
      id: staff['id'],
      companyId: widget.currentUser.companyId,
      role: staff['role'] as UserRole,
      firstName: staff['first_name'],
      lastName: staff['last_name'],
      email: staff['email'],
      phone: staff['phone'],
      isActive: staff['is_active'],
      createdAt: DateTime.now(),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditStaffDialog(
        activeTheme: widget.activeTheme,
        staffToEdit: userModel,
        availableSupervisors: _supervisors,
      ),
    );

    if (result != null) {
      final index = _staffMembers.indexWhere((s) => s['id'] == staff['id']);
      if (index != -1) {
        final roleObj = result['role'] as UserRole;
        final supId = result['supervisor_id'] as String?;
        final supervisorObj = _supervisors.firstWhere((s) => s.id == supId, orElse: () => _supervisors.first);

        setState(() {
          _staffMembers[index] = {
            'id': result['id'],
            'first_name': result['first_name'],
            'last_name': result['last_name'],
            'email': result['email'],
            'phone': result['phone'],
            'role': roleObj,
            'department': result['department'],
            'supervisor_name': supervisorObj.fullName,
            'is_active': result['is_active'],
          };
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: widget.activeTheme.primaryColor,
            content: Text('Updated staff record for ${result['first_name']} ${result['last_name']}!'),
          ),
        );
      }
    }
  }

  void _toggleStaffStatus(int index) {
    setState(() {
      _staffMembers[index]['is_active'] = !(_staffMembers[index]['is_active'] as bool);
    });

    final isNowActive = _staffMembers[index]['is_active'] as bool;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isNowActive ? Colors.green : Colors.red,
        content: Text('${_staffMembers[index]['first_name']} ${_staffMembers[index]['last_name']} account ${isNowActive ? "Activated" : "Suspended"}!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;

    final filteredStaff = _staffMembers.where((staff) {
      final matchesRole = _selectedRoleFilter == 'All Roles' || (staff['role'] as UserRole).label == _selectedRoleFilter;
      final nameStr = '${staff['first_name']} ${staff['last_name']} ${staff['email']}'.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || nameStr.contains(_searchQuery.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HR Staff Directory & Role Assignment', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Manage company employees, assign user roles, and delegate direct supervisors.', style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _handleAddStaff,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Onboard New Employee'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // HR Metric Cards
          Row(
            children: [
              Expanded(child: _hrMetricCard('ACTIVE EMPLOYEES', '${_staffMembers.where((s) => s["is_active"] == true).length} Active', '100% Verified', Icons.badge, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _hrMetricCard('DEPARTMENTS', '5 Active', 'Sales, Marketing, Ops, Finance, HR', Icons.business, Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: _hrMetricCard('SUPERVISORS', '${_supervisors.length} Assigned', 'Direct Oversight Enabled', Icons.stars, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _hrMetricCard('SYSTEM ACCESS', '100% Secured', 'Row Level Security Active', Icons.security, Colors.green)),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter Bar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search by employee name or email...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedRoleFilter,
                    items: ['All Roles', ...UserRole.values.map((r) => r.label)].map((r) {
                      return DropdownMenuItem(value: r, child: Text('Filter: $r'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRoleFilter = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Staff Directory Table
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Contact Info', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Assigned System Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Assigned Supervisor', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filteredStaff.asMap().entries.map((entry) {
                  final index = entry.key;
                  final staff = entry.value;
                  final roleObj = staff['role'] as UserRole;
                  final isActive = staff['is_active'] as bool;

                  return DataRow(cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            radius: 18,
                            child: Text(
                              (staff['first_name'] as String).substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${staff['first_name']} ${staff['last_name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(staff['id'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(staff['email'], style: const TextStyle(fontSize: 12)),
                          Text(staff['phone'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(roleObj.label, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    DataCell(Text(staff['department'])),
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(staff['supervisor_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Suspended',
                          style: TextStyle(
                            color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                            onPressed: () => _handleEditStaff(staff),
                            tooltip: 'Edit Role / Supervisor',
                          ),
                          IconButton(
                            icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green, size: 18),
                            onPressed: () => _toggleStaffStatus(index),
                            tooltip: isActive ? 'Suspend Employee' : 'Activate Employee',
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hrMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
