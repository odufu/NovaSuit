import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../navigation/providers/app_navigation_provider.dart';
import '../providers/campaign_form_builder_provider.dart';
import 'campaign_form_builder_page.dart';
import '../widgets/order_details_modal.dart';

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

  // Orders Tab State
  String _ordersSearchQuery = '';
  String _ordersSelectedStatus = 'All statuses';
  String _ordersSelectedCloser = 'All closers';
  bool _myOrdersOnly = false;
  final Set<String> _selectedOrderIds = {};
  int _rowsPerPage = 20;
  String _batchTargetStatus = 'Select status';

  // Help & Documentation Tab State
  String _helpSearchQuery = '';
  String _helpSelectedCategory = 'All Topics';

  void _showOrderDetailsModal(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => OrderDetailsModal(order: order),
    );
  }

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
        _buildOrdersTab(context),
        _buildBroadcastsTab(context),
        _buildEmailTemplatesTab(context),
        _buildSmsTemplatesTab(context),
        _buildHelpTab(context),
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaign Lead Forms', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                Text('Build checkout forms for WordPress landing pages, TikTok ads, or microsites.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showOnboardProductDialog(context, builderProvider),
                  icon: const Icon(Icons.inventory_2_rounded, size: 18, color: Color(0xFF10B981)),
                  label: const Text('Onboard Product'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create New Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
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
        Text('My Leads', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
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

  void _showOnboardProductDialog(BuildContext context, CampaignFormBuilderProvider provider) {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: provider.selectedProductCategory);
    final priceCtrl = TextEditingController(text: '23500');
    final stockCtrl = TextEditingController(text: '500');
    final skuCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 10),
            Text('Onboard New Product',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Onboard a product to your catalog so digital marketers can create campaign checkout lead forms attached to it.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'PRODUCT NAME *', hintText: 'e.g. Grazer Herbal Tea', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'CATEGORY / BRAND *', hintText: 'e.g. Grazer Herbal Tea / Vitality Booster', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'SELLING PRICE (₦) *', hintText: '23500', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'INITIAL STOCK *', hintText: '500', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(labelText: 'SKU CODE (OPTIONAL)', hintText: 'e.g. GHT-001', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'SHORT DESCRIPTION', hintText: 'Product description...', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a product name.')),
                );
                return;
              }

              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              final stock = int.tryParse(stockCtrl.text.trim()) ?? 100;

              final success = await provider.onboardProductToSupabase(
                name: nameCtrl.text.trim(),
                category: categoryCtrl.text.trim(),
                basePrice: price,
                stockQuantity: stock,
                sku: skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null,
                description: descCtrl.text.trim(),
              );

              if (ctx.mounted) Navigator.pop(ctx);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    content: Text(
                        'Product "${nameCtrl.text.trim()}" onboarded successfully! You can now create forms for it. ✓'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Onboard Product ✓'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUBTAB 3: ORDERS DIRECTORY (Pangea CRM 11-Column Orders Table)
  // ===========================================================================
  Widget _buildOrdersTab(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0);

    // 1. Fetch 100% Live Orders from Supabase DB via Provider
    final List<Map<String, dynamic>> combinedOrders = List.from(builderProvider.orders);

    // If database orders list is empty initially, fall back gracefully to live submissions
    if (combinedOrders.isEmpty) {
      for (final sub in builderProvider.submissions) {
        combinedOrders.add({
          'dbId': sub['id'],
          'id': sub['id']?.toString() ?? 'ORD-001',
          'customerName': sub['customerName'] ?? 'Anonymous Lead',
          'customerPhone': sub['contactPhone'] ?? 'N/A',
          'created': sub['submittedAt'] ?? 'Just now',
          'status': sub['status'] ?? 'Converted',
          'rawStatus': 'converted',
          'category': (sub['productCategory'] ?? 'Grazer Herbal Tea').toString().toUpperCase(),
          'formType': 'Campaign Form',
          'closer': 'Udoka Obed',
          'marketerId': widget.currentUser.id,
          'marketerEmail': widget.currentUser.email,
          'branch': 'Abuja',
          'brand': 'Nova Care',
          'value': (sub['amount'] as num?)?.toDouble() ?? 23500.0,
          'delivery': 'Delivery Pending',
          'lastUpdated': 'Just now',
        });
      }
    }

    // 2. Role-Based Marketer Visibility Filter
    // Digital Marketer can ONLY view their own orders unless DM Supervisor or AGM/Admin
    final roleFilteredOrders = combinedOrders.where((order) {
      final role = widget.currentUser.role;
      if (role == UserRole.digitalMarketer) {
        final orderMarketerId = order['marketerId']?.toString();
        final orderMarketerEmail = order['marketerEmail']?.toString().toLowerCase();
        final currentId = widget.currentUser.id;
        final currentEmail = widget.currentUser.email.toLowerCase();

        if (orderMarketerId != null && orderMarketerId.isNotEmpty && orderMarketerId != currentId) {
          if (orderMarketerEmail != null && orderMarketerEmail.isNotEmpty && orderMarketerEmail != currentEmail) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    // 3. Apply Search & Dropdown Filters
    final filteredOrders = roleFilteredOrders.where((order) {
      if (_ordersSearchQuery.isNotEmpty) {
        final q = _ordersSearchQuery.toLowerCase();
        final nameMatches = order['customerName'].toString().toLowerCase().contains(q);
        final phoneMatches = order['customerPhone'].toString().toLowerCase().contains(q);
        final idMatches = order['id'].toString().toLowerCase().contains(q);
        final categoryMatches = order['category'].toString().toLowerCase().contains(q);
        if (!nameMatches && !phoneMatches && !idMatches && !categoryMatches) return false;
      }
      if (_ordersSelectedStatus != 'All statuses') {
        if (order['status'].toString().toLowerCase() != _ordersSelectedStatus.toLowerCase()) {
          return false;
        }
      }
      if (_ordersSelectedCloser != 'All closers') {
        if (order['closer'].toString().toLowerCase() != _ordersSelectedCloser.toLowerCase()) {
          return false;
        }
      }
      if (_myOrdersOnly) {
        final closerName = order['closer'].toString().toLowerCase();
        final currentName = widget.currentUser.firstName.toLowerCase();
        final currentId = widget.currentUser.id;
        if (!closerName.contains(currentName) && order['marketerId'] != currentId) {
          return false;
        }
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Page Title & Subtitle Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Orders', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(
                    'Review new leads, update statuses, and coordinate dispatch assignments without leaving the Pangea CRM workspace.',
                    style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search & Filter Controls Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Input Box
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  onChanged: (val) => setState(() => _ordersSearchQuery = val),
                  style: GoogleFonts.inter(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search customer, phone, order',
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
                    prefixIcon: Icon(Icons.search, size: 18, color: textMuted),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF07140E) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                  ),
                ),
              ),

              // All Statuses Dropdown Filter
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF07140E) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _ordersSelectedStatus,
                    dropdownColor: cardBg,
                    style: GoogleFonts.inter(fontSize: 13, color: textColor),
                    items: ['All statuses', 'Not ready', 'Duplicate', 'Delivered', 'Call Back', 'Agent Notified', 'Cancelled', 'Confirmed', 'Pending'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _ordersSelectedStatus = val);
                    },
                  ),
                ),
              ),

              // All Closers Dropdown Filter
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF07140E) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _ordersSelectedCloser,
                    dropdownColor: cardBg,
                    style: GoogleFonts.inter(fontSize: 13, color: textColor),
                    items: ['All closers', 'Udoka Obed', 'Comfort Saleh', 'Dooshima Indyerjo', 'Vera Ojomi', 'Blessing Joseph', 'Onyiyechi Ndigwe', 'OJO DEBORAH', 'Righteous Dodo', 'Faderera Oni', 'Duplicate'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _ordersSelectedCloser = val);
                    },
                  ),
                ),
              ),

              // My Orders Toggle Switch
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _myOrdersOnly,
                    activeTrackColor: widget.activeTheme.primaryColor,
                    onChanged: (val) => setState(() => _myOrdersOnly = val),
                  ),
                  Text('My orders', style: GoogleFonts.inter(fontSize: 13, color: textColor)),
                ],
              ),

              // More Filters Button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: borderColor),
                ),
                child: Text('More filters', style: GoogleFonts.inter(fontSize: 12, color: textColor)),
              ),

              // Reset Filters Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _ordersSearchQuery = '';
                    _ordersSelectedStatus = 'All statuses';
                    _ordersSelectedCloser = 'All closers';
                    _myOrdersOnly = false;
                  });
                },
                child: Text('Reset', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Batch Update Action Bar (Appears when 1 or more orders are selected)
        if (_selectedOrderIds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_selectedOrderIds.length} order(s) selected for batch update.',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                ),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF07140E) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _batchTargetStatus,
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(fontSize: 13, color: textColor),
                      items: [
                        'Select status',
                        'New Lead',
                        'Qualified',
                        'Confirmed',
                        'Assigned',
                        'Agent Notified',
                        'Dispatch Assigned',
                        'Order Accepted',
                        'Processing',
                        'Delivery In Progress',
                        'Delivery Rescheduled',
                        'Delivered',
                        'Order Cancelled',
                        'Failed',
                        'Cancelled',
                        'Returned',
                        'Duplicate',
                        'On Hold',
                        'Not Picking',
                        'Call Back',
                        'Not Reachable',
                      ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _batchTargetStatus = val);
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_batchTargetStatus == 'Select status') return;
                    final messenger = ScaffoldMessenger.of(context);
                    for (final id in _selectedOrderIds) {
                      final order = combinedOrders.firstWhere((o) => o['id'] == id || o['dbId'] == id, orElse: () => {});
                      final dbId = order['dbId'] ?? order['id'] ?? id;
                      if (dbId != null) {
                        await builderProvider.updateOrderStatusInSupabase(dbId.toString(), _batchTargetStatus);
                      }
                    }
                    await builderProvider.fetchOrdersFromSupabase();
                    if (!mounted) return;
                    setState(() {
                      _selectedOrderIds.clear();
                      _batchTargetStatus = 'Select status';
                    });
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Batch order status updated successfully!'), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Apply To Selected', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedOrderIds.clear()),
                  child: Text('Clear', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Orders Data Table (11 Columns matching Pangea CRM)
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF0E2419) : const Color(0xFFF8FAFC)),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 58,
              horizontalMargin: 14,
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: _selectedOrderIds.length == filteredOrders.length && filteredOrders.isNotEmpty,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedOrderIds.addAll(filteredOrders.map((o) => o['id'].toString()));
                        } else {
                          _selectedOrderIds.clear();
                        }
                      });
                    },
                  ),
                ),
                DataColumn(label: Text('ORDER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('CREATED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('CATEGORY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('CLOSER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('BRANCH', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('BRAND', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('VALUE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('DELIVERY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
                DataColumn(label: Text('LAST UPDATED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted))),
              ],
              rows: filteredOrders.take(_rowsPerPage).map((order) {
                final orderId = order['id'].toString();
                final isSelected = _selectedOrderIds.contains(orderId);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedOrderIds.add(orderId);
                            } else {
                              _selectedOrderIds.remove(orderId);
                            }
                          });
                        },
                      ),
                    ),
                    // 1. ORDER (Customer Name & Phone) -> Click opens OrderDetailsModal
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(order['customerName'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                            Text(order['customerPhone'], style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                          ],
                        ),
                      ),
                    ),
                    // 2. CREATED
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['created'], style: GoogleFonts.inter(fontSize: 12, color: textColor)),
                        ),
                      ),
                    ),
                    // 3. STATUS (Interactive Pill badge with Supabase update)
                    DataCell(_buildOrderStatusPill(order, builderProvider, isDark)),
                    // 4. CATEGORY
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(order['category'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: textColor)),
                            Text(order['formType'] ?? 'Campaign Form', style: GoogleFonts.inter(fontSize: 10, color: textMuted)),
                          ],
                        ),
                      ),
                    ),
                    // 5. CLOSER
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['closer'], style: GoogleFonts.inter(fontSize: 12, color: textColor)),
                        ),
                      ),
                    ),
                    // 6. BRANCH
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['branch'], style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                        ),
                      ),
                    ),
                    // 7. BRAND
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['brand'], style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                        ),
                      ),
                    ),
                    // 8. VALUE
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('NGN ${(order['value'] as num).toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                        ),
                      ),
                    ),
                    // 9. DELIVERY
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['delivery'], style: GoogleFonts.inter(fontSize: 12, color: textColor)),
                        ),
                      ),
                    ),
                    // 10. LAST UPDATED
                    DataCell(
                      InkWell(
                        onTap: () => _showOrderDetailsModal(context, order),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(order['lastUpdated'], style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pagination Footer Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${filteredOrders.length} orders · Page 1 of 1', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _rowsPerPage,
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(fontSize: 12, color: textColor),
                      items: [10, 20, 50, 100].map((c) => DropdownMenuItem(value: c, child: Text('$c per page'))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _rowsPerPage = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Text('Previous', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Text('Next', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderStatusPill(Map<String, dynamic> order, CampaignFormBuilderProvider provider, bool isDark) {
    final status = order['status'].toString();
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'not ready':
        bg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        fg = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
        break;
      case 'duplicate':
        bg = isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2);
        fg = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
        break;
      case 'delivered':
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
        fg = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
        break;
      case 'call back':
        bg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case 'agent notified':
        bg = isDark ? const Color(0xFF431407) : const Color(0xFFFFEDD5);
        fg = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
        break;
      case 'cancelled':
        bg = isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2);
        fg = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
        break;
      case 'confirmed':
        bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        fg = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
        break;
      default:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
        fg = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }

    final availableStatuses = ['Not ready', 'Duplicate', 'Delivered', 'Call Back', 'Agent Notified', 'Cancelled', 'Confirmed'];

    return PopupMenuButton<String>(
      onSelected: (newStatus) {
        final dbId = order['dbId'] ?? order['id'];
        if (dbId != null) {
          provider.updateOrderStatusInSupabase(dbId.toString(), newStatus);
        }
      },
      tooltip: 'Change Status',
      itemBuilder: (context) => availableStatuses.map((s) {
        return PopupMenuItem(
          value: s,
          child: Text(s, style: GoogleFonts.inter(fontSize: 12)),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
            ),
            const SizedBox(width: 3),
            Icon(Icons.arrow_drop_down, size: 14, color: fg),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUBTAB 7: HELP & DOCUMENTATION HUB
  // ===========================================================================
  Widget _buildHelpTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE2E8F0);
    const accentColor = Color(0xFF10B981);

    final categories = [
      'All Topics',
      'Form Builder & Embedding',
      'UTM Tracking & Ads',
      'Ad Wallet & Spend',
      'Lead Conversion',
      'Meta CAPI & Pixel',
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. Header Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF064E3B), const Color(0xFF022C22)]
                  : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.help_center_rounded, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Digital Marketing Knowledge Base & Help Hub',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exhaustive operational guides, UTM ad parameters, form embed tutorials, and marketing KPIs',
                          style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search Field
              TextField(
                onChanged: (val) => setState(() => _helpSearchQuery = val),
                style: GoogleFonts.inter(fontSize: 13, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search documentation (e.g. embed code, utm tracking, cpl, custom fields)...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: accentColor, size: 20),
                  suffixIcon: _helpSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textMuted, size: 18),
                          onPressed: () => setState(() => _helpSearchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F291E) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: accentColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _helpSelectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : textColor,
                        ),
                        selectedColor: accentColor,
                        backgroundColor: isDark ? const Color(0xFF0F291E) : Colors.white,
                        checkmarkColor: Colors.white,
                        onSelected: (val) => setState(() => _helpSelectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Quick Action Cards Shortcuts
        Row(
          children: [
            Expanded(
              child: _buildHelpShortcutCard(
                context,
                title: 'Form Builder Wizard',
                desc: 'Create new lead forms with 10 custom questions',
                icon: Icons.build_circle_rounded,
                color: Colors.purple,
                onTap: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHelpShortcutCard(
                context,
                title: 'My Leads Table',
                desc: 'View live submissions and update order statuses',
                icon: Icons.format_list_bulleted_rounded,
                color: Colors.blue,
                onTap: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHelpShortcutCard(
                context,
                title: 'Lead Forms List',
                desc: 'Manage published forms & grab HTML embed code',
                icon: Icons.dynamic_form_rounded,
                color: Colors.orange,
                onTap: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 3. Documentation Guides Section
        Text(
          'Operational Guides & Tutorials',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Click any section below to view step-by-step instructions and code snippets',
          style: GoogleFonts.inter(fontSize: 12, color: textMuted),
        ),
        const SizedBox(height: 16),

        _buildHelpGuideAccordion(
          context,
          category: 'Form Builder & Embedding',
          title: '1. Building Lead Forms & 10 Custom Question Types',
          icon: Icons.tune_rounded,
          color: Colors.purple,
          content: [
            'NovaSuite Form Builder empowers digital marketers to build high-converting lead capture forms without writing code.',
            '• Core Standard Fields: Full Name, Phone Number, Alt Phone / WhatsApp, Email Address, Delivery Address, State, City, Product / Package selector.',
            '• 10 Custom Field Types: Text (Short input), Paragraph (Multi-line), Phone (WhatsApp validator), Dropdown (Single select options), Checkbox Group (Multi-select), Radio Group (Pill selectors), Date Picker, Time Picker, Number (Quantity/Age), File Upload (Receipts/Prescriptions).',
            '• High-Contrast Styling Engine: All field types and dropdown pickers automatically switch text color to high-contrast dark (#0F172A) or light (#FFFFFF) based on background luminance, ensuring 100% legibility across light & dark themes.',
          ],
        ),

        const SizedBox(height: 12),

        _buildHelpGuideAccordion(
          context,
          category: 'Form Builder & Embedding',
          title: '2. Embedding Forms on Landing Pages (WordPress, ClickFunnels, Custom HTML)',
          icon: Icons.code_rounded,
          color: Colors.blue,
          content: [
            'You can embed any published lead form directly into your external landing page or website.',
            '• How to grab code: Go to Lead Forms tab -> Click "Embed Code" on your desired form card -> Copy the Javascript snippet.',
            '• Embedded Script Format:\n  <script src="https://novasuite.app/embed.js" data-form-id="FORM_ID"></script>',
            '• Automatic Iframe Resizing: The embedded script automatically computes form height and adjusts the iframe seamless container without scrollbars.',
            '• White-label integration: The embed code inherits your theme colors and styling settings.',
          ],
        ),

        const SizedBox(height: 12),

        _buildHelpGuideAccordion(
          context,
          category: 'UTM Tracking & Ads',
          title: '3. Dynamic UTM Tracking & Ad Platform Attribution (Meta, TikTok, Google)',
          icon: Icons.ads_click_rounded,
          color: Colors.amber,
          content: [
            'Track exact lead sources across Facebook Ads, Instagram, TikTok Ads, and Google PPC.',
            '• Supported URL Parameters:\n  - utm_source (e.g. facebook, tiktok, google)\n  - utm_medium (e.g. cpc, story_ad, bio_link)\n  - utm_campaign (e.g. promo_august_v1)\n  - utm_term (e.g. targeted_keyword)\n  - utm_content (e.g. video_ad_v2)',
            '• Automatic URL Capture: Embedded forms automatically extract query parameters from the parent browser URL and attach them to the lead payload.',
            '• Dashboard Analytics: The Marketer Dashboard displays real-time UTM Traffic Acquisition breakdown charts based on incoming leads.',
          ],
        ),

        const SizedBox(height: 12),

        _buildHelpGuideAccordion(
          context,
          category: 'Ad Wallet & Spend',
          title: '4. Digital Marketer Wallet & Cost Per Lead (CPL) Metrics',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF10B981),
          content: [
            'Manage ad campaign budgets and track Return On Ad Spend (ROAS).',
            '• Marketer Wallet Balance: Represents allocated ad spend budget funded by supervisors or admin.',
            '• Cost Per Lead (CPL) Calculation:\n  CPL = Total Ad Spend / Total Leads Generated',
            '• Form Conversion Rate:\n  Conversion Rate = (Converted Orders / Total Submissions) * 100%',
            '• Wallet Top-Ups: Digital marketers can request wallet funding directly in the Marketer Dashboard Overview.',
          ],
        ),

        const SizedBox(height: 12),

        _buildHelpGuideAccordion(
          context,
          category: 'Lead Conversion',
          title: '5. Real-Time Lead Lifecycle & Sales Call Rep Routing',
          icon: Icons.alt_route_rounded,
          color: Colors.orange,
          content: [
            'Every lead submitted through a lead form is instantly converted into an Order in NovaSuite.',
            '• Zero Lead Duplication: Every form submission creates a distinct lead record tied exclusively to that form.',
            '• Auto-Assignment: Incoming leads are routed to online sales call reps based on round-robin assignment.',
            '• Status Lifecycle: Pending -> Agent Notified -> Call Back -> Confirmed -> Delivered / Cancelled.',
          ],
        ),

        const SizedBox(height: 12),

        _buildHelpGuideAccordion(
          context,
          category: 'Meta CAPI & Pixel',
          title: '6. Facebook Conversions API (CAPI) & Pixel Event Tracking',
          icon: Icons.webhook_rounded,
          color: Colors.indigo,
          content: [
            'Bypass iOS 14+ tracking restrictions using server-side Conversions API.',
            '• Server-Side Event Firing: When a user submits a form, NovaSuite Edge Functions fire a server-side `Lead` event to Facebook CAPI.',
            '• Event Deduplication: Dual browser Pixel + CAPI events share matching `event_id` parameters to prevent duplicate attribution in Meta Ads Manager.',
            '• Setting up CAPI: Enter your Facebook Pixel ID and Access Token under Form Settings in the Form Builder.',
          ],
        ),

        const SizedBox(height: 28),

        // 4. Frequently Asked Questions (FAQ) Accordion
        Text(
          'Frequently Asked Questions (FAQs)',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),

        _buildFaqItem(
          context,
          question: 'Can two separate forms share the exact same lead record?',
          answer: 'No. Every form submission creates a distinct lead record tied specifically to that form ID, ensuring complete isolation and precise campaign attribution.',
          isDark: isDark,
          textColor: textColor,
          textMuted: textMuted,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
        const SizedBox(height: 8),

        _buildFaqItem(
          context,
          question: 'How do I change the style/theme of my form?',
          answer: 'Open the Form Builder Wizard, navigate to Preset Styling tab, and choose between Luxury Glassmorphism, Emerald Clean, Cyberpunk Neon, or Classic Light presets.',
          isDark: isDark,
          textColor: textColor,
          textMuted: textMuted,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
        const SizedBox(height: 8),

        _buildFaqItem(
          context,
          question: 'Where are file upload question attachments saved?',
          answer: 'Uploaded files are securely transferred to Supabase Storage in dedicated form attachments buckets with encrypted public download URLs.',
          isDark: isDark,
          textColor: textColor,
          textMuted: textMuted,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
        const SizedBox(height: 8),

        _buildFaqItem(
          context,
          question: 'How quickly do new leads appear in My Leads table?',
          answer: 'Leads appear in real-time (< 500ms) thanks to Supabase Realtime WebSocket listeners active in the application.',
          isDark: isDark,
          textColor: textColor,
          textMuted: textMuted,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildHelpShortcutCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 2),
                  Text(desc, style: GoogleFonts.inter(fontSize: 11, color: textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpGuideAccordion(
    BuildContext context, {
    required String category,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> content,
  }) {
    if (_helpSelectedCategory != 'All Topics' && _helpSelectedCategory != category) {
      return const SizedBox.shrink();
    }
    if (_helpSearchQuery.isNotEmpty) {
      final query = _helpSearchQuery.toLowerCase();
      final matchTitle = title.toLowerCase().contains(query);
      final matchContent = content.any((c) => c.toLowerCase().contains(query));
      if (!matchTitle && !matchContent) return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          category,
          style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((paragraph) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              paragraph,
              style: GoogleFonts.inter(fontSize: 13, color: textMuted, height: 1.5),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    required bool isDark,
    required Color textColor,
    required Color textMuted,
    required Color cardBg,
    required Color borderColor,
  }) {
    if (_helpSearchQuery.isNotEmpty) {
      final query = _helpSearchQuery.toLowerCase();
      if (!question.toLowerCase().contains(query) && !answer.toLowerCase().contains(query)) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: GoogleFonts.inter(fontSize: 13, color: textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

