import 'package:equatable/equatable.dart';

class CompanyCallWalletModel extends Equatable {
  final String id;
  final String companyId;
  final double balance;
  final double ratePerMinute;
  final double wholesaleRatePerMinute;
  final double lowBalanceThreshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyCallWalletModel({
    required this.id,
    required this.companyId,
    required this.balance,
    this.ratePerMinute = 14.75,
    this.wholesaleRatePerMinute = 13.75,
    this.lowBalanceThreshold = 5000.00,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyCallWalletModel.fromMap(Map<String, dynamic> map) {
    return CompanyCallWalletModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      ratePerMinute: (map['rate_per_minute'] as num?)?.toDouble() ?? 14.75,
      wholesaleRatePerMinute:
          (map['wholesale_rate_per_minute'] as num?)?.toDouble() ?? 13.75,
      lowBalanceThreshold:
          (map['low_balance_threshold'] as num?)?.toDouble() ?? 5000.00,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'balance': balance,
      'rate_per_minute': ratePerMinute,
      'wholesale_rate_per_minute': wholesaleRatePerMinute,
      'low_balance_threshold': lowBalanceThreshold,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isLowBalance => balance <= lowBalanceThreshold;

  @override
  List<Object?> get props => [
        id,
        companyId,
        balance,
        ratePerMinute,
        wholesaleRatePerMinute,
        lowBalanceThreshold,
        isActive,
        createdAt,
        updatedAt,
      ];
}
