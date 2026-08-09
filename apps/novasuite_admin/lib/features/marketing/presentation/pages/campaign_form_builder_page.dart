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
                child: _buildTextField('FORM TITLE', _formTitleController, 'Grazer Tea Joel'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('DIGITAL MARKETER', _digitalMarketerController, 'joelodufu@gmail.com'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('REDIRECT URL', _redirectUrlController, 'https://...'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('SUCCESS MESSAGE', _successMessageController, 'Thanks!...'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('SUBMIT BUTTON TEXT', _submitButtonTextController, 'Get Yours Now'),
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
          _buildTextField('DESCRIPTION', _descriptionController, 'Internal note or CTA shown above the form.', maxLines: 3),
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
  // STEP 2: BUILDER (Screenshots 3, 4 & 5)
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

                  // Offer Packages Container (Screenshot 4)
                  _buildSectionCard(
                    'Offer packages',
                    'Show package choices instead of listing the base item directly on the hosted form.',
                    cardBg,
                    isDark,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        provider.addOfferPackage({
                          'id': 'pkg-${DateTime.now().millisecondsSinceEpoch}',
                          'label': 'New Offer Package',
                          'buyQty': 1,
                          'freeQty': 0,
                          'amount': 25000.0,
                          'discount': 0.0,
                          'isDefault': false,
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Add package'),
                    ),
                    child: Column(
                      children: provider.offerPackages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final pkg = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Package ${idx + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                    onPressed: () => provider.removeOfferPackage(idx),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('PACKAGE LABEL', TextEditingController(text: pkg['label']), 'Label')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('BUY QUANTITY', TextEditingController(text: '${pkg['buyQty']}'), '1')),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('FREE QUANTITY', TextEditingController(text: '${pkg['freeQty']}'), '0')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTextField('FIXED PACKAGE AMOUNT', TextEditingController(text: '${pkg['amount']}'), '23500')),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('DISCOUNT AMOUNT', TextEditingController(text: '${pkg['discount']}'), '0')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('Default package', style: TextStyle(fontSize: 12)),
                                      value: true,
                                      groupValue: pkg['isDefault'] as bool,
                                      onChanged: (val) => provider.setDefaultPackage(idx),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF09140E) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Question ${idx + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                  IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red), onPressed: () => provider.removeAdditionalQuestion(idx)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('QUESTION LABEL', TextEditingController(text: q['label']), 'Label')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('FIELD TYPE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                                        const SizedBox(height: 4),
                                        DropdownButtonFormField<String>(
                                          initialValue: q['type'] ?? 'Text',
                                          decoration: const InputDecoration(border: OutlineInputBorder()),
                                          items: const [
                                            DropdownMenuItem(value: 'Text', child: Text('Text')),
                                            DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                                            DropdownMenuItem(value: 'Dropdown', child: Text('Dropdown')),
                                          ],
                                          onChanged: (v) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                    _buildTextField('BUTTON BACKGROUND', _buttonBgController, '#568500'),
                    const SizedBox(height: 12),
                    _buildTextField('BUTTON TEXT COLOR', _buttonTextController, '#ffffff'),
                    const SizedBox(height: 12),
                    _buildTextField('PAGE BACKGROUND', _pageBgController, '#0f172a'),
                    const SizedBox(height: 12),
                    _buildTextField('CARD BACKGROUND', _cardBgController, '#fafafc'),
                    const SizedBox(height: 12),
                    _buildTextField('HEADING COLOR', _headingColorController, '#0f172a'),
                    const SizedBox(height: 12),
                    _buildTextField('INPUT BORDER RADIUS', _borderRadiusController, '10px'),
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
          _buildTextField('UPSELL OFFER TITLE', _upsellTitleController, 'Add 1 Extra Bottle...'),
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

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
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
