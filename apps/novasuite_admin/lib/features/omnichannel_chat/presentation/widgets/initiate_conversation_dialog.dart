import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class InitiateConversationDialog extends StatefulWidget {
  final List<OrderModel> orders;
  final Function(String phone, CommChannelType channel, OrderModel? order) onInitiate;

  const InitiateConversationDialog({
    super.key,
    required this.orders,
    required this.onInitiate,
  });

  @override
  State<InitiateConversationDialog> createState() => _InitiateConversationDialogState();
}

class _InitiateConversationDialogState extends State<InitiateConversationDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  CommChannelType _selectedChannel = CommChannelType.voiceCall;
  OrderModel? _selectedOrder;
  bool _isOpenEnded = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_comment_rounded, color: Color(0xFF10B981), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Start New Conversation',
                        style: GoogleFonts.outfit(
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Initiate an outbound Voice Call, WhatsApp chat, or SMS session.',
                style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Channel Selection Pills
              Text('SELECT OMNICHANNEL CHANNEL', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChannelChoicePill(CommChannelType.voiceCall, '📞 Voice Call', isDarkMode),
                  const SizedBox(width: 8),
                  _buildChannelChoicePill(CommChannelType.whatsapp, '💬 WhatsApp', isDarkMode),
                  const SizedBox(width: 8),
                  _buildChannelChoicePill(CommChannelType.sms, '📱 SMS', isDarkMode),
                ],
              ),
              const SizedBox(height: 18),

              // Phone Number Field
              Text('DESTINATION PHONE NUMBER', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. 08012345678 or +2348012345678',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey.shade500, fontSize: 12),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 16),

              // Open-Ended vs Order Attachment Segmented Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONVERSATION TYPE',
                    style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                  ),
                  Row(
                    children: [
                      FilterChip(
                        selected: _isOpenEnded,
                        label: const Text('Open-Ended Inquiry', style: TextStyle(fontSize: 11)),
                        onSelected: (val) => setState(() => _isOpenEnded = true),
                        selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        selected: !_isOpenEnded,
                        label: const Text('Attach to Order', style: TextStyle(fontSize: 11)),
                        onSelected: (val) => setState(() => _isOpenEnded = false),
                        selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dropdown for Order Attachment if not open-ended
              if (!_isOpenEnded) ...[
                DropdownButtonFormField<OrderModel>(
                  initialValue: _selectedOrder ?? (widget.orders.isNotEmpty ? widget.orders.first : null),
                  dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Select Customer Order',
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: widget.orders.map((o) {
                    return DropdownMenuItem(
                      value: o,
                      child: Text('${o.customerName} (${o.customerPhone}) - #${o.orderNumber}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedOrder = val),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isEmpty && _selectedOrder == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a phone number or select an order!')),
                      );
                      return;
                    }
                    final targetPhone = phone.isNotEmpty ? phone : (_selectedOrder?.customerPhone ?? '');
                    Navigator.pop(context);
                    widget.onInitiate(targetPhone, _selectedChannel, _isOpenEnded ? null : _selectedOrder);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(_selectedChannel == CommChannelType.voiceCall ? Icons.phone_in_talk : Icons.send_rounded, size: 18),
                  label: Text(
                    'Start Conversation (${_selectedChannel.value})',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelChoicePill(CommChannelType channel, String label, bool isDarkMode) {
    final isSelected = _selectedChannel == channel;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedChannel = channel),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }
}
