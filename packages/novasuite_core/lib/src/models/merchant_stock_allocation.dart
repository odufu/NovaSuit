import 'package:equatable/equatable.dart';

/// Domain model representing merchant physical stock allocations held across 3PL warehouses / Nova Express Circuit Centers.
class MerchantStockAllocationModel extends Equatable {
  final String id;
  final String companyId;
  final String productId;
  final String productName;
  final String logisticsPartnerId;
  final String warehouseHubCode;
  final int physicalStock;
  final int reservedStock;
  final int availableStock;
  final DateTime lastReconciledAt;

  const MerchantStockAllocationModel({
    required this.id,
    required this.companyId,
    required this.productId,
    required this.productName,
    required this.logisticsPartnerId,
    required this.warehouseHubCode,
    required this.physicalStock,
    required this.reservedStock,
    required this.availableStock,
    required this.lastReconciledAt,
  });

  factory MerchantStockAllocationModel.fromJson(Map<String, dynamic> json) {
    return MerchantStockAllocationModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] ?? 'Product Item',
      logisticsPartnerId: json['logistics_partner_id'] as String,
      warehouseHubCode: json['warehouse_hub_code'] as String,
      physicalStock: (json['physical_stock'] as num?)?.toInt() ?? 0,
      reservedStock: (json['reserved_stock'] as num?)?.toInt() ?? 0,
      availableStock: (json['available_stock'] as num?)?.toInt() ?? 0,
      lastReconciledAt: json['last_reconciled_at'] != null ? DateTime.parse(json['last_reconciled_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'product_id': productId,
      'product_name': productName,
      'logistics_partner_id': logisticsPartnerId,
      'warehouse_hub_code': warehouseHubCode,
      'physical_stock': physicalStock,
      'reserved_stock': reservedStock,
      'available_stock': availableStock,
      'last_reconciled_at': lastReconciledAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        productId,
        productName,
        logisticsPartnerId,
        warehouseHubCode,
        physicalStock,
        reservedStock,
        availableStock,
        lastReconciledAt,
      ];
}
