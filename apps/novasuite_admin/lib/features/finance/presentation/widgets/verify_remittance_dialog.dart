import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class VerifyRemittanceDialog extends StatelessWidget {
  final String riderName;
  final double currentBalance;
  final double maxCreditLimit;
  final double remittedAmount;
  final TenantTheme activeTheme;

  const VerifyRemittanceDialog({
    super.key,
    required this.riderName,
    required this.currentBalance,
    required this.maxCreditLimit,
    required this.remittedAmount,
    required this.activeTheme,
  });

  @override
  Widget build(BuildContext context) {
    final currency = activeTheme.currencySymbol;
    final newBalance = (currentBalance - remittedAmount).clamp(0.0, double.infinity);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.verified_user, color: Colors.green.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Bank Deposit Receipt',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  'COD Remittance & Rider Credit Limit Clearance',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rider Information Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rider: $riderName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Current Unremitted Balance: $currency ${currentBalance.toStringAsFixed(0)}'),
                  Text('Max Credit Limit: $currency ${maxCreditLimit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Deposit Receipt Preview Mock
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.greenAccent, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Bank Deposit Receipt Uploaded',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Amount Deposited: $currency ${remittedAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Post-Verification Calculation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Remaining COD Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '$currency ${newBalance.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Reject Receipt'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Verify & Clear Rider Balance'),
        ),
      ],
    );
  }
}
