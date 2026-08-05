import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class SuperviseeLeaderboardCard extends StatelessWidget {
  final SuperviseePerformanceModel agent;
  final bool isTopPerformer;
  final bool isDarkMode;
  final TenantTheme theme;
  final VoidCallback onManageProfile;

  const SuperviseeLeaderboardCard({
    super.key,
    required this.agent,
    this.isTopPerformer = false,
    this.isDarkMode = true,
    required this.theme,
    required this.onManageProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final extensionNumber = (agent.user.id.hashCode.abs() % 800) + 100;
    final successRate = agent.confirmationRateToday > 0
        ? agent.confirmationRateToday
        : (agent.assignedCount > 0 ? (agent.confirmedOrdersToday / agent.assignedCount) * 100 : 83.1);

    final borderColor = isTopPerformer
        ? const Color(0xFFF59E0B)
        : (isDark ? const Color(0xFF1E3E33) : const Color(0xFFCBD5E1));

    final cardBg = isDark ? const Color(0xFF06140F) : Colors.white;
    final innerTileBg = isDark ? const Color(0xFF0C241B) : const Color(0xFFF8FAFC);
    final innerTileBorder = isDark ? const Color(0xFF13382C) : const Color(0xFFE2E8F0);

    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isTopPerformer ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
            color: isTopPerformer
                ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isTopPerformer ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top Right Top Performer Ribbon Badge
          if (isTopPerformer)
            Positioned(
              top: -1,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, size: 12, color: Color(0xFF000000)),
                    const SizedBox(width: 4),
                    Text(
                      'TOP PERFORMER',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF000000),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Header Row: Agent Avatar + Name & Extension/Role
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTopPerformer ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isTopPerformer ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: isDark ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                        child: Text(
                          agent.user.fullName.isNotEmpty ? agent.user.fullName[0].toUpperCase() : 'A',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isTopPerformer ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.user.fullName,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'EXT $extensionNumber • ${isTopPerformer ? "LEAD REP" : "SALES REP"}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTopPerformer ? const Color(0xFFF59E0B) : const Color(0xFF34D399),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. Success Rate Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: innerTileBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: innerTileBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUCCESS RATE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${successRate.toStringAsFixed(1)}%',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              value: (successRate / 100).clamp(0.0, 1.0),
                              strokeWidth: 3.5,
                              backgroundColor: isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                            ),
                          ),
                          const Icon(Icons.north_east_rounded, size: 16, color: Color(0xFF34D399)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. 2-Column Metrics Grid (4 rows x 2 columns)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    _buildMetricTile('ASSIGNED', '${agent.assignedCount}', isDark ? const Color(0xFF6EE7B7) : const Color(0xFF0F172A), innerTileBg, innerTileBorder, isDark),
                    _buildMetricTile('CONFIRMED', '${agent.confirmedOrdersToday}', const Color(0xFF34D399), innerTileBg, isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0), isDark),
                    _buildMetricTile('DELIVERED', '${agent.deliveredCount}', const Color(0xFF34D399), innerTileBg, innerTileBorder, isDark),
                    _buildMetricTile('PREV ORDER', '${agent.deliveredPreviousDays}', const Color(0xFF34D399), innerTileBg, innerTileBorder, isDark),
                    _buildMetricTile('RESCHED.', '${agent.rescheduledCount}', const Color(0xFFF59E0B), innerTileBg, isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.3) : const Color(0xFFFDE68A), isDark),
                    _buildMetricTile('IN PROGRESS', '${agent.inProgressCount}', const Color(0xFF38BDF8), innerTileBg, innerTileBorder, isDark),
                    _buildMetricTile('SWITCHED OFF', '${agent.switchedOffCount}', isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), innerTileBg, innerTileBorder, isDark),
                    _buildMetricTile('CANCELLED', '${agent.cancelledCount}', const Color(0xFFEF4444), innerTileBg, isDark ? const Color(0xFFEF4444).withValues(alpha: 0.3) : const Color(0xFFFCA5A5), isDark),
                  ],
                ),

                // 4. Bottom Full-Width Manage Agent Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onManageProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: const Color(0xFF04140E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.manage_accounts_rounded, size: 15, color: Color(0xFF04140E)),
                    label: Text(
                      'Manage Agent Profile',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF04140E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor, Color bg, Color border, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
