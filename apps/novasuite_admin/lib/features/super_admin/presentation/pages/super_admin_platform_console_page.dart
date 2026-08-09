import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/tenant_brand_provider.dart';

/// Super Admin Platform Console for managing Tenant Companies, White-Label Branding, Subscriptions, and Addon Provisioning.
class SuperAdminPlatformConsolePage extends StatefulWidget {
  const SuperAdminPlatformConsolePage({super.key});

  @override
  State<SuperAdminPlatformConsolePage> createState() => _SuperAdminPlatformConsolePageState();
}

class _SuperAdminPlatformConsolePageState extends State<SuperAdminPlatformConsolePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock list of registered tenant companies
  final List<CompanyModel> _companies = [
    CompanyModel(
      id: 'cmp-novacare-1',
      name: 'NovaCare Health & Wellness',
      type: CompanyType.eCommerce,
      subdomain: 'novacare',
      customDomain: 'novacare.ng',
      branding: const BrandingConfig(
        primaryColorHex: '#10B981',
        secondaryColorHex: '#09140E',
        idpAppTitle: 'NovaCare Delivery',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    CompanyModel(
      id: 'cmp-novaexpress-1',
      name: 'Nova Express Logistics Network',
      type: CompanyType.logistics,
      subdomain: 'novaexpress',
      customDomain: 'express.novasuit.com',
      branding: const BrandingConfig(
        primaryColorHex: '#3B82F6',
        secondaryColorHex: '#0F172A',
        idpAppTitle: 'Nova Express Rider App',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    CompanyModel(
      id: 'cmp-leafora-1',
      name: 'Leafora Organics',
      type: CompanyType.eCommerce,
      subdomain: 'leafora',
      branding: const BrandingConfig(
        primaryColorHex: '#059669',
        secondaryColorHex: '#064E3B',
        idpAppTitle: 'Leafora Direct Delivery',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandProvider = Provider.of<TenantBrandProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = brandProvider.primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.admin_panel_settings_rounded, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin Platform Console',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                ),
                Text(
                  'Tenant Company Onboarding, White-Label Personalization & Addon Provisioner',
                  style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _showCreateCompanyModal,
            icon: const Icon(Icons.add_business_rounded, size: 18),
            label: Text('Onboard New Company', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: textMuted,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.business_rounded, size: 18), text: 'Tenant Companies'),
            Tab(icon: Icon(Icons.subscriptions_rounded, size: 18), text: 'SaaS Subscriptions'),
            Tab(icon: Icon(Icons.phone_in_talk_rounded, size: 18), text: 'Addon Provisioner'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Global Audit Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompaniesTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildSubscriptionsTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildAddonProvisionerTab(isDark, cardColor, textColor, textMuted, primaryColor),
          _buildAuditLogTab(isDark, cardColor, textColor, textMuted, primaryColor),
        ],
      ),
    );
  }

  /// Tab 1: Tenant Companies Directory & White-Label Switcher
  Widget _buildCompaniesTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Metrics Row
          Row(
            children: [
              _buildStatCard('Total Registered Tenants', '${_companies.length}', Icons.business_center_rounded, primaryColor, cardColor, textColor, textMuted),
              const SizedBox(width: 16),
              _buildStatCard('E-Commerce Companies', '${_companies.where((c) => c.type == CompanyType.eCommerce).length}', Icons.shopping_bag_rounded, const Color(0xFF10B981), cardColor, textColor, textMuted),
              const SizedBox(width: 16),
              _buildStatCard('Logistics Companies', '${_companies.where((c) => c.type == CompanyType.logistics).length}', Icons.local_shipping_rounded, const Color(0xFF3B82F6), cardColor, textColor, textMuted),
              const SizedBox(width: 16),
              _buildStatCard('Platform Monthly Revenue', '₦270,000 / mo', Icons.account_balance_wallet_rounded, const Color(0xFFF59E0B), cardColor, textColor, textMuted),
            ],
          ),
          const SizedBox(height: 24),

          // Companies Data Table
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Registered Tenant Network', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text('${_companies.length} active tenants', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('COMPANY NAME')),
                      DataColumn(label: Text('TYPE')),
                      DataColumn(label: Text('SUBDOMAIN')),
                      DataColumn(label: Text('BRAND COLOR')),
                      DataColumn(label: Text('RIDER APP TITLE')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: _companies.map((company) {
                      final isEcommerce = company.type == CompanyType.eCommerce;
                      final typeColor = isEcommerce ? const Color(0xFF10B981) : const Color(0xFF3B82F6);
                      final brandColor = TenantBrandProvider.hexToColor(company.branding.primaryColorHex);

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: brandColor.withValues(alpha: 0.2),
                                  child: Text(company.name[0], style: TextStyle(color: brandColor, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Text(company.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                company.type.label,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: typeColor),
                              ),
                            ),
                          ),
                          DataCell(Text('${company.subdomain}.novasuit.com', style: GoogleFonts.inter(color: textMuted, fontSize: 13))),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: brandColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(company.branding.primaryColorHex, style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                              ],
                            ),
                          ),
                          DataCell(Text(company.branding.idpAppTitle, style: GoogleFonts.inter(color: textColor, fontSize: 13))),
                          DataCell(
                            OutlinedButton.icon(
                              onPressed: () {
                                Provider.of<TenantBrandProvider>(context, listen: false).setTenantCompany(company);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Switched to ${company.name} white-label branding!')),
                                );
                              },
                              icon: const Icon(Icons.palette_rounded, size: 14),
                              label: const Text('Apply Theme'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 2: SaaS Subscriptions & Commercial Offers
  Widget _buildSubscriptionsTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('SaaS Commercial Subscription Plans', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 8),
        Text('Manage pricing tiers, offer discounts, and feature entitlements across the platform.', style: GoogleFonts.inter(color: textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPlanCard('Starter Tier', '₦25,000 / mo', 'Small E-Commerce Merchants', ['Up to 500 Orders / mo', '3 Telesales Rep Seats', 'Fail-Safe Form Builder', 'Basic Inventory'], primaryColor, cardColor, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildPlanCard('Growth Tier', '₦65,000 / mo', 'Telesales Call Centers', ['Up to 2,500 Orders / mo', '15 Telesales Rep Seats', '1 SIP Telephony DID Line', 'Multi-Warehouse Allocation'], const Color(0xFF3B82F6), cardColor, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildPlanCard('Enterprise Tier', '₦150,000 / mo', 'High-Scale E-Commerce Brands', ['Unlimited Orders', 'Unlimited Closers', '3 SIP Telephony DIDs', 'Custom Subdomain & Logo'], const Color(0xFF8B5CF6), cardColor, textColor, textMuted)),
            const SizedBox(width: 16),
            Expanded(child: _buildPlanCard('Logistics Standalone', '₦120,000 / mo', 'Logistics Companies (Nova Express)', ['Unlimited Delivery Waybills', 'Circuit Center Directory', 'Hybrid Auto/Manual Dispatch', 'White-Labeled IDP Rider App'], const Color(0xFFF59E0B), cardColor, textColor, textMuted)),
          ],
        ),
      ],
    );
  }

  /// Tab 3: Addon Provisioner (SIP DID / WhatsApp / SMS)
  Widget _buildAddonProvisionerTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Telecom & Messaging Addon Provisioner', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 8),
        Text('Provision SIP Trunk DIDs, WhatsApp Business API tokens, and Termii SMS Sender IDs for tenants.', style: GoogleFonts.inter(color: textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_forwarded_rounded, color: Color(0xFF10B981), size: 24),
                    const SizedBox(width: 12),
                    Text('Active Provisioned SIP DIDs', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  ],
                ),
                const SizedBox(height: 16),
                const ListTile(
                  title: Text('DID: 07003100077 (IT Sky Trunk)'),
                  subtitle: Text('Assigned Tenant: NovaCare Health & Wellness | Host: astpp.itskysolutions.com:7443'),
                  trailing: Chip(label: Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 4: Global System Financial Audit Log
  Widget _buildAuditLogTab(bool isDark, Color cardColor, Color textColor, Color textMuted, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Immutable Platform Audit Log', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        const SizedBox(height: 8),
        Text('System transaction history and data loss prevention event audit.', style: GoogleFonts.inter(color: textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(
            children: [
              _buildAuditRow('2026-08-09 08:15:00', 'COMPANY_ONBOARDED', 'Nova Express Logistics Network registered as LOGISTICS tenant.', textColor, textMuted),
              const Divider(),
              _buildAuditRow('2026-08-09 08:12:00', 'TELEPHONY_DID_PROVISIONED', 'Assigned DID 07003100077 to NovaCare tenant.', textColor, textMuted),
              const Divider(),
              _buildAuditRow('2026-08-09 07:55:00', 'FORM_SUBMISSION_ACK', 'Order ORD-2026-9912 safely ingested without data loss.', textColor, textMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color cardColor, Color textColor, Color textMuted) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, String sub, List<String> features, Color color, Color cardColor, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 4),
          Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: color, size: 14),
                const SizedBox(width: 6),
                Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 12, color: textColor))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String time, String event, String detail, Color textColor, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(event, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(detail, style: GoogleFonts.inter(fontSize: 12, color: textColor))),
        ],
      ),
    );
  }

  void _showCreateCompanyModal() {
    final nameCtrl = TextEditingController();
    final subdomainCtrl = TextEditingController();
    CompanyType selectedType = CompanyType.eCommerce;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Onboard New Tenant Company', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Company Name (e.g. Nova Express)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CompanyType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Company Type', border: OutlineInputBorder()),
                  items: CompanyType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subdomainCtrl,
                  decoration: const InputDecoration(labelText: 'Custom Subdomain (e.g. novaexpress)', suffixText: '.novasuit.com', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && subdomainCtrl.text.isNotEmpty) {
                  setState(() {
                    _companies.add(
                      CompanyModel(
                        id: 'cmp-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text,
                        type: selectedType,
                        subdomain: subdomainCtrl.text.toLowerCase().trim(),
                        branding: BrandingConfig(
                          primaryColorHex: selectedType == CompanyType.eCommerce ? '#10B981' : '#3B82F6',
                          idpAppTitle: '${nameCtrl.text} Rider App',
                        ),
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully onboarded ${nameCtrl.text}!')),
                  );
                }
              },
              child: const Text('Create Company'),
            ),
          ],
        ),
      ),
    );
  }
}
