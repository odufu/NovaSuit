import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/campaign_form_builder_provider.dart';

class CampaignFormBuilderPage extends StatelessWidget {
  final TenantTheme activeTheme;
  final VoidCallback onBackToForms;

  const CampaignFormBuilderPage({
    super.key,
    required this.activeTheme,
    required this.onBackToForms,
  });

  // Step 1: Basics Static Controllers
  static final _formTitleController = TextEditingController(text: 'Grazer Herbal Tea');
  static final _digitalMarketerController = TextEditingController(text: 'joelodufu@gmail.com');
  static final _redirectUrlController = TextEditingController(text: 'https://detoxwithnova.xyz/thank-you');
  static final _successMessageController = TextEditingController(text: 'Thanks! Our concierge team will confirm shortly.');
  static final _submitButtonTextController = TextEditingController(text: 'Submit request');
  static final _descriptionController = TextEditingController(text: 'Fill out the order form below for instant Pay-on-Delivery confirmation.');

  // Step 3: Upsell State Controller
  static final _upsellTitleController = TextEditingController(text: 'Add 1 Extra Bottle of Detox Tea for 50% Off!');

  String _generateEmbedHtml(String buttonBgHex, String buttonTextHex, String cardBgHex, String headingHex) {
    const endpoint = '${SupabaseConfig.supabaseUrl}/functions/v1/submit-order';
    return '''
<!-- NovaSuite CRM - Embedded Campaign Checkout Form -->
<div id="novasuite-form-container" style="
  background: #0f172a;
  font-family: 'Inter', sans-serif;
  padding: 30px;
">
  <div style="
    background: $cardBgHex;
    border-radius: 10px;
    padding: 24px;
    max-width: 500px;
    margin: 0 auto;
    border: 1px solid #cbd5e1;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
  ">
  <h2 style="color: $headingHex; margin-bottom: 8px;">${_formTitleController.text}</h2>
  <p style="color: #64748b; font-size: 14px; margin-bottom: 20px;">${_descriptionController.text}</p>
  
  <form id="novasuite-lead-form" onsubmit="submitNovaSuiteLead(event)">
    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Full Name *</label>
      <input type="text" id="customer_name" required style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:10px;">
    </div>
    
    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Phone Number *</label>
      <input type="tel" id="customer_phone" required style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:10px;">
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Delivery State *</label>
      <input type="text" id="delivery_state" required style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:10px;">
    </div>

    <div style="margin-bottom: 14px;">
      <label style="display:block; font-weight:600; margin-bottom:4px; font-size:13px;">Delivery Address *</label>
      <textarea id="delivery_address" required rows="2" style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:10px;"></textarea>
    </div>

    <button type="submit" id="submit-btn" style="
      width: 100%;
      background-color: $buttonBgHex;
      color: $buttonTextHex;
      padding: 14px;
      font-size: 16px;
      font-weight: bold;
      border: none;
      border-radius: 10px;
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
    form.innerHTML = `<div style="text-align:center; padding:20px; color:$headingHex;"><h3>${_successMessageController.text}</h3></div>`;
    if ('${_redirectUrlController.text}'.length > 5) {
      setTimeout(() => { window.location.href = '${_redirectUrlController.text}'; }, 1500);
    }
  } catch (err) {
    alert('${_successMessageController.text}');
  }
}
</script>
<!-- Embedded NovaSuite Fail-Safe FormGuard Protection Script -->
<script src="https://novasuit.com/sdk/v1/form-guard.js" async></script>
''';
  }

  @override
  Widget build(BuildContext context) {
    final builderProvider = context.watch<CampaignFormBuilderProvider>();
    final currentStep = builderProvider.currentStep;
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
                  onPressed: onBackToForms,
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
                  onPressed: onBackToForms,
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
                  _stepButton(context, 0, 'Step 1: Basics'),
                  const SizedBox(width: 8),
                  _stepButton(context, 1, 'Step 2: Builder'),
                  const SizedBox(width: 8),
                  _stepButton(context, 2, 'Step 3: Upsell & Embed'),
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
          if (currentStep == 0) _buildStep1Basics(context, isMobile),
          if (currentStep == 1) _buildStep2Builder(context, isMobile),
          if (currentStep == 2) _buildStep3UpsellAndEmbed(context, isMobile),
        ],
      ),
    );
  }

  Widget _stepButton(BuildContext context, int index, String label) {
    final currentStep = context.watch<CampaignFormBuilderProvider>().currentStep;
    final isActive = currentStep == index;
    return ElevatedButton(
      onPressed: () => context.read<CampaignFormBuilderProvider>().setStep(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF2563EB) : Colors.grey.shade100,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        elevation: isActive ? 2 : 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStep1Basics(BuildContext context, bool isMobile) {
    final fieldWidth = isMobile ? double.infinity : 320.0;
    final builderProvider = context.watch<CampaignFormBuilderProvider>();

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
                        initialValue: builderProvider.quantityDisplayMode,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Number input', child: Text('Number input')),
                          DropdownMenuItem(value: 'Dropdown', child: Text('Dropdown')),
                          DropdownMenuItem(value: 'radio', child: Text('Radio buttons')),
                        ],
                        onChanged: (val) {
                          if (val != null) context.read<CampaignFormBuilderProvider>().setQuantityDisplayMode(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
                  onPressed: () => context.read<CampaignFormBuilderProvider>().setStep(1),
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

  Widget _buildStep2Builder(BuildContext context, bool isMobile) {
    final builderProvider = context.watch<CampaignFormBuilderProvider>();
    final formFields = builderProvider.formFields;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Custom Fields', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('Configure active checkout inputs and required validation rules.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: formFields.length,
              itemBuilder: (context, index) {
                final field = formFields[index];
                final isRequired = field['required'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(field['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Type: ${field['type']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Required', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Switch(
                            value: isRequired,
                            onChanged: (val) {
                              context.read<CampaignFormBuilderProvider>().toggleFieldRequired(index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CampaignFormBuilderProvider>().setStep(2),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('Continue to Upsell & Embed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3UpsellAndEmbed(BuildContext context, bool isMobile) {
    final embedHtml = _generateEmbedHtml('#2563eb', '#ffffff', '#f8fafc', '#0f172a');

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
                TextField(controller: _upsellTitleController, decoration: _inputDecoration(hint: 'Upsell Offer Headline')),
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
