import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

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
  int _currentStep = 0; // 0: Basics, 1: Builder, 2: Upsell & Embed

  // Step 1: Basics Controllers
  final _formTitleController = TextEditingController(text: 'Grazer Herbal Tea');
  final _digitalMarketerController = TextEditingController(text: 'joelodufu@gmail.com');
  final _redirectUrlController = TextEditingController(text: 'https://detoxwithnova.xyz/thank-you');
  final _successMessageController = TextEditingController(text: 'Thanks! Our concierge team will confirm shortly.');
  final _submitButtonTextController = TextEditingController(text: 'Submit request');
  final _descriptionController = TextEditingController(text: 'Fill out the order form below for instant Pay-on-Delivery confirmation.');
  String _quantityDisplayMode = 'Number input';
  String _presetCountry = 'Nigeria';

  // Step 2: Builder State
  String _selectedCategory = 'Herbal Tea Detox';
  final Map<String, Map<String, bool>> _fields = {
    'Full Name': {'required': true, 'visible': true},
    'Email': {'required': false, 'visible': true},
    'Phone': {'required': true, 'visible': true},
    'Address Line 1': {'required': true, 'visible': true},
    'Address Line 2': {'required': false, 'visible': false},
    'Country': {'required': true, 'visible': true},
    'State/Province': {'required': true, 'visible': true},
  };

  // Step 2: Appearance Customization
  String _buttonBackgroundHex = '#2563eb';
  String _buttonTextColorHex = '#ffffff';
  final String _pageBackgroundHex = '#0f172a';
  String _cardBackgroundHex = '#f8fafc';
  String _headingColorHex = '#0f172a';
  final String _inputBorderColorHex = '#cbd5e1';
  final String _inputBorderRadius = '10px';
  final String _fontFamily = 'Inter';

  // Step 3: Upsell State
  bool _enableUpsell = true;
  final _upsellTitleController = TextEditingController(text: 'Add 1 Extra Bottle of Detox Tea for 50% Off!');

  String _generateEmbedHtml() {
    const endpoint = '${SupabaseConfig.supabaseUrl}/functions/v1/submit-order';
    return '''
<!-- NovaSuite CRM - Embedded Campaign Checkout Form -->
<div id="novasuite-form-container" style="
  background: $_pageBackgroundHex;
  font-family: '$_fontFamily', sans-serif;
  padding: 30px;
">
  <div style="
    background: $_cardBackgroundHex;
    border-radius: $_inputBorderRadius;
    padding: 24px;
    max-width: 500px;
    margin: 0 auto;
    border: 1px solid $_inputBorderColorHex;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
  ">
  <h2 style="color: $_headingColorHex; margin-bottom: 8px;">${_formTitleController.text}</h2>
  <p style="color: #64748b; font-size: 14px; margin-bottom: 20px;">${_descriptionController.text}</p>
  
  <form id="novasuite-lead-form" onsubmit="submitNovaSuiteLead(event)">
    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Full Name *</label>
      <input type="text" id="customer_name" required style="width:100%; padding:10px; border:1px solid $_inputBorderColorHex; border-radius:$_inputBorderRadius;">
    </div>
    
    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Phone Number *</label>
      <input type="tel" id="customer_phone" required style="width:100%; padding:10px; border:1px solid $_inputBorderColorHex; border-radius:$_inputBorderRadius;">
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Delivery State *</label>
      <input type="text" id="delivery_state" required style="width:100%; padding:10px; border:1px solid $_inputBorderColorHex; border-radius:$_inputBorderRadius;">
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Delivery Address *</label>
      <textarea id="delivery_address" required rows="2" style="width:100%; padding:10px; border:1px solid $_inputBorderColorHex; border-radius:$_inputBorderRadius;"></textarea>
    </div>

    <button type="submit" id="submit-btn" style="
      width: 100%;
      background-color: $_buttonBackgroundHex;
      color: $_buttonTextColorHex;
      padding: 14px;
      font-size: 16px;
      font-weight: bold;
      border: none;
      border-radius: $_inputBorderRadius;
      cursor: pointer;
      margin-top: 10px;
    ">${_submitButtonTextController.text}</button>
  </form>
</div>

<script>
async function submitNovaSuiteLead(e) {
  e.preventDefault();
  const btn = document.getElementById('submit-btn');
  btn.innerText = 'Processing Order...';
  btn.disabled = true;

  const payload = {
    company_id: 'tenant-novacare',
    product_id: 'prod-herbal-tea',
    customer_name: document.getElementById('customer_name').value,
    customer_phone: document.getElementById('customer_phone').value,
    delivery_state: document.getElementById('delivery_state').value,
    delivery_address: document.getElementById('delivery_address').value,
    marketer_email: '${_digitalMarketerController.text}',
    quantity: 1,
    base_price: 25000
  };

  try {
    const res = await fetch('$endpoint', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (res.ok) {
      window.location.href = '${_redirectUrlController.text}';
    } else {
      alert('${_successMessageController.text}');
    }
  } catch (err) {
    alert('${_successMessageController.text}');
  }
}
</script>
''';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaign Form Builder', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Embed ready forms for Facebook tabs, WordPress landing pages, or microsites.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onBackToForms,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to forms'),
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
                    Text('Campaign Form Builder', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Embed ready forms for Facebook tabs, WordPress landing pages, or microsites.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: widget.onBackToForms,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to forms'),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Stepper Buttons Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _stepButton(0, 'Step 1: Basics'),
                  const SizedBox(width: 8),
                  _stepButton(1, 'Step 2: Builder'),
                  const SizedBox(width: 8),
                  _stepButton(2, 'Step 3: Upsell & Embed'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black87),
                    child: const Text('Save Draft'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Active Step Content Body
          if (_currentStep == 0) _buildStep1Basics(isMobile),
          if (_currentStep == 1) _buildStep2Builder(isMobile),
          if (_currentStep == 2) _buildStep3UpsellAndEmbed(isMobile),
        ],
      ),
    );
  }

  Widget _stepButton(int index, String label) {
    final isActive = _currentStep == index;
    return ElevatedButton(
      onPressed: () => setState(() => _currentStep = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF2563EB) : Colors.grey.shade100,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        elevation: isActive ? 2 : 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStep1Basics(bool isMobile) {
    final fieldWidth = isMobile ? double.infinity : 320.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FORM TITLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(controller: _formTitleController, decoration: _inputDecoration()),
                    ],
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DIGITAL MARKETER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(controller: _digitalMarketerController, decoration: _inputDecoration()),
                    ],
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('REDIRECT URL (Thank You Page)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(controller: _redirectUrlController, decoration: _inputDecoration()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SUCCESS MESSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(controller: _successMessageController, decoration: _inputDecoration()),
                    ],
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SUBMIT BUTTON TEXT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(controller: _submitButtonTextController, decoration: _inputDecoration()),
                    ],
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QUANTITY DISPLAY MODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _quantityDisplayMode,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Number input', child: Text('Number input')),
                          DropdownMenuItem(value: 'Dropdown', child: Text('Dropdown')),
                          DropdownMenuItem(value: 'Radio buttons', child: Text('Radio buttons')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _quantityDisplayMode = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: fieldWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRESET COUNTRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _presetCountry,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'Nigeria', child: Text('Nigeria')),
                      DropdownMenuItem(value: 'Ghana', child: Text('Ghana')),
                      DropdownMenuItem(value: 'Kenya', child: Text('Kenya')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _presetCountry = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration(hint: 'Internal note or CTA shown above the form.'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('Continue to Builder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Builder(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildOrderDimensionsAndFieldsCard(isMobile),
          const SizedBox(height: 16),
          _buildAppearanceAndPreviewCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildOrderDimensionsAndFieldsCard(isMobile)),
        const SizedBox(width: 20),
        Expanded(flex: 5, child: _buildAppearanceAndPreviewCard(isMobile)),
      ],
    );
  }

  Widget _buildOrderDimensionsAndFieldsCard(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order dimensions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Select one product category. Brand and cost center are derived automatically.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Herbal Tea Detox', child: Text('Herbal Tea Detox')),
                DropdownMenuItem(value: 'Vitality Booster', child: Text('Vitality Booster')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 24),

            Text('Core field options', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Configure visibility, labels, and required state for built-in checkout fields.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),

            ..._fields.entries.map((entry) {
              final fieldName = entry.key;
              final isRequired = entry.value['required'] ?? false;
              final isVisible = entry.value['visible'] ?? true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fieldName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('Required', style: TextStyle(fontSize: 12)),
                                  Switch(
                                    value: isRequired,
                                    onChanged: (val) {
                                      setState(() => _fields[fieldName]!['required'] = val);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Visible', style: TextStyle(fontSize: 12)),
                                  Switch(
                                    value: isVisible,
                                    onChanged: (val) {
                                      setState(() => _fields[fieldName]!['visible'] = val);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: Text(fieldName, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Required', style: TextStyle(fontSize: 12)),
                              Switch(
                                value: isRequired,
                                onChanged: (val) {
                                  setState(() => _fields[fieldName]!['required'] = val);
                                },
                              ),
                              const SizedBox(width: 12),
                              const Text('Visible', style: TextStyle(fontSize: 12)),
                              Switch(
                                value: isVisible,
                                onChanged: (val) {
                                  setState(() => _fields[fieldName]!['visible'] = val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceAndPreviewCard(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Customize form colors, typography, and input shape.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _colorPickerInput('BUTTON BACKGROUND', _buttonBackgroundHex, (val) => setState(() => _buttonBackgroundHex = val), isMobile),
                    _colorPickerInput('BUTTON TEXT COLOR', _buttonTextColorHex, (val) => setState(() => _buttonTextColorHex = val), isMobile),
                    _colorPickerInput('CARD BACKGROUND', _cardBackgroundHex, (val) => setState(() => _cardBackgroundHex = val), isMobile),
                    _colorPickerInput('HEADING COLOR', _headingColorHex, (val) => setState(() => _headingColorHex = val), isMobile),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Live Form Preview Card with Real-time Theme Color Updates
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF0F172A),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 8),
                    Text('Live Form Preview', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _parseHexColor(_cardBackgroundHex, Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _parseHexColor(_inputBorderColorHex, Colors.grey.shade300)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formTitleController.text,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _parseHexColor(_headingColorHex, const Color(0xFF0F172A)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_descriptionController.text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),

                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Full Name *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Phone Number *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Delivery Address *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _parseHexColor(_buttonBackgroundHex, const Color(0xFF2563EB)),
                              foregroundColor: _parseHexColor(_buttonTextColorHex, Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              _submitButtonTextController.text,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3UpsellAndEmbed(bool isMobile) {
    final embedHtml = _generateEmbedHtml();

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instant Checkout Upsell Offer', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Offer an optional discounted add-on item directly on form submission.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Expanded(child: Text('Enable 1-Click Checkout Upsell', style: TextStyle(fontWeight: FontWeight.bold))),
                    Switch(
                      value: _enableUpsell,
                      onChanged: (val) => setState(() => _enableUpsell = val),
                    ),
                  ],
                ),
                if (_enableUpsell) ...[
                  const SizedBox(height: 12),
                  TextField(controller: _upsellTitleController, decoration: _inputDecoration(hint: 'Upsell Offer Headline')),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Embed Code Snippet Output Box
        Card(
          elevation: 0,
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
                      Row(
                        children: [
                          const Icon(Icons.code, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('Copy Embed HTML Code', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: embedHtml));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: Colors.green, content: Text('Embedded HTML code copied to clipboard!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy HTML Code'),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.code, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('Copy Embed HTML Code', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: embedHtml));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: Colors.green, content: Text('Embedded HTML code copied to clipboard!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy HTML Code'),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                const Text('Paste this standalone snippet into your WordPress landing page, Elementor HTML block, or custom website:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      embedHtml,
                      style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorPickerInput(String label, String hexValue, ValueChanged<String> onChanged, bool isMobile) {
    final parsedColor = _parseHexColor(hexValue, Colors.blue);

    return SizedBox(
      width: isMobile ? double.infinity : 220.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openColorPickerDialog(label, hexValue, onChanged),
                child: Tooltip(
                  message: 'Click to open Color Picker',
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: parsedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.palette, size: 18, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: hexValue),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: '#000000',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.color_lens_outlined, size: 20, color: Colors.blue),
                      onPressed: () => _openColorPickerDialog(label, hexValue, onChanged),
                      tooltip: 'Color Palette',
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

  void _openColorPickerDialog(String title, String currentHex, ValueChanged<String> onSelected) {
    final presetColors = [
      {'name': 'Royal Blue', 'hex': '#2563eb'},
      {'name': 'Emerald Green', 'hex': '#16a34a'},
      {'name': 'Crimson Red', 'hex': '#dc2626'},
      {'name': 'Deep Purple', 'hex': '#7c3aed'},
      {'name': 'Amber Orange', 'hex': '#ea580c'},
      {'name': 'Dark Slate Header', 'hex': '#0f172a'},
      {'name': 'Light Card Gray', 'hex': '#f8fafc'},
      {'name': 'Pure White', 'hex': '#ffffff'},
      {'name': 'Jet Black', 'hex': '#000000'},
      {'name': 'Ocean Teal', 'hex': '#0284c7'},
      {'name': 'Forest Pine', 'hex': '#059669'},
      {'name': 'Rose Pink', 'hex': '#db2777'},
    ];

    final customHexController = TextEditingController(text: currentHex);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.palette_rounded, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Pick Color for $title', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PRESET SWATCHES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: presetColors.map((item) {
                    final hex = item['hex']!;
                    final color = _parseHexColor(hex, Colors.blue);
                    final isSelected = hex.toLowerCase() == currentHex.toLowerCase();

                    return GestureDetector(
                      onTap: () {
                        onSelected(hex);
                        Navigator.pop(context);
                      },
                      child: Tooltip(
                        message: '${item['name']} ($hex)',
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue.shade900 : Colors.grey.shade300,
                              width: isSelected ? 3 : 1.5,
                            ),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('CUSTOM HEX CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customHexController,
                        decoration: _inputDecoration(hint: '#2563eb'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final val = customHexController.text.trim();
                        if (val.isNotEmpty) {
                          onSelected(val.startsWith('#') ? val : '#$val');
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _parseHexColor(String hex, Color fallback) {
    try {
      String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return fallback;
    }
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
