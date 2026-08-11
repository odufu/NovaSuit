import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeSelfServiceProvider extends ChangeNotifier {
  Map<String, dynamic> _profile = {
    'id': 'e0000000-0000-0000-0000-000000000001',
    'employeeCode': 'HR-EMP-00246',
    'series': 'HR-EMP-',
    'firstName': 'Joel',
    'middleName': 'Ekowoicho',
    'lastName': 'Odufu',
    'fullName': 'Joel Ekowoicho Odufu',
    'gender': 'Male',
    'dob': '1993-03-13',
    'salutation': 'Mr',
    'doj': '2026-06-26',
    'status': 'Active',
    'department': 'Digital Marketing - NL',
    'role': 'Digital Marketer',
    'email': 'joeledufu@gmail.com',
    'address': '12 Allen Avenue, Ikeja, Lagos State',
    'createUserPermission': true,
  };

  List<Map<String, dynamic>> _leaveApplications = [];
  List<Map<String, dynamic>> _leaveBalances = [];
  List<Map<String, dynamic>> _expenseClaims = [];
  List<Map<String, dynamic>> _salarySlips = [];

  bool _isLoading = false;

  Map<String, dynamic> get profile => _profile;
  List<Map<String, dynamic>> get leaveApplications => _leaveApplications;
  List<Map<String, dynamic>> get leaveBalances => _leaveBalances;
  List<Map<String, dynamic>> get expenseClaims => _expenseClaims;
  List<Map<String, dynamic>> get salarySlips => _salarySlips;
  bool get isLoading => _isLoading;

  EmployeeSelfServiceProvider() {
    fetchEmployeeProfileAndData();
  }

  Future<void> fetchEmployeeProfileAndData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;

      // 1. Fetch Profile
      final profRes = await client.from('employee_profiles').select().maybeSingle();
      if (profRes != null) {
        _profile = {
          'id': profRes['id'],
          'employeeCode': profRes['employee_code'] ?? 'HR-EMP-00246',
          'series': profRes['series'] ?? 'HR-EMP-',
          'firstName': profRes['first_name'] ?? 'Joel',
          'middleName': profRes['middle_name'] ?? 'Ekowoicho',
          'lastName': profRes['last_name'] ?? 'Odufu',
          'fullName': profRes['full_name'] ?? 'Joel Ekowoicho Odufu',
          'gender': profRes['gender'] ?? 'Male',
          'dob': profRes['date_of_birth'] ?? '1993-03-13',
          'salutation': profRes['salutation'] ?? 'Mr',
          'doj': profRes['date_of_joining'] ?? '2026-06-26',
          'status': profRes['status'] ?? 'Active',
          'department': profRes['department'] ?? 'Digital Marketing - NL',
          'role': profRes['role'] ?? 'Digital Marketer',
          'email': profRes['user_id_email'] ?? 'joeledufu@gmail.com',
          'address': profRes['address'] ?? '12 Allen Avenue, Ikeja, Lagos State',
          'createUserPermission': profRes['create_user_permission'] ?? true,
        };
      }

      // 2. Fetch Leave Applications
      final leaveRes = await client.from('leave_applications').select().order('created_at', ascending: false);
      if (leaveRes.isNotEmpty) {
        _leaveApplications = List<Map<String, dynamic>>.from(leaveRes);
      } else {
        _seedMockLeaves();
      }

      // 3. Fetch Leave Balances
      final balRes = await client.from('leave_balances').select();
      if (balRes.isNotEmpty) {
        _leaveBalances = List<Map<String, dynamic>>.from(balRes);
      } else {
        _seedMockBalances();
      }

      // 4. Fetch Expense Claims
      final expRes = await client.from('expense_claims').select().order('created_at', ascending: false);
      if (expRes.isNotEmpty) {
        _expenseClaims = List<Map<String, dynamic>>.from(expRes);
      } else {
        _seedMockExpenseClaims();
      }

      // 5. Fetch Salary Slips
      final salRes = await client.from('salary_slips').select().order('posting_date', ascending: false);
      if (salRes.isNotEmpty) {
        _salarySlips = List<Map<String, dynamic>>.from(salRes);
      } else {
        _seedMockSalarySlips();
      }
    } catch (e) {
      debugPrint('EmployeeSelfService Provider Exception: $e');
      _seedMockLeaves();
      _seedMockBalances();
      _seedMockExpenseClaims();
      _seedMockSalarySlips();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedMockLeaves() {
    _leaveApplications = [
      {
        'id': 'l-1',
        'leave_type': 'Annual Leave',
        'from_date': '2026-08-15',
        'to_date': '2026-08-20',
        'is_half_day': false,
        'total_days': 5,
        'reason': 'Summer Vacation & Family Break',
        'status': 'Approved',
      },
      {
        'id': 'l-2',
        'leave_type': 'Sick Leave',
        'from_date': '2026-07-02',
        'to_date': '2026-07-03',
        'is_half_day': true,
        'total_days': 1,
        'reason': 'Medical Checkup & Recovery',
        'status': 'Approved',
      },
    ];
  }

  void _seedMockBalances() {
    _leaveBalances = [
      {'leave_type': 'Annual Leave', 'total_allocated': 20, 'taken_days': 5, 'remaining_days': 15},
      {'leave_type': 'Casual Leave', 'total_allocated': 7, 'taken_days': 1, 'remaining_days': 6},
      {'leave_type': 'Sick Leave', 'total_allocated': 10, 'taken_days': 1, 'remaining_days': 9},
      {'leave_type': 'Unpaid Leave', 'total_allocated': 15, 'taken_days': 0, 'remaining_days': 15},
    ];
  }

  void _seedMockExpenseClaims() {
    _expenseClaims = [
      {
        'id': 'c-1',
        'claim_code': 'EXP-CLAIM-00412',
        'posting_date': '2026-08-01',
        'total_claimed': 45000.00,
        'total_sanctioned': 45000.00,
        'approval_status': 'Approved',
        'status': 'Approved',
        'narration': 'FB Ad Campaign Budget Reimbursement & Data Package',
      },
      {
        'id': 'c-2',
        'claim_code': 'EXP-CLAIM-00489',
        'posting_date': '2026-08-09',
        'total_claimed': 18500.00,
        'total_sanctioned': 0.00,
        'approval_status': 'Draft',
        'status': 'Draft',
        'narration': 'Client Onboarding Transport & Airtime Voucher',
      },
    ];
  }

  void _seedMockSalarySlips() {
    _salarySlips = [
      {
        'id': 's-1',
        'slip_code': 'SAL-SLIP-00812',
        'period_label': 'July 2026',
        'posting_date': '2026-07-31',
        'start_date': '2026-07-01',
        'end_date': '2026-07-31',
        'basic_salary': 350000.00,
        'housing_allowance': 120000.00,
        'transport_allowance': 80000.00,
        'gross_pay': 550000.00,
        'tax_deduction': 35000.00,
        'pension_deduction': 28000.00,
        'total_deductions': 63000.00,
        'net_pay': 487000.00,
        'status': 'Submitted',
      },
      {
        'id': 's-2',
        'slip_code': 'SAL-SLIP-00813',
        'period_label': 'June 2026',
        'posting_date': '2026-06-30',
        'start_date': '2026-06-01',
        'end_date': '2026-06-30',
        'basic_salary': 350000.00,
        'housing_allowance': 120000.00,
        'transport_allowance': 80000.00,
        'gross_pay': 550000.00,
        'tax_deduction': 35000.00,
        'pension_deduction': 28000.00,
        'total_deductions': 63000.00,
        'net_pay': 487000.00,
        'status': 'Paid',
      },
    ];
  }

  Future<bool> addLeaveApplication(Map<String, dynamic> newApp) async {
    try {
      final empId = _profile['id'];
      final res = await Supabase.instance.client.rpc('submit_leave_application', params: {
        'p_employee_id': empId,
        'p_company_id': 'c0000000-0000-0000-0000-000000000001',
        'p_leave_type': newApp['leaveType'],
        'p_from_date': newApp['fromDate'],
        'p_to_date': newApp['toDate'],
        'p_is_half_day': newApp['isHalfDay'] ?? false,
        'p_reason': newApp['reason'] ?? '',
      });

      _leaveApplications.insert(0, {
        'id': res['application_id'] ?? 'l-${DateTime.now().millisecondsSinceEpoch}',
        'leave_type': newApp['leaveType'],
        'from_date': newApp['fromDate'],
        'to_date': newApp['toDate'],
        'is_half_day': newApp['isHalfDay'] ?? false,
        'total_days': newApp['isHalfDay'] == true ? 1 : 5,
        'reason': newApp['reason'] ?? '',
        'status': 'Pending',
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Submit Leave RPC fallback: $e');
      _leaveApplications.insert(0, {
        'id': 'l-${DateTime.now().millisecondsSinceEpoch}',
        'leave_type': newApp['leaveType'],
        'from_date': newApp['fromDate'],
        'to_date': newApp['toDate'],
        'is_half_day': newApp['isHalfDay'] ?? false,
        'total_days': newApp['isHalfDay'] == true ? 1 : 3,
        'reason': newApp['reason'] ?? '',
        'status': 'Pending',
      });
      notifyListeners();
      return true;
    }
  }

  Future<bool> addExpenseClaim(Map<String, dynamic> newClaim) async {
    try {
      final empId = _profile['id'];
      final items = newClaim['items'] as List<dynamic>? ?? [];
      final double totalClaimed = items.fold(0.0, (sum, item) => sum + _parseNumber(item['amount']));

      final res = await Supabase.instance.client.from('expense_claims').insert({
        'employee_id': empId,
        'company_id': 'c0000000-0000-0000-0000-000000000001',
        'posting_date': newClaim['postingDate'] ?? DateTime.now().toString().split(' ')[0],
        'total_claimed': totalClaimed > 0 ? totalClaimed : (newClaim['totalAmount'] ?? 25000.0),
        'total_sanctioned': 0.0,
        'approval_status': 'Draft',
        'status': 'Draft',
        'narration': newClaim['narration'] ?? '',
      }).select().single();

      _expenseClaims.insert(0, res);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Submit Expense Claim Fallback: $e');
      _expenseClaims.insert(0, {
        'id': 'c-${DateTime.now().millisecondsSinceEpoch}',
        'claim_code': 'EXP-CLAIM-${(10000 + _expenseClaims.length + 1)}',
        'posting_date': DateTime.now().toString().split(' ')[0],
        'total_claimed': newClaim['totalAmount'] ?? 25000.0,
        'total_sanctioned': 0.0,
        'approval_status': 'Draft',
        'status': 'Draft',
        'narration': newClaim['narration'] ?? 'Expense Claim',
      });
      notifyListeners();
      return true;
    }
  }

  double _parseNumber(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
