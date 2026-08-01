import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../navigation/providers/app_navigation_provider.dart';
import 'campaign_form_builder_page.dart';

class DigitalMarketingSuitePage extends StatelessWidget {
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final int activeSubIndex;

  const DigitalMarketingSuitePage({
    super.key,
    required this.activeTheme,
    required this.currentUser,
    this.activeSubIndex = 0,
  });

  // Sample Lead Forms Static Seed Data
  static final List<Map<String, dynamic>> _forms = [
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
  static final List<Map<String, dynamic>> _submissions = [
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

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<AppNavigationProvider>();
    final activeNavIndex = navProvider.marketingSubNavIndex;

    return IndexedStack(
      index: activeNavIndex,
      children: [
        _buildAdPerformanceTab(context),
        _buildLeadFormsTab(context),
        CampaignFormBuilderPage(
          activeTheme: activeTheme,
          onBackToForms: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(1),
        ),
        _buildSubmissionsTab(context),
        _buildBroadcastsTab(context),
        _buildFbCapiTab(context),
      ],
    );
  }

  // TAB 0: AD PERFORMANCE DASHBOARD
  Widget _buildAdPerformanceTab(BuildContext context) {
    final currency = activeTheme.currencySymbol;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Responsive Stacking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ad Performance', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
                  const Text('Spend and conversions for your digital campaigns.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3 Main Metric Cards
          if (isMobile)
            Column(
              children: [
                _pangeaMetricCard('SPEND', '$currency 3,500,000', '142 orders generated', Icons.account_balance_wallet_outlined, Colors.blue),
                const SizedBox(height: 12),
                _pangeaMetricCard('GENERATED', '142', '84.5% delivery rate', Icons.shopping_bag_outlined, Colors.orange),
                const SizedBox(height: 12),
                _pangeaMetricCard('DELIVERED', '120', '$currency 14.8M delivered (4.24x ROAS)', Icons.check_circle_outline, Colors.green),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _pangeaMetricCard('SPEND', '$currency 3,500,000', '142 orders generated', Icons.account_balance_wallet_outlined, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _pangeaMetricCard('GENERATED', '142', '84.5% delivery rate', Icons.shopping_bag_outlined, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _pangeaMetricCard('DELIVERED', '120', '$currency 14.8M delivered (4.24x ROAS)', Icons.check_circle_outline, Colors.green)),
              ],
            ),
          const SizedBox(height: 24),

          // Top Campaigns by Conversions & Recent Orders Row
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
  Widget _buildLeadFormsTab(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Campaign Lead Forms', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
                  const Text('Manage embeddable checkout forms and thank you conversion links', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
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
                    child: Row(
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
                              onPressed: () => context.read<AppNavigationProvider>().setMarketingSubNavIndex(2),
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

  // TAB 3: SUBMISSIONS TRACKER
  Widget _buildSubmissionsTab(BuildContext context) {
    final currency = activeTheme.currencySymbol;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campaign Submissions & Order Lifecycle', style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const Text('Real-time order pipeline tracking assigned Call Reps, Riders & Delivery States.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Customer & Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Assigned Call Rep', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Assigned Rider / Hub', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Order Lifecycle State', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _submissions.map((sub) {
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
                      DataCell(Text(sub['assignedCallRep'] ?? 'Unassigned', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                      DataCell(Text(sub['assignedRider'] ?? 'Pending', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: stateColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(sub['orderStateLabel'], style: TextStyle(color: stateColor, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      DataCell(Text('$currency ${sub['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
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

  Widget _buildBroadcastsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SMS & WhatsApp Broadcasts', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Trigger SMS/WhatsApp campaigns for re-engagement and abandoned checkouts.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFbCapiTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Facebook CAPI & Pixel Integration', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Configure Conversions API server-to-server tracking for Facebook Ads.', style: TextStyle(color: Colors.grey)),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 20),
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
