import 'package:equatable/equatable.dart';

enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  agm('agm', 'Assistant General Manager'),
  hod('hod', 'Head of Department (HOD)'),
  assistantHod('assistant_hod', 'Assistant HOD (AHOD)'),
  hrManager('hr_manager', 'HR Manager'),
  inventoryManager('inventory_manager', 'GM Logistics / Inventory Manager'),
  supervisor('supervisor', 'Supervisor'),
  salesCallRep('sales_call_rep', 'Sales Call Rep'),
  logisticsCallRep('logistics_call_rep', 'Logistics Call Rep'),
  digitalMarketer('digital_marketer', 'Digital Marketer'),
  deliveryAgent('delivery_agent', 'Delivery Agent / Rider'),
  financeManager('finance_manager', 'Finance Manager');

  final String dbValue;
  final String label;
  const UserRole(this.dbValue, this.label);

  static UserRole fromDbValue(String value) {
    return UserRole.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => UserRole.salesCallRep,
    );
  }
}

class UserModel extends Equatable {
  final String id;
  final String? authUserId;
  final String companyId;
  final String? departmentId;
  final String? supervisorId;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? sipExtension;
  final String? sipPassword;
  final bool isActive;
  final bool canTakeCalls;
  final bool isActiveCallRep;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    this.authUserId,
    required this.companyId,
    this.departmentId,
    this.supervisorId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.sipExtension,
    this.sipPassword,
    required this.isActive,
    this.canTakeCalls = true,
    this.isActiveCallRep = true,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      authUserId: map['auth_user_id'],
      companyId: map['company_id'] ?? '',
      departmentId: map['department_id'],
      supervisorId: map['supervisor_id'],
      role: UserRole.fromDbValue(map['role'] ?? 'sales_call_rep'),
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      sipExtension: map['sip_extension'],
      sipPassword: map['sip_password'],
      isActive: map['is_active'] ?? true,
      canTakeCalls: map['can_take_calls'] ?? true,
      isActiveCallRep: map['is_active_call_rep'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'company_id': companyId,
      'department_id': departmentId,
      'supervisor_id': supervisorId,
      'role': role.dbValue,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'sip_extension': sipExtension,
      'sip_password': sipPassword,
      'is_active': isActive,
      'can_take_calls': canTakeCalls,
      'is_active_call_rep': isActiveCallRep,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        authUserId,
        companyId,
        departmentId,
        supervisorId,
        role,
        firstName,
        lastName,
        email,
        phone,
        sipExtension,
        sipPassword,
        isActive,
        canTakeCalls,
        isActiveCallRep,
      ];
}
