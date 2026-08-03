import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/omnichannel_chat_provider.dart';

class OmnichannelUnifiedChatSheet extends StatefulWidget {
  final OrderModel order;
  final UserModel currentUser;
  final TenantTheme activeTheme;
  final bool isDarkMode;

  const OmnichannelUnifiedChatSheet({
    super.key,
    required this.order,
    required this.currentUser,
    required this.activeTheme,
    required this.isDarkMode,
  });

  static void show(
    BuildContext context, {
    required OrderModel order,
    required UserModel currentUser,
    required TenantTheme activeTheme,
    required bool isDarkMode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider(
        create: (_) => OmnichannelChatProvider()
          ..loadConversationForOrder(
            companyId: currentUser.companyId,
            orderId: order.id,
            repId: currentUser.id,
          ),
        child: OmnichannelUnifiedChatSheet(
          order: order,
          currentUser: currentUser,
          activeTheme: activeTheme,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  @override
  State<OmnichannelUnifiedChatSheet> createState() => _OmnichannelUnifiedChatSheetState();
}

class _OmnichannelUnifiedChatSheetState extends State<OmnichannelUnifiedChatSheet> {
  final TextEditingController _textController = TextEditingController();
  CommChannelType _selectedChannel = CommChannelType.whatsapp;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OmnichannelChatProvider>();
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF132A22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Handle & Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Omnichannel Timeline • ${widget.order.customerName}',
                        style: GoogleFonts.outfit(fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.bold, color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Order #${widget.order.orderNumber} • ${widget.order.customerPhone}',
                        style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: textMuted,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Channel Filter Tabs & Quick Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', provider, isDark, theme),
                        _buildFilterChip('whatsapp', provider, isDark, theme, label: '💬 WhatsApp'),
                        _buildFilterChip('voice_call', provider, isDark, theme, label: '📞 Voice Calls'),
                        _buildFilterChip('sms', provider, isDark, theme, label: '📱 SMS Alerts'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Quick Templates',
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 4),
                        Text('Templates', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      ],
                    ),
                  ),
                  onSelected: (val) {
                    provider.triggerQuickTemplate(
                      repId: widget.currentUser.id,
                      templateName: val,
                      customerName: widget.order.customerName,
                      orderNumber: widget.order.orderNumber,
                      totalAmount: widget.order.totalAmount,
                    );
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'confirm_order', child: Text('✅ Send Order Confirmation')),
                    const PopupMenuItem(value: 'dispatch_alert', child: Text('🚚 Send Dispatch Alert')),
                  ],
                ),
              ],
            ),
          ),

          // Conversation Messages Timeline
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredMessages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages found for selected filter.',
                          style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredMessages.length,
                        itemBuilder: (ctx, index) {
                          final msg = provider.filteredMessages[index];
                          return _buildMessageBubble(msg, isDark, theme, cardBg, textPrimary, textMuted, borderColor);
                        },
                      ),
          ),

          // Message Composer Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9),
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<CommChannelType>(
                    value: _selectedChannel,
                    dropdownColor: cardBg,
                    items: const [
                      DropdownMenuItem(value: CommChannelType.whatsapp, child: Text('💬 WhatsApp', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: CommChannelType.sms, child: Text('📱 SMS', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: CommChannelType.voiceCall, child: Text('📞 Log Call', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedChannel = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: _selectedChannel == CommChannelType.whatsapp
                          ? 'Type WhatsApp message...'
                          : (_selectedChannel == CommChannelType.sms ? 'Type SMS message...' : 'Log call summary notes...'),
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      provider.sendOutboundMessage(
                        repId: widget.currentUser.id,
                        content: _textController.text.trim(),
                        channel: _selectedChannel,
                      );
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, OmnichannelChatProvider provider, bool isDark, TenantTheme theme, {String? label}) {
    final isSelected = provider.selectedChannelFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label ?? value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)))),
        selected: isSelected,
        selectedColor: theme.primaryColor,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        visualDensity: VisualDensity.compact,
        onSelected: (_) => provider.setChannelFilter(value),
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessageModel msg,
    bool isDark,
    TenantTheme theme,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
    Color borderColor,
  ) {
    final isOutbound = msg.direction == MessageDirection.outbound;
    final isSystem = msg.senderType == 'system';

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg.content,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutbound
              ? (isDark ? const Color(0xFF0C3B2E) : const Color(0xFFDCF8C6))
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isOutbound ? const Color(0xFF10B981).withValues(alpha: 0.3) : borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  msg.channel == CommChannelType.voiceCall
                      ? Icons.phone
                      : (msg.channel == CommChannelType.sms ? Icons.sms : Icons.chat),
                  size: 13,
                  color: isOutbound ? const Color(0xFF10B981) : theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  msg.channel.name.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 9.5, fontWeight: FontWeight.bold, color: textMuted),
                ),
                const Spacer(),
                Text(
                  '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(fontSize: 10, color: textMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.content,
              style: GoogleFonts.inter(fontSize: 13, color: textPrimary),
            ),
            if (msg.interactiveButtons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.interactiveButtons.map((btn) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Text(btn, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
