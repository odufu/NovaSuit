import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class AddEditStaffDialog extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel? staffToEdit;
  final List<UserModel> availableSupervisors;

  const AddEditStaffDialog({
    super.key,
    required this.activeTheme,
    this.staffToEdit,
    required this.availableSupervisors,
  });

  @override
  State<AddEditStaffDialog> createState() => _AddEditStaffDialogState();
}

class _AddEditStaffDialogState extends State<AddEditStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late ValueNotifier<UserRole> _selectedRole;
  late ValueNotifier<String> _selectedDepartment;
  late ValueNotifier<String?> _selectedSupervisorId;
  late ValueNotifier<bool> _isActive;

  final List<String> _departments = [
    'Digital Marketing',
    'Sales Call Center',
    'Logistics Operations',
    'Finance & Reconciliation',
    'Human Resources',
  ];

  @override
  void initState() {
    super.initState();
    final staff = widget.staffToEdit;
    _firstNameController = TextEditingController(text: staff?.firstName ?? '');
    _lastNameController = TextEditingController(text: staff?.lastName ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _phoneController = TextEditingController(text: staff?.phone ?? '');

    _selectedRole = ValueNotifier<UserRole>(staff?.role ?? UserRole.salesCallRep);
    _selectedDepartment = ValueNotifier<String>(_departments[1]);
    _selectedSupervisorId = ValueNotifier<String?>(staff?.supervisorId ?? (widget.availableSupervisors.isNotEmpty ? widget.availableSupervisors.first.id : null));
    _isActive = ValueNotifier<bool>(staff?.isActive ?? true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _selectedRole.dispose();
    _selectedDepartment.dispose();
    _selectedSupervisorId.dispose();
    _isActive.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.staffToEdit != null;
      final staffData = {
        'id': isEditing ? widget.staffToEdit!.id : 'usr-${DateTime.now().millisecondsSinceEpoch}',
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole.value,
        'department': _selectedDepartment.value,
        'supervisor_id': _selectedSupervisorId.value,
        'is_active': _isActive.value,
      };

      Navigator.of(context).pop(staffData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staffToEdit != null;
    final theme = widget.activeTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.badge, color: theme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Employee Credentials' : 'Onboard New Staff Member',
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text('Assign User Role, Department & Direct Supervisor', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Name Fields Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('First Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _firstNameController,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(hint: 'e.g. Samuel'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lastNameController,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(hint: 'e.g. Supervisor'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email & Phone Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Work Email Address *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                            decoration: _inputDecoration(hint: 'staff@novacare.com'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            decoration: _inputDecoration(hint: '+234 803 000 0000'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role Assignment Dropdown
                const Text('Assign System Access Role *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ValueListenableBuilder<UserRole>(
                  valueListenable: _selectedRole,
                  builder: (context, roleVal, _) {
                    return DropdownButtonFormField<UserRole>(
                      initialValue: roleVal,
                      decoration: _inputDecoration(),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _selectedRole.value = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Department & Supervisor Selection Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Department *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          ValueListenableBuilder<String>(
                            valueListenable: _selectedDepartment,
                            builder: (context, deptVal, _) {
                              return DropdownButtonFormField<String>(
                                initialValue: deptVal,
                                decoration: _inputDecoration(),
                                items: _departments.map((dept) {
                                  return DropdownMenuItem(value: dept, child: Text(dept));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) _selectedDepartment.value = val;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Assigned Supervisor *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          ValueListenableBuilder<String?>(
                            valueListenable: _selectedSupervisorId,
                            builder: (context, supIdVal, _) {
                              return DropdownButtonFormField<String>(
                                initialValue: supIdVal,
                                decoration: _inputDecoration(),
                                items: widget.availableSupervisors.map((sup) {
                                  return DropdownMenuItem(
                                    value: sup.id,
                                    child: Text('${sup.fullName} (${sup.role.label})', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  _selectedSupervisorId.value = val;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account Status Switch
                ValueListenableBuilder<bool>(
                  valueListenable: _isActive,
                  builder: (context, activeVal, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Active Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(activeVal ? 'Employee is active and can sign in' : 'Employee access is suspended', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                        Switch(
                          value: activeVal,
                          activeThumbColor: Colors.green,
                          onChanged: (val) => _isActive.value = val,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: Icon(isEditing ? Icons.check : Icons.person_add, size: 18),
                      label: Text(isEditing ? 'Save Changes' : 'Onboard Employee'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
