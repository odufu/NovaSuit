import 'package:equatable/equatable.dart';

enum WarehouseType {
  central('central', 'Central Factory Hub'),
  agencyHub('agency_hub', 'Agency Logistics Hub'),
  riderMiniHub('rider_mini_hub', 'Rider Mini-Hub');

  final String dbValue;
  final String label;
  const WarehouseType(this.dbValue, this.label);

  static WarehouseType fromDbValue(String value) {
    return WarehouseType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WarehouseType.central,
    );
  }
}

class WarehouseModel extends Equatable {
  final String id;
  final String companyId;
  final String? agencyId;
  final String? riderId;
  final String name;
  final WarehouseType type;
  final String locationState;
  final String? address;
  final bool isActive;

  const WarehouseModel({
    required this.id,
    required this.companyId,
    this.agencyId,
    this.riderId,
    required this.name,
    required this.type,
    required this.locationState,
    this.address,
    required this.isActive,
  });

  factory WarehouseModel.fromMap(Map<String, dynamic> map) {
    return WarehouseModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      agencyId: map['agency_id'],
      riderId: map['rider_id'],
      name: map['name'] ?? '',
      type: WarehouseType.fromDbValue(map['type'] ?? 'central'),
      locationState: map['location_state'] ?? '',
      address: map['address'],
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'agency_id': agencyId,
      'rider_id': riderId,
      'name': name,
      'type': type.dbValue,
      'location_state': locationState,
      'address': address,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, companyId, agencyId, riderId, name, type, locationState];
}

class StockTransferModel extends Equatable {
  final String id;
  final String waybillNumber;
  final String companyId;
  final String sourceWarehouseId;
  final String destinationWarehouseId;
  final String initiatedByUserId;
  final String? receivedByUserId;
  final String status; // 'pending', 'dispatched', 'completed', 'cancelled'
  final DateTime? dispatchDate;
  final DateTime? receivedDate;
  final String? notes;
  final DateTime createdAt;

  const StockTransferModel({
    required this.id,
    required this.waybillNumber,
    required this.companyId,
    required this.sourceWarehouseId,
    required this.destinationWarehouseId,
    required this.initiatedByUserId,
    this.receivedByUserId,
    required this.status,
    this.dispatchDate,
    this.receivedDate,
    this.notes,
    required this.createdAt,
  });

  factory StockTransferModel.fromMap(Map<String, dynamic> map) {
    return StockTransferModel(
      id: map['id'] ?? '',
      waybillNumber: map['waybill_number'] ?? '',
      companyId: map['company_id'] ?? '',
      sourceWarehouseId: map['source_warehouse_id'] ?? '',
      destinationWarehouseId: map['destination_warehouse_id'] ?? '',
      initiatedByUserId: map['initiated_by_user_id'] ?? '',
      receivedByUserId: map['received_by_user_id'],
      status: map['status'] ?? 'pending',
      dispatchDate: map['dispatch_date'] != null ? DateTime.parse(map['dispatch_date']) : null,
      receivedDate: map['received_date'] != null ? DateTime.parse(map['received_date']) : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waybill_number': waybillNumber,
      'company_id': companyId,
      'source_warehouse_id': sourceWarehouseId,
      'destination_warehouse_id': destinationWarehouseId,
      'initiated_by_user_id': initiatedByUserId,
      'received_by_user_id': receivedByUserId,
      'status': status,
      'dispatch_date': dispatchDate?.toIso8601String(),
      'received_date': receivedDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, waybillNumber, companyId, sourceWarehouseId, destinationWarehouseId, status];
}
