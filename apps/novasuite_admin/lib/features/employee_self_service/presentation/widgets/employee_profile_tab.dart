import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_self_service_provider.dart';

class EmployeeProfileTab extends StatefulWidget {
  const EmployeeProfileTab({super.key});

  @override
  State<EmployeeProfileTab> createState() => _EmployeeProfileTabState();
}

class _EmployeeProfileTabState extends State<EmployeeProfileTab> {
  int _activeSubTabIndex = 0;

  final List<String> _subTabs = [
    'Overview',
    'Joining',
    'Address & Contacts',
    'Attendance & Leaves',
    'Salary',
    'Personal Details',
    'Profile',
    'Employee Exit',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0D1F18) : Colors.white;
    final primaryColor = const Color(0xFF2563EB);

    final provider = context.watch<EmployeeSelfServiceProvider>();
    final profile = provider.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title Header
        Text('Employee Profile', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        Text(
          '${profile['fullName']} · ${profile['department']}',
          style: GoogleFonts.inter(fontSize: 12, color: textMuted),
        ),
        const SizedBox(height: 16),

        // Sub Tab Navigation Bar
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _subTabs.asMap().entries.map((entry) {
                final idx = entry.key;
                final title = entry.value;
                final isSelected = _activeSubTabIndex == idx;

                return InkWell(
                  onTap: () => setState(() => _activeSubTabIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Sub Tab Content
        Expanded(
          child: ListView(
            children: [
              if (_activeSubTabIndex == 0) ...[
                // General Section Card
                _buildSectionCard(
                  title: 'General',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                  fields: [
                    {'label': 'EMPLOYEE', 'value': profile['employeeCode']},
                    {'label': 'SERIES', 'value': profile['series']},
                    {'label': 'FIRST NAME', 'value': profile['firstName']},
                    {'label': 'MIDDLE NAME', 'value': profile['middleName']},
                    {'label': 'LAST NAME', 'value': profile['lastName']},
                    {'label': 'FULL NAME', 'value': profile['fullName']},
                    {'label': 'GENDER', 'value': profile['gender']},
                    {'label': 'DATE OF BIRTH', 'value': profile['dob']},
                    {'label': 'SALUTATION', 'value': profile['salutation']},
                    {'label': 'DATE OF JOINING', 'value': profile['doj']},
                    {'label': 'IMAGE', 'value': '—'},
                    {'label': 'STATUS', 'value': profile['status']},
                  ],
                ),
                const SizedBox(height: 20),

                // User Details Card
                _buildSectionCard(
                  title: 'User Details',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                  fields: [
                    {'label': 'USER ID', 'value': profile['email']},
                    {'label': 'CREATE USER', 'value': '—'},
                    {'label': 'CREATE USER PERMISSION', 'value': profile['createUserPermission'] == true ? 'Yes' : 'No'},
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                  child: Column(
                    children: [
                      Icon(Icons.badge_outlined, size: 48, color: textMuted),
                      const SizedBox(height: 12),
                      Text(
                        '${_subTabs[_activeSubTabIndex]} Information',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified employee HR & ERP records linked to ${profile['employeeCode']}.',
                        style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required List<Map<String, dynamic>> fields,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
              Icon(Icons.edit_outlined, size: 16, color: textMuted),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final item = fields[index];
              final isStatus = item['label'] == 'STATUS';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['label'] ?? '', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                  const SizedBox(height: 2),
                  if (isStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['value'] ?? 'Active',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                      ),
                    )
                  else
                    Text(
                      item['value'] ?? '—',
                      style: GoogleFonts.inter(fontSize: 13, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
