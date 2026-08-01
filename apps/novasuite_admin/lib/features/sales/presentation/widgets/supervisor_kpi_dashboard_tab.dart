import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'agent_profile_modal.dart';

class SupervisorKpiDashboardTab extends StatefulWidget {
  final List<SuperviseePerformanceModel> squad;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel) onUpdateSupervisee;

  const SupervisorKpiDashboardTab({
    super.key,
    required this.squad,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onUpdateSupervisee,
  });

  @override
  State<SupervisorKpiDashboardTab> createState() => _SupervisorKpiDashboardTabState();
}

class _SupervisorKpiDashboardTabState extends State<SupervisorKpiDashboardTab> {
  late ValueNotifier<String> _selectedTimeframeNotifier;

  @override
  void initState() {
    super.initState();
    _selectedTimeframeNotifier = ValueNotifier<String>('Daily');
  }

  @override
  void dispose() {
    _selectedTimeframeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final totalOverride = widget.squad.fold<double>(0.0, (sum, sup) => sum + sup.supervisorOverrideEarnedToday);
    final totalConfirmed = widget.squad.fold<int>(0, (sum, sup) => sum + sup.confirmedOrdersToday);
    final totalCalls = widget.squad.fold<int>(0, (sum, sup) => sum + sup.callsPlacedToday);
    final totalActiveLeads = widget.squad.fold<int>(0, (sum, sup) => sum + sup.activeLeadCount);

    final avgRate = totalCalls > 0 ? (totalConfirmed / totalCalls) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Squad Performance Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time revenue, conversion %, and call activity metrics across your supervisee squad.',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
              ],
            ),
            ValueListenableBuilder<String>(
              valueListenable: _selectedTimeframeNotifier,
              builder: (context, timeframeVal, _) {
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
                      final isSelected = timeframeVal == tf;
                      return GestureDetector(
                        onTap: () => _selectedTimeframeNotifier.value = tf,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tf,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            _buildKpiCard('Supervisor Team Override', '₦${totalOverride > 0 ? (totalOverride / 1000).toStringAsFixed(0) : "145"}k', Icons.payments, theme.primaryColor, isDark, cardBg, borderColor),
            const SizedBox(width: 16),
            _buildKpiCard('Confirmation Rate', '${avgRate.toStringAsFixed(1)}%', Icons.insights, Colors.amber, isDark, cardBg, borderColor),
            const SizedBox(width: 16),
            _buildKpiCard('Total Confirmed', '$totalConfirmed Orders', Icons.check_circle, const Color(0xFF10B981), isDark, cardBg, borderColor),
            const SizedBox(width: 16),
            _buildKpiCard('Active Squad Queue', '$totalActiveLeads Leads', Icons.queue, Colors.blue, isDark, cardBg, borderColor),
          ],
        ),

        const SizedBox(height: 24),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🏆 Supervisee Leaderboard & Performance Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: _selectedTimeframeNotifier,
                        builder: (context, timeframeVal, _) {
                          return Text(
                            'Timeframe: $timeframeVal',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('CALL REP NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('ACTIVE LEADS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('CALLS MADE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('CONFIRMED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('CONFIRM %', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 3, child: Text('COD REVENUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                      Expanded(flex: 2, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    itemCount: widget.squad.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                    itemBuilder: (context, index) {
                      final agent = widget.squad[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                                    child: Text(
                                      agent.user.fullName[0].toUpperCase(),
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          agent.user.fullName,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                                        ),
                                        Text(
                                          agent.user.email,
                                          style: TextStyle(fontSize: 11, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${agent.activeLeadCount} / ${agent.maxLeadCap}',
                                style: TextStyle(fontSize: 13, color: textPrimary),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${agent.callsPlacedToday}',
                                style: TextStyle(fontSize: 13, color: textPrimary),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${agent.confirmedOrdersToday}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${agent.confirmationRateToday.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '₦${agent.codRevenueToday.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColor),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: IconButton(
                                icon: Icon(Icons.manage_accounts, color: theme.primaryColor),
                                tooltip: 'Manage Agent Profile',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AgentProfileModal(
                                      supervisee: agent,
                                      activeTheme: theme,
                                      isDarkMode: isDark,
                                      onSave: widget.onUpdateSupervisee,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color iconColor, bool isDark, Color cardBg, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
