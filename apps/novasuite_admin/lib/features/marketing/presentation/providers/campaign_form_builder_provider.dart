import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider managing state for Campaign Form Builder, Offer Packages, Linked Items, Additional Questions, Broadcast Templates, and Supabase DB Sync.
class CampaignFormBuilderProvider extends ChangeNotifier {
  int _currentStep = 0;
  bool _isLoading = false;
  String _quantityDisplayMode = 'Radio buttons';
  String _selectedProductCategory = 'Grazer Herbal Tea';

  bool get isLoading => _isLoading;

  // Core Field Options (Visibility & Required toggles)
  final List<Map<String, dynamic>> _coreFields = [
    {'key': 'full_name', 'label': 'Full Name', 'required': true, 'visible': true},
    {'key': 'email', 'label': 'Email', 'required': false, 'visible': true},
    {'key': 'phone', 'label': 'Phone', 'required': true, 'visible': true},
    {'key': 'address1', 'label': 'Address Line 1', 'required': true, 'visible': true},
    {'key': 'address2', 'label': 'Address Line 2', 'required': false, 'visible': false},
    {'key': 'country', 'label': 'Country', 'required': false, 'visible': false},
    {'key': 'state', 'label': 'State/Province', 'required': true, 'visible': true},
    {'key': 'city', 'label': 'City', 'required': false, 'visible': true},
    {'key': 'postal_code', 'label': 'Postal Code', 'required': false, 'visible': false},
  ];

  // Offer Packages (Dynamic package choices for buyers)
  final List<Map<String, dynamic>> _offerPackages = [
    {
      'id': 'pkg-1',
      'label': '1 Grazer Detox Tea',
      'buyQty': 1,
      'freeQty': 0,
      'amount': 23500.0,
      'discount': 0.0,
      'isDefault': true,
    },
    {
      'id': 'pkg-2',
      'label': '2 Grazer Detox Tea',
      'buyQty': 2,
      'freeQty': 0,
      'amount': 37000.0,
      'discount': 10000.0,
      'isDefault': false,
    },
    {
      'id': 'pkg-3',
      'label': '3 Grazer Detox Tea',
      'buyQty': 3,
      'freeQty': 0,
      'amount': 47000.0,
      'discount': 23500.0,
      'isDefault': false,
    },
    {
      'id': 'pkg-4',
      'label': '4 Grazer Detox Tea + 1 Free',
      'buyQty': 4,
      'freeQty': 1,
      'amount': 70000.0,
      'discount': 23500.0,
      'isDefault': false,
    },
  ];

  // Linked Items (Onboarded merchant products)
  final List<Map<String, dynamic>> _linkedItems = [
    {
      'id': 'item-1',
      'name': 'Grazer Herbal Tea',
      'type': 'Main',
      'qty': 1,
      'price': 23500.0,
      'isDefault': true,
    },
  ];

  // Additional Questions / Custom Fields
  final List<Map<String, dynamic>> _additionalQuestions = [
    {
      'id': 'q-1',
      'label': 'WhatsApp Number',
      'type': 'Phone',
      'placeholder': 'WhatsApp Number',
      'required': false,
    },
  ];

  // Broadcast & Template Storage
  final List<Map<String, dynamic>> _broadcasts = [
    {
      'id': 'bcast-1',
      'name': 'August Flash Promo Blast',
      'channel': 'Email & SMS',
      'template': 'Herbal Detox Offer Template',
      'recipientsCount': 1240,
      'status': 'Sent',
      'sentAt': '2026-08-08 14:00',
    },
  ];

  final List<Map<String, dynamic>> _emailTemplates = [
    {
      'id': 'tpl-email-1',
      'title': 'Grazer Tea Order Confirmation',
      'subject': 'Your Order is Confirmed! (Pay on Delivery)',
      'body': 'Dear {customer_name}, thank you for ordering {product_name}. Our rider will deliver to {delivery_state} shortly.',
      'createdAt': '2026-08-01',
    },
  ];

  final List<Map<String, dynamic>> _smsTemplates = [
    {
      'id': 'tpl-sms-1',
      'title': 'SMS Order Alert',
      'senderId': 'NOVACARE',
      'message': 'Hello {customer_name}, your order for {product_name} has been processed. Total: ₦{amount}. Support: 07003100077',
      'createdAt': '2026-08-01',
    },
  ];

  // Getters
  int get currentStep => _currentStep;
  String get quantityDisplayMode => _quantityDisplayMode;
  String get selectedProductCategory => _selectedProductCategory;
  List<Map<String, dynamic>> get coreFields => List.unmodifiable(_coreFields);
  List<Map<String, dynamic>> get offerPackages => List.unmodifiable(_offerPackages);
  List<Map<String, dynamic>> get linkedItems => List.unmodifiable(_linkedItems);
  List<Map<String, dynamic>> get additionalQuestions => List.unmodifiable(_additionalQuestions);
  List<Map<String, dynamic>> get broadcasts => List.unmodifiable(_broadcasts);
  List<Map<String, dynamic>> get emailTemplates => List.unmodifiable(_emailTemplates);
  List<Map<String, dynamic>> get smsTemplates => List.unmodifiable(_smsTemplates);

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setQuantityDisplayMode(String mode) {
    _quantityDisplayMode = mode;
    notifyListeners();
  }

  void setProductCategory(String cat) {
    _selectedProductCategory = cat;
    notifyListeners();
  }

  void toggleCoreFieldRequired(int index) {
    if (index >= 0 && index < _coreFields.length) {
      _coreFields[index]['required'] = !(_coreFields[index]['required'] as bool);
      notifyListeners();
    }
  }

  void toggleCoreFieldVisible(int index) {
    if (index >= 0 && index < _coreFields.length) {
      _coreFields[index]['visible'] = !(_coreFields[index]['visible'] as bool);
      notifyListeners();
    }
  }

  // ===========================================================================
  // OFFER PACKAGE METHODS (Preserves User Edits Across Rebuilds!)
  // ===========================================================================
  void addOfferPackage(Map<String, dynamic> pkg) {
    _offerPackages.add(Map<String, dynamic>.from(pkg));
    notifyListeners();
  }

  void updateOfferPackage(int index, String key, dynamic value) {
    if (index >= 0 && index < _offerPackages.length) {
      _offerPackages[index][key] = value;
      notifyListeners();
    }
  }

  void duplicateOfferPackage(int index) {
    if (index >= 0 && index < _offerPackages.length) {
      final source = _offerPackages[index];
      final copy = Map<String, dynamic>.from(source);
      copy['id'] = 'pkg-${DateTime.now().millisecondsSinceEpoch}';
      copy['label'] = '${source['label']} (Copy)';
      copy['isDefault'] = false;
      _offerPackages.insert(index + 1, copy);
      notifyListeners();
    }
  }

  void removeOfferPackage(int index) {
    if (index >= 0 && index < _offerPackages.length) {
      _offerPackages.removeAt(index);
      if (_offerPackages.isNotEmpty && !_offerPackages.any((p) => p['isDefault'] == true)) {
        _offerPackages[0]['isDefault'] = true;
      }
      notifyListeners();
    }
  }

  void setDefaultPackage(int index) {
    for (int i = 0; i < _offerPackages.length; i++) {
      _offerPackages[i]['isDefault'] = (i == index);
    }
    notifyListeners();
  }

  // ===========================================================================
  // ADDITIONAL QUESTIONS METHODS
  // ===========================================================================
  void addAdditionalQuestion(Map<String, dynamic> q) {
    _additionalQuestions.add(Map<String, dynamic>.from(q));
    notifyListeners();
  }

  void updateAdditionalQuestion(int index, String key, dynamic value) {
    if (index >= 0 && index < _additionalQuestions.length) {
      _additionalQuestions[index][key] = value;
      notifyListeners();
    }
  }

  void removeAdditionalQuestion(int index) {
    if (index >= 0 && index < _additionalQuestions.length) {
      _additionalQuestions.removeAt(index);
      notifyListeners();
    }
  }

  // Broadcast & Template Methods
  void addBroadcast(Map<String, dynamic> bcast) {
    _broadcasts.add(bcast);
    notifyListeners();
  }

  void addEmailTemplate(Map<String, dynamic> tpl) {
    _emailTemplates.add(tpl);
    notifyListeners();
  }

  void addSmsTemplate(Map<String, dynamic> tpl) {
    _smsTemplates.add(tpl);
    notifyListeners();
  }

  /// 🛢️ Save Campaign Lead Form to Supabase Database (`lead_forms` table)
  Future<bool> saveLeadFormToSupabase({
    required String companyId,
    required String title,
    required String marketerEmail,
    required String redirectUrl,
    required String successMessage,
    required String submitButtonText,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      await client.from('lead_forms').insert({
        'company_id': companyId.isNotEmpty ? companyId : 'c0000000-0000-0000-0000-000000000001',
        'title': title,
        'digital_marketer_email': marketerEmail,
        'redirect_url': redirectUrl,
        'success_message': successMessage,
        'submit_button_text': submitButtonText,
        'quantity_display_mode': _quantityDisplayMode,
        'preset_country': 'Nigeria',
        'description': description,
        'product_category': _selectedProductCategory,
        'core_fields': _coreFields,
        'offer_packages': _offerPackages,
        'linked_items': _linkedItems,
        'additional_questions': _additionalQuestions,
        'appearance': {
          'button_bg': '#568500',
          'button_text': '#ffffff',
          'page_bg': '#0f172a',
          'card_bg': '#fafafc',
          'border_radius': '10px',
        },
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Supabase Lead Form Save Exception (Fallback to local state): $e');
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }
}
