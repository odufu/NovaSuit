import 'package:equatable/equatable.dart';

class DailyReportModel extends Equatable {
  final String id;
  final String repId;
  final String repName;
  final String supervisorId;
  final DateTime date;
  final int totalCalls;
  final int confirmedOrders;
  final double totalCod;
  final double upsellAmount;
  final double conversionRate;
  final DateTime submittedAt;
  final bool isVerifiedBySupervisor;
  final String? notes;

  const DailyReportModel({
    required this.id,
    required this.repId,
    required this.repName,
    required this.supervisorId,
    required this.date,
    required this.totalCalls,
    required this.confirmedOrders,
    required this.totalCod,
    required this.upsellAmount,
    required this.conversionRate,
    required this.submittedAt,
    this.isVerifiedBySupervisor = false,
    this.notes,
  });

  factory DailyReportModel.fromMap(Map<String, dynamic> map) {
    return DailyReportModel(
      id: map['id'] ?? '',
      repId: map['rep_id'] ?? '',
      repName: map['rep_name'] ?? '',
      supervisorId: map['supervisor_id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      totalCalls: map['total_calls'] ?? 0,
      confirmedOrders: map['confirmed_orders'] ?? 0,
      totalCod: (map['total_cod'] as num?)?.toDouble() ?? 0.0,
      upsellAmount: (map['upsell_amount'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (map['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      submittedAt: DateTime.parse(map['submitted_at'] ?? DateTime.now().toIso8601String()),
      isVerifiedBySupervisor: map['is_verified_by_supervisor'] ?? false,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rep_id': repId,
      'rep_name': repName,
      'supervisor_id': supervisorId,
      'date': date.toIso8601String(),
      'total_calls': totalCalls,
      'confirmed_orders': confirmedOrders,
      'total_cod': totalCod,
      'upsell_amount': upsellAmount,
      'conversion_rate': conversionRate,
      'submitted_at': submittedAt.toIso8601String(),
      'is_verified_by_supervisor': isVerifiedBySupervisor,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        repId,
        repName,
        supervisorId,
        date,
        totalCalls,
        confirmedOrders,
        totalCod,
        upsellAmount,
        conversionRate,
        submittedAt,
        isVerifiedBySupervisor,
        notes,
      ];
}
