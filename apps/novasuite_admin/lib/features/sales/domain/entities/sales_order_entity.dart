import 'package:equatable/equatable.dart';
import 'package:novasuite_core/novasuite_core.dart';

class SalesOrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String companyId;
  final String productId;
  final String? salesRepId;
  final String customerName;
  final String customerPhone;
  final String deliveryState;
  final String deliveryAddress;
  final OrderStatus status;
  final int quantity;
  final double basePrice;
  final double upsellAmount;
  final double downsellDiscount;
  final double totalAmount;
  final UpsellStatus upsellStatus;
  final String? upsellNotes;
  final CancellationReason? cancellationReason;
  final DateTime? cancellationFollowUpAt;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.companyId,
    required this.productId,
    this.salesRepId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryState,
    required this.deliveryAddress,
    required this.status,
    required this.quantity,
    required this.basePrice,
    required this.upsellAmount,
    required this.downsellDiscount,
    required this.totalAmount,
    required this.upsellStatus,
    this.upsellNotes,
    this.cancellationReason,
    this.cancellationFollowUpAt,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        companyId,
        productId,
        salesRepId,
        customerName,
        customerPhone,
        deliveryState,
        deliveryAddress,
        status,
        quantity,
        basePrice,
        upsellAmount,
        downsellDiscount,
        totalAmount,
        upsellStatus,
        upsellNotes,
        cancellationReason,
        cancellationFollowUpAt,
        paymentStatus,
        createdAt,
        updatedAt,
      ];
}
