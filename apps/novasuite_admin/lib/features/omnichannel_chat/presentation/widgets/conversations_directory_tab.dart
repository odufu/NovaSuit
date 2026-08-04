import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'operations_channel_control_card.dart';
import 'initiate_conversation_dialog.dart';
import 'omnichannel_unified_chat_sheet.dart';

class ConversationsDirectoryTab extends StatefulWidget {
  final List<OrderModel> orders;
  final UserModel currentUser;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(OrderModel order) onStartVoiceCall;

  const ConversationsDirectoryTab({
    super.key,
    required this.orders,
    required this.currentUser,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onStartVoiceCall,
  });

  @override
  State<ConversationsDirectoryTab> createState() => _ConversationsDirectoryTabState();
}

class _ConversationsDirectoryTabState extends State<ConversationsDirectoryTab> {
  String _selectedChannelFilter = 'All'; // 'All', 'voice', 'whatsapp', 'sms'
  String _searchQuery = '';

  late List<ConversationModel> _conversations;

  @override
  void initState() {
    super.initState();
    _initConversationsList();
  }

  void _initConversationsList() {
    // Generate realistic mock conversations (some attached to orders, others open-ended)
    final List<ConversationModel> list = [];

    // Order-Bound Conversations
    for (int i = 0; i < widget.orders.length && i < 4; i++) {
      final o = widget.orders[i];
      list.add(
        ConversationModel(
          id: 'conv-ord-${o.id}',
          companyId: o.companyId,
          customerId: o.id,
          orderId: o.id,
          assignedRepId: widget.currentUser.id,
          customerName: o.customerName,
          customerPhone: o.customerPhone,
          primaryChannel: i % 2 == 0 ? CommChannelType.voiceCall : CommChannelType.whatsapp,
          status: 'active',
          lastMessageSummary: i % 2 == 0 ? '📞 Inbound PSTN Voice Call (02:45) • Recorded' : '💬 Client asked: "Can I pay cash on delivery in Ikeja?"',
          lastMessageAt: DateTime.now().subtract(Duration(minutes: i * 25 + 5)),
          createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
        ),
      );
    }

    // Open-Ended Conversations (No Order Attached)
    list.add(
      ConversationModel(
        id: 'conv-open-1',
        companyId: widget.currentUser.companyId,
        customerName: 'Alhaji Danjuma Kano',
        customerPhone: '+234 803 999 8811',
        assignedRepId: widget.currentUser.id,
        primaryChannel: CommChannelType.voiceCall,
        status: 'active',
        lastMessageSummary: '📞 Inbound Voice Call • Inquiry on Herbal Detox wholesale prices',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    );

    list.add(
      ConversationModel(
        id: 'conv-open-2',
        companyId: widget.currentUser.companyId,
        customerName: 'Mrs. Cynthia Okpara',
        customerPhone: '+234 812 444 5566',
        assignedRepId: widget.currentUser.id,
        primaryChannel: CommChannelType.whatsapp,
        status: 'active',
        lastMessageSummary: '💬 WhatsApp Message: "Hello NovaSuite, do you deliver to Port Harcourt airport?"',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 45)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    );

    _conversations = list;
  }

  void _openStartConversationModal() {
    showDialog(
      context: context,
      builder: (ctx) => InitiateConversationDialog(
        orders: widget.orders,
        onInitiate: (phone, channel, order) {
          if (channel == CommChannelType.voiceCall) {
            final targetOrder = order ?? OrderModel(
              id: 'inc-${DateTime.now().millisecondsSinceEpoch}',
              orderNumber: 'INC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              companyId: widget.currentUser.companyId,
              productId: 'tea-pack-1',
              salesRepId: widget.currentUser.id,
              customerName: 'Customer ($phone)',
              customerPhone: phone,
              deliveryState: 'Lagos',
              deliveryCity: 'Ikeja',
              deliveryAddress: 'Open-Ended Inquiry Call',
              status: OrderStatus.newOrder,
              paymentStatus: 'Pending COD',
              upsellStatus: UpsellStatus.none,
              quantity: 1,
              basePrice: 25000,
              upsellAmount: 0,
              downsellDiscount: 0,
              totalAmount: 25000,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            widget.onStartVoiceCall(targetOrder);
          } else {
            final targetOrder = order ?? OrderModel(
              id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
              orderNumber: 'OPEN-INQUIRY',
              companyId: widget.currentUser.companyId,
              productId: 'general',
              salesRepId: widget.currentUser.id,
              customerName: 'Customer ($phone)',
              customerPhone: phone,
              deliveryState: 'Lagos',
              deliveryCity: 'Ikeja',
              deliveryAddress: 'Open Omnichannel Chat',
              status: OrderStatus.newOrder,
              paymentStatus: 'Pending COD',
              upsellStatus: UpsellStatus.none,
              quantity: 1,
              basePrice: 0,
              upsellAmount: 0,
              downsellDiscount: 0,
              totalAmount: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            OmnichannelUnifiedChatSheet.show(
              context,
              order: targetOrder,
              currentUser: widget.currentUser,
              activeTheme: widget.activeTheme,
              isDarkMode: widget.isDarkMode,
              onStartCall: () => widget.onStartVoiceCall(targetOrder),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    final filtered = _conversations.where((c) {
      final matchesChannel = _selectedChannelFilter == 'All' ||
          (_selectedChannelFilter == 'voice' && c.primaryChannel == CommChannelType.voiceCall) ||
          (_selectedChannelFilter == 'whatsapp' && c.primaryChannel == CommChannelType.whatsapp) ||
          (_selectedChannelFilter == 'sms' && c.primaryChannel == CommChannelType.sms);

      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          (c.customerName?.toLowerCase().contains(query) ?? false) ||
          (c.customerPhone?.toLowerCase().contains(query) ?? false) ||
          (c.lastMessageSummary?.toLowerCase().contains(query) ?? false);

      return matchesChannel && matchesQuery;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streamlined Header Row (Compact & Space-saving)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Conversations (${_conversations.length})',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openStartConversationModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 16,
                        vertical: isMobile ? 8 : 12,
                      ),
                      visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.add_comment_rounded, size: isMobile ? 14 : 18),
                    label: Text(
                      isMobile ? '+ New' : 'Start New Conversation',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Compact Operations Channel Status Bar
              OperationsChannelControlCard(
                currentUser: widget.currentUser,
                isDarkMode: isDarkMode,
                isCompact: true,
              ),
              const SizedBox(height: 10),

              // Filter & Search Controls Bar (Responsive)
              if (isMobile) ...[
                Column(
                  children: [
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search by name, phone, or message content...',
                          hintStyle: TextStyle(fontSize: 11, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                          prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF10B981)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildChannelFilterChip('All', 'All Channels', isDarkMode),
                          const SizedBox(width: 6),
                          _buildChannelFilterChip('voice', '📞 Voice Calls', isDarkMode),
                          const SizedBox(width: 6),
                          _buildChannelFilterChip('whatsapp', '💬 WhatsApp', isDarkMode),
                          const SizedBox(width: 6),
                          _buildChannelFilterChip('sms', '📱 SMS', isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search conversations by name, phone, or message content...',
                            hintStyle: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF10B981)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildChannelFilterChip('All', 'All Channels', isDarkMode),
                    const SizedBox(width: 6),
                    _buildChannelFilterChip('voice', '📞 Voice Calls', isDarkMode),
                    const SizedBox(width: 6),
                    _buildChannelFilterChip('whatsapp', '💬 WhatsApp', isDarkMode),
                    const SizedBox(width: 6),
                    _buildChannelFilterChip('sms', '📱 SMS', isDarkMode),
                  ],
                ),
              ],
          const SizedBox(height: 16),

          // Conversations List View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 48, color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No conversations found matching filters!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return _buildConversationCard(c, isDarkMode, isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  },
);
}

  Widget _buildChannelFilterChip(String key, String label, bool isDarkMode) {
    final isSelected = _selectedChannelFilter == key;
    return FilterChip(
      selected: isSelected,
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onSelected: (val) => setState(() => _selectedChannelFilter = key),
      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
      backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade100,
      side: BorderSide(color: isSelected ? const Color(0xFF10B981) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
    );
  }

  Widget _buildConversationCard(ConversationModel c, bool isDarkMode, bool isMobile) {
    final timeStr = DateFormat('h:mm a • EEE, MMM d').format(c.lastMessageAt);
    final isVoice = c.primaryChannel == CommChannelType.voiceCall;
    final isWhatsApp = c.primaryChannel == CommChannelType.whatsapp;

    final matchingOrder = widget.orders.firstWhere(
      (o) => o.id == c.orderId,
      orElse: () => OrderModel(
        id: c.id,
        orderNumber: 'OPEN-INQUIRY',
        companyId: widget.currentUser.companyId,
        productId: 'general',
        salesRepId: widget.currentUser.id,
        customerName: c.customerName ?? 'Customer (${c.customerPhone})',
        customerPhone: c.customerPhone ?? 'Customer',
        deliveryState: 'Lagos',
        deliveryCity: 'Ikeja',
        deliveryAddress: 'Open Inquiry',
        status: OrderStatus.newOrder,
        paymentStatus: 'Pending COD',
        upsellStatus: UpsellStatus.none,
        quantity: 1,
        basePrice: 0,
        upsellAmount: 0,
        downsellDiscount: 0,
        totalAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (isMobile) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Customer Name + Badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isVoice
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : (isWhatsApp ? const Color(0xFF25D366).withValues(alpha: 0.15) : const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                    child: Icon(
                      isVoice ? Icons.phone_in_talk_rounded : (isWhatsApp ? Icons.chat_bubble_rounded : Icons.sms_rounded),
                      color: isVoice ? const Color(0xFF10B981) : (isWhatsApp ? const Color(0xFF25D366) : const Color(0xFF3B82F6)),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.customerName ?? 'Customer (${c.customerPhone})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: isDarkMode ? const Color(0xFF64748B) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.isOrderBound ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.isOrderBound ? const Color(0xFF10B981) : Colors.amber, width: 1),
                    ),
                    child: Text(
                      c.isOrderBound ? '#${matchingOrder.orderNumber}' : 'Open Inquiry',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: c.isOrderBound ? const Color(0xFF10B981) : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message Summary
              Text(
                c.lastMessageSummary ?? 'No recent messages',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => widget.onStartVoiceCall(matchingOrder),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                    label: const Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      OmnichannelUnifiedChatSheet.show(
                        context,
                        order: matchingOrder,
                        currentUser: widget.currentUser,
                        activeTheme: widget.activeTheme,
                        isDarkMode: isDarkMode,
                        onStartCall: () => widget.onStartVoiceCall(matchingOrder),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                      foregroundColor: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 14),
                    label: const Text('Open Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Channel Avatar Icon
            CircleAvatar(
              radius: 22,
              backgroundColor: isVoice
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : (isWhatsApp ? const Color(0xFF25D366).withValues(alpha: 0.15) : const Color(0xFF3B82F6).withValues(alpha: 0.15)),
              child: Icon(
                isVoice ? Icons.phone_in_talk_rounded : (isWhatsApp ? Icons.chat_bubble_rounded : Icons.sms_rounded),
                color: isVoice ? const Color(0xFF10B981) : (isWhatsApp ? const Color(0xFF25D366) : const Color(0xFF3B82F6)),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Customer Name & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.customerName ?? 'Customer (${c.customerPhone})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Order-Bound vs Open-Ended Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.isOrderBound ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.isOrderBound ? const Color(0xFF10B981) : Colors.amber, width: 1),
                        ),
                        child: Text(
                          c.isOrderBound ? 'Order #${matchingOrder.orderNumber}' : 'Open-Ended Inquiry',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: c.isOrderBound ? const Color(0xFF10B981) : Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.lastMessageSummary ?? 'No recent messages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Timestamp & Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: isDarkMode ? const Color(0xFF64748B) : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Voice Call Button
                    IconButton(
                      onPressed: () => widget.onStartVoiceCall(matchingOrder),
                      tooltip: 'Call Phone Number',
                      icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    // Omnichannel Chat Sheet Button
                    ElevatedButton.icon(
                      onPressed: () {
                        OmnichannelUnifiedChatSheet.show(
                          context,
                          order: matchingOrder,
                          currentUser: widget.currentUser,
                          activeTheme: widget.activeTheme,
                          isDarkMode: isDarkMode,
                          onStartCall: () => widget.onStartVoiceCall(matchingOrder),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                        foregroundColor: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.chat_outlined, size: 14),
                      label: const Text('Open Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
