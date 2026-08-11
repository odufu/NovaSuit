import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';
import 'salary_slip_details_modal.dart';

class SalarySlipsTab extends StatelessWidget {
  const SalarySlipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0D1F18) : Colors.white;

    final provider = context.watch<EmployeeSelfServiceProvider>();
    final slips = provider.salarySlips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text('Salary Slips', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        Text('Review and download your monthly salary slips.', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
        const SizedBox(height: 20),

        // Data Table Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1813) : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('NAME', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('PERIOD', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('POSTING DATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('NET PAY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 1, child: Text('ACTION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table Rows
                Expanded(
                  child: slips.isEmpty
                      ? Center(child: Text('No salary slips found.', style: GoogleFonts.inter(color: textMuted)))
                      : ListView.separated(
                          itemCount: slips.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final s = slips[index];
                            final status = s['status'] ?? 'Submitted';
                            final isPaid = status == 'Paid';
                            final netPay = (s['net_pay'] as num?)?.toDouble() ?? 487000.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(s['slip_code'] ?? 'SAL-SLIP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                  ),
                                  Expanded(flex: 2, child: Text(s['period_label'] ?? '—', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                                  Expanded(flex: 2, child: Text(s['posting_date'] ?? '—', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                                  Expanded(flex: 2, child: Text('NGN ${netPay.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isPaid ? const Color(0xFF10B981) : Colors.blue).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isPaid ? const Color(0xFF10B981) : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => SalarySlipDetailsModal(slip: s),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility_outlined, size: 16, color: textColor),
                                          const SizedBox(width: 4),
                                          Text('View', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
