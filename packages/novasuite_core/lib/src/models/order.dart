import 'package:equatable/equatable.dart';

enum OrderStatus {
  newOrder('new', 'New Lead'),
  qualified('qualified', 'Qualified'),
  accepted('accepted', 'Confirmed'),
  assignedToRep('assigned_to_rep', 'Assigned'),
  agentNotified('agent_notified', 'Agent Notified'),
  dispatchAssigned('dispatch_assigned', 'Dispatch Assigned'),
  orderAccepted('order_accepted', 'Order Accepted'),
  processing('processing', 'Processing'),
  inTransit('in_transit', 'Delivery In Progress'),
  deliveryRescheduled('delivery_rescheduled', 'Delivery Rescheduled'),
  delivered('delivered', 'Delivered'),
  deliveredOrderCancelled('delivered_order_cancelled', 'Delivered Order Cancelled'),
  failedDelivery('failed_delivery', 'Failed'),
  cancelled('cancelled', 'Cancelled'),
  returned('returned', 'Returned'),
  duplicate('duplicate', 'Duplicate'),
  onHold('on_hold', 'On Hold'),
  notPicking('not_picking', 'Not Picking'),
  callBack('call_back', 'Call Back'),
  notReachable('not_reachable', 'Not Reachable'),
  noProduct('no_product', 'No Product'),
  notReady('not_ready', 'Not ready'),
  switchedOff('switched_off', 'Switched Off'),
  rescheduled('rescheduled', 'Rescheduled'),
  rejected('rejected', 'Rejected'),
  contacting('contacting', 'Contacting Client'),
  upsellPending('upsell_pending', 'Upsell Approval Pending'),
  logisticsConfirmed('logistics_confirmed', 'Location Confirmed');

  final String dbValue;
  final String label;
  const OrderStatus(this.dbValue, this.label);

  static OrderStatus fromDbValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => OrderStatus.newOrder,
    );
  }
}

enum UpsellStatus {
  none('none', 'None'),
  pending('pending', 'Pending Approval'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected');

  final String dbValue;
  final String label;
  const UpsellStatus(this.dbValue, this.label);

  static UpsellStatus fromDbValue(String value) {
    return UpsellStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => UpsellStatus.none,
    );
  }
}

enum CancellationReason {
  noMoney('no_money', 'Insufficient Funds / Waiting for Salary', '💸'),
  traveling('traveling', 'Traveling / Out of Town', '✈️'),
  tooExpensive('too_expensive', 'Price Too High / Wants Discount', '🏷️'),
  boughtElsewhere('bought_elsewhere', 'Bought Alternative Elsewhere', '🛒'),
  orderedByMistake('ordered_by_mistake', 'Ordered by Mistake / Didn\'t Order', '❓'),
  deliveryDelay('delivery_delay', 'Delivery Taking Too Long', '⏱️'),
  spouseDisapproved('spouse_disapproved', 'Spouse / Family Disapproved', '👨‍👩‍👧'),
  other('other', 'Other Reason (Custom Notes)', '📝');

  final String dbValue;
  final String label;
  final String emoji;
  const CancellationReason(this.dbValue, this.label, this.emoji);

  static CancellationReason? fromDbValue(String? value) {
    if (value == null) return null;
    return CancellationReason.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CancellationReason.other,
    );
  }
}

class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String companyId;
  final String productId;
  final String? salesRepId;
  final String? logisticsRepId;
  final String? deliveryAgentId;
  final String? warehouseId;

  final String customerName;
  final String customerPhone;
  final String? customerAltPhone;
  final String deliveryState;
  final String? deliveryCity;
  final String deliveryAddress;

  final OrderStatus status;
  final int quantity;
  final double basePrice;
  final double upsellAmount;
  final double downsellDiscount;
  final double totalAmount;

  // Upsell / Downsell detail fields
  final int upsellQuantity;       // Extra units added (positive) or removed (negative)
  final double upsellUnitPrice;   // Price per unit for the upsell/downsell combo

  final UpsellStatus upsellStatus;
  final String? upsellNotes;
  final String? approvedBySupervisorId;

  final CancellationReason? cancellationReason;
  final DateTime? cancellationFollowUpAt;

  final String paymentStatus;
  final bool crmTagged;
  final String? proofOfDeliveryUrl;
  final String? deliveryNotes;
  final DateTime? scheduledCallbackAt;
  final String? rescheduleNote;

  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.companyId,
    required this.productId,
    this.salesRepId,
    this.logisticsRepId,
    this.deliveryAgentId,
    this.warehouseId,
    required this.customerName,
    required this.customerPhone,
    this.customerAltPhone,
    required this.deliveryState,
    this.deliveryCity,
    required this.deliveryAddress,
    required this.status,
    required this.quantity,
    required this.basePrice,
    required this.upsellAmount,
    required this.downsellDiscount,
    required this.totalAmount,
    this.upsellQuantity = 0,
    this.upsellUnitPrice = 0.0,
    required this.upsellStatus,
    this.upsellNotes,
    this.approvedBySupervisorId,
    this.cancellationReason,
    this.cancellationFollowUpAt,
    required this.paymentStatus,
    this.crmTagged = true,
    this.proofOfDeliveryUrl,
    this.deliveryNotes,
    this.scheduledCallbackAt,
    this.rescheduleNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['order_number'] ?? '',
      companyId: map['company_id'] ?? '',
      productId: map['product_id'] ?? '',
      salesRepId: map['sales_rep_id'],
      logisticsRepId: map['logistics_rep_id'],
      deliveryAgentId: map['delivery_agent_id'],
      warehouseId: map['warehouse_id'],
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      customerAltPhone: map['customer_alt_phone'],
      deliveryState: map['delivery_state'] ?? '',
      deliveryCity: map['delivery_city'],
      deliveryAddress: map['delivery_address'] ?? '',
      status: OrderStatus.fromDbValue(map['status'] ?? 'new'),
      quantity: map['quantity'] ?? 1,
      basePrice: (map['base_price'] as num?)?.toDouble() ?? 0.0,
      upsellAmount: (map['upsell_amount'] as num?)?.toDouble() ?? 0.0,
      downsellDiscount: (map['downsell_discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      upsellQuantity: map['upsell_quantity'] ?? 0,
      upsellUnitPrice: (map['upsell_unit_price'] as num?)?.toDouble() ?? 0.0,
      upsellStatus: UpsellStatus.fromDbValue(map['upsell_status'] ?? 'none'),
      upsellNotes: map['upsell_notes'],
      approvedBySupervisorId: map['approved_by_supervisor_id'],
      cancellationReason: CancellationReason.fromDbValue(map['cancellation_reason']),
      cancellationFollowUpAt: map['cancellation_follow_up_at'] != null ? DateTime.parse(map['cancellation_follow_up_at']) : null,
      paymentStatus: map['payment_status'] ?? 'pending',
      crmTagged: map['crm_tagged'] ?? true,
      proofOfDeliveryUrl: map['proof_of_delivery_url'],
      deliveryNotes: map['delivery_notes'],
      scheduledCallbackAt: map['scheduled_callback_at'] != null ? DateTime.parse(map['scheduled_callback_at']) : null,
      rescheduleNote: map['reschedule_note'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'company_id': companyId,
      'product_id': productId,
      'sales_rep_id': salesRepId,
      'logistics_rep_id': logisticsRepId,
      'delivery_agent_id': deliveryAgentId,
      'warehouse_id': warehouseId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_alt_phone': customerAltPhone,
      'delivery_state': deliveryState,
      'delivery_city': deliveryCity,
      'delivery_address': deliveryAddress,
      'status': status.dbValue,
      'quantity': quantity,
      'base_price': basePrice,
      'upsell_amount': upsellAmount,
      'downsell_discount': downsellDiscount,
      'total_amount': totalAmount,
      'upsell_quantity': upsellQuantity,
      'upsell_unit_price': upsellUnitPrice,
      'upsell_status': upsellStatus.dbValue,
      'upsell_notes': upsellNotes,
      'approved_by_supervisor_id': approvedBySupervisorId,
      'cancellation_reason': cancellationReason?.dbValue,
      'cancellation_follow_up_at': cancellationFollowUpAt?.toIso8601String(),
      'payment_status': paymentStatus,
      'crm_tagged': crmTagged,
      'proof_of_delivery_url': proofOfDeliveryUrl,
      'delivery_notes': deliveryNotes,
      'scheduled_callback_at': scheduledCallbackAt?.toIso8601String(),
      'reschedule_note': rescheduleNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        companyId,
        productId,
        salesRepId,
        logisticsRepId,
        deliveryAgentId,
        warehouseId,
        customerName,
        customerPhone,
        customerAltPhone,
        deliveryState,
        deliveryCity,
        deliveryAddress,
        status,
        quantity,
        basePrice,
        upsellAmount,
        downsellDiscount,
        totalAmount,
        upsellQuantity,
        upsellUnitPrice,
        upsellStatus,
        upsellNotes,
        approvedBySupervisorId,
        cancellationReason,
        cancellationFollowUpAt,
        paymentStatus,
        crmTagged,
        proofOfDeliveryUrl,
        deliveryNotes,
        scheduledCallbackAt,
        rescheduleNote,
        createdAt,
        updatedAt,
      ];
}
