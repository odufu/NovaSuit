import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalarySlipDetailsModal extends StatelessWidget {
  final Map<String, dynamic> slip;

  const SalarySlipDetailsModal({super.key, required this.slip});

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

    final slipCode = slip['slip_code'] ?? 'SAL-SLIP-00812';
    final period = slip['period_label'] ?? 'July 2026';
    final postingDate = slip['posting_date'] ?? '2026-07-31';

    final basic = (slip['basic_salary'] as num?)?.toDouble() ?? 350000.0;
    final housing = (slip['housing_allowance'] as num?)?.toDouble() ?? 120000.0;
    final transport = (slip['transport_allowance'] as num?)?.toDouble() ?? 80000.0;
    final gross = (slip['gross_pay'] as num?)?.toDouble() ?? (basic + housing + transport);

    final tax = (slip['tax_deduction'] as num?)?.toDouble() ?? 35000.0;
    final pension = (slip['pension_deduction'] as num?)?.toDouble() ?? 28000.0;
    final totalDeductions = (slip['total_deductions'] as num?)?.toDouble() ?? (tax + pension);

    final netPay = (slip['net_pay'] as num?)?.toDouble() ?? (gross - totalDeductions);

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slipCode, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Text('Period: $period | Posting Date: $postingDate', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  _buildStatCard('GROSS PAY', 'NGN ${gross.toStringAsFixed(0)}', cardBg, borderColor, textColor, textMuted),
                  const SizedBox(width: 12),
                  _buildStatCard('DEDUCTIONS', 'NGN ${totalDeductions.toStringAsFixed(0)}', cardBg, borderColor, Colors.red, textMuted),
                  const SizedBox(width: 12),
                  _buildStatCard('NET PAY', 'NGN ${netPay.toStringAsFixed(0)}', cardBg, borderColor, const Color(0xFF10B981), textMuted),
                ],
              ),
              const SizedBox(height: 20),

              // Breakdowns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Earnings Column
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EARNINGS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                          const Divider(height: 16),
                          _buildLineItem('Basic Salary', basic, textColor, textMuted),
                          _buildLineItem('Housing Allowance', housing, textColor, textMuted),
                          _buildLineItem('Transport Allowance', transport, textColor, textMuted),
                          const Divider(height: 16),
                          _buildLineItem('TOTAL GROSS', gross, textColor, textMuted, isBold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Deductions Column
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DEDUCTIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                          const Divider(height: 16),
                          _buildLineItem('PAYE Income Tax', tax, textColor, textMuted),
                          _buildLineItem('RSA Pension Contribution', pension, textColor, textMuted),
                          const Divider(height: 16),
                          _buildLineItem('TOTAL DEDUCTIONS', totalDeductions, textColor, textMuted, isBold: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Download Button Action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Salary slip PDF downloaded successfully!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: Icon(Icons.picture_as_pdf, size: 16, color: primaryColor),
                    label: Text('Download PDF', style: GoogleFonts.inter(fontSize: 12, color: primaryColor)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bg, Color border, Color valColor, Color textMuted) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: valColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(String title, double amount, Color textColor, Color textMuted, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? textColor : textMuted)),
          Text('NGN ${amount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: textColor)),
        ],
      ),
    );
  }
}
