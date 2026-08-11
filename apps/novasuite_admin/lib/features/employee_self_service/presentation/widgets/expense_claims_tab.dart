import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';
import 'new_expense_claim_modal.dart';

class ExpenseClaimsTab extends StatelessWidget {
  const ExpenseClaimsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0D1F18) : Colors.white;
    final primaryColor = const Color(0xFF2563EB);

    final provider = context.watch<EmployeeSelfServiceProvider>();
    final claims = provider.expenseClaims;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Action Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expense Claims', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  Text('Create and manage your business expense claims.', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const NewExpenseClaimModal(),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text('New Expense Claim', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
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
                      Expanded(flex: 2, child: Text('POSTING DATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('CLAIMED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('SANCTIONED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 1, child: Text('ACTIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table Rows
                Expanded(
                  child: claims.isEmpty
                      ? Center(child: Text('No expense claims recorded yet.', style: GoogleFonts.inter(color: textMuted)))
                      : ListView.separated(
                          itemCount: claims.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final c = claims[index];
                            final status = c['approval_status'] ?? 'Draft';
                            final isApproved = status == 'Approved';
                            final claimedAmt = (c['total_claimed'] as num?)?.toDouble() ?? 0.0;
                            final sanctionedAmt = (c['total_sanctioned'] as num?)?.toDouble() ?? 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c['claim_code'] ?? 'EXP-CLAIM', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                        if (c['narration'] != null && (c['narration'] as String).isNotEmpty)
                                          Text(c['narration'], style: GoogleFonts.inter(fontSize: 11, color: textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Text(c['posting_date'] ?? '—', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                                  Expanded(flex: 2, child: Text('NGN ${claimedAmt.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                  Expanded(flex: 2, child: Text('NGN ${sanctionedAmt.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: textColor))),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isApproved ? const Color(0xFF10B981) : Colors.blue).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isApproved ? const Color(0xFF10B981) : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 16, color: textMuted),
                                      ],
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
