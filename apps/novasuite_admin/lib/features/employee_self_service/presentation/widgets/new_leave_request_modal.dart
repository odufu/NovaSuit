import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';

class NewLeaveRequestModal extends StatefulWidget {
  const NewLeaveRequestModal({super.key});

  @override
  State<NewLeaveRequestModal> createState() => _NewLeaveRequestModalState();
}

class _NewLeaveRequestModalState extends State<NewLeaveRequestModal> {
  String _selectedLeaveType = 'Annual Leave';
  final TextEditingController _fromDateController = TextEditingController(text: '2026-08-20');
  final TextEditingController _toDateController = TextEditingController(text: '2026-08-25');
  final TextEditingController _reasonController = TextEditingController();
  bool _isHalfDay = false;
  bool _isSubmitting = false;

  final List<String> _leaveTypes = [
    'Annual Leave',
    'Casual Leave',
    'Sick Leave',
    'Maternity / Paternity Leave',
    'Unpaid Leave',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF0D1F18) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0A1813) : const Color(0xFFF8FAFC);
    final primaryColor = const Color(0xFF2563EB);

    final provider = context.watch<EmployeeSelfServiceProvider>();
    final currentBal = provider.leaveBalances.firstWhere(
      (b) => b['leave_type'] == _selectedLeaveType,
      orElse: () => {'remaining_days': 15, 'taken_days': 5},
    );

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'New Leave Application',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill the same core details used in ERPNext leave requests before submission.',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted),
              ),
              const SizedBox(height: 20),

              // Section: Leave Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave Details', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 12),

                    // Row 1: Leave Type & From Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Leave Type', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedLeaveType,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: dialogBg,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                ),
                                style: GoogleFonts.inter(fontSize: 13, color: textColor),
                                dropdownColor: dialogBg,
                                items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedLeaveType = val);
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
                              Text('From Date', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _fromDateController,
                                style: GoogleFonts.inter(fontSize: 13, color: textColor),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.calendar_today, size: 16, color: textMuted),
                                  filled: true,
                                  fillColor: dialogBg,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: To Date & Half Day Toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('To Date', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _toDateController,
                                style: GoogleFonts.inter(fontSize: 13, color: textColor),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.calendar_today, size: 16, color: textMuted),
                                  filled: true,
                                  fillColor: dialogBg,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Half Day', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Switch(
                                    value: _isHalfDay,
                                    activeColor: primaryColor,
                                    onChanged: (val) => setState(() => _isHalfDay = val),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_isHalfDay ? 'Yes' : 'No', style: GoogleFonts.inter(fontSize: 13, color: textColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Leave Balance Insight Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dialogBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LEAVE BALANCE INSIGHT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            '$_selectedLeaveType: ${currentBal['remaining_days'] ?? 15} days remaining (${currentBal['taken_days'] ?? 0} days taken).',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section: Reason
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter detailed reason or handoff instructions...',
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
                        filled: true,
                        fillColor: dialogBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close', style: GoogleFonts.inter(color: textMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            await provider.addLeaveApplication({
                              'leaveType': _selectedLeaveType,
                              'fromDate': _fromDateController.text,
                              'toDate': _toDateController.text,
                              'isHalfDay': _isHalfDay,
                              'reason': _reasonController.text,
                            });
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Leave application submitted successfully!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
