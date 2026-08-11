import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';
import '../widgets/employee_profile_tab.dart';
import '../widgets/leave_applications_tab.dart';
import '../widgets/expense_claims_tab.dart';
import '../widgets/salary_slips_tab.dart';

class EmployeeSelfServicePage extends StatefulWidget {
  final int initialTabIndex;

  const EmployeeSelfServicePage({super.key, this.initialTabIndex = 0});

  @override
  State<EmployeeSelfServicePage> createState() => _EmployeeSelfServicePageState();
}

class _EmployeeSelfServicePageState extends State<EmployeeSelfServicePage> {
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF07120E) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0D1F18) : Colors.white;
    final primaryColor = const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Breadcrumb & Overview Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee Self Service', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    Text(
                      'Manage profile details, leave requests, expense claims, and salary slips in one place.',
                      style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    context.read<EmployeeSelfServiceProvider>().fetchEmployeeProfileAndData();
                  },
                  icon: Icon(Icons.refresh, size: 20, color: textMuted),
                  tooltip: 'Refresh Employee Data',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main ESS Workspace Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Internal Navigation Sub-Sidebar
                  Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ESS MENU', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                        const SizedBox(height: 12),
                        _buildNavItem(0, 'Employee Profile', Icons.person_outline, primaryColor, textColor, textMuted, cardBg),
                        const SizedBox(height: 4),
                        _buildNavItem(1, 'Leave Applications', Icons.event_note_outlined, primaryColor, textColor, textMuted, cardBg),
                        const SizedBox(height: 4),
                        _buildNavItem(2, 'Expense Claims', Icons.receipt_long_outlined, primaryColor, textColor, textMuted, cardBg),
                        const SizedBox(height: 4),
                        _buildNavItem(3, 'Salary Slips', Icons.payments_outlined, primaryColor, textColor, textMuted, cardBg),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Tab Display View
                  Expanded(
                    child: IndexedStack(
                      index: _activeTabIndex,
                      children: const [
                        EmployeeProfileTab(),
                        LeaveApplicationsTab(),
                        ExpenseClaimsTab(),
                        SalarySlipsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, Color primaryColor, Color textColor, Color textMuted, Color cardBg) {
    final isSelected = _activeTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _activeTabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? primaryColor : textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primaryColor : textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
