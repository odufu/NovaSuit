import 'package:equatable/equatable.dart';

enum CommissionStatus {
  earned('earned', 'Earned'),
  paid('paid', 'Paid'),
  clawback('clawback', 'Clawback');

  final String dbValue;
  final String label;
  const CommissionStatus(this.dbValue, this.label);

  static CommissionStatus fromDbValue(String value) {
    return CommissionStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CommissionStatus.earned,
    );
  }
}

class CommissionModel extends Equatable {
  final String id;
  final String companyId;
  final String userId;
  final String? supervisorId;
  final String orderId;
  final String recipientRole; // 'sales_call_rep' or 'sales_supervisor'
  final String productId;
  final int quantity;
  final double unitCommissionRate;
  final double totalCommission;
  final CommissionStatus status;
  final DateTime createdAt;

  const CommissionModel({
    required this.id,
    required this.companyId,
    required this.userId,
    this.supervisorId,
    required this.orderId,
    required this.recipientRole,
    required this.productId,
    required this.quantity,
    required this.unitCommissionRate,
    required this.totalCommission,
    required this.status,
    required this.createdAt,
  });

  factory CommissionModel.fromMap(Map<String, dynamic> map) {
    return CommissionModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      userId: map['user_id'] ?? '',
      supervisorId: map['supervisor_id'],
      orderId: map['order_id'] ?? '',
      recipientRole: map['recipient_role'] ?? 'sales_call_rep',
      productId: map['product_id'] ?? '',
      quantity: map['quantity'] ?? 1,
      unitCommissionRate: (map['unit_commission_rate'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (map['total_commission'] as num?)?.toDouble() ?? 0.0,
      status: CommissionStatus.fromDbValue(map['status'] ?? 'earned'),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'supervisor_id': supervisorId,
      'order_id': orderId,
      'recipient_role': recipientRole,
      'product_id': productId,
      'quantity': quantity,
      'unit_commission_rate': unitCommissionRate,
      'total_commission': totalCommission,
      'status': status.dbValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        userId,
        supervisorId,
        orderId,
        recipientRole,
        productId,
        quantity,
        unitCommissionRate,
        totalCommission,
        status,
        createdAt,
      ];
}
