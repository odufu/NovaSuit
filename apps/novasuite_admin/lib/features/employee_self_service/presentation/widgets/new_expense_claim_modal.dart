import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';

class NewExpenseClaimModal extends StatefulWidget {
  const NewExpenseClaimModal({super.key});

  @override
  State<NewExpenseClaimModal> createState() => _NewExpenseClaimModalState();
}

class _NewExpenseClaimModalState extends State<NewExpenseClaimModal> {
  final TextEditingController _postingDateController = TextEditingController(text: '2026-08-11');
  final TextEditingController _narrationController = TextEditingController();

  List<Map<String, dynamic>> _items = [
    {
      'date': '2026-08-11',
      'type': 'Marketing & Ads',
      'description': 'FB Ad Campaign Budget Refill',
      'amount': 25000.0,
    }
  ];

  bool _isSubmitting = false;

  final List<String> _expenseTypes = [
    'Marketing & Ads',
    'Travel & Transport',
    'Client Entertainment',
    'Office Supplies',
    'Internet & Airtime',
  ];

  double get _totalClaimed => _items.fold(0.0, (sum, i) => sum + (i['amount'] as num).toDouble());

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
    final profile = provider.profile;

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Text('New Expense Claim', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 2),
              Text('Capture the full expense claim details before saving.', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
              const SizedBox(height: 16),

              // Overview Section Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSummaryBox('EMPLOYEE', profile['fullName'] ?? 'Joel Odufu', borderColor, textColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('COMPANY', 'NovaCare Ltd', borderColor, textColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('DEPARTMENT', profile['department'] ?? 'Digital Marketing - NL', borderColor, textColor, textMuted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSummaryBox('SERIES', 'EXP-CLAIM-', borderColor, textColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('APPROVAL STATUS', 'Draft', borderColor, textColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('DOCSTATUS', 'Draft', borderColor, textColor, textMuted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSummaryBox('TOTAL CLAIMED', 'NGN ${_totalClaimed.toStringAsFixed(0)}', borderColor, primaryColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('TOTAL SANCTIONED', 'NGN 0', borderColor, textColor, textMuted),
                        const SizedBox(width: 8),
                        _buildSummaryBox('TOTAL REIMBURSED', 'NGN 0', borderColor, textColor, textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Claim Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Details', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Posting Date', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _postingDateController,
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Expense Items Table
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Expenses Items', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _items.add({
                                'date': _postingDateController.text,
                                'type': 'Travel & Transport',
                                'description': 'Logistics & Taxi Fare',
                                'amount': 5000.0,
                              });
                            });
                          },
                          icon: Icon(Icons.add, size: 14, color: textColor),
                          label: Text('Add row', style: GoogleFonts.inter(fontSize: 11, color: textColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Items Grid Table
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 2, child: Text('Date', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                            Expanded(flex: 3, child: Text('Expense Type', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                            Expanded(flex: 3, child: Text('Description', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                            Expanded(flex: 2, child: Text('Amount (NGN)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                            Expanded(flex: 1, child: Text('Action', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                          ],
                        ),
                        const Divider(height: 12),
                        ..._items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(item['date'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                                Expanded(
                                  flex: 3,
                                  child: DropdownButton<String>(
                                    value: _expenseTypes.contains(item['type']) ? item['type'] : _expenseTypes.first,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: dialogBg,
                                    style: GoogleFonts.inter(fontSize: 12, color: textColor),
                                    items: _expenseTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => item['type'] = val);
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: TextEditingController(text: item['description'] ?? '')..selection = TextSelection.collapsed(offset: (item['description'] ?? '').length),
                                    style: GoogleFonts.inter(fontSize: 12, color: textColor),
                                    onChanged: (val) => item['description'] = val,
                                    decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: TextEditingController(text: (item['amount'] as num).toStringAsFixed(0)),
                                    style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => setState(() => item['amount'] = double.tryParse(val) ?? 0.0),
                                    decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      if (_items.length > 1) {
                                        setState(() => _items.removeAt(idx));
                                      }
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Narration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Narration', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _narrationController,
                      maxLines: 2,
                      style: GoogleFonts.inter(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter expense justification...',
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

              // Footer Action
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
                            await provider.addExpenseClaim({
                              'postingDate': _postingDateController.text,
                              'totalAmount': _totalClaimed,
                              'narration': _narrationController.text,
                              'items': _items,
                            });
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense claim created successfully!'),
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
                        : Text('Create Claim', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color borderColor, Color valueColor, Color textMuted) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: textMuted)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
