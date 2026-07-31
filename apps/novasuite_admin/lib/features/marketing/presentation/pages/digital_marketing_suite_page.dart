import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import 'campaign_form_builder_page.dart';

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
  late int _activeNavIndex;
  String _timeRange = 'Month'; // Today, Week, Month, Quarter

  @override
  void initState() {
    super.initState();
    _activeNavIndex = widget.activeSubIndex;
  }

  @override
  void didUpdateWidget(covariant DigitalMarketingSuitePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSubIndex != widget.activeSubIndex) {
      setState(() {
        _activeNavIndex = widget.activeSubIndex;
      });
    }
  }

  // Sample Lead Forms
  final List<Map<String, dynamic>> _forms = [
    {
      'id': 'form-1',
      'title': 'Grazer Herbal Tea Checkout',
      'marketer': 'marketer.david@novacare.com',
      'product': 'Herbal Care Detox Tea',
      'redirectUrl': 'https://detoxwithnova.xyz/thank-you',
      'submissions': 142,
      'status': 'active',
      'createdAt': '2026-07-20',
    },
    {
      'id': 'form-2',
      'title': 'Vitality Booster Special Offer',
      'marketer': 'marketer.david@novacare.com',
      'product': 'Herbal Vitality Booster',
      'redirectUrl': 'https://detoxwithnova.xyz/booster-thanks',
      'submissions': 89,
      'status': 'active',
      'createdAt': '2026-07-22',
    },
  ];

  // Sample Form Submissions with Order Lifecycle & Role Assignments
  final List<Map<String, dynamic>> _submissions = [
    {
      'id': 'sub-8901',
      'orderId': 'ORD-2026-8901',
      'customerName': 'Amina Bello',
      'phone': '+234 803 123 4567',
      'state': 'Lagos (Ikeja Hub)',
      'formTitle': 'Grazer Herbal Tea Checkout',
      'campaign': 'FB_HerbalTea_Jul2026',
      'assignedCallRep': 'Sarah CallRep',
      'assignedRider': 'Emeka Rider (Lagos Hub)',
      'amount': 25000.0,
      'orderState': 'in_transit',
      'orderStateLabel': 'Out for Delivery (Rider)',
      'orderStateColor': Colors.orange,
      'date': '2026-07-24 07:15 PM',
    },
    {
      'id': 'sub-8902',
      'orderId': 'ORD-2026-8902',
      'customerName': 'Chidi Okeke',
      'phone': '+234 812 987 6543',
      'state': 'Abuja (Garki Hub)',
      'formTitle': 'Vitality Booster Special Offer',
      'campaign': 'TikTok_Booster_Jul2026',
      'assignedCallRep': 'John CallRep',
      'assignedRider': 'Buchi Rider (Abuja Hub)',
      'amount': 35000.0,
      'orderState': 'delivered',
      'orderStateLabel': 'Delivered & Paid (COD)',
      'orderStateColor': Colors.green,
      'date': '2026-07-24 06:40 PM',
    },
    {
      'id': 'sub-8903',
      'orderId': 'ORD-2026-8903',
      'customerName': 'Emeka Nwosu',
      'phone': '+234 701 555 8899',
      'state': 'Rivers (PH Hub)',
      'formTitle': 'Grazer Herbal Tea Checkout',
      'campaign': 'FB_HerbalTea_Jul2026',
      'assignedCallRep': 'Sarah CallRep',
      'assignedRider': 'Pending Dispatch',
      'amount': 52000.0,
      'orderState': 'accepted',
      'orderStateLabel': 'Call Confirmed (Awaiting Waybill)',
      'orderStateColor': Colors.blue,
      'date': '2026-07-24 04:12 PM',
    },
    {
      'id': 'sub-8904',
      'orderId': 'ORD-2026-8904',
      'customerName': 'Fatima Mohammed',
      'phone': '+234 809 333 1122',
      'state': 'Kano (Central Hub)',
      'formTitle': 'Vitality Booster Special Offer',
      'campaign': 'Google_SkinCare_Jul2026',
      'assignedCallRep': 'Grace CallRep',
      'assignedRider': 'Unassigned',
      'amount': 25000.0,
      'orderState': 'contacting',
      'orderStateLabel': 'Call Rep Contacting',
      'orderStateColor': Colors.purple,
      'date': '2026-07-25 08:30 AM',
    },
  ];

  // FB CAPI Settings
  final _pixelIdController = TextEditingController(text: '849204918204912');
  final _capiTokenController = TextEditingController(text: 'EAAFxZ...91823791823791823');

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _activeNavIndex,
      children: [
        _buildAdPerformanceTab(),
        _buildLeadFormsTab(),
        CampaignFormBuilderPage(
          activeTheme: widget.activeTheme,
          onBackToForms: () => setState(() => _activeNavIndex = 1),
        ),
        _buildSubmissionsTab(),
        _buildBroadcastsTab(),
        _buildFbCapiTab(),
      ],
    );
  }


  // TAB 0: AD PERFORMANCE DASHBOARD (Matching Pangea CRM Layout)
  Widget _buildAdPerformanceTab() {
    final currency = widget.activeTheme.currencySymbol;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Responsive Stacking
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ad Performance', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Spend and conversions for your digital campaigns.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: ['Today', 'Week', 'Month', 'Quarter'].map((range) {
                        final isSel = _timeRange == range;
                        return GestureDetector(
                          onTap: () => setState(() => _timeRange = range),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF0F172A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              range,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ad Performance', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Spend and conversions for your digital campaigns.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['Today', 'Week', 'Month', 'Quarter'].map((range) {
                      final isSel = _timeRange == range;
                      return GestureDetector(
                        onTap: () => setState(() => _timeRange = range),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF0F172A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            range,
                            style: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Pangea CRM 3 Main Cards: Responsive Stack (Column on Mobile, Row on Desktop)
          if (isMobile)
            Column(
              children: [
                _pangeaMetricCard(
                  'SPEND',
                  '$currency 3,500,000',
                  '142 orders generated',
                  Icons.account_balance_wallet_outlined,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _pangeaMetricCard(
                  'GENERATED',
                  '142',
                  '84.5% delivery rate',
                  Icons.shopping_bag_outlined,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _pangeaMetricCard(
                  'DELIVERED',
                  '120',
                  '$currency 14.8M delivered (4.24x ROAS)',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _pangeaMetricCard(
                    'SPEND',
                    '$currency 3,500,000',
                    '142 orders generated',
                    Icons.account_balance_wallet_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _pangeaMetricCard(
                    'GENERATED',
                    '142',
                    '84.5% delivery rate',
                    Icons.shopping_bag_outlined,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _pangeaMetricCard(
                    'DELIVERED',
                    '120',
                    '$currency 14.8M delivered (4.24x ROAS)',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Spend Trend Chart Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spend Trend', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text('Daily totals across your campaigns', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.tune, color: Colors.grey, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trend Graph Area
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.show_chart, color: Colors.blue.shade700, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'Daily Campaign Conversion Trend Active',
                              style: GoogleFonts.outfit(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'Tracking Facebook Ads, TikTok Events & Google Analytics 4',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top Campaigns by Conversions & Recent Orders Row (Responsive Stack)
          if (isMobile)
            Column(
              children: [
                _buildTopCampaignsCard(currency),
                const SizedBox(height: 16),
                _buildRecentOrdersFeedCard(currency),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _buildTopCampaignsCard(currency)),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: _buildRecentOrdersFeedCard(currency)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTopCampaignsCard(String currency) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Campaigns by Conversions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Campaign Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Platform', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Spend', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ROAS', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('FB_HerbalTea_Jul2026', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('Facebook Ads')),
                    DataCell(Text('$currency 2,100,000')),
                    const DataCell(Text('4.8x', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('TikTok_Booster_Jul2026', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('TikTok Ads')),
                    DataCell(Text('$currency 950,000')),
                    const DataCell(Text('3.9x', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Google_SkinCare_Jul2026', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('Google Search')),
                    DataCell(Text('$currency 450,000')),
                    const DataCell(Text('3.2x', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersFeedCard(String currency) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Campaign Orders', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _submissions.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final sub = _submissions[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${sub['state']} • ${sub['campaign']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Text('$currency ${sub['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: LEAD FORMS LIST
  Widget _buildLeadFormsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaign Lead Forms', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Manage embeddable checkout forms and thank you conversion links', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _activeNavIndex = 2),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Campaign Lead Form'),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Campaign Lead Forms', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Manage embeddable checkout forms and thank you conversion links', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _activeNavIndex = 2),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Campaign Lead Form'),
                ),
              ],
            ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: _forms.length,
              itemBuilder: (context, index) {
                final form = _forms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 14 : 20),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                                    child: Icon(Icons.description, color: Colors.blue.shade700, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(form['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Product: ${form['product']}', style: const TextStyle(fontSize: 12)),
                              Text('Marketer: ${form['marketer']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('Thank You Link: ${form['redirectUrl']}', style: const TextStyle(color: Colors.blue, fontSize: 11)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Text('${form['submissions']} Submissions', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => setState(() => _activeNavIndex = 2),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit Form'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.description, color: Colors.blue.shade700, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(form['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Product: ${form['product']} | Marketer: ${form['marketer']}'),
                                    Text('Thank You Link: ${form['redirectUrl']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Text('${form['submissions']} Submissions', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => setState(() => _activeNavIndex = 2),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit Form'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _submissionStatusFilter = 'All';
  String _submissionSearchQuery = '';

  // TAB 3: SUBMISSIONS & ORDER LIFECYCLE TRACKER
  Widget _buildSubmissionsTab() {
    final currency = widget.activeTheme.currencySymbol;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final filteredSubmissions = _submissions.where((sub) {
      final matchesStatus = _submissionStatusFilter == 'All' ||
          (sub['orderState']?.toString().toLowerCase() == _submissionStatusFilter.toLowerCase()) ||
          (sub['orderStateLabel']?.toString().toLowerCase().contains(_submissionStatusFilter.toLowerCase()) ?? false);

      final q = _submissionSearchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (sub['orderId']?.toString().toLowerCase().contains(q) ?? false) ||
          (sub['customerName']?.toString().toLowerCase().contains(q) ?? false) ||
          (sub['assignedCallRep']?.toString().toLowerCase().contains(q) ?? false) ||
          (sub['assignedRider']?.toString().toLowerCase().contains(q) ?? false) ||
          (sub['campaign']?.toString().toLowerCase().contains(q) ?? false);

      return matchesStatus && matchesSearch;
    }).toList();

    final statusFilters = [
      {'label': 'All States', 'value': 'All'},
      {'label': '📞 Call Rep Contacting', 'value': 'contacting'},
      {'label': '✅ Call Confirmed', 'value': 'accepted'},
      {'label': '🚚 Out for Delivery', 'value': 'out_for_delivery'},
      {'label': '💰 Delivered & Paid', 'value': 'delivered'},
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campaign Submissions & Order Lifecycle', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('Real-time order pipeline tracking assigned Call Reps, Riders & Delivery States.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          // Filters & Search Header Bar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _submissionSearchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search by Order ID, Customer, Call Rep, or Rider...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusFilters.map((filter) {
                        final isSelected = _submissionStatusFilter == filter['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _submissionStatusFilter = filter['value']!);
                              }
                            },
                            selectedColor: widget.activeTheme.secondaryColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? widget.activeTheme.primaryColor : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
              child: filteredSubmissions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No order submissions match the selected status filter.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Customer & Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Assigned Call Rep', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Assigned Rider / Hub', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Order Lifecycle State', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Campaign Tag', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredSubmissions.map((sub) {
                          final Color stateColor = sub['orderStateColor'] ?? Colors.grey;
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                sub['orderId'] ?? sub['id'],
                                style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(sub['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${sub['phone']} (${sub['state']})', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(Icons.headset_mic_rounded, size: 15, color: Colors.indigo),
                                  const SizedBox(width: 6),
                                  Text(sub['assignedCallRep'] ?? 'Unassigned', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(Icons.two_wheeler_rounded, size: 15, color: Colors.orange),
                                  const SizedBox(width: 6),
                                  Text(sub['assignedRider'] ?? 'Pending', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: stateColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: stateColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  sub['orderStateLabel'] ?? sub['status'],
                                  style: TextStyle(color: stateColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                            DataCell(Text(sub['campaign'], style: const TextStyle(fontSize: 12))),
                            DataCell(Text('$currency ${sub['amount']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13))),
                            DataCell(Text(sub['date'], style: const TextStyle(color: Colors.grey, fontSize: 11))),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: BROADCASTS & MESSAGING CENTER
  Widget _buildBroadcastsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SMS & WhatsApp Broadcasts', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('Send promotional offers or delivery follow-ups to past customer leads.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Broadcast Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: 'All Past Customers',
                    decoration: const InputDecoration(labelText: 'Target Audience Segment', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'All Past Customers', child: Text('All Past Customers')),
                      DropdownMenuItem(value: 'Delivered Orders Only', child: Text('Delivered Orders Only')),
                      DropdownMenuItem(value: 'Abandoned Leads', child: Text('Abandoned Leads')),
                    ],
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Broadcast Message Text',
                      hintText: 'Hi {name}, order 1 extra bottle of Herbal Detox today for 30% off! Offer expires in 24hrs.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.green, content: Text('Broadcast dispatched to 142 recipient phone numbers!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send Broadcast Campaign'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 5: FB CAPI & PIXEL TRACKING SETUP
  Widget _buildFbCapiTab() {
    const webhookUrl = '${SupabaseConfig.supabaseUrl}/functions/v1/submit-order';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Facebook CAPI & Pixel Setup', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('Configure server-side conversion tracking for Meta Ads, TikTok Events, and GA4.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CAPI Webhook Endpoint URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: webhookUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: Colors.green, content: Text('Webhook URL copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Webhook'),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CAPI Webhook Endpoint URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: webhookUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: Colors.green, content: Text('Webhook URL copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Webhook'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  SelectableText(webhookUrl, style: GoogleFonts.firaCode(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                  const SizedBox(height: 24),

                  const Text('Meta Pixel ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _pixelIdController, decoration: const InputDecoration(border: OutlineInputBorder())),
                  const SizedBox(height: 16),

                  const Text('Meta CAPI Access Token', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _capiTokenController, decoration: const InputDecoration(border: OutlineInputBorder())),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.green, content: Text('Facebook CAPI credentials saved & verified!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                    child: const Text('Save CAPI Credentials'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pangeaMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
