import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';

class OmnichannelRepository {
  final SupabaseClient _client;

  OmnichannelRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch or create a conversation thread for a given order & customer
  Future<ConversationModel> fetchOrCreateConversation({
    required String companyId,
    required String orderId,
    required String repId,
  }) async {
    try {
      final response = await _client
          .from('conversations')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (response != null) {
        return ConversationModel.fromMap(response);
      }

      // Create new conversation thread
      final newConv = await _client
          .from('conversations')
          .insert({
            'company_id': companyId,
            'order_id': orderId,
            'assigned_rep_id': repId,
            'primary_channel': 'whatsapp',
            'status': 'active',
            'last_message_summary': 'Conversation initialized',
          })
          .select()
          .single();

      return ConversationModel.fromMap(newConv);
    } catch (_) {
      // Fallback mock conversation
      return getMockConversation(orderId: orderId, repId: repId);
    }
  }

  /// Fetch messages for a specific conversation thread
  Future<List<ChatMessageModel>> fetchMessages(String conversationId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final list = (response as List).map((json) => ChatMessageModel.fromMap(json)).toList();
      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {
      // Fallback to rich mock messages
    }
    return getMockMessages(conversationId);
  }

  /// Send outbound message (WhatsApp / SMS / Call Log)
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    CommChannelType channel = CommChannelType.whatsapp,
    String? mediaUrl,
    String? mediaType,
    List<String> interactiveButtons = const [],
  }) async {
    try {
      final response = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'sender_type': 'sales_rep',
            'channel': channel.value,
            'direction': 'outbound',
            'content': content,
            'media_url': mediaUrl,
            'media_type': mediaType,
            'interactive_buttons': interactiveButtons,
            'message_status': 'sent',
          })
          .select()
          .single();

      return ChatMessageModel.fromMap(response);
    } catch (_) {
      // Return generated offline mock message
      return ChatMessageModel(
        id: 'msg-local-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderType: 'sales_rep',
        channel: channel,
        direction: MessageDirection.outbound,
        content: content,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        interactiveButtons: interactiveButtons,
        messageStatus: MessageDeliveryStatus.sent,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Realtime Stream of Messages
  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .map((data) => data.map((json) => ChatMessageModel.fromMap(json)).toList());
    } catch (_) {
      return Stream.value(getMockMessages(conversationId));
    }
  }

  // ==========================================================================
  // MOCK DATA ENGINE: Keeps track of sample conversations & multi-channel threads
  // ==========================================================================

  ConversationModel getMockConversation({required String orderId, String? repId}) {
    return ConversationModel(
      id: 'conv-$orderId',
      companyId: '11111111-1111-4111-8111-111111111111',
      orderId: orderId,
      assignedRepId: repId ?? '30000000-0000-4000-8000-000000000003',
      primaryChannel: CommChannelType.whatsapp,
      status: 'active',
      lastMessageSummary: 'Customer confirmed delivery address over WhatsApp!',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    );
  }

  List<ChatMessageModel> getMockMessages(String conversationId) {
    final now = DateTime.now();
    return [
      ChatMessageModel(
        id: 'msg-1',
        conversationId: conversationId,
        senderType: 'system',
        channel: CommChannelType.inApp,
        direction: MessageDirection.outbound,
        content: '📦 Order #ORD-849201 created & assigned to Call Rep John.',
        messageStatus: MessageDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      ChatMessageModel(
        id: 'msg-2',
        conversationId: conversationId,
        senderType: 'sales_rep',
        channel: CommChannelType.voiceCall,
        direction: MessageDirection.outbound,
        content: '📞 Outbound Voice Call via IT Sky (07003100077) • Duration: 3m 42s',
        mediaUrl: 'https://cdn.novasuite.app/recordings/rec-849201.mp3',
        mediaType: 'audio_voicenote',
        messageStatus: MessageDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(hours: 3, minutes: 45)),
      ),
      ChatMessageModel(
        id: 'msg-3',
        conversationId: conversationId,
        senderType: 'sales_rep',
        channel: CommChannelType.whatsapp,
        direction: MessageDirection.outbound,
        content: 'Hello Amina! 👋 Thank you for speaking with NovaCare. Here is your order summary for Grazer Herbal Detox Tea (₦25,000). Please tap below to confirm delivery:',
        interactiveButtons: ['Confirm Order ✅', 'Reschedule Delivery 📅'],
        messageStatus: MessageDeliveryStatus.read,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ChatMessageModel(
        id: 'msg-4',
        conversationId: conversationId,
        senderType: 'customer',
        channel: CommChannelType.whatsapp,
        direction: MessageDirection.inbound,
        content: 'Yes! Please deliver to 14 Allen Avenue, Ikeja tomorrow morning by 10 AM.',
        messageStatus: MessageDeliveryStatus.read,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      ChatMessageModel(
        id: 'msg-5',
        conversationId: conversationId,
        senderType: 'sales_rep',
        channel: CommChannelType.whatsapp,
        direction: MessageDirection.outbound,
        content: 'Awesome! I have upgraded your package with 1 Extra Detox Bottle (+₦10,000). Total: ₦35,000.',
        messageStatus: MessageDeliveryStatus.read,
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      ChatMessageModel(
        id: 'msg-6',
        conversationId: conversationId,
        senderType: 'customer',
        channel: CommChannelType.whatsapp,
        direction: MessageDirection.inbound,
        content: 'Perfect, thank you! Send the rider receipt when dispatched.',
        messageStatus: MessageDeliveryStatus.read,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      ChatMessageModel(
        id: 'msg-7',
        conversationId: conversationId,
        senderType: 'system',
        channel: CommChannelType.sms,
        direction: MessageDirection.outbound,
        content: '📱 SMS Alert Sent: NovaCare Order #ORD-849201 is Dispatched via NovaExpress Rider Emeka (+2347015558899).',
        messageStatus: MessageDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}
