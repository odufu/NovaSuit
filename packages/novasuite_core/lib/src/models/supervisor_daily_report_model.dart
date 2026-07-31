import 'package:equatable/equatable.dart';

class SupervisorDailyReportModel extends Equatable {
  final DateTime date;
  final String reportTitle; // e.g. "Report for Monday 27th July, 2026"
  final List<String> productBreakdown; // e.g. ["GRAZER HERBAL DETOX TEA", "HERBAL SHAMPOO & BOOSTER"]
  final int totalAssigned; // 35
  final int confirmedCount; // 21
  final int totalDelivered; // 17
  final int deliveredTodayAssigned; // 15
  final int deliveredPreviousDays; // 2
  final int untaggedCrmCount; // 6 yet to be tagged on CRM
  final int rescheduledCount; // 7
  final int inProgressCount; // 6
  final int switchedOffCount; // 2
  final int notPickingCount; // 4
  final int cancelledCount; // 0
  final int notReadyCount; // 1

  const SupervisorDailyReportModel({
    required this.date,
    required this.reportTitle,
    required this.productBreakdown,
    required this.totalAssigned,
    required this.confirmedCount,
    required this.totalDelivered,
    required this.deliveredTodayAssigned,
    required this.deliveredPreviousDays,
    required this.untaggedCrmCount,
    required this.rescheduledCount,
    required this.inProgressCount,
    required this.switchedOffCount,
    required this.notPickingCount,
    required this.cancelledCount,
    required this.notReadyCount,
  });

  @override
  List<Object?> get props => [
        date,
        reportTitle,
        productBreakdown,
        totalAssigned,
        confirmedCount,
        totalDelivered,
        deliveredTodayAssigned,
        deliveredPreviousDays,
        untaggedCrmCount,
        rescheduledCount,
        inProgressCount,
        switchedOffCount,
        notPickingCount,
        cancelledCount,
        notReadyCount,
      ];

  factory SupervisorDailyReportModel.defaultReportForJuly27() {
    return SupervisorDailyReportModel(
      date: DateTime(2026, 7, 27),
      reportTitle: 'Report for Monday 27th July, 2026',
      productBreakdown: const ['GRAZER HERBAL DETOX TEA', 'HERBAL SHAMPOO & VITALITY BOOSTER'],
      totalAssigned: 35,
      confirmedCount: 21,
      totalDelivered: 17,
      deliveredTodayAssigned: 15,
      deliveredPreviousDays: 2,
      untaggedCrmCount: 6,
      rescheduledCount: 7,
      inProgressCount: 6,
      switchedOffCount: 2,
      notPickingCount: 4,
      cancelledCount: 0,
      notReadyCount: 1,
    );
  }
}
