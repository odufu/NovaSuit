import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

enum QuotaTimeframe { daily, weekly, monthly }

class SuperviseeQuotaMeterCard extends StatefulWidget {
  final UserModel currentUser;
  final List<OrderModel> myOrders;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final bool isMobile;

  const SuperviseeQuotaMeterCard({
    super.key,
    required this.currentUser,
    required this.myOrders,
    required this.activeTheme,
    required this.isDarkMode,
    this.isMobile = false,
  });

  @override
  State<SuperviseeQuotaMeterCard> createState() => _SuperviseeQuotaMeterCardState();
}

class _SuperviseeQuotaMeterCardState extends State<SuperviseeQuotaMeterCard> {
  QuotaTimeframe _selectedTimeframe = QuotaTimeframe.daily;

  @override
  Widget build(BuildContext context) {
    final currency = widget.activeTheme.currencySymbol;
    final now = DateTime.now();

    // Determine filter parameters based on selected timeframe
    int targetOrders = 25;
    String targetLabel = 'DAILY CALL REP TARGET';
    String commissionLabel = 'TODAY\'S COMMISSION';
    List<OrderModel> filteredOrders = [];

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    switch (_selectedTimeframe) {
      case QuotaTimeframe.daily:
        targetOrders = 25;
        targetLabel = 'DAILY TARGET';
        commissionLabel = 'TODAY\'S COMMISSION';
        filteredOrders = widget.myOrders.where((o) =>
            o.updatedAt.year == now.year &&
            o.updatedAt.month == now.month &&
            o.updatedAt.day == now.day).toList();
        break;

      case QuotaTimeframe.weekly:
        targetOrders = 125;
        targetLabel = 'WEEKLY TARGET';
        commissionLabel = 'WEEKLY COMMISSION';
        filteredOrders = widget.myOrders.where((o) => o.updatedAt.isAfter(startOfWeekDay)).toList();
        break;

      case QuotaTimeframe.monthly:
        targetOrders = 500;
        targetLabel = 'MONTHLY TARGET';
        commissionLabel = 'MONTHLY COMMISSION';
        filteredOrders = widget.myOrders.where((o) =>
            o.updatedAt.year == now.year &&
            o.updatedAt.month == now.month).toList();
        break;
    }

    // Count confirmed/accepted orders for this rep within selected period
    final confirmedCount = filteredOrders.where((o) =>
        o.status == OrderStatus.accepted ||
        o.status == OrderStatus.delivered ||
        o.status == OrderStatus.inTransit).length;

    final progressRatio = (confirmedCount / targetOrders).clamp(0.0, 1.0);
    final progressPct = (progressRatio * 100).toInt();

    // Confirmation Rate calculation
    final totalAssigned = filteredOrders.length;
    final confirmationRate = totalAssigned > 0
        ? ((confirmedCount / totalAssigned) * 100).toStringAsFixed(1)
        : '0.0';

    // Commission accrued (₦500 per confirmed order)
    final accruedCommission = confirmedCount * 500.00;

    final cardBg = widget.isDarkMode ? const Color(0xFF132A22) : Colors.white;
    final borderColor = widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Timeframe Selector Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.query_stats, size: 16, color: widget.isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    'PERFORMANCE METRICS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              // Segmented Timeframe Switcher (Daily | Weekly | Monthly)
              Container(
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimeframeChip(QuotaTimeframe.daily, 'Daily'),
                    Container(width: 1, height: 16, color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                    _buildTimeframeChip(QuotaTimeframe.weekly, 'Weekly'),
                    Container(width: 1, height: 16, color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                    _buildTimeframeChip(QuotaTimeframe.monthly, 'Monthly'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Stats Content Grid
          widget.isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Active Dialer Badge + Commission Earned
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActiveDialerBadge(),
                        _buildCommissionBadge(accruedCommission, currency, commissionLabel),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Target Progress Bar
                    _buildTargetProgressBar(confirmedCount, targetOrders, progressPct, progressRatio, targetLabel),
                  ],
                )
              : Row(
                  children: [
                    // Left Block: Target Progress Bar
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                targetLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '$confirmedCount of $targetOrders Orders ($progressPct%)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress Bar Track
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 8,
                              backgroundColor: widget.isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressPct >= 100
                                    ? const Color(0xFF10B981)
                                    : (widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300,
                    ),

                    // Center Block: Conversion Rate %
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIRMATION RATE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '$confirmationRate%',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              double.parse(confirmationRate) >= 70.0 ? Icons.trending_up : Icons.trending_flat,
                              size: 16,
                              color: double.parse(confirmationRate) >= 70.0
                                  ? const Color(0xFF10B981)
                                  : Colors.amber.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),

                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300,
                    ),

                    // Right Block: Accrued Commission & Dialer Status
                    Row(
                      children: [
                        _buildCommissionBadge(accruedCommission, currency, commissionLabel),
                        const SizedBox(width: 12),
                        _buildActiveDialerBadge(),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTimeframeChip(QuotaTimeframe timeframe, String label) {
    final isSelected = _selectedTimeframe == timeframe;

    return InkWell(
      onTap: () => setState(() => _selectedTimeframe = timeframe),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669))
                : (widget.isDarkMode ? Colors.white38 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetProgressBar(int confirmedCount, int targetOrders, int progressPct, double progressRatio, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$confirmedCount/$targetOrders ($progressPct%)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progressRatio,
            minHeight: 7,
            backgroundColor: widget.isDarkMode ? const Color(0xFF0C1F17) : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionBadge(double commission, String currency, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.isDarkMode ? const Color(0xFF10B981) : Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '$currency${commission.toStringAsFixed(0)}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDialerBadge() {
    final canTakeCalls = widget.currentUser.canTakeCalls;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: canTakeCalls
            ? (widget.isDarkMode ? const Color(0xFF0C2A38) : const Color(0xFFE0F2FE))
            : (widget.isDarkMode ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: canTakeCalls
              ? (widget.isDarkMode ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD))
              : (widget.isDarkMode ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canTakeCalls ? const Color(0xFF0284C7) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            canTakeCalls ? 'Dialer Active' : 'Dialer Paused',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: canTakeCalls
                  ? (widget.isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0369A1))
                  : (widget.isDarkMode ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }
}
