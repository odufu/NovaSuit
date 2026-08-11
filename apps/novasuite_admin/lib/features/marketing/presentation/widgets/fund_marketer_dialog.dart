import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class FundMarketerDialog extends StatefulWidget {
  final TenantTheme activeTheme;

  const FundMarketerDialog({
    super.key,
    required this.activeTheme,
  });

  @override
  State<FundMarketerDialog> createState() => _FundMarketerDialogState();
}

class _FundMarketerDialogState extends State<FundMarketerDialog> {
  final _amountController = TextEditingController(text: '500000');
  final _notesController =
      TextEditingController(text: 'Weekly Ad Campaign Budget Allocation');
  late ValueNotifier<String> _selectedMarketer;

  @override
  void initState() {
    super.initState();
    _selectedMarketer = ValueNotifier<String>('marketer.david@novacare.com');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _selectedMarketer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final currency = theme.currencySymbol;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.account_balance_wallet,
                color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AGM Ad Budget Allocation',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  'Credit ad funding to a Digital Marketer account',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select Marketer Account
            const Text('Digital Marketer Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            ValueListenableBuilder<String>(
              valueListenable: _selectedMarketer,
              builder: (context, marketerVal, _) {
                return DropdownButtonFormField<String>(
                  initialValue: marketerVal,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'marketer.david@novacare.com',
                        child: Text('👤 David Marketer (FB & TikTok Ads)')),
                    DropdownMenuItem(
                        value: 'marketer.alex@novacare.com',
                        child: Text('👤 Alex Marketer (Google Ads)')),
                  ],
                  onChanged: (val) {
                    if (val != null) _selectedMarketer.value = val;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Amount to Fund
            Text('Funding Amount ($currency)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '$currency ',
                hintText: '0.00',
                filled: true,
                fillColor: Colors.grey.shade50,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            const Text('Allocation Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Campaign authorization notes...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            Navigator.pop(context, {
              'marketer_email': _selectedMarketer.value,
              'amount': amount,
              'notes': _notesController.text,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text('Approve & Credit Budget'),
        ),
      ],
    );
  }
}
