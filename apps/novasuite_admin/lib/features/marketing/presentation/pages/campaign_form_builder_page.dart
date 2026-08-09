import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/campaign_form_builder_provider.dart';

/// Campaign Form Builder supporting Step 1: Basics, Step 2: Builder (Offer Packages, Linked Items, Custom Questions, Appearance), and Step 3: Upsells.
class CampaignFormBuilderPage extends StatefulWidget {
  final TenantTheme activeTheme;
  final VoidCallback onBackToForms;

  const CampaignFormBuilderPage({
    super.key,
    required this.activeTheme,
    required this.onBackToForms,
  });

  @override
  State<CampaignFormBuilderPage> createState() => _CampaignFormBuilderPageState();
}

class _CampaignFormBuilderPageState extends State<CampaignFormBuilderPage> {
  // Step 1: Basics Controllers
  final _formTitleController = TextEditingController(text: 'Grazer Tea Joel');
  final _digitalMarketerController = TextEditingController(text: 'joelodufu@gmail.com');
  final _redirectUrlController = TextEditingController(text: 'https://detoxwithnova.xyz/ura-clear-detox-tea');
  final _successMessageController = TextEditingController(text: 'Thanks! Our concierge team will confirm shortly.');
  final _submitButtonTextController = TextEditingController(text: 'Get Yours Now');
  final _descriptionController = TextEditingController(text: 'Internal note or CTA shown above the form.');

  // Step 2: Appearance Customization Controllers
  final _buttonBgController = TextEditingController(text: '#568500');
  final _buttonTextController = TextEditingController(text: '#ffffff');
  final _pageBgController = TextEditingController(text: '#0f172a');
  final _cardBgController = TextEditingController(text: '#fafafc');
  final _headingColorController = TextEditingController(text: '#0f172a');
  final _borderRadiusController = TextEditingController(text: '10px');

  // Step 3: Upsell Controller
  final _upsellTitleController = TextEditingController(text: 'Add 1 Extra Bottle of Detox Tea for 50% Off!');

  @override
  Widget build(BuildContext context) {
    final builderProvider = Provider.of<CampaignFormBuilderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0C1F17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBackToForms,
        ),
        title: Text('Campaign Form Builder', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        actions: [
          OutlinedButton(
            onPressed: widget.onBackToForms,
            child: const Text('Back to forms'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description & Stepper Tabs
            Text(
              'Embed-ready forms for Facebook tabs, WordPress landing pages, or microsites. Name, email, phone, address, quantity, and notes are included by default and can be configured.',
              style: GoogleFonts.inter(fontSize: 12.5, color: textMuted),
            ),
            const SizedBox(height: 20),

            // Stepper Navigation Row
            Row(
              children: [
                _buildStepTab(0, 'Step 1: Basics', builderProvider, primaryColor),
                const SizedBox(width: 10),
                _buildStepTab(1, 'Step 2: Builder', builderProvider, primaryColor),
                const SizedBox(width: 10),
                _buildStepTab(2, 'Step 3: Upsell', builderProvider, primaryColor),
                const Spacer(),
                Text('RESUME DRAFT: ', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                DropdownButton<String>(
                  value: 'Grazer Tea Joel',
                  items: const [DropdownMenuItem(value: 'Grazer Tea Joel', child: Text('Grazer Tea Joel'))],
                  onChanged: (val) {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Step Content View
            if (builderProvider.currentStep == 0)
              _buildStep1Basics(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider)
            else if (builderProvider.currentStep == 1)
              _buildStep2Builder(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider)
            else
              _buildStep3Upsell(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(int stepIndex, String label, CampaignFormBuilderProvider provider, Color primaryColor) {
    final isActive = provider.currentStep == stepIndex;
    return ElevatedButton(
      onPressed: () => provider.setStep(stepIndex),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? primaryColor : Colors.grey.withValues(alpha: 0.15),
        foregroundColor: isActive ? Colors.white : Colors.grey,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  // ===========================================================================
  // STEP 1: BASICS (Screenshot 2)
  // ===========================================================================
  Widget _buildStep1Basics(bool isDark, Color cardBg, Color textColor, Color textMuted, Color primaryColor, CampaignFormBuilderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInputGroup('FORM TITLE', _formTitleController, 'Grazer Tea Joel'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputGroup('DIGITAL MARKETER', _digitalMarketerController, 'joelodufu@gmail.com'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputGroup('REDIRECT URL', _redirectUrlController, 'https://...'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputGroup('SUCCESS MESSAGE', _successMessageController, 'Thanks!...'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputGroup('SUBMIT BUTTON TEXT', _submitButtonTextController, 'Get Yours Now'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUANTITY DISPLAY MODE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: provider.quantityDisplayMode,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Radio buttons', child: Text('Radio buttons')),
                        DropdownMenuItem(value: 'Dropdown selector', child: Text('Dropdown selector')),
                      ],
                      onChanged: (val) {
                        if (val != null) provider.setQuantityDisplayMode(val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRESET COUNTRY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: 'Nigeria',
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [DropdownMenuItem(value: 'Nigeria', child: Text('Nigeria'))],
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputGroup('DESCRIPTION', _descriptionController, 'Internal note or CTA shown above the form.', maxLines: 3),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset builder'),
              ),
              Row(
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Save draft')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => provider.setStep(1),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    child: const Text('Continue to builder ➔'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 2: BUILDER (Screenshots 3, 4 & 5 - Stateful Offer Package Cards)
  // ===========================================================================
  Widget _buildStep2Builder(bool isDark, Color cardBg, Color textColor, Color textMuted, Color primaryColor, CampaignFormBuilderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Order Dimensions, Core Fields, Offer Packages, Linked Items & Custom Questions
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Dimensions Container
                  _buildSectionCard(
                    'Order dimensions',
                    'Select one product category. Brand and cost center are derived and applied automatically.',
                    cardBg,
                    isDark,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRODUCT CATEGORY *', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: provider.selectedProductCategory,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'Grazer Herbal Tea', child: Text('Grazer Herbal Tea')),
                                  DropdownMenuItem(value: 'Vitality Booster', child: Text('Vitality Booster')),
                                ],
                                onChanged: (val) {
                                  if (val != null) provider.setProductCategory(val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField('RESOLVED BRAND', 'Novacare'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField('RESOLVED COST CENTER', 'Novacare - NL'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Core Field Options Container (Required / Visible Switches)
                  _buildSectionCard(
                    'Core field options',
                    'Configure visibility, labels, and required state for built-in checkout fields.',
                    cardBg,
                    isDark,
                    child: Column(
                      children: provider.coreFields.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final field = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: field['label'],
                                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Switch(
                                    value: field['required'] as bool,
                                    onChanged: (val) => provider.toggleCoreFieldRequired(idx),
                                  ),
                                  Text('Required', style: GoogleFonts.inter(fontSize: 12)),
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: field['visible'] as bool,
                                    onChanged: (val) => provider.toggleCoreFieldVisible(idx),
                                  ),
                                  Text('Visible', style: GoogleFonts.inter(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Offer Packages Container (Interactive State-Safe Cards!)
                  _buildSectionCard(
                    'Offer packages',
                    'Show package choices instead of listing the base item directly on the hosted form.',
                    cardBg,
                    isDark,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        final count = provider.offerPackages.length + 1;
                        provider.addOfferPackage({
                          'id': 'pkg-${DateTime.now().millisecondsSinceEpoch}',
                          'label': '$count Grazer Detox Tea',
                          'buyQty': count,
                          'freeQty': 0,
                          'amount': 25000.0 * count,
                          'discount': 0.0,
                          'isDefault': provider.offerPackages.isEmpty,
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('+ Add package'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    ),
                    child: Column(
                      children: provider.offerPackages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final pkg = entry.value;
                        return _OfferPackageCardItem(
                          key: ValueKey(pkg['id'] ?? 'pkg-$idx'),
                          index: idx,
                          package: pkg,
                          isDark: isDark,
                          provider: provider,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Linked Items & Additional Questions (Screenshot 5)
                  _buildSectionCard(
                    'Linked items',
                    'Add items through the picker, set quantity, and review price/qty in one table.',
                    cardBg,
                    isDark,
                    action: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Add item'),
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ITEM')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('QTY')),
                        DataColumn(label: Text('PRICE')),
                        DataColumn(label: Text('DEFAULT')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.linkedItems.map((item) => DataRow(cells: [
                        DataCell(Text(item['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                        DataCell(Text(item['type'])),
                        DataCell(Text('${item['qty']}')),
                        DataCell(Text('₦${item['price']}')),
                        DataCell(Radio<bool>(value: true, groupValue: item['isDefault'] as bool, onChanged: (v) {})),
                        DataCell(IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red), onPressed: () {})),
                      ])).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Questions Container (Screenshot 5)
                  _buildSectionCard(
                    'Additional questions',
                    'Optional custom fields for pickup store, delivery instructions, or financing choices.',
                    cardBg,
                    isDark,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        provider.addAdditionalQuestion({
                          'id': 'q-${DateTime.now().millisecondsSinceEpoch}',
                          'label': 'New Question',
                          'type': 'Text',
                          'placeholder': 'Enter response...',
                          'required': false,
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Add question'),
                    ),
                    child: Column(
                      children: provider.additionalQuestions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final q = entry.value;
                        return _AdditionalQuestionCardItem(
                          key: ValueKey(q['id'] ?? 'q-$idx'),
                          index: idx,
                          question: q,
                          isDark: isDark,
                          provider: provider,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Right Column: Appearance Customization Drawer (Screenshot 3 Right Column)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    Text('Customize form colors, typography, and input shape.', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                    const SizedBox(height: 16),
                    _buildInputGroup('BUTTON BACKGROUND', _buttonBgController, '#568500'),
                    const SizedBox(height: 12),
                    _buildInputGroup('BUTTON TEXT COLOR', _buttonTextController, '#ffffff'),
                    const SizedBox(height: 12),
                    _buildInputGroup('PAGE BACKGROUND', _pageBgController, '#0f172a'),
                    const SizedBox(height: 12),
                    _buildInputGroup('CARD BACKGROUND', _cardBgController, '#fafafc'),
                    const SizedBox(height: 12),
                    _buildInputGroup('HEADING COLOR', _headingColorController, '#0f172a'),
                    const SizedBox(height: 12),
                    _buildInputGroup('INPUT BORDER RADIUS', _borderRadiusController, '10px'),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open live preview'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: () => provider.setStep(0), child: const Text('Back to basics')),
            ElevatedButton(
              onPressed: () => provider.setStep(2),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
              child: const Text('Continue to upsell ➔'),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP 3: UPSELL (Screenshot 2 / Step 3)
  // ===========================================================================
  Widget _buildStep3Upsell(bool isDark, Color cardBg, Color textColor, Color textMuted, Color primaryColor, CampaignFormBuilderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Post-Checkout Upsell Configuration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          const SizedBox(height: 4),
          Text('Offer an instant 1-click upsell immediately after initial checkout form submission.', style: GoogleFonts.inter(fontSize: 12.5, color: textMuted)),
          const SizedBox(height: 20),
          _buildInputGroup('UPSELL OFFER TITLE', _upsellTitleController, 'Add 1 Extra Bottle...'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(onPressed: () => provider.setStep(1), child: const Text('Back to builder')),
              ElevatedButton(
                onPressed: () async {
                  await provider.saveLeadFormToSupabase(
                    companyId: 'c0000000-0000-0000-0000-000000000001',
                    title: _formTitleController.text,
                    marketerEmail: _digitalMarketerController.text,
                    redirectUrl: _redirectUrlController.text,
                    successMessage: _successMessageController.text,
                    submitButtonText: _submitButtonTextController.text,
                    description: _descriptionController.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign Form Saved & Published to Supabase Database ✓')));
                    widget.onBackToForms();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                child: provider.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save & Publish Campaign Form ✓'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, Color cardBg, bool isDark, {required Widget child, Widget? action}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          child: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }
}

// =============================================================================
// STATEFUL OFFER PACKAGE CARD (Preserves exact user typing across rebuilds!)
// =============================================================================
class _OfferPackageCardItem extends StatefulWidget {
  final int index;
  final Map<String, dynamic> package;
  final bool isDark;
  final CampaignFormBuilderProvider provider;

  const _OfferPackageCardItem({
    super.key,
    required this.index,
    required this.package,
    required this.isDark,
    required this.provider,
  });

  @override
  State<_OfferPackageCardItem> createState() => _OfferPackageCardItemState();
}

class _OfferPackageCardItemState extends State<_OfferPackageCardItem> {
  late final TextEditingController _labelController;
  late final TextEditingController _buyQtyController;
  late final TextEditingController _freeQtyController;
  late final TextEditingController _amountController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.package['label'] ?? '');
    _buyQtyController = TextEditingController(text: '${widget.package['buyQty'] ?? 1}');
    _freeQtyController = TextEditingController(text: '${widget.package['freeQty'] ?? 0}');
    _amountController = TextEditingController(text: '${widget.package['amount'] ?? 25000}');
    _discountController = TextEditingController(text: '${widget.package['discount'] ?? 0}');
  }

  @override
  void didUpdateWidget(covariant _OfferPackageCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.package['label'] != widget.package['label'] && _labelController.text != widget.package['label']) {
      _labelController.text = widget.package['label'] ?? '';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _buyQtyController.dispose();
    _freeQtyController.dispose();
    _amountController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = widget.package['isDefault'] == true;
    final discountVal = double.tryParse(_discountController.text) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDefault ? const Color(0xFF10B981) : (widget.isDark ? Colors.white10 : Colors.black12), width: isDefault ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Package ${widget.index + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('DEFAULT SELECTION', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                    ),
                  ],
                  if (discountVal > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('SAVE ₦${discountVal.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.blue),
                    tooltip: 'Duplicate Package',
                    onPressed: () => widget.provider.duplicateOfferPackage(widget.index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    tooltip: 'Remove Package',
                    onPressed: () => widget.provider.removeOfferPackage(widget.index),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField('PACKAGE LABEL', _labelController, 'e.g. 2 Bottles (Buy 1 Get 1 Free)', (val) {
                  widget.provider.updateOfferPackage(widget.index, 'label', val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField('BUY QUANTITY', _buyQtyController, '1', (val) {
                  widget.provider.updateOfferPackage(widget.index, 'buyQty', int.tryParse(val) ?? 1);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField('FREE QUANTITY', _freeQtyController, '0', (val) {
                  widget.provider.updateOfferPackage(widget.index, 'freeQty', int.tryParse(val) ?? 0);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField('FIXED PACKAGE AMOUNT (₦)', _amountController, '25000', (val) {
                  widget.provider.updateOfferPackage(widget.index, 'amount', double.tryParse(val) ?? 0.0);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField('DISCOUNT AMOUNT (₦)', _discountController, '0', (val) {
                  widget.provider.updateOfferPackage(widget.index, 'discount', double.tryParse(val) ?? 0.0);
                  setState(() {});
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => widget.provider.setDefaultPackage(widget.index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDefault ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDefault ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18, color: isDefault ? const Color(0xFF10B981) : Colors.grey),
                        const SizedBox(width: 8),
                        Text('Set as Default Choice', style: GoogleFonts.inter(fontSize: 12, fontWeight: isDefault ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// STATEFUL ADDITIONAL QUESTION CARD ITEM
// =============================================================================
class _AdditionalQuestionCardItem extends StatefulWidget {
  final int index;
  final Map<String, dynamic> question;
  final bool isDark;
  final CampaignFormBuilderProvider provider;

  const _AdditionalQuestionCardItem({
    super.key,
    required this.index,
    required this.question,
    required this.isDark,
    required this.provider,
  });

  @override
  State<_AdditionalQuestionCardItem> createState() => _AdditionalQuestionCardItemState();
}

class _AdditionalQuestionCardItemState extends State<_AdditionalQuestionCardItem> {
  late final TextEditingController _labelController;
  late final TextEditingController _placeholderController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.question['label'] ?? '');
    _placeholderController = TextEditingController(text: widget.question['placeholder'] ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${widget.index + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                onPressed: () => widget.provider.removeAdditionalQuestion(widget.index),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUESTION LABEL', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _labelController,
                      onChanged: (val) => widget.provider.updateAdditionalQuestion(widget.index, 'label', val),
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FIELD TYPE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: widget.question['type'] ?? 'Text',
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Text', child: Text('Text')),
                        DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                        DropdownMenuItem(value: 'Dropdown', child: Text('Dropdown')),
                      ],
                      onChanged: (v) {
                        if (v != null) widget.provider.updateAdditionalQuestion(widget.index, 'type', v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
