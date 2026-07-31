import 'package:equatable/equatable.dart';

class OrderActivityModel extends Equatable {
  final String id;
  final String orderId;
  final String activityType; // 'status_update', 'callback_scheduled', 'logistics_assigned', 'upsell_requested', 'cancelled', 'order_created', 'call_placed'
  final String title;
  final String details;
  final String performedBy;
  final String userRole;
  final DateTime? scheduledCallbackAt;
  final String? oldStatus;
  final String? newStatus;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const OrderActivityModel({
    required this.id,
    required this.orderId,
    required this.activityType,
    required this.title,
    required this.details,
    required this.performedBy,
    required this.userRole,
    this.scheduledCallbackAt,
    this.oldStatus,
    this.newStatus,
    this.metadata,
    required this.createdAt,
  });

  factory OrderActivityModel.fromMap(Map<String, dynamic> map) {
    return OrderActivityModel(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? '',
      activityType: map['activity_type'] ?? 'status_update',
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      performedBy: map['performed_by'] ?? 'System',
      userRole: map['user_role'] ?? 'Automated Workflow',
      scheduledCallbackAt: map['scheduled_callback_at'] != null ? DateTime.tryParse(map['scheduled_callback_at']) : null,
      oldStatus: map['old_status'],
      newStatus: map['new_status'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'activity_type': activityType,
      'title': title,
      'details': details,
      'performed_by': performedBy,
      'user_role': userRole,
      if (scheduledCallbackAt != null) 'scheduled_callback_at': scheduledCallbackAt!.toIso8601String(),
      if (oldStatus != null) 'old_status': oldStatus,
      if (newStatus != null) 'new_status': newStatus,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        activityType,
        title,
        details,
        performedBy,
        userRole,
        scheduledCallbackAt,
        oldStatus,
        newStatus,
        metadata,
        createdAt,
      ];
}
