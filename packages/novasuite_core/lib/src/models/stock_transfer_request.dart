import 'package:equatable/equatable.dart';

/// Enum representing the lifecycle status of a merchant stock transfer shipment.
enum StockTransferStatus {
  pendingDispatch('pending_dispatch', 'Pending Dispatch'),
  inTransit('in_transit', 'In Transit'),
  received('received', 'Received at Hub'),
  rejected('rejected', 'Rejected');

  final String dbValue;
  final String label;
  const StockTransferStatus(this.dbValue, this.label);

  static StockTransferStatus fromDbValue(String value) {
    return StockTransferStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => StockTransferStatus.pendingDispatch,
    );
  }
}

/// Domain model representing stock transfer shipments sent from merchants to Nova Express Circuit Centers.
class StockTransferRequestModel extends Equatable {
  final String id;
  final String companyId;
  final String productId;
  final String productName;
  final String targetPartnerId;
  final String targetHubCode;
  final int quantitySent;
  final int quantityReceived;
  final StockTransferStatus status;
  final String? waybillRef;
  final DateTime createdAt;

  const StockTransferRequestModel({
    required this.id,
    required this.companyId,
    required this.productId,
    required this.productName,
    required this.targetPartnerId,
    required this.targetHubCode,
    required this.quantitySent,
    this.quantityReceived = 0,
    this.status = StockTransferStatus.pendingDispatch,
    this.waybillRef,
    required this.createdAt,
  });

  factory StockTransferRequestModel.fromJson(Map<String, dynamic> json) {
    return StockTransferRequestModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] ?? 'Product Item',
      targetPartnerId: json['target_partner_id'] as String,
      targetHubCode: json['target_hub_code'] as String,
      quantitySent: (json['quantity_sent'] as num?)?.toInt() ?? 0,
      quantityReceived: (json['quantity_received'] as num?)?.toInt() ?? 0,
      status: StockTransferStatus.fromDbValue(json['status'] ?? 'pending_dispatch'),
      waybillRef: json['waybill_ref'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'product_id': productId,
      'product_name': productName,
      'target_partner_id': targetPartnerId,
      'target_hub_code': targetHubCode,
      'quantity_sent': quantitySent,
      'quantity_received': quantityReceived,
      'status': status.dbValue,
      'waybill_ref': waybillRef,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        productId,
        productName,
        targetPartnerId,
        targetHubCode,
        quantitySent,
        quantityReceived,
        status,
        waybillRef,
        createdAt,
      ];
}
