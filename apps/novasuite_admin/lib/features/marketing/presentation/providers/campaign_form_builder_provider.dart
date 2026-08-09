import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider managing state for Campaign Form Builder, Lead Forms Listing (Drafts & Published), Offer Packages (with Cross-Product Free Gift Addons), Linked Items, Product Catalog Search, Custom Questions, Marketing Broadcasts, Email/SMS Templates, Layout Styles, and Supabase DB Sync.
class CampaignFormBuilderProvider extends ChangeNotifier {
  int _currentStep = 0;
  bool _isLoading = false;
  String _quantityDisplayMode = 'Radio buttons';
  String _selectedProductCategory = 'Grazer Herbal Tea';

  bool get isLoading => _isLoading;

  // Dynamic List of Lead Forms (Contains both Drafts & Published Forms)
  List<Map<String, dynamic>> _leadForms = [
    {
      'id': 'form-001',
      'title': 'Grazer Tea Joel',
      'code': 'CRMF-00223',
      'marketerEmail': 'joelodufu@gmail.com',
      'productCategory': 'Grazer Herbal Tea',
      'submissionsCount': 142,
      'status': 'Published',
      'updatedAt': '2026-08-09 11:30',
      'redirectUrl': 'https://detoxwithnova.xyz/ura-clear-detox-tea',
    },
    {
      'id': 'form-002',
      'title': 'Vitality Detox Booster Special Promo',
      'code': 'CRMF-00224',
      'marketerEmail': 'joelodufu@gmail.com',
      'productCategory': 'Vitality Booster',
      'submissionsCount': 0,
      'status': 'Draft',
      'updatedAt': '2026-08-09 12:15',
      'redirectUrl': 'https://detoxwithnova.xyz/vitality-thank-you',
    },
  ];

  // Onboarded Available Products Catalog (Fetched from Supabase or Fallback Seed)
  List<Map<String, dynamic>> _availableProducts = [
    {
      'id': 'p0000000-0000-0000-0000-000000000001',
      'name': 'Grazer Herbal Tea',
      'sku': 'GHT-001',
      'category': 'Grazer Herbal Tea',
      'price': 23500.0,
      'stock': 500,
    },
    {
      'id': 'p0000000-0000-0000-0000-000000000002',
      'name': 'Vitality Detox Booster',
      'sku': 'VDB-002',
      'category': 'Vitality Booster',
      'price': 35000.0,
      'stock': 350,
    },
    {
      'id': 'p0000000-0000-0000-0000-000000000003',
      'name': 'SkinCare Glow Capsule',
      'sku': 'SGC-003',
      'category': 'SkinCare Glow',
      'price': 18000.0,
      'stock': 420,
    },
    {
      'id': 'p0000000-0000-0000-0000-000000000004',
      'name': 'Flat Belly Tea Cleanse',
      'sku': 'FBT-004',
      'category': 'Grazer Herbal Tea',
      'price': 28000.0,
      'stock': 300,
    },
    {
      'id': 'p0000000-0000-0000-0000-000000000005',
      'name': 'Respira Clear Detox',
      'sku': 'RCD-005',
      'category': 'Respiratory Health',
      'price': 15000.0,
      'stock': 400,
    },
  ];

  // Core Field Options
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

  // Offer Packages
  final List<Map<String, dynamic>> _offerPackages = [
    {
      'id': 'pkg-1',
      'label': '1 Grazer Detox Tea',
      'buyQty': 1,
      'freeQty': 0,
      'freeAddonProductId': null,
      'freeAddonProductName': null,
      'freeAddonQty': 0,
      'amount': 23500.0,
      'discount': 0.0,
      'isDefault': true,
    },
    {
      'id': 'pkg-2',
      'label': '2 Grazer Detox Tea',
      'buyQty': 2,
      'freeQty': 0,
      'freeAddonProductId': null,
      'freeAddonProductName': null,
      'freeAddonQty': 0,
      'amount': 37000.0,
      'discount': 10000.0,
      'isDefault': false,
    },
    {
      'id': 'pkg-3',
      'label': '3 Grazer Detox Tea',
      'buyQty': 3,
      'freeQty': 0,
      'freeAddonProductId': null,
      'freeAddonProductName': null,
      'freeAddonQty': 0,
      'amount': 47000.0,
      'discount': 23500.0,
      'isDefault': false,
    },
    {
      'id': 'pkg-4',
      'label': '4 Grazer Detox Tea + 1 Free',
      'buyQty': 4,
      'freeQty': 1,
      'freeAddonProductId': null,
      'freeAddonProductName': null,
      'freeAddonQty': 0,
      'amount': 70000.0,
      'discount': 23500.0,
      'isDefault': false,
    },
    {
      'id': 'pkg-5',
      'label': 'Buy 5 Grazer Tea + 1 Respira Detox Free',
      'buyQty': 5,
      'freeQty': 0,
      'freeAddonProductId': 'p0000000-0000-0000-0000-000000000005',
      'freeAddonProductName': 'Respira Clear Detox',
      'freeAddonQty': 1,
      'amount': 85000.0,
      'discount': 15000.0,
      'isDefault': false,
    },
  ];

  // Linked Items
  final List<Map<String, dynamic>> _linkedItems = [
    {
      'id': 'item-1',
      'productId': 'p0000000-0000-0000-0000-000000000001',
      'name': 'Grazer Herbal Tea',
      'sku': 'GHT-001',
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

  // Broadcast Storage
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
  List<Map<String, dynamic>> get leadForms => List.unmodifiable(_leadForms);
  List<Map<String, dynamic>> get availableProducts => List.unmodifiable(_availableProducts);
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

  /// Add or Update Form in the Lead Forms List (For both Drafts & Published Forms)
  void addOrUpdateLeadForm({
    required String title,
    required String marketerEmail,
    required String productCategory,
    required String status, // 'Draft' or 'Published'
    required String redirectUrl,
  }) {
    final cleanTitle = title.isNotEmpty ? title : 'Untitled Lead Form';
    final existingIndex = _leadForms.indexWhere((f) => f['title'].toString().toLowerCase() == cleanTitle.toLowerCase());
    
    final newFormData = {
      'id': existingIndex >= 0 ? _leadForms[existingIndex]['id'] : 'form-${DateTime.now().millisecondsSinceEpoch}',
      'title': cleanTitle,
      'code': existingIndex >= 0 ? _leadForms[existingIndex]['code'] : 'CRMF-00${_leadForms.length + 224}',
      'marketerEmail': marketerEmail.isNotEmpty ? marketerEmail : 'joelodufu@gmail.com',
      'productCategory': productCategory.isNotEmpty ? productCategory : _selectedProductCategory,
      'submissionsCount': existingIndex >= 0 ? _leadForms[existingIndex]['submissionsCount'] : 0,
      'status': status,
      'updatedAt': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'redirectUrl': redirectUrl,
    };

    if (existingIndex >= 0) {
      _leadForms[existingIndex] = newFormData;
    } else {
      _leadForms.insert(0, newFormData);
    }
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

  // Linked Items Methods
  void addLinkedItem(Map<String, dynamic> item) {
    _linkedItems.add(Map<String, dynamic>.from(item));
    notifyListeners();
  }

  void removeLinkedItem(int index) {
    if (index >= 0 && index < _linkedItems.length) {
      _linkedItems.removeAt(index);
      if (_linkedItems.isNotEmpty && !_linkedItems.any((i) => i['isDefault'] == true)) {
        _linkedItems[0]['isDefault'] = true;
      }
      notifyListeners();
    }
  }

  void setDefaultLinkedItem(int index) {
    for (int i = 0; i < _linkedItems.length; i++) {
      _linkedItems[i]['isDefault'] = (i == index);
    }
    notifyListeners();
  }

  // Offer Package Methods (Cross-Product Free Gift Addon Support)
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

  // Additional Questions Methods
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

  /// 🛢️ Fetch All Campaign Lead Forms from Supabase Database (`lead_forms` table)
  Future<void> fetchLeadFormsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('lead_forms')
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        _leadForms = response.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? 'Untitled Form',
          'code': 'CRMF-${item['id'].toString().substring(0, 5).toUpperCase()}',
          'marketerEmail': item['digital_marketer_email'] ?? 'marketer@novasuite.com',
          'productCategory': item['product_category'] ?? 'General',
          'submissionsCount': 0,
          'status': (item['status'] ?? 'Draft').toString().toLowerCase() == 'published' ? 'Published' : 'Draft',
          'updatedAt': item['updated_at'] != null ? item['updated_at'].toString().split('T').first : 'Just now',
          'redirectUrl': item['redirect_url'] ?? '',
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Lead Forms Fetch Exception (Using local state): $e');
    }
  }

  /// 🛢️ Fetch Pre-Onboarded Products from Supabase `products` Table
  Future<void> fetchAvailableProductsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('id, name, sku, category, base_price, stock_quantity')
          .eq('is_active', true);

      if (response.isNotEmpty) {
        _availableProducts = response.map((p) => {
          'id': p['id'],
          'name': p['name'],
          'sku': p['sku'] ?? 'SKU-000',
          'category': p['category'] ?? 'General',
          'price': (p['base_price'] as num).toDouble(),
          'stock': p['stock_quantity'] ?? 100,
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Product Search Sync Warning (Using local catalog): $e');
    }
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
    Map<String, dynamic>? appearance,
    String status = 'Published',
  }) async {
    _isLoading = true;
    notifyListeners();

    // Register in Local Lead Forms List immediately so it appears on the Forms tab!
    addOrUpdateLeadForm(
      title: title,
      marketerEmail: marketerEmail,
      productCategory: _selectedProductCategory,
      status: status,
      redirectUrl: redirectUrl,
    );

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
        'status': status.toLowerCase(),
        'appearance': appearance ?? {
          'button_bg': '#568500',
          'button_text': '#ffffff',
          'page_bg': '#0f172a',
          'card_bg': '#fafafc',
          'heading_color': '#0f172a',
          'input_bg': '#ffffff',
          'input_text': '#0f172a',
          'placeholder_color': '#94a3b8',
          'font_family': 'Inter',
          'layout_style': 'High-Converting E-Commerce',
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
