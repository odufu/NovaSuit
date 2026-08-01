import 'package:equatable/equatable.dart';

enum CommissionCalculationType {
  fixedPerUnit('fixed_per_unit', 'Fixed Value Per Unit'),
  percentage('percentage', 'Percentage of Delivered Value');

  final String dbValue;
  final String label;
  const CommissionCalculationType(this.dbValue, this.label);

  static CommissionCalculationType fromDbValue(String value) {
    return CommissionCalculationType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CommissionCalculationType.fixedPerUnit,
    );
  }
}

/// Operations / GM Commission Configuration Model
class CommissionConfigModel extends Equatable {
  final String id;
  final String companyId;
  final bool incentivesEnabled;

  // Sales Rep Settings
  final CommissionCalculationType repCommissionType;
  final double repCommissionValue;

  // Supervisor (Team Leader) Settings
  final CommissionCalculationType supervisorCommissionType;
  final double supervisorCommissionValue;

  // AHOD Settings
  final CommissionCalculationType ahodCommissionType;
  final double ahodCommissionValue;

  // HOD Settings
  final CommissionCalculationType hodCommissionType;
  final double hodCommissionValue;

  const CommissionConfigModel({
    required this.id,
    required this.companyId,
    this.incentivesEnabled = true,
    this.repCommissionType = CommissionCalculationType.fixedPerUnit,
    this.repCommissionValue = 1000.0,
    this.supervisorCommissionType = CommissionCalculationType.fixedPerUnit,
    this.supervisorCommissionValue = 250.0,
    this.ahodCommissionType = CommissionCalculationType.fixedPerUnit,
    this.ahodCommissionValue = 150.0,
    this.hodCommissionType = CommissionCalculationType.fixedPerUnit,
    this.hodCommissionValue = 100.0,
  });

  factory CommissionConfigModel.fromMap(Map<String, dynamic> map) {
    return CommissionConfigModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      incentivesEnabled: map['incentives_enabled'] ?? true,
      repCommissionType: CommissionCalculationType.fromDbValue(map['rep_commission_type'] ?? 'fixed_per_unit'),
      repCommissionValue: (map['rep_commission_value'] as num?)?.toDouble() ?? 1000.0,
      supervisorCommissionType: CommissionCalculationType.fromDbValue(map['supervisor_commission_type'] ?? 'fixed_per_unit'),
      supervisorCommissionValue: (map['supervisor_commission_value'] as num?)?.toDouble() ?? 250.0,
      ahodCommissionType: CommissionCalculationType.fromDbValue(map['ahod_commission_type'] ?? 'fixed_per_unit'),
      ahodCommissionValue: (map['ahod_commission_value'] as num?)?.toDouble() ?? 150.0,
      hodCommissionType: CommissionCalculationType.fromDbValue(map['hod_commission_type'] ?? 'fixed_per_unit'),
      hodCommissionValue: (map['hod_commission_value'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'incentives_enabled': incentivesEnabled,
      'rep_commission_type': repCommissionType.dbValue,
      'rep_commission_value': repCommissionValue,
      'supervisor_commission_type': supervisorCommissionType.dbValue,
      'supervisor_commission_value': supervisorCommissionValue,
      'ahod_commission_type': ahodCommissionType.dbValue,
      'ahod_commission_value': ahodCommissionValue,
      'hod_commission_type': hodCommissionType.dbValue,
      'hod_commission_value': hodCommissionValue,
    };
  }

  CommissionConfigModel copyWith({
    String? id,
    String? companyId,
    bool? incentivesEnabled,
    CommissionCalculationType? repCommissionType,
    double? repCommissionValue,
    CommissionCalculationType? supervisorCommissionType,
    double? supervisorCommissionValue,
    CommissionCalculationType? ahodCommissionType,
    double? ahodCommissionValue,
    CommissionCalculationType? hodCommissionType,
    double? hodCommissionValue,
  }) {
    return CommissionConfigModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      incentivesEnabled: incentivesEnabled ?? this.incentivesEnabled,
      repCommissionType: repCommissionType ?? this.repCommissionType,
      repCommissionValue: repCommissionValue ?? this.repCommissionValue,
      supervisorCommissionType: supervisorCommissionType ?? this.supervisorCommissionType,
      supervisorCommissionValue: supervisorCommissionValue ?? this.supervisorCommissionValue,
      ahodCommissionType: ahodCommissionType ?? this.ahodCommissionType,
      ahodCommissionValue: ahodCommissionValue ?? this.ahodCommissionValue,
      hodCommissionType: hodCommissionType ?? this.hodCommissionType,
      hodCommissionValue: hodCommissionValue ?? this.hodCommissionValue,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        incentivesEnabled,
        repCommissionType,
        repCommissionValue,
        supervisorCommissionType,
        supervisorCommissionValue,
        ahodCommissionType,
        ahodCommissionValue,
        hodCommissionType,
        hodCommissionValue,
      ];
}
