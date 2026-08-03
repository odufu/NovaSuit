import 'chat_message.dart';

class ConversationModel {
  final String id;
  final String companyId;
  final String? customerId;
  final String? orderId;
  final String? assignedRepId;
  final CommChannelType primaryChannel;
  final String status;
  final String? lastMessageSummary;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.companyId,
    this.customerId,
    this.orderId,
    this.assignedRepId,
    this.primaryChannel = CommChannelType.whatsapp,
    this.status = 'active',
    this.lastMessageSummary,
    required this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      customerId: map['customer_id'],
      orderId: map['order_id'],
      assignedRepId: map['assigned_rep_id'],
      primaryChannel: CommChannelType.fromString(map['primary_channel'] ?? 'whatsapp'),
      status: map['status'] ?? 'active',
      lastMessageSummary: map['last_message_summary'],
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'])
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'order_id': orderId,
      'assigned_rep_id': assignedRepId,
      'primary_channel': primaryChannel.value,
      'status': status,
      'last_message_summary': lastMessageSummary,
      'last_message_at': lastMessageAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
