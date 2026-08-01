import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/hr_provider.dart';
import '../widgets/add_edit_staff_dialog.dart';

class HRStaffManagementPage extends StatelessWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;

  const HRStaffManagementPage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
  });

  // Sample Supervisors List
  static final List<UserModel> _supervisors = [
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

  void _handleAddStaff(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditStaffDialog(
        activeTheme: activeTheme,
        availableSupervisors: _supervisors,
      ),
    );

    if (result != null) {
      final roleObj = result['role'] as UserRole;
      final supId = result['supervisor_id'] as String?;
      final supervisorObj = _supervisors.firstWhere((s) => s.id == supId, orElse: () => _supervisors.first);

      if (!context.mounted) return;
      context.read<HRProvider>().addStaff({
        'id': result['id'],
        'name': '${result['first_name']} ${result['last_name']}',
        'first_name': result['first_name'],
        'last_name': result['last_name'],
        'email': result['email'],
        'phone': result['phone'],
        'role': roleObj.label,
        'department': result['department'],
        'supervisor_name': supervisorObj.fullName,
        'status': result['is_active'] ? 'Active' : 'Suspended',
        'is_active': result['is_active'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Onboarded ${result['first_name']} ${result['last_name']} as ${roleObj.label}!'),
        ),
      );
    }
  }

  void _handleEditStaff(BuildContext context, Map<String, dynamic> staff) async {
    final userModel = UserModel(
      id: staff['id'] ?? 'usr-001',
      companyId: currentUser.companyId,
      role: UserRole.salesCallRep,
      firstName: staff['first_name'] ?? (staff['name'] != null ? (staff['name'] as String).split(' ').first : 'John'),
      lastName: staff['last_name'] ?? (staff['name'] != null ? (staff['name'] as String).split(' ').last : 'Doe'),
      email: staff['email'] ?? '',
      phone: staff['phone'] ?? '',
      isActive: staff['status'] == 'Active' || staff['is_active'] == true,
      createdAt: DateTime.now(),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditStaffDialog(
        activeTheme: activeTheme,
        staffToEdit: userModel,
        availableSupervisors: _supervisors,
      ),
    );

    if (result != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: activeTheme.primaryColor,
          content: Text('Updated staff record for ${result['first_name']} ${result['last_name']}!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hrProvider = context.watch<HRProvider>();
    final theme = activeTheme;
    final filteredStaff = hrProvider.filteredStaff;
    final staffMembers = hrProvider.staffMembers;

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
                onPressed: () => _handleAddStaff(context),
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
              Expanded(child: _hrMetricCard('ACTIVE EMPLOYEES', '${staffMembers.where((s) => s["status"] == "Active" || s["is_active"] == true).length} Active', '100% Verified', Icons.badge, Colors.blue)),
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
                      onChanged: (val) => context.read<HRProvider>().setSearchQuery(val),
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
                    value: hrProvider.selectedRoleFilter,
                    items: ['All', ...UserRole.values.map((r) => r.label)].map((r) {
                      return DropdownMenuItem(value: r, child: Text('Filter: $r'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) context.read<HRProvider>().setRoleFilter(val);
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
                  final roleStr = staff['role'] as String? ?? 'Staff';
                  final isActive = staff['status'] == 'Active' || staff['is_active'] == true;
                  final nameStr = staff['name'] as String? ?? '${staff["first_name"]} ${staff["last_name"]}';

                  return DataRow(cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            radius: 18,
                            child: Text(
                              nameStr.isNotEmpty ? nameStr.substring(0, 1) : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nameStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(staff['id'] ?? 'usr-00', style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
                          Text(staff['email'] ?? '', style: const TextStyle(fontSize: 12)),
                          Text(staff['phone'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(roleStr, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    DataCell(Text(staff['department'] ?? 'General')),
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(staff['supervisor_name'] ?? 'Samuel Supervisor', style: const TextStyle(fontWeight: FontWeight.w600)),
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
                            onPressed: () => _handleEditStaff(context, staff),
                            tooltip: 'Edit Role / Supervisor',
                          ),
                          IconButton(
                            icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green, size: 18),
                            onPressed: () {
                              context.read<HRProvider>().toggleStaffActive(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: isActive ? Colors.red : Colors.green,
                                  content: Text('$nameStr account ${isActive ? "Suspended" : "Activated"}!'),
                                ),
                              );
                            },
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
