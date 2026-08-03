enum CommChannelType {
  voiceCall('voice_call'),
  whatsapp('whatsapp'),
  sms('sms'),
  inApp('in_app');

  final String value;
  const CommChannelType(this.value);

  static CommChannelType fromString(String val) {
    return CommChannelType.values.firstWhere(
      (e) => e.value == val || e.name == val,
      orElse: () => CommChannelType.whatsapp,
    );
  }
}

enum MessageDirection {
  inbound('inbound'),
  outbound('outbound');

  final String value;
  const MessageDirection(this.value);

  static MessageDirection fromString(String val) {
    return MessageDirection.values.firstWhere(
      (e) => e.value == val || e.name == val,
      orElse: () => MessageDirection.outbound,
    );
  }
}

enum MessageDeliveryStatus {
  sending('sending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed');

  final String value;
  const MessageDeliveryStatus(this.value);

  static MessageDeliveryStatus fromString(String val) {
    return MessageDeliveryStatus.values.firstWhere(
      (e) => e.value == val || e.name == val,
      orElse: () => MessageDeliveryStatus.sent,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String? senderId;
  final String senderType; // 'sales_rep', 'customer', 'system', 'ai_bot'
  final CommChannelType channel;
  final MessageDirection direction;
  final String content;
  final String? mediaUrl;
  final String? mediaType; // 'image', 'audio_voicenote', 'pdf_receipt'
  final List<String> interactiveButtons;
  final MessageDeliveryStatus messageStatus;
  final String? externalMsgId;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    this.senderId,
    this.senderType = 'sales_rep',
    this.channel = CommChannelType.whatsapp,
    this.direction = MessageDirection.outbound,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.interactiveButtons = const [],
    this.messageStatus = MessageDeliveryStatus.sent,
    this.externalMsgId,
    required this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      senderId: map['sender_id'],
      senderType: map['sender_type'] ?? 'sales_rep',
      channel: CommChannelType.fromString(map['channel'] ?? 'whatsapp'),
      direction: MessageDirection.fromString(map['direction'] ?? 'outbound'),
      content: map['content'] ?? '',
      mediaUrl: map['media_url'],
      mediaType: map['media_type'],
      interactiveButtons: (map['interactive_buttons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      messageStatus: MessageDeliveryStatus.fromString(map['message_status'] ?? 'sent'),
      externalMsgId: map['external_msg_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType,
      'channel': channel.value,
      'direction': direction.value,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'interactive_buttons': interactiveButtons,
      'message_status': messageStatus.value,
      'external_msg_id': externalMsgId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
