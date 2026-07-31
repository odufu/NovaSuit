import 'package:equatable/equatable.dart';

class CallLogModel extends Equatable {
  final String id;
  final String companyId;
  final String agentId;
  final String? orderId;
  final String customerPhone;
  final int durationSeconds;
  final double billedAmount;
  final double costAmount;
  final double profitAmount;
  final String sipProvider;
  final String callStatus;
  final String? recordingUrl;
  final DateTime createdAt;

  const CallLogModel({
    required this.id,
    required this.companyId,
    required this.agentId,
    this.orderId,
    required this.customerPhone,
    required this.durationSeconds,
    required this.billedAmount,
    required this.costAmount,
    required this.profitAmount,
    this.sipProvider = 'IT Sky Solutions',
    this.callStatus = 'ANSWERED',
    this.recordingUrl,
    required this.createdAt,
  });

  factory CallLogModel.fromMap(Map<String, dynamic> map) {
    return CallLogModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      agentId: map['agent_id'] ?? '',
      orderId: map['order_id'],
      customerPhone: map['customer_phone'] ?? '',
      durationSeconds: map['duration_seconds'] ?? 0,
      billedAmount: (map['billed_amount'] as num?)?.toDouble() ?? 0.0,
      costAmount: (map['cost_amount'] as num?)?.toDouble() ?? 0.0,
      profitAmount: (map['profit_amount'] as num?)?.toDouble() ?? 0.0,
      sipProvider: map['sip_provider'] ?? 'IT Sky Solutions',
      callStatus: map['call_status'] ?? 'ANSWERED',
      recordingUrl: map['recording_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'agent_id': agentId,
      'order_id': orderId,
      'customer_phone': customerPhone,
      'duration_seconds': durationSeconds,
      'billed_amount': billedAmount,
      'cost_amount': costAmount,
      'profit_amount': profitAmount,
      'sip_provider': sipProvider,
      'call_status': callStatus,
      'recording_url': recordingUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        agentId,
        orderId,
        customerPhone,
        durationSeconds,
        billedAmount,
        costAmount,
        profitAmount,
        sipProvider,
        callStatus,
        recordingUrl,
        createdAt,
      ];
}
