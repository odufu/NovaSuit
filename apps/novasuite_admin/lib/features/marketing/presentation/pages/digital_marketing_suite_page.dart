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
  String _selectedCategoryFilter = 'All categories';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CampaignFormBuilderProvider>();
      p.fetchLeadFormsFromSupabase();
      p.fetchSubmissionsFromSupabase();
      p.fetchAvailableProductsFromSupabase();
      p.subscribeToRealtimeSubmissionsAndForms();
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
  // SUBTAB 1: SUBMISSIONS & REALTIME LEADS EXCHANGE
  // ===========================================================================
  Widget _buildSubmissionsTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final rawSubmissions = builderProvider.submissions;
    final forms = builderProvider.leadForms;

    final availableCategories = ['All categories', ...forms.map((f) => f['productCategory'].toString()).toSet()];
    final availableForms = ['All forms', ...forms.map((f) => f['title'].toString())];

    final filteredSubmissions = rawSubmissions.where((sub) {
      if (_selectedStatus != 'All statuses' && sub['status'].toString().toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_selectedCategoryFilter != 'All categories' && sub['productCategory'].toString().toLowerCase() != _selectedCategoryFilter.toLowerCase()) {
        return false;
      }
      if (_selectedFormFilter != 'All forms') {
        final matchingForm = forms.firstWhere(
          (f) => f['title'].toString().toLowerCase() == _selectedFormFilter.toLowerCase(),
          orElse: () => {},
        );
        if (matchingForm.isNotEmpty) {
          final fCode = matchingForm['code'];
          final fId = matchingForm['id'];
          if (sub['formCode'] != fCode && sub['formId'] != fId && sub['formTitle'] != _selectedFormFilter) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    final totalSubmissions = filteredSubmissions.length;
    final conversions = filteredSubmissions.where((s) => s['status'].toString().toLowerCase() == 'converted').length;
    final conversionRate = totalSubmissions > 0 ? '${((conversions / totalSubmissions) * 100).toStringAsFixed(0)}%' : '0%';
    final topFormTitle = forms.isNotEmpty ? forms.first['title'] : 'Grazer Tea Joel';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Campaigns & Live Leads', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        Text('Realtime lead exchange between landing page checkout forms and your dashboard.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
        const SizedBox(height: 24),

        // KPI Summary Cards Header
        Row(
          children: [
            Expanded(child: _buildKpiCard('Total Submissions', '$totalSubmissions', cardBg, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Conversions', '$conversions', cardBg, const Color(0xFF10B981), textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Conversion Rate', conversionRate, cardBg, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Top Form', topFormTitle.toString(), cardBg, textColor, textMuted)),
          ],
        ),
        const SizedBox(height: 24),

        // Filter Controls Bar (Timespan, Status, Product Category, Lead Form, Refresh)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(color: textColor, fontSize: 13),
                      items: ['All statuses', 'Converted', 'Pending', 'Cancelled'].map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Product Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRODUCT CATEGORY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: textMuted)),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: availableCategories.contains(_selectedCategoryFilter) ? _selectedCategoryFilter : availableCategories.first,
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(color: textColor, fontSize: 13),
                      items: availableCategories.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategoryFilter = val);
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
                      value: availableForms.contains(_selectedFormFilter) ? _selectedFormFilter : availableForms.first,
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(color: textColor, fontSize: 13),
                      items: availableForms.map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFormFilter = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    builderProvider.fetchLeadFormsFromSupabase();
                    builderProvider.fetchSubmissionsFromSupabase();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Submissions Data Table
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('CONTACT')),
                DataColumn(label: Text('FORM / CATEGORY')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('SUBMITTED')),
                DataColumn(label: Text('ORDER REF')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: filteredSubmissions.map((sub) => DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(sub['customerName']?.toString() ?? 'Anonymous Lead', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
                    Text(sub['id']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 10, color: textMuted)),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(sub['contactEmail']?.toString() ?? 'N/A', style: GoogleFonts.inter(fontSize: 11, color: textColor)),
                    Text(sub['contactPhone']?.toString() ?? 'N/A', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(sub['formCode']?.toString() ?? 'CRMF-001', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                    Text(sub['productCategory']?.toString() ?? 'General', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF10B981))),
                  ],
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text(sub['status']?.toString() ?? 'Converted', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                )),
                DataCell(Text(sub['submittedAt']?.toString() ?? 'Just now', style: GoogleFonts.inter(fontSize: 11, color: textMuted))),
                DataCell(Text(sub['orderRef']?.toString() ?? 'Pending Order', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)))),
                DataCell(IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18), onPressed: () {})),
              ])).toList(),
            ),
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
