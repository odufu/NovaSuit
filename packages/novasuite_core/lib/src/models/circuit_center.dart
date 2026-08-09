import 'package:equatable/equatable.dart';

/// Domain model representing a regional Circuit Center / Collation & Distribution Center (CDC) operated by a Logistics Company (e.g. Nova Express).
class CircuitCenterModel extends Equatable {
  final String id;
  final String companyId;
  final String centerName;
  final String hubCode;
  final String state;
  final String city;
  final String address;
  final String? managerName;
  final String? managerPhone;
  final List<String> coverageZones;
  final bool isActive;
  final DateTime createdAt;

  const CircuitCenterModel({
    required this.id,
    required this.companyId,
    required this.centerName,
    required this.hubCode,
    required this.state,
    required this.city,
    required this.address,
    this.managerName,
    this.managerPhone,
    this.coverageZones = const [],
    this.isActive = true,
    required this.createdAt,
  });

  factory CircuitCenterModel.fromJson(Map<String, dynamic> json) {
    return CircuitCenterModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      centerName: json['center_name'] as String,
      hubCode: json['hub_code'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      managerName: json['manager_name'],
      managerPhone: json['manager_phone'],
      coverageZones: (json['coverage_zones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'center_name': centerName,
      'hub_code': hubCode,
      'state': state,
      'city': city,
      'address': address,
      'manager_name': managerName,
      'manager_phone': managerPhone,
      'coverage_zones': coverageZones,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        centerName,
        hubCode,
        state,
        city,
        address,
        managerName,
        managerPhone,
        coverageZones,
        isActive,
        createdAt,
      ];
}
