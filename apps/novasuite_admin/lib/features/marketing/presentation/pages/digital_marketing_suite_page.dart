import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../navigation/providers/app_navigation_provider.dart';
import '../providers/campaign_form_builder_provider.dart';
import 'campaign_form_builder_page.dart';

/// Complete Digital Marketing Suite matching Pangea CRM's exact subtabs:
/// - Campaigns: Lead Forms, Submissions (KPIs, Timespan, Status, Form Filters, Data Table)
/// - Marketing: Broadcasts, Email Templates, SMS Templates
class DigitalMarketingSuitePage extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final int activeSubIndex;

  const DigitalMarketingSuitePage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    this.activeSubIndex = 0,
  });

  @override
  State<DigitalMarketingSuitePage> createState() => _DigitalMarketingSuitePageState();
}

class _DigitalMarketingSuitePageState extends State<DigitalMarketingSuitePage> {
  String _selectedTimespan = 'Monthly';
  String _selectedStatus = 'All statuses';
  String _selectedFormFilter = 'All forms';

  // Sample Submissions Data (Screenshot 1)
  final List<Map<String, dynamic>> _submissions = [
    {
      'id': 'CRM-SUB-224496',
      'customerName': 'Aduniyi Oluwatoyin',
      'contactEmail': 'ftomtoyin@gmail.com',
      'contactPhone': '08030407373',
      'formCode': 'CRMF-00223',
      'status': 'Converted',
      'submittedAt': '08/08/2026, 22:14:39',
      'orderRef': 'Novacare Ltd-CRM-ORD-08-015863',
    },
    {
      'id': 'CRM-SUB-224489',
      'customerName': 'Oyewale',
      'contactEmail': 'oyewalephebe996@gmail.com',
      'contactPhone': '+2349134898980',
      'formCode': 'CRMF-00223',
      'status': 'Converted',
      'submittedAt': '08/08/2026, 22:08:19',
      'orderRef': 'Novacare Ltd-CRM-ORD-08-015856',
    },
    {
      'id': 'CRM-SUB-223609',
      'customerName': 'Halifa',
      'contactEmail': 'halifamohdaliko@gmail.com',
      'contactPhone': '08035954478',
      'formCode': 'CRMF-00223',
      'status': 'Converted',
      'submittedAt': '08/08/2026, 13:01:57',
      'orderRef': 'Novacare Ltd-CRM-ORD-08-014950',
    },
    {
      'id': 'CRM-SUB-223440',
      'customerName': 'Meze favour',
      'contactEmail': 'mezefavour3@gmail.com',
      'contactPhone': '07050729319',
      'formCode': 'CRMF-00223',
      'status': 'Converted',
      'submittedAt': '08/08/2026, 11:26:19',
      'orderRef': 'Novacare Ltd-CRM-ORD-08-014789',
    },
    {
      'id': 'CRM-SUB-222931',
      'customerName': 'Lanre Dickson',
      'contactEmail': 'dixksonjamiu@gmail.com',
      'contactPhone': '08023523196',
      'formCode': 'CRMF-00216',
      'status': 'Converted',
      'submittedAt': '08/08/2026, 06:29:22',
      'orderRef': 'Novacare Ltd-CRM-ORD-08-014244',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampaignFormBuilderProvider>().fetchLeadFormsFromSupabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<AppNavigationProvider>();
    final activeNavIndex = navProvider.marketingSubNavIndex;

    return IndexedStack(
      index: activeNavIndex,
      children: [
        _buildLeadFormsTab(context),
        _buildSubmissionsTab(context),
        CampaignFormBuilderPage(
          activeTheme: widget.activeTheme,
          onBackToForms: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(0),
        ),
        _buildBroadcastsTab(context),
        _buildEmailTemplatesTab(context),
        _buildSmsTemplatesTab(context),
      ],
    );
  }

  // ===========================================================================
  // SUBTAB 0: LEAD FORMS LIST (Shows all Drafts & Published Forms!)
  // ===========================================================================
  Widget _buildLeadFormsTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final forms = builderProvider.leadForms;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaign Lead Forms', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                Text('Build checkout forms for WordPress landing pages, TikTok ads, or microsites.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create New Form'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF09140E) : const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('FORM TITLE')),
                DataColumn(label: Text('FORM CODE')),
                DataColumn(label: Text('DIGITAL MARKETER')),
                DataColumn(label: Text('PRODUCT CATEGORY')),
                DataColumn(label: Text('SUBMISSIONS')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('LAST UPDATED')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: forms.map((item) {
                final isPublished = item['status'] == 'Published';
                final statusColor = isPublished ? const Color(0xFF10B981) : Colors.amber;

                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Icon(isPublished ? Icons.article_rounded : Icons.edit_note_rounded, size: 18, color: statusColor),
                      const SizedBox(width: 8),
                      Text(item['title'] ?? 'Untitled Form', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  )),
                  DataCell(Text(item['code'] ?? 'CRMF-001', style: GoogleFonts.robotoMono(fontSize: 11, color: textMuted))),
                  DataCell(Text(item['marketerEmail'] ?? 'marketer@novasuite.com', style: GoogleFonts.inter(color: textMuted))),
                  DataCell(Text(item['productCategory'] ?? 'General', style: GoogleFonts.inter(color: textColor))),
                  DataCell(Text('${item['submissionsCount'] ?? 0} submissions', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      item['status']?.toString().toUpperCase() ?? 'DRAFT',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  )),
                  DataCell(Text(item['updatedAt'] ?? 'Just now', style: GoogleFonts.inter(fontSize: 11, color: textMuted))),
                  DataCell(
                    OutlinedButton.icon(
                      onPressed: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Edit Form'),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUBTAB 1: SUBMISSIONS (Screenshot 1 Exact replica!)
  // ===========================================================================
  Widget _buildSubmissionsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Campaigns', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        Text('Build lead forms and review submission performance across campaigns.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        const SizedBox(height: 24),

        // KPI Summary Cards Header (Screenshot 1 Top Cards)
        Row(
          children: [
            Expanded(child: _buildKpiCard('Total Submissions (Last 30 days)', '13', cardBg, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Conversions', '13', cardBg, const Color(0xFF10B981), textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Conversion Rate', '100%', cardBg, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Top Form', 'Grazer Tea Joel', cardBg, textColor, textMuted)),
          ],
        ),
        const SizedBox(height: 24),

        // Filter Controls Bar (Timespan, Status, Lead Form, Refresh - Screenshot 1)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Row(
            children: [
              // Timespan Segmented Switch
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIMESPAN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: textMuted)),
                  const SizedBox(height: 4),
                  Row(
                    children: ['Daily', 'Weekly', 'Monthly', 'Custom'].map((t) {
                      final isSel = _selectedTimespan == t;
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: ChoiceChip(
                          label: Text(t, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : textColor)),
                          selected: isSel,
                          selectedColor: const Color(0xFF0F172A),
                          onSelected: (val) => setState(() => _selectedTimespan = t),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Status Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STATUS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: textMuted)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'All statuses', child: Text('All statuses')),
                      DropdownMenuItem(value: 'Converted', child: Text('Converted')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Lead Form Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEAD FORM', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: textMuted)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedFormFilter,
                    items: const [
                      DropdownMenuItem(value: 'All forms', child: Text('All forms')),
                      DropdownMenuItem(value: 'Grazer Tea Joel', child: Text('Grazer Tea Joel')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFormFilter = val);
                    },
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Submissions Data Table (Screenshot 1 Table)
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('CONTACT')),
              DataColumn(label: Text('FORM')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('SUBMITTED')),
              DataColumn(label: Text('ORDER')),
              DataColumn(label: Text('ACTION')),
            ],
            rows: _submissions.map((sub) => DataRow(cells: [
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(sub['customerName'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
                  Text(sub['id'], style: GoogleFonts.inter(fontSize: 10, color: textMuted)),
                ],
              )),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(sub['contactEmail'], style: GoogleFonts.inter(fontSize: 11, color: textColor)),
                  Text(sub['contactPhone'], style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                ],
              )),
              DataCell(Text(sub['formCode'], style: GoogleFonts.inter(fontSize: 12, color: textColor))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(sub['status'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              )),
              DataCell(Text(sub['submittedAt'], style: GoogleFonts.inter(fontSize: 11, color: textMuted))),
              DataCell(Text(sub['orderRef'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)))),
              DataCell(IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18), onPressed: () {})),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUBTAB 3: BROADCASTS
  // ===========================================================================
  Widget _buildBroadcastsTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Marketing Broadcasts', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
            ElevatedButton.icon(
              onPressed: () => _showCreateBroadcastModal(context, builderProvider),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('New Broadcast'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('BROADCAST NAME')),
              DataColumn(label: Text('CHANNEL')),
              DataColumn(label: Text('TEMPLATE')),
              DataColumn(label: Text('RECIPIENTS')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('DATE')),
            ],
            rows: builderProvider.broadcasts.map((b) => DataRow(cells: [
              DataCell(Text(b['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataCell(Text(b['channel'])),
              DataCell(Text(b['template'])),
              DataCell(Text('${b['recipientsCount']} contacts')),
              DataCell(Chip(label: Text(b['status'], style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green)),
              DataCell(Text(b['sentAt'])),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUBTAB 4: EMAIL TEMPLATES
  // ===========================================================================
  Widget _buildEmailTemplatesTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Email Templates', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
            ElevatedButton.icon(
              onPressed: () => _showCreateEmailTemplateModal(context, builderProvider),
              icon: const Icon(Icons.email_rounded, size: 16),
              label: const Text('Create Email Template'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('TEMPLATE TITLE')),
              DataColumn(label: Text('SUBJECT LINE')),
              DataColumn(label: Text('DATE CREATED')),
              DataColumn(label: Text('ACTIONS')),
            ],
            rows: builderProvider.emailTemplates.map((t) => DataRow(cells: [
              DataCell(Text(t['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataCell(Text(t['subject'])),
              DataCell(Text(t['createdAt'])),
              DataCell(OutlinedButton(onPressed: () {}, child: const Text('Edit'))),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUBTAB 5: SMS TEMPLATES
  // ===========================================================================
  Widget _buildSmsTemplatesTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SMS Templates', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
            ElevatedButton.icon(
              onPressed: () => _showCreateSmsTemplateModal(context, builderProvider),
              icon: const Icon(Icons.sms_rounded, size: 16),
              label: const Text('Create SMS Template'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('TITLE')),
              DataColumn(label: Text('SENDER ID')),
              DataColumn(label: Text('MESSAGE')),
              DataColumn(label: Text('ACTIONS')),
            ],
            rows: builderProvider.smsTemplates.map((t) => DataRow(cells: [
              DataCell(Text(t['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataCell(Text(t['senderId'])),
              DataCell(Text(t['message'], overflow: TextOverflow.ellipsis)),
              DataCell(OutlinedButton(onPressed: () {}, child: const Text('Edit'))),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, Color cardBg, Color valColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  void _showCreateBroadcastModal(BuildContext context, CampaignFormBuilderProvider provider) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Marketing Broadcast'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Broadcast Name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                provider.addBroadcast({
                  'id': 'bcast-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text,
                  'channel': 'Email & SMS',
                  'template': 'Default Template',
                  'recipientsCount': 500,
                  'status': 'Scheduled',
                  'sentAt': '2026-08-09',
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showCreateEmailTemplateModal(BuildContext context, CampaignFormBuilderProvider provider) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Email Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Template Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject Line', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Email Body HTML/Text', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                provider.addEmailTemplate({
                  'id': 'tpl-email-${DateTime.now().millisecondsSinceEpoch}',
                  'title': titleCtrl.text,
                  'subject': subjectCtrl.text,
                  'body': bodyCtrl.text,
                  'createdAt': '2026-08-09',
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Email Template'),
          ),
        ],
      ),
    );
  }

  void _showCreateSmsTemplateModal(BuildContext context, CampaignFormBuilderProvider provider) {
    final titleCtrl = TextEditingController();
    final senderCtrl = TextEditingController(text: 'NOVACARE');
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create SMS Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Template Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: senderCtrl, decoration: const InputDecoration(labelText: 'SMS Sender ID (11 chars max)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'SMS Message Content', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                provider.addSmsTemplate({
                  'id': 'tpl-sms-${DateTime.now().millisecondsSinceEpoch}',
                  'title': titleCtrl.text,
                  'senderId': senderCtrl.text,
                  'message': msgCtrl.text,
                  'createdAt': '2026-08-09',
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save SMS Template'),
          ),
        ],
      ),
    );
  }
}
