import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../pages/sales_call_center_suite_page.dart';

class SalesCallCenterSuiteScreen extends StatelessWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final List<OrderModel> orders;
  final Function(OrderModel) onUpdateOrder;
  final Function(OrderModel) onRequestUpsell;
  final int activeSubIndex;

  const SalesCallCenterSuiteScreen({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    required this.orders,
    required this.onUpdateOrder,
    required this.onRequestUpsell,
    this.activeSubIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SalesCallCenterSuitePage(
      activeTheme: activeTheme,
      currentUser: currentUser,
      orders: orders,
      onUpdateOrder: onUpdateOrder,
      onRequestUpsell: onRequestUpsell,
      activeSubIndex: activeSubIndex,
    );
  }
}
