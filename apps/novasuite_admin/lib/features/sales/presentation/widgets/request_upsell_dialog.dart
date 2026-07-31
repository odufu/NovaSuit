import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class RequestUpsellDialog extends StatefulWidget {
  final OrderModel order;
  final TenantTheme activeTheme;

  const RequestUpsellDialog({
    super.key,
    required this.order,
    required this.activeTheme,
  });

  @override
  State<RequestUpsellDialog> createState() => _RequestUpsellDialogState();
}

class _RequestUpsellDialogState extends State<RequestUpsellDialog> {
  // Upsell: positive quantity; Downsell: negative quantity
  int _upsellQuantity = 1;
  bool _isUpsell = true; // toggle: upsell vs downsell

  final _unitPriceController = TextEditingController();
  final _notesController = TextEditingController(text: 'Customer requested 1 extra Detox Tea Bottle');

  double _calculatedTotal = 0.0;
  double _unitPriceValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Default unit price to the order's base price per unit
    _unitPriceValue = widget.order.basePrice;
    _unitPriceController.text = widget.order.basePrice.toStringAsFixed(0);
    _recalculate();
    _unitPriceController.addListener(_onUnitPriceChanged);
  }

  @override
  void dispose() {
    _unitPriceController.removeListener(_onUnitPriceChanged);
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onUnitPriceChanged() {
    _unitPriceValue = double.tryParse(_unitPriceController.text) ?? 0.0;
    _recalculate();
  }

  void _recalculate() {
    final baseTotal = widget.order.basePrice * widget.order.quantity;
    final adjustment = _upsellQuantity * _unitPriceValue;
    setState(() {
      _calculatedTotal = _isUpsell
          ? baseTotal + adjustment
          : (baseTotal - adjustment).clamp(0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final currency = theme.currencySymbol;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color purple = isDarkMode ? const Color(0xFFC084FC) : Colors.purple.shade700;
    final Color purpleBg = isDarkMode ? const Color(0xFF2E1065) : Colors.purple.shade50;
    final Color cardBg = isDarkMode ? const Color(0xFF132A22) : Colors.grey.shade100;
    final Color cardBorder = isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200;
    final Color inputFill = isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade50;
    final Color inputBorder = isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300;
    final Color focusBorder = isDarkMode ? const Color(0xFF10B981) : theme.primaryColor;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final Color mutedColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600;

    final adjustmentAmount = _upsellQuantity * _unitPriceValue;
    final baseTotal = widget.order.basePrice * widget.order.quantity;

    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: purpleBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.trending_up, color: purple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Up-sell / Down-sell', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
                Text('Order #${widget.order.orderNumber}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: mutedColor)),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 460,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ─── Customer Info Card ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${widget.order.customerName}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 2),
                    Text('Phone: ${widget.order.customerPhone}', style: TextStyle(color: mutedColor, fontSize: 12)),
                    Text('Base Unit Price: $currency ${widget.order.basePrice.toStringAsFixed(0)}  ×  ${widget.order.quantity} units = $currency ${baseTotal.toStringAsFixed(0)}',
                        style: TextStyle(color: mutedColor, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ─── Upsell / Downsell Toggle ─────────────────────────────
              Row(
                children: [
                  _ToggleChip(
                    label: '⬆ Up-sell',
                    selected: _isUpsell,
                    activeColor: const Color(0xFF10B981),
                    isDarkMode: isDarkMode,
                    onTap: () { setState(() { _isUpsell = true; _recalculate(); }); },
                  ),
                  const SizedBox(width: 8),
                  _ToggleChip(
                    label: '⬇ Down-sell',
                    selected: !_isUpsell,
                    activeColor: const Color(0xFFEF4444),
                    isDarkMode: isDarkMode,
                    onTap: () { setState(() { _isUpsell = false; _recalculate(); }); },
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ─── Quantity Dropdown ────────────────────────────────────
              Text(
                _isUpsell ? 'Extra Units to Add' : 'Units to Remove',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: inputBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _upsellQuantity,
                    isExpanded: true,
                    dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    items: List.generate(10, (i) => i + 1).map((qty) {
                      return DropdownMenuItem<int>(
                        value: qty,
                        child: Text(
                          '$qty unit${qty > 1 ? "s" : ""}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() { _upsellQuantity = val; _recalculate(); });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // ─── Unit Price Input ─────────────────────────────────────
              Text('Price per Unit ($currency)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
              const SizedBox(height: 6),
              TextField(
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(
                  prefixText: '$currency ',
                  prefixStyle: TextStyle(color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: mutedColor),
                  helperText: 'e.g. $currency${widget.order.basePrice.toStringAsFixed(0)} for the same product, or a different bundle price',
                  helperStyle: TextStyle(fontSize: 10, color: mutedColor),
                  filled: true,
                  fillColor: inputFill,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: focusBorder, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Computed Adjustment Preview ──────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isUpsell
                      ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4))
                      : (isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFFF5F5)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isUpsell
                        ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF86EFAC))
                        : (isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isUpsell
                          ? '+$_upsellQuantity unit${_upsellQuantity > 1 ? "s" : ""} × $currency${_unitPriceValue.toStringAsFixed(0)}'
                          : '-$_upsellQuantity unit${_upsellQuantity > 1 ? "s" : ""} × $currency${_unitPriceValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      '${_isUpsell ? "+" : "-"}$currency ${adjustmentAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, fontWeight: FontWeight.bold,
                        color: _isUpsell ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Notes Input ──────────────────────────────────────────
              Text('Notes for Supervisor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: TextStyle(color: textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Reason for price/quantity change...',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: inputFill,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: focusBorder, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── New Total Banner ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Total COD Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.black87)),
                    Text(
                      '$currency ${_calculatedTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFF34D399) : Colors.green.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700,
            side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final qty = _isUpsell ? _upsellQuantity : -_upsellQuantity;
            Navigator.pop(context, {
              'upsell_quantity': qty,
              'upsell_unit_price': _unitPriceValue,
              'upsell_amount': _isUpsell ? adjustmentAmount : 0.0,
              'downsell_discount': _isUpsell ? 0.0 : adjustmentAmount,
              'new_total_amount': _calculatedTotal,
              'notes': _notesController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? const Color(0xFF10B981) : theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Submit for Supervisor Approval'),
        ),
      ],
    );
  }
}

/// Simple toggle chip widget
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: isDarkMode ? 0.25 : 0.15)
              : (isDarkMode ? const Color(0xFF132A22) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: selected ? activeColor : (isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}
