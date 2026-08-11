import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider managing state for Campaign Form Builder, Lead Forms Listing (Drafts & Published), Offer Packages (with Cross-Product Free Gift Addons), Linked Items, Product Catalog Search, Custom Questions, Marketing Broadcasts, Email/SMS Templates, Layout Styles, and Supabase DB Sync.
class CampaignFormBuilderProvider extends ChangeNotifier {
  int _currentStep = 0;
  bool _isLoading = false;
  String _quantityDisplayMode = 'Radio buttons';
  String _selectedProductCategory = 'Grazer Herbal Tea';

  bool get isLoading => _isLoading;

  // Dynamic List of Lead Forms (Contains both Drafts & Published Forms from Supabase DB)
  List<Map<String, dynamic>> _leadForms = [];

  // Onboarded Available Products Catalog (Fetched from Supabase DB with default seeds)
  List<Map<String, dynamic>> _availableProducts = [
    {
      'id': '90000000-0000-4000-8000-000000000001',
      'name': 'Grazer Herbal Tea',
      'sku': 'GHT-001',
      'category': 'Grazer Herbal Tea',
      'price': 23500.0,
      'stock': 500,
    },
    {
      'id': '90000000-0000-4000-8000-000000000002',
      'name': 'Vitality Detox Booster',
      'sku': 'VDB-002',
      'category': 'Vitality Booster',
      'price': 35000.0,
      'stock': 300,
    },
    {
      'id': 'p0000000-0000-0000-0000-000000000003',
      'name': 'Alpha Man Formula',
      'sku': 'AMF-003',
      'category': 'Men\'s Health',
      'price': 27000.0,
      'stock': 450,
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

  // Offer Packages (Dynamic for active form being edited)
  final List<Map<String, dynamic>> _offerPackages = [
    {
      'id': 'pkg-1',
      'label': '1 Alpha Man',
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
      'label': '2 Alpha Man',
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
      'label': '3 Alpha Man',
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
      'label': '4 Alpha Man + 1 Free',
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
      'label': '5 Alpha Man + 1 Respira Detox Free',
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
  final List<Map<String, dynamic>> _linkedItems = [];

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
  final List<Map<String, dynamic>> _broadcasts = [];
  final List<Map<String, dynamic>> _emailTemplates = [];
  final List<Map<String, dynamic>> _smsTemplates = [];

  // Realtime Broadcast Channel
  RealtimeChannel? _realtimeChannel;
  bool _isRealtimeSubscribed = false;

  // Realtime Submissions & Orders List (Fetched dynamically from Supabase DB)
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _orders = [];

  // Getters
  int get currentStep => _currentStep;
  String get quantityDisplayMode => _quantityDisplayMode;
  String get selectedProductCategory => _selectedProductCategory;
  List<Map<String, dynamic>> get leadForms => List.unmodifiable(_leadForms);
  List<Map<String, dynamic>> get submissions => List.unmodifiable(_submissions);
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
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

  void updateCoreFieldLabel(int index, String newLabel) {
    if (index >= 0 && index < _coreFields.length) {
      _coreFields[index]['label'] = newLabel;
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
        _updateFormSubmissionCounts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Lead Forms Fetch Exception: $e');
    }
  }

  String? _attachedProductId;

  String? get attachedProductId {
    if (_attachedProductId != null) return _attachedProductId;
    if (_availableProducts.isNotEmpty) {
      final matching = _availableProducts.firstWhere(
        (p) => p['category'].toString().toLowerCase() == _selectedProductCategory.toLowerCase(),
        orElse: () => _availableProducts.first,
      );
      return matching['id']?.toString();
    }
    return null;
  }

  void setAttachedProductId(String? prodId) {
    _attachedProductId = prodId;
    if (prodId != null && _availableProducts.isNotEmpty) {
      final matching = _availableProducts.firstWhere((p) => p['id'] == prodId, orElse: () => {});
      if (matching.isNotEmpty && matching['category'] != null) {
        _selectedProductCategory = matching['category'].toString();
      }
    }
    notifyListeners();
  }

  /// 🛢️ Onboard / Create New Product in Supabase `products` Table
  Future<bool> onboardProductToSupabase({
    required String name,
    required String category,
    required double basePrice,
    required int stockQuantity,
    String? sku,
    String? description,
    String companyId = 'c0000000-0000-0000-0000-000000000001',
  }) async {
    _isLoading = true;
    notifyListeners();

    final cleanName = name.trim();
    final cleanCat = category.trim().isNotEmpty ? category.trim() : 'General';
    final cleanSku = sku?.trim().isNotEmpty == true
        ? sku!.trim()
        : 'SKU-${cleanName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase().substring(0, cleanName.length > 3 ? 3 : cleanName.length)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final localId = 'p${DateTime.now().millisecondsSinceEpoch}';

    // 1. Register instantly in local memory catalog so UI updates IMMEDIATELY!
    final newProd = {
      'id': localId,
      'name': cleanName,
      'sku': cleanSku,
      'category': cleanCat,
      'price': basePrice,
      'stock': stockQuantity,
    };

    // Remove duplicates if any
    _availableProducts.removeWhere((p) => p['name'].toString().toLowerCase() == cleanName.toLowerCase());
    _availableProducts.insert(0, newProd);
    _selectedProductCategory = cleanCat;
    _attachedProductId = localId;
    notifyListeners();

    // 2. Persist to Supabase products table asynchronously
    try {
      final client = Supabase.instance.client;
      Map<String, dynamic> newRecord;
      try {
        newRecord = await client.from('products').insert({
          'company_id': companyId,
          'name': cleanName,
          'sku': cleanSku,
          'category': cleanCat,
          'base_price': basePrice,
          'stock_quantity': stockQuantity,
          'description': description ?? 'Onboarded by Digital Marketer',
          'is_active': true,
        }).select().single();
      } catch (_) {
        // Fallback without category column if schema cache lacks category
        newRecord = await client.from('products').insert({
          'company_id': companyId,
          'name': cleanName,
          'sku': cleanSku,
          'base_price': basePrice,
          'stock_quantity': stockQuantity,
          'description': description ?? 'Onboarded by Digital Marketer',
          'is_active': true,
        }).select().single();
      }

      if (newRecord['id'] != null) {
        final dbId = newRecord['id'].toString();
        final idx = _availableProducts.indexWhere((p) => p['id'] == localId);
        if (idx >= 0) {
          _availableProducts[idx]['id'] = dbId;
        }
        if (_attachedProductId == localId) {
          _attachedProductId = dbId;
        }
      }
    } catch (e) {
      debugPrint('Supabase Product Onboard Warning (Fallback to local state): $e');
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// 🛢️ Fetch Pre-Onboarded Products from Supabase `products` Table
  Future<void> fetchAvailableProductsFromSupabase() async {
    try {
      dynamic response;
      try {
        response = await Supabase.instance.client
            .from('products')
            .select('id, name, sku, category, base_price, stock_quantity')
            .eq('is_active', true);
      } catch (_) {
        response = await Supabase.instance.client
            .from('products')
            .select('id, name, sku, base_price, stock_quantity')
            .eq('is_active', true);
      }

      if (response != null && response is List && response.isNotEmpty) {
        final fetchedProds = response.map((p) => {
          'id': p['id'],
          'name': p['name'],
          'sku': p['sku'] ?? 'SKU-000',
          'category': p['category'] ?? 'General',
          'price': (p['base_price'] as num).toDouble(),
          'stock': p['stock_quantity'] ?? 100,
        }).toList();

        for (final item in fetchedProds) {
          final idx = _availableProducts.indexWhere((existing) =>
              existing['id'] == item['id'] ||
              existing['name'].toString().toLowerCase() == item['name'].toString().toLowerCase());
          if (idx >= 0) {
            _availableProducts[idx] = item;
          } else {
            _availableProducts.add(item);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Product Search Sync Warning: $e');
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

    final cleanTitle = title.trim().isNotEmpty ? title.trim() : 'Untitled Lead Form';

    // Register in Local Lead Forms List immediately so it appears on the Forms tab!
    addOrUpdateLeadForm(
      title: cleanTitle,
      marketerEmail: marketerEmail,
      productCategory: _selectedProductCategory,
      status: status,
      redirectUrl: redirectUrl,
    );

    try {
      final client = Supabase.instance.client;

      bool isUuid(String? s) => s != null && RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(s);

      // Check if existing lead form with title exists to acquire primary key UUID
      final existingRes = await client
          .from('lead_forms')
          .select('id')
          .eq('title', cleanTitle)
          .maybeSingle();

      final existingId = existingRes != null ? existingRes['id'] : null;

      final formPayload = {
        if (existingId != null) 'id': existingId,
        'company_id': isUuid(companyId) ? companyId : 'c0000000-0000-0000-0000-000000000001',
        'product_id': isUuid(attachedProductId) ? attachedProductId : null,
        'title': cleanTitle,
        'digital_marketer_email': marketerEmail.trim().isNotEmpty ? marketerEmail.trim() : 'marketer@novacare.com',
        'redirect_url': redirectUrl.trim().isNotEmpty ? redirectUrl.trim() : 'https://detoxwithnova.xyz/thank-you',
        'success_message': successMessage,
        'submit_button_text': submitButtonText,
        'quantity_display_mode': _quantityDisplayMode,
        'preset_country': 'Nigeria',
        'description': description,
        'product_category': _selectedProductCategory.trim().isNotEmpty ? _selectedProductCategory.trim() : 'Grazer Herbal Tea',
        'core_fields': _coreFields,
        'offer_packages': _offerPackages,
        'linked_items': _linkedItems,
        'additional_questions': _additionalQuestions,
        'status': status.toLowerCase() == 'published' ? 'published' : 'draft',
        'updated_at': DateTime.now().toIso8601String(),
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
      };

      final savedRecord = await client
          .from('lead_forms')
          .upsert(formPayload)
          .select()
          .single();

      if (savedRecord['id'] != null) {
        final formId = savedRecord['id'];
        final idx = _leadForms.indexWhere((f) => f['title'].toString().toLowerCase() == cleanTitle.toLowerCase());
        if (idx >= 0) {
          _leadForms[idx]['id'] = formId;
          _leadForms[idx]['code'] = 'CRMF-${formId.toString().substring(0, 5).toUpperCase()}';
          _leadForms[idx]['status'] = status;
        }
      }

      await fetchLeadFormsFromSupabase();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Supabase Lead Form Save Exception: $e');
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// 🛢️ Fetch All Lead Submissions from Supabase Database (`form_submissions` table)
  Future<void> fetchSubmissionsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('form_submissions')
          .select('*, lead_forms(title, product_category)')
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        _submissions = response.map((item) {
          final formInfo = item['lead_forms'] as Map<String, dynamic>?;
          return {
            'id': item['submission_code'] ?? item['id'].toString(),
            'customerName': item['customer_name'] ?? 'Anonymous Lead',
            'contactEmail': item['contact_email'] ?? 'no-email@novasuite.com',
            'contactPhone': item['contact_phone'] ?? 'N/A',
            'formCode': item['form_id'] != null 
                ? 'CRMF-${item['form_id'].toString().substring(0, 5).toUpperCase()}' 
                : 'CRMF-00223',
            'formId': item['form_id'],
            'productCategory': formInfo?['product_category'] ?? _selectedProductCategory,
            'status': (item['status'] ?? 'Converted').toString(),
            'submittedAt': item['created_at'] != null 
                ? item['created_at'].toString().replaceAll('T', ' ').split('.').first 
                : 'Just now',
            'orderRef': item['order_id'] != null 
                ? 'Novacare Ltd-CRM-ORD-${item['order_id'].toString().substring(0, 5).toUpperCase()}' 
                : 'Pending Order',
            'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
            'utmSource': item['utm_source'] ?? 'direct',
            'rawCreatedAt': item['created_at'],
          };
        }).toList();
        _updateFormSubmissionCounts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Submissions Fetch Exception (Using local state): $e');
    }
  }

  /// 🛢️ Fetch All Orders from Supabase Database (`orders` table)
  Future<void> fetchOrdersFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('*, products(name, category), sales_rep:users!sales_rep_id(first_name, last_name, email), marketer:users!marketer_id(first_name, last_name, email)')
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        _orders = response.map((item) {
          final productInfo = item['products'] as Map<String, dynamic>?;
          final salesRepInfo = item['sales_rep'] as Map<String, dynamic>?;
          final marketerInfo = item['marketer'] as Map<String, dynamic>?;

          String statusLabel = 'New';
          final rawStatus = item['status'].toString().toLowerCase();
          switch (rawStatus) {
            case 'not_ready':
              statusLabel = 'Not ready';
              break;
            case 'duplicate':
              statusLabel = 'Duplicate';
              break;
            case 'delivered':
              statusLabel = 'Delivered';
              break;
            case 'call_back':
              statusLabel = 'Call Back';
              break;
            case 'agent_notified':
              statusLabel = 'Agent Notified';
              break;
            case 'cancelled':
              statusLabel = 'Cancelled';
              break;
            case 'confirmed':
              statusLabel = 'Confirmed';
              break;
            case 'in_transit':
              statusLabel = 'In Transit';
              break;
            case 'contacting':
              statusLabel = 'Contacting';
              break;
            default:
              statusLabel = rawStatus.isNotEmpty 
                  ? '${rawStatus[0].toUpperCase()}${rawStatus.substring(1)}'
                  : 'New';
          }

          String closerName = 'Udoka Obed';
          if (salesRepInfo != null && salesRepInfo['first_name'] != null) {
            closerName = '${salesRepInfo['first_name']} ${salesRepInfo['last_name'] ?? ''}'.trim();
          }

          final createdAtStr = item['created_at'] != null 
              ? item['created_at'].toString().replaceAll('T', ' ').split('.').first 
              : 'Just now';

          return {
            'dbId': item['id'],
            'id': item['order_number'] ?? 'ORD-${item['id'].toString().substring(0, 5).toUpperCase()}',
            'customerName': item['customer_name'] ?? 'Anonymous Lead',
            'customerPhone': item['customer_phone'] ?? 'N/A',
            'created': createdAtStr,
            'status': statusLabel,
            'rawStatus': rawStatus,
            'category': (productInfo?['category'] ?? productInfo?['name'] ?? _selectedProductCategory).toString().toUpperCase(),
            'formType': 'Campaign Form',
            'closer': closerName,
            'closerId': item['sales_rep_id'],
            'marketerId': item['marketer_id'],
            'marketerEmail': marketerInfo?['email'],
            'branch': item['delivery_state'] ?? 'Abuja',
            'brand': 'Nova Care',
            'value': (item['total_amount'] as num?)?.toDouble() ?? 23500.0,
            'delivery': item['delivery_state'] != null ? 'ETA in ${item['delivery_state']}' : 'Delivery Pending',
            'lastUpdated': item['updated_at'] != null 
                ? item['updated_at'].toString().replaceAll('T', ' ').split('.').first 
                : 'Just now',
          };
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Supabase Orders Fetch Exception: $e');
    }
  }

  /// 🛢️ Update Order Status in Supabase `orders` Table
  Future<bool> updateOrderStatusInSupabase(String orderDbId, String newStatusLabel) async {
    String rawStatus = newStatusLabel.toLowerCase().replaceAll(' ', '_');
    try {
      // Optimistically update local state
      final idx = _orders.indexWhere((o) => o['dbId'] == orderDbId || o['id'] == orderDbId);
      if (idx >= 0) {
        _orders[idx]['status'] = newStatusLabel;
        _orders[idx]['rawStatus'] = rawStatus;
        notifyListeners();
      }

      await Supabase.instance.client
          .from('orders')
          .update({
            'status': rawStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderDbId);

      return true;
    } catch (e) {
      debugPrint('Supabase Order Status Update Exception: $e');
      return false;
    }
  }

  void _updateFormSubmissionCounts() {
    for (int i = 0; i < _leadForms.length; i++) {
      final fId = _leadForms[i]['id'];
      final fCode = _leadForms[i]['code'];
      final count = _submissions.where((s) => 
        (fId != null && s['formId'] == fId) || 
        (fCode != null && s['formCode'] == fCode)
      ).length;
      if (count > 0) {
        _leadForms[i]['submissionsCount'] = count;
      }
    }
  }

  /// 📡 Subscribe to Supabase Realtime Channels for Instant Forms, Submissions & Orders Exchange
  void subscribeToRealtimeSubmissionsAndForms() {
    if (_isRealtimeSubscribed) return;
    _isRealtimeSubscribed = true;

    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client.channel('public:lead_suite_realtime');

      // 1. Realtime Listener on lead_forms table
      _realtimeChannel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'lead_forms',
        callback: (payload) {
          debugPrint('📡 Realtime lead_forms broadcast event: ${payload.eventType}');
          fetchLeadFormsFromSupabase();
        },
      );

      // 2. Realtime Listener on form_submissions table (Instant Lead Exchange)
      _realtimeChannel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'form_submissions',
        callback: (payload) {
          debugPrint('📡 Realtime form_submissions broadcast event: ${payload.eventType}');
          if (payload.eventType == PostgresChangeEvent.insert && payload.newRecord.isNotEmpty) {
            final item = payload.newRecord;
            String resolvedCategory = _selectedProductCategory;
            if (item['form_id'] != null) {
              final matchingForm = _leadForms.firstWhere(
                (f) => f['id'] == item['form_id'],
                orElse: () => {},
              );
              if (matchingForm.isNotEmpty && matchingForm['productCategory'] != null) {
                resolvedCategory = matchingForm['productCategory'].toString();
              }
            }

            final newSub = {
              'id': item['submission_code'] ?? item['id'] ?? 'CRM-SUB-${DateTime.now().millisecondsSinceEpoch}',
              'customerName': item['customer_name'] ?? 'New Customer Lead',
              'contactEmail': item['contact_email'] ?? 'lead@novasuite.com',
              'contactPhone': item['contact_phone'] ?? 'N/A',
              'formCode': item['form_id'] != null ? 'CRMF-${item['form_id'].toString().substring(0, 5).toUpperCase()}' : 'CRMF-00223',
              'formId': item['form_id'],
              'productCategory': resolvedCategory,
              'status': item['status'] ?? 'Converted',
              'submittedAt': 'Just now',
              'orderRef': item['order_id'] != null ? 'Novacare Ltd-CRM-ORD-${item['order_id'].toString().substring(0, 5).toUpperCase()}' : 'Live Conversion',
              'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
              'utmSource': item['utm_source'] ?? 'direct',
              'rawCreatedAt': item['created_at'] ?? DateTime.now().toIso8601String(),
            };
            _submissions.insert(0, newSub);
            _updateFormSubmissionCounts();
            notifyListeners();
          } else {
            fetchSubmissionsFromSupabase();
          }
        },
      );

      // 3. Realtime Listener on orders table (Instant Order Pipeline Exchange)
      _realtimeChannel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        callback: (payload) {
          debugPrint('📡 Realtime orders broadcast event: ${payload.eventType}');
          fetchOrdersFromSupabase();
        },
      );

      _realtimeChannel!.subscribe();
    } catch (e) {
      debugPrint('Supabase Realtime Channel Subscription Warning: $e');
    }
  }

  @override
  void dispose() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }
}
