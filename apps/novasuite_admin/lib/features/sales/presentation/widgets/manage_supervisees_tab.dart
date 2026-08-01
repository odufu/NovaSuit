import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'agent_profile_modal.dart';

class ManageSuperviseesTab extends StatefulWidget {
  final List<SuperviseePerformanceModel> squad;
  final TenantTheme activeTheme;
  final bool isDarkMode;
  final Function(SuperviseePerformanceModel) onUpdateSupervisee;

  const ManageSuperviseesTab({
    super.key,
    required this.squad,
    required this.activeTheme,
    required this.isDarkMode,
    required this.onUpdateSupervisee,
  });

  @override
  State<ManageSuperviseesTab> createState() => _ManageSuperviseesTabState();
}

class _ManageSuperviseesTabState extends State<ManageSuperviseesTab> {
  late ValueNotifier<String> _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _searchQuery.dispose();
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

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, queryVal, _) {
        final filteredSquad = widget.squad.where((sup) {
          final name = sup.user.fullName.toLowerCase();
          final email = sup.user.email.toLowerCase();
          return name.contains(queryVal.toLowerCase()) || email.contains(queryVal.toLowerCase());
        }).toList();

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
                      '👥 Squad Supervisee Management Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage squad call reps, assign product licenses for auto-distribution, and configure lead caps.',
                      style: TextStyle(fontSize: 13, color: textMuted),
                    ),
                  ],
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    onChanged: (val) => _searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search supervisee...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: filteredSquad.isEmpty
                  ? Center(
                      child: Text('No supervisees found matching "$queryVal"',
                          style: TextStyle(color: textMuted)),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450,
                        mainAxisExtent: 290,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredSquad.length,
                      itemBuilder: (context, index) {
                        final agent = filteredSquad[index];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                                    child: Text(
                                      agent.user.fullName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          agent.user.fullName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          agent.user.email,
                                          style: TextStyle(fontSize: 12, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Online',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Text('Assigned Products Authority:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: agent.assignedProducts.map((prod) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      prod,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const Spacer(),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Active Leads', style: TextStyle(fontSize: 11, color: textMuted)),
                                        Text('${agent.activeLeadCount} / ${agent.maxLeadCap}',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Confirmation', style: TextStyle(fontSize: 11, color: textMuted)),
                                        Text('${agent.confirmationRateToday.toStringAsFixed(1)}%',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Commission', style: TextStyle(fontSize: 11, color: textMuted)),
                                        Text('₦${agent.commissionEarnedToday.toStringAsFixed(0)}',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.primaryColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
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
                                  icon: const Icon(Icons.manage_accounts, size: 18),
                                  label: const Text('Manage Agent Profile'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
