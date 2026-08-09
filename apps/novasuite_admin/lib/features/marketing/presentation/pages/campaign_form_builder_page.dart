import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/campaign_form_builder_provider.dart';

/// Address Location Cascade Helper Service for Country, State, and City/LGA.
class AddressLocationService {
  static const List<String> countries = [
    'Nigeria',
    'Ghana',
    'Kenya',
    'South Africa',
    'United Kingdom',
    'United States',
    'Canada',
  ];

  static const Map<String, List<String>> statesByCountry = {
    'Nigeria': [
      'Lagos',
      'Abuja (FCT)',
      'Rivers (Port Harcourt)',
      'Oyo (Ibadan)',
      'Kano',
      'Ogun',
      'Enugu',
      'Delta',
      'Anambra',
      'Kaduna',
      'Edo',
      'Osun',
      'Ondo',
      'Imo',
      'Kwara',
      'Plateau',
      'Akwa Ibom',
      'Benue',
      'Abia',
      'Cross River',
    ],
    'Ghana': ['Greater Accra', 'Ashanti (Kumasi)', 'Western (Takoradi)', 'Northern (Tamale)'],
    'Kenya': ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru'],
    'South Africa': ['Gauteng (Johannesburg)', 'Western Cape (Cape Town)', 'KwaZulu-Natal (Durban)'],
    'United Kingdom': ['England (London)', 'Scotland (Edinburgh)', 'Wales (Cardiff)', 'Northern Ireland'],
    'United States': ['California', 'Texas', 'New York', 'Florida', 'Georgia'],
    'Canada': ['Ontario (Toronto)', 'British Columbia (Vancouver)', 'Quebec (Montreal)'],
  };

  static const Map<String, List<String>> citiesLgasByState = {
    'Lagos': [
      'Ikeja',
      'Victoria Island / Eti-Osa',
      'Lekki / Ajah',
      'Surulere',
      'Alimosho',
      'Kosofe / Ojota',
      'Apapa',
      'Ikorodu',
      'Epe',
      'Badagry',
      'Mushin',
      'Agege',
      'Oshodi-Isolo',
      'Yaba / Lagos Mainland',
      'Amuwo-Odofin',
    ],
    'Abuja (FCT)': [
      'Garki',
      'Wuse',
      'Maitama',
      'Asokoro',
      'Gwarinpa',
      'Kubwa',
      'Lugbe',
      'Bwari',
      'Kuje',
      'Abaji',
      'Utako',
      'Jabi',
    ],
    'Rivers (Port Harcourt)': [
      'Port Harcourt City',
      'Obio-Akpor',
      'Eleme',
      'Ikwerre',
      'Bonny Island',
      'Oyigbo',
      'Degema',
    ],
    'Oyo (Ibadan)': [
      'Ibadan North',
      'Ibadan Southwest',
      'Ibadan Southeast',
      'Ibadan Northwest',
      'Oyo East',
      'Ogbomoso',
    ],
    'Kano': [
      'Kano Municipal',
      'Fagge',
      'Dala',
      'Gwale',
      'Tarauni',
      'Nassarawa',
    ],
    'Ogun': [
      'Abeokuta South',
      'Abeokuta North',
      'Ifo',
      'Ota / Ado-Odo',
      'Ijebu Ode',
      'Sagamu',
    ],
    'Enugu': ['Enugu North', 'Enugu South', 'Enugu East', 'Nsukka'],
    'Delta': ['Warri South', 'Asaba / Oshimili South', 'Uvwie / Effurun', 'Ughelli'],
  };

  static List<String> getStates(String country) {
    return statesByCountry[country] ?? statesByCountry['Nigeria']!;
  }

  static List<String> getCitiesLgas(String state) {
    return citiesLgasByState[state] ?? ['Central District', 'Metropolitan Area', 'Main City Zone'];
  }
}

/// Campaign Form Builder supporting Step 1: Basics, Step 2: Builder (Offer Packages, Cross-Product Free Gifts, Searchable Product Picker, 2D HSV Spectrum Color Canvas, Typography Fonts, Layout Templates, Embed Code Generator, Live Form Preview), and Step 3: Upsells.
/// Fully Responsive across Mobile (<768px), Tablet (768px-1023px), and Desktop (>=1024px).
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

  // Step 2: Appearance & Styling Customization Controls
  final _buttonBgController = TextEditingController(text: '#568500');
  final _buttonTextController = TextEditingController(text: '#ffffff');
  final _pageBgController = TextEditingController(text: '#0f172a');
  final _cardBgController = TextEditingController(text: '#fafafc');
  final _headingColorController = TextEditingController(text: '#0f172a');
  final _inputBgController = TextEditingController(text: '#ffffff');
  final _inputTextColorController = TextEditingController(text: '#0f172a');
  final _placeholderColorController = TextEditingController(text: '#94a3b8');
  final _borderRadiusController = TextEditingController(text: '10px');

  String _fontFamily = 'Inter';
  String _selectedLayoutTemplate = 'High-Converting E-Commerce';

  // Step 3: Upsell Controller
  final _upsellTitleController = TextEditingController(text: 'Add 1 Extra Bottle of Detox Tea for 50% Off!');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampaignFormBuilderProvider>().fetchAvailableProductsFromSupabase();
    });
  }

  void _applyLayoutTemplatePreset(String templateName) {
    setState(() {
      _selectedLayoutTemplate = templateName;
      switch (templateName) {
        case 'Minimalist Clean':
          _buttonBgController.text = '#3B82F6';
          _buttonTextController.text = '#FFFFFF';
          _pageBgController.text = '#F8FAFC';
          _cardBgController.text = '#FFFFFF';
          _headingColorController.text = '#1E293B';
          _inputBgController.text = '#F1F5F9';
          _inputTextColorController.text = '#0F172A';
          _placeholderColorController.text = '#64748B';
          _borderRadiusController.text = '6px';
          _fontFamily = 'Inter';
          break;
        case 'Luxury Glassmorphism':
          _buttonBgController.text = '#D97706';
          _buttonTextController.text = '#FFFFFF';
          _pageBgController.text = '#09140E';
          _cardBgController.text = '#0F172A';
          _headingColorController.text = '#F59E0B';
          _inputBgController.text = '#1E293B';
          _inputTextColorController.text = '#F8FAFC';
          _placeholderColorController.text = '#94A3B8';
          _borderRadiusController.text = '16px';
          _fontFamily = 'Playfair Display';
          break;
        case 'Compact Express Checkout':
          _buttonBgController.text = '#EF4444';
          _buttonTextController.text = '#FFFFFF';
          _pageBgController.text = '#F1F5F9';
          _cardBgController.text = '#FFFFFF';
          _headingColorController.text = '#111827';
          _inputBgController.text = '#FFFFFF';
          _inputTextColorController.text = '#111827';
          _placeholderColorController.text = '#9CA3AF';
          _borderRadiusController.text = '4px';
          _fontFamily = 'Poppins';
          break;
        case 'High-Converting E-Commerce':
        default:
          _buttonBgController.text = '#568500';
          _buttonTextController.text = '#FFFFFF';
          _pageBgController.text = '#0F172A';
          _cardBgController.text = '#FAFAFC';
          _headingColorController.text = '#0F172A';
          _inputBgController.text = '#FFFFFF';
          _inputTextColorController.text = '#0F172A';
          _placeholderColorController.text = '#94A3B8';
          _borderRadiusController.text = '10px';
          _fontFamily = 'Outfit';
          break;
      }
    });
  }

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showLiveFormPreviewModalDialog(context, provider: builderProvider),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Live Form Preview'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, elevation: 0),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showEmbedCodeModalDialog(context, provider: builderProvider),
                  icon: const Icon(Icons.code_rounded, size: 16),
                  label: const Text('Get Embed Code & Redirect ✓'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, elevation: 0),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: widget.onBackToForms,
                  child: const Text('Back to forms'),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isDesktop = constraints.maxWidth >= 1024;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Description & Responsive Stepper Navigation
                Text(
                  'Embed-ready forms for Facebook tabs, WordPress landing pages, or microsites. Submissions are tracked instantly and buyers redirect automatically to your Thank-You Page.',
                  style: GoogleFonts.inter(fontSize: isMobile ? 11.5 : 12.5, color: textMuted),
                ),
                const SizedBox(height: 16),

                // Responsive Stepper Navigation Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepTab(0, 'Step 1: Basics', builderProvider, primaryColor),
                      const SizedBox(width: 8),
                      _buildStepTab(1, 'Step 2: Builder', builderProvider, primaryColor),
                      const SizedBox(width: 8),
                      _buildStepTab(2, 'Step 3: Upsell', builderProvider, primaryColor),
                      const SizedBox(width: 16),
                      Text('RESUME DRAFT: ', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                      DropdownButton<String>(
                        value: 'Grazer Tea Joel',
                        items: const [DropdownMenuItem(value: 'Grazer Tea Joel', child: Text('Grazer Tea Joel'))],
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Active Step Content View
                if (builderProvider.currentStep == 0)
                  _buildStep1Basics(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider, isMobile: isMobile)
                else if (builderProvider.currentStep == 1)
                  _buildStep2Builder(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider, isDesktop: isDesktop, isMobile: isMobile)
                else
                  _buildStep3Upsell(isDark, cardBg, textColor, textMuted, primaryColor, builderProvider, isMobile: isMobile),
              ],
            ),
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5)),
    );
  }

  // ===========================================================================
  // STEP 1: BASICS
  // ===========================================================================
  Widget _buildStep1Basics(bool isDark, Color cardBg, Color textColor, Color textMuted, Color primaryColor, CampaignFormBuilderProvider provider, {required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildInputGroup('FORM TITLE', _formTitleController, 'Grazer Tea Joel'),
            const SizedBox(height: 12),
            _buildInputGroup('DIGITAL MARKETER', _digitalMarketerController, 'joelodufu@gmail.com'),
            const SizedBox(height: 12),
            _buildInputGroup('REDIRECT URL / THANK YOU LINK *', _redirectUrlController, 'https://detoxwithnova.xyz/thank-you'),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildInputGroup('FORM TITLE', _formTitleController, 'Grazer Tea Joel')),
                const SizedBox(width: 16),
                Expanded(child: _buildInputGroup('DIGITAL MARKETER', _digitalMarketerController, 'joelodufu@gmail.com')),
                const SizedBox(width: 16),
                Expanded(child: _buildInputGroup('REDIRECT URL / THANK YOU LINK *', _redirectUrlController, 'https://detoxwithnova.xyz/thank-you')),
              ],
            ),
          ],
          const SizedBox(height: 16),

          if (isMobile) ...[
            _buildInputGroup('SUCCESS MESSAGE', _successMessageController, 'Thanks!...'),
            const SizedBox(height: 12),
            _buildInputGroup('SUBMIT BUTTON TEXT', _submitButtonTextController, 'Get Yours Now'),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QUANTITY DISPLAY MODE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: provider.quantityDisplayMode,
                  dropdownColor: cardBg,
                  style: GoogleFonts.inter(color: textColor, fontSize: 13),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['Radio buttons', 'Dropdown selector'].map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) provider.setQuantityDisplayMode(val);
                  },
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildInputGroup('SUCCESS MESSAGE', _successMessageController, 'Thanks!...')),
                const SizedBox(width: 16),
                Expanded(child: _buildInputGroup('SUBMIT BUTTON TEXT', _submitButtonTextController, 'Get Yours Now')),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QUANTITY DISPLAY MODE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: provider.quantityDisplayMode,
                        dropdownColor: cardBg,
                        style: GoogleFonts.inter(color: textColor, fontSize: 13),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: ['Radio buttons', 'Dropdown selector'].map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) provider.setQuantityDisplayMode(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                  OutlinedButton(
                    onPressed: () {
                      provider.addOrUpdateLeadForm(
                        title: _formTitleController.text,
                        marketerEmail: _digitalMarketerController.text,
                        productCategory: provider.selectedProductCategory,
                        status: 'Draft',
                        redirectUrl: _redirectUrlController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF3B82F6),
                          content: Text('Form draft saved! Listed in Campaign Lead Forms. ✓'),
                        ),
                      );
                    },
                    child: const Text('Save draft'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      provider.addOrUpdateLeadForm(
                        title: _formTitleController.text,
                        marketerEmail: _digitalMarketerController.text,
                        productCategory: provider.selectedProductCategory,
                        status: 'Draft',
                        redirectUrl: _redirectUrlController.text,
                      );
                      provider.setStep(1);
                    },
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
  // STEP 2: BUILDER
  // ===========================================================================
  Widget _buildStep2Builder(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color textMuted,
    Color primaryColor,
    CampaignFormBuilderProvider provider, {
    required bool isDesktop,
    required bool isMobile,
  }) {
    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Dimensions Container
        _buildSectionCard(
          'Order dimensions',
          'Select one product category. Brand and cost center are derived and applied automatically.',
          cardBg,
          isDark,
          child: isMobile
              ? Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRODUCT CATEGORY *', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: provider.selectedProductCategory,
                          dropdownColor: cardBg,
                          style: GoogleFonts.inter(color: textColor, fontSize: 13),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: ['Grazer Herbal Tea', 'Vitality Booster'].map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) provider.setProductCategory(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('RESOLVED BRAND', 'Novacare'),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('RESOLVED COST CENTER', 'Novacare - NL'),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRODUCT CATEGORY *', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: textMuted)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: provider.selectedProductCategory,
                            dropdownColor: cardBg,
                            style: GoogleFonts.inter(color: textColor, fontSize: 13),
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: ['Grazer Herbal Tea', 'Vitality Booster'].map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) provider.setProductCategory(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildReadOnlyField('RESOLVED BRAND', 'Novacare')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildReadOnlyField('RESOLVED COST CENTER', 'Novacare - NL')),
                  ],
                ),
        ),
        const SizedBox(height: 20),

        // Core Field Options Container
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
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Switch(
                          value: field['required'] as bool,
                          onChanged: (val) => provider.toggleCoreFieldRequired(idx),
                        ),
                        Text('Req', style: GoogleFonts.inter(fontSize: 11)),
                        const SizedBox(width: 8),
                        Switch(
                          value: field['visible'] as bool,
                          onChanged: (val) => provider.toggleCoreFieldVisible(idx),
                        ),
                        Text('Vis', style: GoogleFonts.inter(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Offer Packages DataTable
        _buildSectionCard(
          'Offer packages',
          'Show package choices instead of listing the base item directly on the hosted form.',
          cardBg,
          isDark,
          action: ElevatedButton.icon(
            onPressed: () => _showOfferPackageModalDialog(context, provider: provider),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('+ Add Offer Package'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
          child: provider.offerPackages.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Text('No offer packages added yet. Click "+ Add Offer Package" to create one.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF09140E) : const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text('PACKAGE LABEL')),
                      DataColumn(label: Text('BUY QTY')),
                      DataColumn(label: Text('FREE GIFT / ADDON')),
                      DataColumn(label: Text('TOTAL DEDUCTED STOCK')),
                      DataColumn(label: Text('AMOUNT (₦)')),
                      DataColumn(label: Text('SAVINGS')),
                      DataColumn(label: Text('DEFAULT CHOICE')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: provider.offerPackages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final pkg = entry.value;
                      final isDefault = pkg['isDefault'] == true;
                      final buyQty = (pkg['buyQty'] ?? 1) as int;
                      final freeQty = (pkg['freeQty'] ?? 0) as int;
                      final freeAddonName = pkg['freeAddonProductName'] as String?;
                      final freeAddonQty = (pkg['freeAddonQty'] ?? 0) as int;
                      final totalStockUnits = buyQty + freeQty + freeAddonQty;
                      final discountVal = (pkg['discount'] ?? 0.0) as double;

                      return DataRow(
                        color: isDefault ? WidgetStateProperty.all(primaryColor.withValues(alpha: 0.08)) : null,
                        cells: [
                          DataCell(Row(
                            children: [
                              Text(pkg['label'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                  child: Text('DEFAULT', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: primaryColor)),
                                ),
                              ],
                            ],
                          )),
                          DataCell(Text('$buyQty', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                          DataCell(
                            freeAddonName != null && freeAddonQty > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                    child: Text('🎁 ${freeAddonQty}x $freeAddonName (FREE)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                                  )
                                : Text(freeQty > 0 ? '${freeQty}x Same Product (Free)' : '—', style: GoogleFonts.inter(color: textMuted)),
                          ),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: Text('$totalStockUnits units ($buyQty + ${freeQty + freeAddonQty} free)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                          )),
                          DataCell(Text('₦${(pkg['amount'] ?? 0.0).toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
                          DataCell(
                            discountVal > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                    child: Text('Save ₦${discountVal.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  )
                                : Text('—', style: TextStyle(color: textMuted)),
                          ),
                          DataCell(Radio<bool>(
                            value: true,
                            groupValue: isDefault,
                            activeColor: primaryColor,
                            onChanged: (v) => provider.setDefaultPackage(idx),
                          )),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                                tooltip: 'Edit Package',
                                onPressed: () => _showOfferPackageModalDialog(context, provider: provider, editIndex: idx, existingPkg: pkg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.indigo),
                                tooltip: 'Duplicate Package',
                                onPressed: () => provider.duplicateOfferPackage(idx),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                tooltip: 'Delete Package',
                                onPressed: () => provider.removeOfferPackage(idx),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 20),

        // Linked Items
        _buildSectionCard(
          'Linked items',
          'Add items through the picker, set quantity, and review price/qty in one table.',
          cardBg,
          isDark,
          action: ElevatedButton.icon(
            onPressed: () => _showAddLinkedItemModalDialog(context, provider: provider),
            icon: const Icon(Icons.search_rounded, size: 16),
            label: const Text('+ Attach Product Item'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
          child: provider.linkedItems.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Text('No product items attached yet. Click "+ Attach Product Item" to search onboarded catalog.', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF09140E) : const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text('ITEM NAME')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('TYPE')),
                      DataColumn(label: Text('QTY')),
                      DataColumn(label: Text('PRICE (₦)')),
                      DataColumn(label: Text('DEFAULT ITEM')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: provider.linkedItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isDefault = item['isDefault'] == true;

                      return DataRow(
                        color: isDefault ? WidgetStateProperty.all(const Color(0xFF3B82F6).withValues(alpha: 0.08)) : null,
                        cells: [
                          DataCell(Text(item['name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
                          DataCell(Text(item['sku'] ?? 'SKU-001', style: GoogleFonts.inter(fontSize: 11, color: textMuted))),
                          DataCell(Chip(
                            label: Text(item['type'] ?? 'Main', style: const TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: item['type'] == 'Main' ? Colors.blue : Colors.purple,
                          )),
                          DataCell(Text('${item['qty'] ?? 1}', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                          DataCell(Text('₦${(item['price'] ?? 0.0).toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor))),
                          DataCell(Radio<bool>(
                            value: true,
                            groupValue: isDefault,
                            activeColor: const Color(0xFF3B82F6),
                            onChanged: (v) => provider.setDefaultLinkedItem(idx),
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                            tooltip: 'Remove Item',
                            onPressed: () => provider.removeLinkedItem(idx),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 20),

        // Additional Questions Container
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
    );

    final appearanceDrawer = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance & Styling Controls', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          Text('Choose layout templates, typography fonts, input background/placeholder colors, and fine-tune RGB spectrum colors.', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
          const SizedBox(height: 16),

          Text('PREBUILT LAYOUT STYLE / TEMPLATE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _selectedLayoutTemplate,
            dropdownColor: cardBg,
            style: GoogleFonts.inter(color: textColor, fontSize: 13),
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            items: ['High-Converting E-Commerce', 'Minimalist Clean', 'Luxury Glassmorphism', 'Compact Express Checkout'].map((t) => DropdownMenuItem(
              value: t,
              child: Text(t, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
            )).toList(),
            onChanged: (val) {
              if (val != null) _applyLayoutTemplatePreset(val);
            },
          ),
          const SizedBox(height: 14),

          Text('TYPOGRAPHY FONT FAMILY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _fontFamily,
            dropdownColor: cardBg,
            style: GoogleFonts.inter(color: textColor, fontSize: 13),
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            items: ['Inter', 'Outfit', 'Roboto', 'Poppins', 'Montserrat', 'Plus Jakarta Sans', 'Playfair Display'].map((f) => DropdownMenuItem(
              value: f,
              child: Text(f, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _fontFamily = val);
            },
          ),
          const SizedBox(height: 14),

          _buildColorPickerGroup('BUTTON BACKGROUND', _buttonBgController, defaultHex: '#568500'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('BUTTON TEXT COLOR', _buttonTextController, defaultHex: '#ffffff'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('PAGE BACKGROUND', _pageBgController, defaultHex: '#0f172a'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('CARD BACKGROUND', _cardBgController, defaultHex: '#fafafc'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('HEADING TEXT COLOR', _headingColorController, defaultHex: '#0f172a'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('FORM INPUT BACKGROUND', _inputBgController, defaultHex: '#ffffff'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('FORM INPUT TEXT COLOR', _inputTextColorController, defaultHex: '#0f172a'),
          const SizedBox(height: 10),
          _buildColorPickerGroup('PLACEHOLDER TEXT COLOR', _placeholderColorController, defaultHex: '#94a3b8'),
          const SizedBox(height: 10),
          _buildInputGroup('INPUT BORDER RADIUS', _borderRadiusController, '10px'),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => _showLiveFormPreviewModalDialog(context, provider: provider),
            icon: const Icon(Icons.visibility_rounded, size: 16),
            label: const Text('Open Live Customer Form Preview'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _showEmbedCodeModalDialog(context, provider: provider),
            icon: const Icon(Icons.code_rounded, size: 16),
            label: const Text('Get Embed Code & Redirect ✓'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(44)),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: leftContent),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: appearanceDrawer),
            ],
          ),
        ] else ...[
          leftContent,
          const SizedBox(height: 24),
          appearanceDrawer,
        ],
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
  // STEP 3: UPSELL
  // ===========================================================================
  Widget _buildStep3Upsell(bool isDark, Color cardBg, Color textColor, Color textMuted, Color primaryColor, CampaignFormBuilderProvider provider, {required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                    appearance: {
                      'button_bg': _buttonBgController.text,
                      'button_text': _buttonTextController.text,
                      'page_bg': _pageBgController.text,
                      'card_bg': _cardBgController.text,
                      'heading_color': _headingColorController.text,
                      'input_bg': _inputBgController.text,
                      'input_text': _inputTextColorController.text,
                      'placeholder_color': _placeholderColorController.text,
                      'font_family': _fontFamily,
                      'layout_style': _selectedLayoutTemplate,
                      'border_radius': _borderRadiusController.text,
                    },
                  );
                  if (mounted) {
                    _showEmbedCodeModalDialog(context, provider: provider);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                child: provider.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save, Publish & Get Embed Code ✓'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODAL DIALOG: LIVE CUSTOMER ACQUISITION CHECKOUT FORM PREVIEW
  // Re-ordered Layout: Form Inputs FIRST -> Package Selection SECOND -> Submit Button LAST
  // Address Location Cascade: Country -> State -> City/LGA
  // Form Name is NOT shown at the top of the preview form
  // Submit button is disabled in preview mode until embedded live on landing page
  // ===========================================================================
  void _showLiveFormPreviewModalDialog(BuildContext context, {required CampaignFormBuilderProvider provider}) {
    final formDesc = _descriptionController.text;
    final btnBg = _parseColorFromHex(_buttonBgController.text, defaultHex: '#568500');
    final btnText = _parseColorFromHex(_buttonTextController.text, defaultHex: '#ffffff');
    final cardBgColor = _parseColorFromHex(_cardBgController.text, defaultHex: '#fafafc');
    final headingColor = _parseColorFromHex(_headingColorController.text, defaultHex: '#0f172a');
    final inputBgColor = _parseColorFromHex(_inputBgController.text, defaultHex: '#ffffff');
    final inputTextColor = _parseColorFromHex(_inputTextColorController.text, defaultHex: '#0f172a');
    final placeholderColor = _parseColorFromHex(_placeholderColorController.text, defaultHex: '#94a3b8');
    final btnLabel = _submitButtonTextController.text;

    Map<String, dynamic>? selectedOfferPkg = provider.offerPackages.firstWhere(
      (p) => p['isDefault'] == true,
      orElse: () => provider.offerPackages.isNotEmpty ? provider.offerPackages.first : {},
    );

    final nameController = TextEditingController(text: 'Chief Customer Tester');
    final phoneController = TextEditingController(text: '08099887766');
    final addressController = TextEditingController(text: '12 Victoria Island Expressway');

    String selectedCountry = 'Nigeria';
    List<String> availableStates = AddressLocationService.getStates('Nigeria');
    String selectedState = availableStates.first;
    List<String> availableCitiesLgas = AddressLocationService.getCitiesLgas(selectedState);
    String selectedCityLga = availableCitiesLgas.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: cardBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_rounded, color: Color(0xFF10B981), size: 22),
                    const SizedBox(width: 8),
                    Text('Live Form Preview', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 16, color: headingColor)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('PREVIEW MODE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview Banner Notification (Submit disabled in preview mode)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Preview Mode: Submissions are disabled here. Form active once embedded on your landing page.',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: headingColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Headline CTA Description (NO Form Name at top!)
                    if (formDesc.isNotEmpty) ...[
                      Text(formDesc, style: GoogleFonts.getFont(_fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: headingColor)),
                      const SizedBox(height: 16),
                    ],

                    // 1. SECTION 1: FORM INPUTS FIRST
                    Text('CUSTOMER & DELIVERY DETAILS', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 11, color: placeholderColor)),
                    const SizedBox(height: 8),
                    _buildCustomStyledTextField('FULL NAME *', nameController, 'Chief Customer Tester', inputBgColor, inputTextColor, placeholderColor),
                    const SizedBox(height: 10),
                    _buildCustomStyledTextField('PHONE NUMBER (FOR RIDER) *', phoneController, '08099887766', inputBgColor, inputTextColor, placeholderColor),
                    const SizedBox(height: 10),

                    // Address API Cascade: Country -> State -> City/LGA
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COUNTRY *', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 10, color: placeholderColor)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCountry,
                                dropdownColor: inputBgColor,
                                decoration: InputDecoration(
                                  fillColor: inputBgColor,
                                  filled: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 12),
                                items: AddressLocationService.countries.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 12)),
                                )).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() {
                                      selectedCountry = v;
                                      availableStates = AddressLocationService.getStates(v);
                                      selectedState = availableStates.first;
                                      availableCitiesLgas = AddressLocationService.getCitiesLgas(selectedState);
                                      selectedCityLga = availableCitiesLgas.first;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('STATE *', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 10, color: placeholderColor)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedState,
                                dropdownColor: inputBgColor,
                                decoration: InputDecoration(
                                  fillColor: inputBgColor,
                                  filled: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 12),
                                items: availableStates.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis, style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 12)),
                                )).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() {
                                      selectedState = v;
                                      availableCitiesLgas = AddressLocationService.getCitiesLgas(v);
                                      selectedCityLga = availableCitiesLgas.first;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text('CITY / LOCAL GOVERNMENT AREA (LGA) *', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 10, color: placeholderColor)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: availableCitiesLgas.contains(selectedCityLga) ? selectedCityLga : availableCitiesLgas.first,
                      dropdownColor: inputBgColor,
                      decoration: InputDecoration(
                        fillColor: inputBgColor,
                        filled: true,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 13),
                      items: availableCitiesLgas.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: GoogleFonts.getFont(_fontFamily, color: inputTextColor, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedCityLga = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildCustomStyledTextField('DELIVERY ADDRESS *', addressController, '12 Victoria Island Expressway', inputBgColor, inputTextColor, placeholderColor),
                    const SizedBox(height: 20),

                    // 2. SECTION 2: OFFER PACKAGES CHOICE CARDS (UNDER FORM INPUTS)
                    Text('SELECT YOUR OFFER PACKAGE *', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 11, color: placeholderColor)),
                    const SizedBox(height: 8),
                    Column(
                      children: provider.offerPackages.map((pkg) {
                        final isSelected = selectedOfferPkg?['id'] == pkg['id'];
                        final label = pkg['label'] ?? '';
                        final amount = (pkg['amount'] ?? 0.0) as double;
                        final discount = (pkg['discount'] ?? 0.0) as double;
                        final freeAddonName = pkg['freeAddonProductName'] as String?;
                        final freeAddonQty = (pkg['freeAddonQty'] ?? 0) as int;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedOfferPkg = pkg);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : inputBgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.3), width: isSelected ? 2 : 1),
                            ),
                            child: Row(
                              children: [
                                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20, color: isSelected ? const Color(0xFF10B981) : Colors.grey),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(label, style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: inputTextColor)),
                                      if (freeAddonName != null && freeAddonQty > 0)
                                        Text('🎁 Includes FREE ${freeAddonQty}x $freeAddonName', style: GoogleFonts.getFont(_fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₦${amount.toStringAsFixed(0)}', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF10B981))),
                                    if (discount > 0)
                                      Text('Save ₦${discount.toStringAsFixed(0)}', style: GoogleFonts.getFont(_fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // 3. SECTION 3: SUBMIT BUTTON (FOLLOWED BY OFFER PACKAGES)
                    Tooltip(
                      message: 'Submissions are active once embedded on landing page.',
                      child: ElevatedButton(
                        onPressed: null, // Disabled in preview mode as requested
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: btnBg.withValues(alpha: 0.5),
                          disabledForegroundColor: btnText.withValues(alpha: 0.8),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('$btnLabel (Preview Disabled)', style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Preview')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomStyledTextField(String label, TextEditingController controller, String hint, Color bg, Color text, Color placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.getFont(_fontFamily, fontWeight: FontWeight.bold, fontSize: 10, color: placeholder)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.getFont(_fontFamily, color: text, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.getFont(_fontFamily, color: placeholder, fontSize: 12),
            fillColor: bg,
            filled: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  // EMBED CODE GENERATOR & THANK-YOU REDIRECT DIALOG
  // Generates complete HTML/JS embed code with:
  // - Address Location Cascade (Country -> State -> City/LGA)
  // - Form Inputs FIRST -> Package Choices SECOND -> Submit Button LAST
  // - NO Form Title at the top
  void _showEmbedCodeModalDialog(BuildContext context, {required CampaignFormBuilderProvider provider}) {
    final redirectUrl = _redirectUrlController.text.isNotEmpty ? _redirectUrlController.text : 'https://detoxwithnova.xyz/thank-you';
    final btnBg = _buttonBgController.text;
    final btnText = _buttonTextController.text;
    final btnLabel = _submitButtonTextController.text;

    final embedCodeSnippet = '''
<!-- NOVASUITE EMBEDDABLE CHECKOUT FORM -->
<div id="novasuite-form-container" style="max-width: 540px; margin: 0 auto; padding: 24px; background: ${_cardBgController.text}; border-radius: ${_borderRadiusController.text}; font-family: '$_fontFamily', sans-serif;">
  <p style="color: ${_placeholderColorController.text}; font-size: 13px; font-weight: 600; margin-bottom: 20px;">${_descriptionController.text}</p>
  
  <form id="novasuite-checkout-form">
    <input type="hidden" name="company_id" value="c0000000-0000-0000-0000-000000000001" />
    <input type="hidden" name="redirect_url" value="$redirectUrl" />

    <!-- SECTION 1: FORM INPUTS FIRST -->
    <div style="margin-bottom: 14px;">
      <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">FULL NAME *</label>
      <input type="text" name="customer_name" required placeholder="Enter full name" style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">PHONE NUMBER (FOR DELIVERY RIDER) *</label>
      <input type="tel" name="customer_phone" required placeholder="08012345678" style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
    </div>

    <div style="display: flex; gap: 10px; margin-bottom: 14px;">
      <div style="flex: 1;">
        <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">COUNTRY *</label>
        <select id="novasuite-country" name="country" required style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;">
          <option value="Nigeria">Nigeria</option>
          <option value="Ghana">Ghana</option>
          <option value="Kenya">Kenya</option>
        </select>
      </div>

      <div style="flex: 1;">
        <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">DELIVERY STATE *</label>
        <select id="novasuite-state" name="delivery_state" required style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;">
          <option value="Lagos">Lagos</option>
          <option value="Abuja (FCT)">Abuja (FCT)</option>
          <option value="Rivers (Port Harcourt)">Rivers (Port Harcourt)</option>
          <option value="Oyo (Ibadan)">Oyo (Ibadan)</option>
          <option value="Kano">Kano</option>
        </select>
      </div>
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">CITY / LGA *</label>
      <select id="novasuite-city" name="delivery_city" required style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;">
        <option value="Ikeja">Ikeja</option>
        <option value="Victoria Island / Eti-Osa">Victoria Island / Eti-Osa</option>
        <option value="Lekki / Ajah">Lekki / Ajah</option>
        <option value="Surulere">Surulere</option>
      </select>
    </div>

    <div style="margin-bottom: 16px;">
      <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 4px;">DELIVERY ADDRESS *</label>
      <textarea name="delivery_address" required rows="2" placeholder="House number, street name, landmark" style="width: 100%; padding: 10px; background: ${_inputBgController.text}; color: ${_inputTextColorController.text}; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;"></textarea>
    </div>

    <!-- SECTION 2: OFFER PACKAGES UNDER FORM INPUTS -->
    <div style="margin-bottom: 20px;">
      <label style="display: block; font-size: 11px; font-weight: bold; color: ${_placeholderColorController.text}; margin-bottom: 8px;">SELECT YOUR OFFER PACKAGE *</label>
      <div style="padding: 12px; background: ${_inputBgController.text}; border: 2px solid #10b981; border-radius: 8px; margin-bottom: 8px;">
        <label style="font-weight: bold; font-size: 13px; color: ${_inputTextColorController.text};">
          <input type="radio" name="offer_package_id" value="pkg-1" checked /> 1 Grazer Detox Tea — ₦23,500
        </label>
      </div>
      <div style="padding: 12px; background: ${_inputBgController.text}; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 8px;">
        <label style="font-weight: bold; font-size: 13px; color: ${_inputTextColorController.text};">
          <input type="radio" name="offer_package_id" value="pkg-2" /> 2 Grazer Detox Tea — ₦37,000 (Save ₦10,000)
        </label>
      </div>
      <div style="padding: 12px; background: ${_inputBgController.text}; border: 1px solid #cbd5e1; border-radius: 8px;">
        <label style="font-weight: bold; font-size: 13px; color: ${_inputTextColorController.text};">
          <input type="radio" name="offer_package_id" value="pkg-5" /> Buy 5 Grazer Tea + 1 Respira Detox Free 🎁 — ₦85,000
        </label>
      </div>
    </div>

    <!-- SECTION 3: SUBMIT BUTTON FOLLOWED BY OFFER PACKAGES -->
    <button type="submit" id="novasuite-submit-btn" style="width: 100%; padding: 14px; background-color: $btnBg; color: $btnText; font-size: 15px; font-weight: bold; border: none; border-radius: ${_borderRadiusController.text}; cursor: pointer;">
      $btnLabel
    </button>
  </form>
</div>

<!-- NOVASUITE AUTOMATIC THANK-YOU REDIRECT & DYNAMIC LOCATION ENGINE SCRIPT -->
<script>
  const locationCascadeData = {
    "Nigeria": {
      "Lagos": ["Ikeja", "Victoria Island / Eti-Osa", "Lekki / Ajah", "Surulere", "Alimosho", "Kosofe / Ojota", "Apapa", "Ikorodu", "Epe", "Badagry", "Mushin", "Agege", "Oshodi-Isolo", "Yaba / Lagos Mainland", "Amuwo-Odofin"],
      "Abuja (FCT)": ["Garki", "Wuse", "Maitama", "Asokoro", "Gwarinpa", "Kubwa", "Lugbe", "Bwari", "Kuje", "Abaji", "Utako", "Jabi"],
      "Rivers (Port Harcourt)": ["Port Harcourt City", "Obio-Akpor", "Eleme", "Ikwerre", "Bonny Island", "Oyigbo", "Degema"],
      "Oyo (Ibadan)": ["Ibadan North", "Ibadan Southwest", "Ibadan Southeast", "Ibadan Northwest", "Oyo East", "Ogbomoso"],
      "Kano": ["Kano Municipal", "Fagge", "Dala", "Gwale", "Tarauni", "Nassarawa"],
      "Ogun": ["Abeokuta South", "Abeokuta North", "Ifo", "Ota / Ado-Odo", "Ijebu Ode", "Sagamu"],
      "Enugu": ["Enugu North", "Enugu South", "Enugu East", "Nsukka"],
      "Delta": ["Warri South", "Asaba / Oshimili South", "Uvwie / Effurun", "Ughelli"]
    },
    "Ghana": {
      "Greater Accra": ["Accra Central", "Tema", "East Legon", "Madina", "Spintex"],
      "Ashanti (Kumasi)": ["Kumasi Central", "Adum", "Bantama", "Asokwa"],
      "Western (Takoradi)": ["Sekondi", "Takoradi Central", "Tarkwa"],
      "Northern (Tamale)": ["Tamale Central", "Sagnarigu"]
    },
    "Kenya": {
      "Nairobi": ["Nairobi Central", "Westlands", "Kilimani", "Karen", "Kasarani"],
      "Mombasa": ["Mombasa Island", "Nyali", "Bamburi", "Likoni"],
      "Kisumu": ["Kisumu Central", "Milimani"],
      "Nakuru": ["Nakuru Town", "Naivasha"]
    },
    "South Africa": {
      "Gauteng (Johannesburg)": ["Sandton", "Rosebank", "Soweto", "Midrand", "Pretoria"],
      "Western Cape (Cape Town)": ["Cape Town CBD", "Stellenbosch", "Bellville", "Camps Bay"],
      "KwaZulu-Natal (Durban)": ["Durban Central", "Umhlanga", "Pinetown"]
    },
    "United Kingdom": {
      "England (London)": ["Central London", "Westminster", "Camden", "Greenwich", "Croydon"],
      "Scotland (Edinburgh)": ["City Centre", "Leith", "Morningside"],
      "Wales (Cardiff)": ["Cardiff Central", "Cardiff Bay"],
      "Northern Ireland": ["Belfast", "Derry"]
    },
    "United States": {
      "California": ["Los Angeles", "San Francisco", "San Diego", "San Jose"],
      "Texas": ["Houston", "Dallas", "Austin", "San Antonio"],
      "New York": ["New York City", "Brooklyn", "Queens", "Buffalo"],
      "Florida": ["Miami", "Orlando", "Tampa", "Jacksonville"],
      "Georgia": ["Atlanta", "Savannah", "Augusta"]
    },
    "Canada": {
      "Ontario (Toronto)": ["Toronto Downtown", "Mississauga", "Brampton", "Ottawa"],
      "British Columbia (Vancouver)": ["Vancouver CBD", "Burnaby", "Richmond"],
      "Quebec (Montreal)": ["Montreal Downtown", "Laval", "Gatineau"]
    }
  };

  const countrySel = document.getElementById('novasuite-country');
  const stateSel = document.getElementById('novasuite-state');
  const citySel = document.getElementById('novasuite-city');

  function populateStates() {
    const selectedCountry = countrySel.value;
    const statesObj = locationCascadeData[selectedCountry] || locationCascadeData['Nigeria'];
    stateSel.innerHTML = '';
    Object.keys(statesObj).forEach(function(state) {
      const opt = document.createElement('option');
      opt.value = state;
      opt.innerText = state;
      stateSel.appendChild(opt);
    });
    populateCities();
  }

  function populateCities() {
    const selectedCountry = countrySel.value;
    const selectedState = stateSel.value;
    const statesObj = locationCascadeData[selectedCountry] || locationCascadeData['Nigeria'];
    const citiesArr = statesObj[selectedState] || ["Central District", "Metropolitan Area", "Main City Zone"];
    citySel.innerHTML = '';
    citiesArr.forEach(function(city) {
      const opt = document.createElement('option');
      opt.value = city;
      opt.innerText = city;
      citySel.appendChild(opt);
    });
  }

  if (countrySel && stateSel && citySel) {
    countrySel.addEventListener('change', populateStates);
    stateSel.addEventListener('change', populateCities);
    populateStates();
  }

  document.getElementById('novasuite-checkout-form').addEventListener('submit', async function(e) {
    e.preventDefault();
    const btn = document.getElementById('novasuite-submit-btn');
    btn.disabled = true;
    btn.innerText = 'Processing Order...';

    const formData = new FormData(this);
    const payload = Object.fromEntries(formData.entries());

    try {
      const response = await fetch('https://eywkyijghfzhzfgffmsr.supabase.co/functions/v1/submit-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const resData = await response.json();
      if (response.ok && resData.redirect_url) {
        window.location.href = resData.redirect_url;
      } else {
        alert('Thank you! Your order has been placed successfully.');
        window.location.href = "$redirectUrl";
      }
    } catch (err) {
      alert('Order placed successfully. Redirecting...');
      window.location.href = "$redirectUrl";
    }
  });
</script>
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.code_rounded, color: Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 8),
            Text('Embed Code & Thank-You Redirect Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981))),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: Color(0xFF10B981), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CONFIGURED THANK-YOU REDIRECT PAGE:', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                            Text(redirectUrl, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('COPY & PASTE HTML / JS CODE FOR WORDPRESS / ELEMENTOR:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(
                    embedCodeSnippet,
                    style: GoogleFonts.robotoMono(color: const Color(0xFF38BDF8), fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: embedCodeSnippet));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Embed HTML/JS Code copied to clipboard! Paste into your landing page editor. ✓')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Embed Code ✓'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildColorPickerGroup(String label, TextEditingController controller, {required String defaultHex}) {
    final activeColor = _parseColorFromHex(controller.text, defaultHex: defaultHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showColorPickerDialog(context, controller: controller, title: label, defaultHex: defaultHex),
              child: Tooltip(
                message: 'Click to open 2D HSV Spectrum Color Canvas',
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '#568500',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.palette_rounded, size: 20, color: Color(0xFF10B981)),
              tooltip: 'Choose Color Canvas',
              onPressed: () => _showColorPickerDialog(context, controller: controller, title: label, defaultHex: defaultHex),
            ),
          ],
        ),
      ],
    );
  }

  // 2D HSV SPECTRUM CANVAS & RAINBOW BAR COLOR PICKER MODAL DIALOG
  void _showColorPickerDialog(
    BuildContext context, {
    required TextEditingController controller,
    required String title,
    required String defaultHex,
  }) {
    Color selectedColor = _parseColorFromHex(controller.text, defaultHex: defaultHex);

    final List<Map<String, dynamic>> paletteSwatches = [
      {'name': 'Emerald Green', 'hex': '#10B981', 'color': const Color(0xFF10B981)},
      {'name': 'Olive Brand', 'hex': '#568500', 'color': const Color(0xFF568500)},
      {'name': 'Midnight Slate', 'hex': '#0F172A', 'color': const Color(0xFF0F172A)},
      {'name': 'Royal Blue', 'hex': '#3B82F6', 'color': const Color(0xFF3B82F6)},
      {'name': 'Vibrant Purple', 'hex': '#8B5CF6', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Sunset Orange', 'hex': '#F97316', 'color': const Color(0xFFF97316)},
      {'name': 'Crimson Red', 'hex': '#EF4444', 'color': const Color(0xFFEF4444)},
      {'name': 'Deep Dark', 'hex': '#09140E', 'color': const Color(0xFF09140E)},
      {'name': 'Pure White', 'hex': '#FFFFFF', 'color': const Color(0xFFFFFFFF)},
      {'name': 'Soft Card Gray', 'hex': '#FAFAFC', 'color': const Color(0xFFFAFAFC)},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.color_lens_rounded, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
                Text('2D Spectrum Color Canvas: $title', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: selectedColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${controller.text.toUpperCase()} | RGB(${selectedColor.r.toInt()}, ${selectedColor.g.toInt()}, ${selectedColor.b.toInt()})',
                          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HsvSpectrumColorPicker(
                      initialColor: selectedColor,
                      onColorChanged: (newColor) {
                        setModalState(() {
                          selectedColor = newColor;
                          final cleanR = (newColor.r * 255.0).round().toRadixString(16).padLeft(2, '0');
                          final cleanG = (newColor.g * 255.0).round().toRadixString(16).padLeft(2, '0');
                          final cleanB = (newColor.b * 255.0).round().toRadixString(16).padLeft(2, '0');
                          controller.text = '#$cleanR$cleanG$cleanB';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('BRAND PALETTE PRESETS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: paletteSwatches.length,
                      itemBuilder: (context, idx) {
                        final item = paletteSwatches[idx];
                        final swatchColor = item['color'] as Color;
                        final hex = item['hex'] as String;
                        final isSelected = controller.text.toLowerCase() == hex.toLowerCase();

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedColor = swatchColor;
                              controller.text = hex;
                            });
                          },
                          child: Tooltip(
                            message: item['name'] as String,
                            child: Container(
                              decoration: BoxDecoration(
                                color: swatchColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.3), width: isSelected ? 3 : 1),
                                boxShadow: isSelected ? [BoxShadow(color: swatchColor.withValues(alpha: 0.4), blurRadius: 6)] : null,
                              ),
                              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('CUSTOM HEX COLOR CODE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller,
                      onChanged: (val) {
                        setModalState(() {
                          selectedColor = _parseColorFromHex(val, defaultHex: defaultHex);
                        });
                      },
                      decoration: const InputDecoration(hintText: '#10B981', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                child: const Text('Apply Color ✓'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _parseColorFromHex(String hexString, {required String defaultHex}) {
    try {
      final cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
    } catch (_) {}
    final fallback = defaultHex.replaceAll('#', '').trim();
    return Color(int.parse('FF$fallback', radix: 16));
  }

  // MODAL DIALOG: CREATE / EDIT OFFER PACKAGE MODAL
  void _showOfferPackageModalDialog(
    BuildContext context, {
    required CampaignFormBuilderProvider provider,
    int? editIndex,
    Map<String, dynamic>? existingPkg,
  }) {
    final isEditing = editIndex != null && existingPkg != null;
    final labelCtrl = TextEditingController(text: existingPkg?['label'] ?? '');
    final buyQtyCtrl = TextEditingController(text: '${existingPkg?['buyQty'] ?? 1}');
    final freeQtyCtrl = TextEditingController(text: '${existingPkg?['freeQty'] ?? 0}');
    final amountCtrl = TextEditingController(text: '${existingPkg?['amount'] ?? 25000}');
    final discountCtrl = TextEditingController(text: '${existingPkg?['discount'] ?? 0}');
    bool isDefaultPkg = existingPkg?['isDefault'] == true;

    Map<String, dynamic>? selectedFreeAddonProduct;
    int freeAddonQty = existingPkg?['freeAddonQty'] ?? 0;

    if (existingPkg?['freeAddonProductId'] != null) {
      selectedFreeAddonProduct = provider.availableProducts.firstWhere(
        (p) => p['id'] == existingPkg!['freeAddonProductId'],
        orElse: () => provider.availableProducts.first,
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final buyQty = int.tryParse(buyQtyCtrl.text) ?? 1;
          final sameFreeQty = int.tryParse(freeQtyCtrl.text) ?? 0;
          final totalDeductedStock = buyQty + sameFreeQty + freeAddonQty;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
                Text(isEditing ? 'Edit Offer Package' : 'Create New Offer Package', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModalTextField('PACKAGE LABEL', labelCtrl, 'e.g. Buy 5 Grazer Tea + 1 Respira Detox Free'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModalTextField('PRIMARY BUY QUANTITY', buyQtyCtrl, '1')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModalTextField('SAME-ITEM FREE QUANTITY', freeQtyCtrl, '0')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModalTextField('FIXED PACKAGE AMOUNT (₦)', amountCtrl, '25000')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModalTextField('DISCOUNT / SAVINGS (₦)', discountCtrl, '0')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.card_giftcard_rounded, color: Colors.purple, size: 18),
                              const SizedBox(width: 6),
                              Text('CROSS-PRODUCT FREE GIFT ADDON (OPTIONAL)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.purple)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Reward buyers with a free gift item from a different product line (e.g. Buy 5 Tea, Get 1 Respira Free).', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedFreeAddonProduct?['id'],
                                  dropdownColor: const Color(0xFF0F172A),
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  hint: Text('Select Free Gift Product...', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                                  items: [
                                    DropdownMenuItem<String>(value: null, child: Text('None (No cross-product free gift)', style: GoogleFonts.inter(color: Colors.white, fontSize: 12))),
                                    ...provider.availableProducts.map((p) => DropdownMenuItem<String>(
                                          value: p['id'] as String,
                                          child: Text('${p['name']} [${p['sku']}]', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                                        )),
                                  ],
                                  onChanged: (val) {
                                    setModalState(() {
                                      if (val == null) {
                                        selectedFreeAddonProduct = null;
                                        freeAddonQty = 0;
                                      } else {
                                        selectedFreeAddonProduct = provider.availableProducts.firstWhere((p) => p['id'] == val);
                                        if (freeAddonQty == 0) freeAddonQty = 1;
                                      }
                                    });
                                  },
                                ),
                              ),
                              if (selectedFreeAddonProduct != null) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    initialValue: freeAddonQty > 0 ? freeAddonQty : 1,
                                    dropdownColor: const Color(0xFF0F172A),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                    items: [1, 2, 3, 4, 5].map((q) => DropdownMenuItem(value: q, child: Text('$q Free', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => freeAddonQty = v);
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withValues(alpha: 0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_rounded, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'TOTAL STOCK ACCOUNTING DEDUCTION: $totalDeductedStock Units (${buyQty}x Primary + ${sameFreeQty}x Same Free ${selectedFreeAddonProduct != null ? "+ ${freeAddonQty}x ${selectedFreeAddonProduct!['name']}" : ""})',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      title: const Text('Set as Default Choice for Buyers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: isDefaultPkg,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        setModalState(() => isDefaultPkg = val ?? false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  final pkgData = {
                    'id': existingPkg?['id'] ?? 'pkg-${DateTime.now().millisecondsSinceEpoch}',
                    'label': labelCtrl.text.isNotEmpty ? labelCtrl.text : 'New Offer Package',
                    'buyQty': int.tryParse(buyQtyCtrl.text) ?? 1,
                    'freeQty': int.tryParse(freeQtyCtrl.text) ?? 0,
                    'freeAddonProductId': selectedFreeAddonProduct?['id'],
                    'freeAddonProductName': selectedFreeAddonProduct?['name'],
                    'freeAddonQty': selectedFreeAddonProduct != null ? freeAddonQty : 0,
                    'amount': double.tryParse(amountCtrl.text) ?? 25000.0,
                    'discount': double.tryParse(discountCtrl.text) ?? 0.0,
                    'isDefault': isDefaultPkg,
                  };

                  if (isEditing) {
                    provider.updateOfferPackage(editIndex, 'label', pkgData['label']);
                    provider.updateOfferPackage(editIndex, 'buyQty', pkgData['buyQty']);
                    provider.updateOfferPackage(editIndex, 'freeQty', pkgData['freeQty']);
                    provider.updateOfferPackage(editIndex, 'freeAddonProductId', pkgData['freeAddonProductId']);
                    provider.updateOfferPackage(editIndex, 'freeAddonProductName', pkgData['freeAddonProductName']);
                    provider.updateOfferPackage(editIndex, 'freeAddonQty', pkgData['freeAddonQty']);
                    provider.updateOfferPackage(editIndex, 'amount', pkgData['amount']);
                    provider.updateOfferPackage(editIndex, 'discount', pkgData['discount']);
                    if (isDefaultPkg) provider.setDefaultPackage(editIndex);
                  } else {
                    provider.addOfferPackage(pkgData);
                    if (isDefaultPkg) provider.setDefaultPackage(provider.offerPackages.length - 1);
                  }

                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(isEditing ? 'Save Changes' : 'Create Package'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  // MODAL DIALOG: SEARCHABLE ONBOARDED PRODUCT PICKER (Linked Items)
  void _showAddLinkedItemModalDialog(BuildContext context, {required CampaignFormBuilderProvider provider}) {
    String searchQuery = '';
    Map<String, dynamic>? selectedProduct = provider.availableProducts.isNotEmpty ? provider.availableProducts.first : null;
    int selectedQty = 1;
    String itemType = 'Main';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredProducts = provider.availableProducts.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            final sku = (p['sku'] ?? '').toString().toLowerCase();
            final q = searchQuery.toLowerCase();
            return name.contains(q) || sku.contains(q);
          }).toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.inventory_2_rounded, color: Color(0xFF3B82F6), size: 22),
                const SizedBox(width: 8),
                Text('Attach Onboarded Product Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SEARCH ONBOARDED PRODUCTS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextField(
                      onChanged: (val) {
                        setModalState(() => searchQuery = val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type product name or SKU to search...',
                        prefixIcon: Icon(Icons.search_rounded, size: 18),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('SELECT PRODUCT ITEM *', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
                      child: filteredProducts.isEmpty
                          ? const Center(child: Text('No products match search query.'))
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, idx) {
                                final p = filteredProducts[idx];
                                final isSelected = selectedProduct?['id'] == p['id'];
                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                  leading: Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF3B82F6) : Colors.grey, size: 18),
                                  title: Text(p['name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('SKU: ${p['sku']} | Category: ${p['category']}', style: const TextStyle(fontSize: 11)),
                                  trailing: Text('₦${(p['price'] ?? 0.0).toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                  onTap: () {
                                    setModalState(() => selectedProduct = p);
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ITEM TYPE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: itemType,
                                dropdownColor: const Color(0xFF0F172A),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: [
                                  DropdownMenuItem(value: 'Main', child: Text('Main Product', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                                  DropdownMenuItem(value: 'Addon', child: Text('Addon / Upsell', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                                ],
                                onChanged: (v) {
                                  if (v != null) setModalState(() => itemType = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BASE QUANTITY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                initialValue: selectedQty,
                                dropdownColor: const Color(0xFF0F172A),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: [1, 2, 3, 4, 5].map((q) => DropdownMenuItem(value: q, child: Text('$q unit(s)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => selectedQty = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: selectedProduct == null
                    ? null
                    : () {
                        provider.addLinkedItem({
                          'id': 'item-${DateTime.now().millisecondsSinceEpoch}',
                          'productId': selectedProduct!['id'],
                          'name': selectedProduct!['name'],
                          'sku': selectedProduct!['sku'],
                          'type': itemType,
                          'qty': selectedQty,
                          'price': selectedProduct!['price'],
                          'isDefault': provider.linkedItems.isEmpty,
                        });
                        Navigator.pop(ctx);
                      },
                icon: const Icon(Icons.add_link_rounded, size: 16),
                label: const Text('Attach Item to Form ✓'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ],
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
// 🎨 2D HSV CANVAS & RAINBOW SPECTRUM BAR COLOR PICKER WIDGET
// =============================================================================
class _HsvSpectrumColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _HsvSpectrumColorPicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_HsvSpectrumColorPicker> createState() => _HsvSpectrumColorPickerState();
}

class _HsvSpectrumColorPickerState extends State<_HsvSpectrumColorPicker> {
  late double _hue; // 0.0 to 360.0
  late double _saturation; // 0.0 to 1.0
  late double _value; // 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  @override
  void didUpdateWidget(covariant _HsvSpectrumColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor != widget.initialColor) {
      final hsv = HSVColor.fromColor(widget.initialColor);
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
    }
  }

  void _notifyColor() {
    final currentColor = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    widget.onColorChanged(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    final activeHueColor = HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();
    final currentColor = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Rainbow Spectrum Hue Bar (Top horizontal gradient bar)
        GestureDetector(
          onPanDown: (details) => _updateHueFromPos(details.localPosition, context),
          onPanUpdate: (details) => _updateHueFromPos(details.localPosition, context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final thumbX = (_hue / 360.0) * barWidth;

              return Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000), // Red
                      Color(0xFFFFFF00), // Yellow
                      Color(0xFF00FF00), // Green
                      Color(0xFF00FFFF), // Cyan
                      Color(0xFF0000FF), // Blue
                      Color(0xFFFF00FF), // Magenta
                      Color(0xFFFF0000), // Red
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: (thumbX - 10).clamp(0.0, barWidth - 20),
                      top: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeHueColor,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // 2. 2D Saturation-Value Canvas (Main gradient canvas box)
        GestureDetector(
          onPanDown: (details) => _updateSvFromPos(details.localPosition, context),
          onPanUpdate: (details) => _updateSvFromPos(details.localPosition, context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth = constraints.maxWidth;
              final canvasHeight = 160.0;
              final thumbX = _saturation * canvasWidth;
              final thumbY = (1.0 - _value) * canvasHeight;

              return Container(
                height: canvasHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: activeHueColor,
                ),
                child: Stack(
                  children: [
                    // Horizontal Saturation Overlay (White to Transparent)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, Colors.transparent],
                        ),
                      ),
                    ),
                    // Vertical Value Overlay (Transparent to Black)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                    // Draggable White Selector Circle Thumb (O)
                    Positioned(
                      left: (thumbX - 10).clamp(0.0, canvasWidth - 20),
                      top: (thumbY - 10).clamp(0.0, canvasHeight - 20),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentColor,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
                        ),
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
  }

  void _updateHueFromPos(Offset localPos, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    final clampedX = localPos.dx.clamp(0.0, width);
    setState(() {
      _hue = (clampedX / width) * 360.0;
      _notifyColor();
    });
  }

  void _updateSvFromPos(Offset localPos, BuildContext context) {
    final canvasWidth = context.size?.width ?? 300.0;
    final canvasHeight = 160.0;
    final clampedX = localPos.dx.clamp(0.0, canvasWidth);
    final clampedY = localPos.dy.clamp(0.0, canvasHeight);

    setState(() {
      _saturation = clampedX / canvasWidth;
      _value = 1.0 - (clampedY / canvasHeight);
      _notifyColor();
    });
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

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.question['label'] ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
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
                      dropdownColor: widget.isDark ? const Color(0xFF09140E) : Colors.white,
                      style: GoogleFonts.inter(color: widget.isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: ['Text', 'Phone', 'Dropdown'].map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: GoogleFonts.inter(color: widget.isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13)),
                      )).toList(),
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
