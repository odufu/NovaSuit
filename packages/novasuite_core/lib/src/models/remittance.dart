import 'package:equatable/equatable.dart';

enum RemittanceStatus {
  pending('pending', 'Pending Verification'),
  verified('verified', 'Verified & Cleared'),
  rejected('rejected', 'Rejected');

  final String dbValue;
  final String label;
  const RemittanceStatus(this.dbValue, this.label);

  static RemittanceStatus fromDbValue(String value) {
    return RemittanceStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => RemittanceStatus.pending,
    );
  }
}

class CashRemittanceModel extends Equatable {
  final String id;
  final String companyId;
  final String deliveryAgentId;
  final double amount;
  final String depositReceiptUrl;
  final RemittanceStatus status;
  final String? verifiedByFinanceUserId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const CashRemittanceModel({
    required this.id,
    required this.companyId,
    required this.deliveryAgentId,
    required this.amount,
    required this.depositReceiptUrl,
    required this.status,
    this.verifiedByFinanceUserId,
    this.notes,
    required this.createdAt,
    this.verifiedAt,
  });

  factory CashRemittanceModel.fromMap(Map<String, dynamic> map) {
    return CashRemittanceModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      deliveryAgentId: map['delivery_agent_id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      depositReceiptUrl: map['deposit_receipt_url'] ?? '',
      status: RemittanceStatus.fromDbValue(map['status'] ?? 'pending'),
      verifiedByFinanceUserId: map['verified_by_finance_user_id'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      verifiedAt: map['verified_at'] != null ? DateTime.parse(map['verified_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'delivery_agent_id': deliveryAgentId,
      'amount': amount,
      'deposit_receipt_url': depositReceiptUrl,
      'status': status.dbValue,
      'verified_by_finance_user_id': verifiedByFinanceUserId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, companyId, deliveryAgentId, amount, status, depositReceiptUrl];
}
