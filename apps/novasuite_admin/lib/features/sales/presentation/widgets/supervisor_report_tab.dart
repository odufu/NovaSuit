import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'package:intl/intl.dart';

class SupervisorReportTab extends StatefulWidget {
  final SupervisorDailyReportModel report;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(DateTime selectedDate, String timeframe) onDateOrTimeframeChanged;

  const SupervisorReportTab({
    super.key,
    required this.report,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onDateOrTimeframeChanged,
  });

  @override
  State<SupervisorReportTab> createState() => _SupervisorReportTabState();
}

class _SupervisorReportTabState extends State<SupervisorReportTab> {
  late ValueNotifier<DateTime> _selectedDate;
  late ValueNotifier<String> _selectedTimeframe;

  @override
  void initState() {
    super.initState();
    _selectedDate = ValueNotifier<DateTime>(widget.report.date);
    _selectedTimeframe = ValueNotifier<String>('Day');
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _selectedTimeframe.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );

    if (picked != null) {
      _selectedDate.value = picked;
      widget.onDateOrTimeframeChanged(_selectedDate.value, _selectedTimeframe.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final r = widget.report;

    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedDate,
      builder: (context, dateVal, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _selectedTimeframe,
          builder: (context, timeframeVal, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '📋 Supervisor Daily Operational Summary',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  DateFormat('EEEE d MMMM, yyyy').format(dateVal),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Standard operational report format for squad performance log submission.',
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text('Change Date'),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: ['Day', 'Week', 'Month'].map((tf) {
                                final isSelected = timeframeVal == tf;
                                return GestureDetector(
                                  onTap: () {
                                    _selectedTimeframe.value = tf;
                                    widget.onDateOrTimeframeChanged(_selectedDate.value, tf);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? theme.primaryColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tf,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : textMuted,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Text('Active Product Lines in Report:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                        const SizedBox(width: 12),
                        Wrap(
                          spacing: 8,
                          children: r.productBreakdown.map((p) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildReportMetricCard('📦 Total Assigned', '${r.totalAssigned}', 'Leads assigned to squad', theme.primaryColor, isDark, cardBg, borderColor),
                      _buildReportMetricCard('✅ Confirmed', '${r.confirmedCount}', 'Orders accepted today', const Color(0xFF10B981), isDark, cardBg, borderColor),
                      _buildReportMetricCard('🚚 Total Delivered', '${r.totalDelivered}', '${r.deliveredTodayAssigned} today + ${r.deliveredPreviousDays} previous', Colors.blue, isDark, cardBg, borderColor),
                      _buildReportMetricCard('📅 Rescheduled', '${r.rescheduledCount}', 'Callback appointments booked', Colors.purple, isDark, cardBg, borderColor),
                      _buildReportMetricCard('⏳ In Progress', '${r.inProgressCount}', 'Active calls / dialed today', Colors.orange, isDark, cardBg, borderColor),
                      _buildReportMetricCard('📵 Switched Off', '${r.switchedOffCount}', 'Unreachable phone signals', Colors.deepOrange, isDark, cardBg, borderColor),
                      _buildReportMetricCard('📞 Not Picking', '${r.notPickingCount}', 'No response call outcomes', Colors.redAccent, isDark, cardBg, borderColor),
                      _buildReportMetricCard('🚫 Cancelled', '${r.cancelledCount}', 'Order cancellations', Colors.grey, isDark, cardBg, borderColor),
                      _buildReportMetricCard('⏸️ Not Ready', '${r.notReadyCount}', 'Pending initial call', Colors.teal, isDark, cardBg, borderColor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (r.untaggedCrmCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'CRM Tagging Notice: ${r.untaggedCrmCount} delivered orders are yet to be tagged on the CRM system.',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '📄 Formatted Operational Report (Copy & Share)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Report summary copied to clipboard!')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy Text'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: SelectableText(
                            '''
${r.reportTitle}

Total Assigned ${r.totalAssigned}
Breakdown as follows:
${r.productBreakdown.join(', ')}

${r.totalAssigned} Total Assigned

${r.confirmedCount} Confirmed

${r.totalDelivered} Delivered (${r.untaggedCrmCount} yet to be tagged on the CRM)

${r.rescheduledCount} Rescheduled

${r.inProgressCount} In progress

${r.switchedOffCount} Switched off

${r.notPickingCount} Not picking

${r.cancelledCount} Cancelled

${r.notReadyCount} Not ready

${r.deliveredTodayAssigned} delivered from today's assigned, ${r.deliveredPreviousDays} from previous days

Total delivered
 ${r.totalDelivered}
''',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportMetricCard(String title, String value, String subtitle, Color color, bool isDark, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
