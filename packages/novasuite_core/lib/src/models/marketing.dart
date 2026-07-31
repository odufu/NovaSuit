import 'package:equatable/equatable.dart';

class MarketerBudgetModel extends Equatable {
  final String id;
  final String companyId;
  final String marketerId;
  final String fundedByAgmId;
  final double amountFunded;
  final double currentBalance;
  final String? notes;
  final DateTime createdAt;

  const MarketerBudgetModel({
    required this.id,
    required this.companyId,
    required this.marketerId,
    required this.fundedByAgmId,
    required this.amountFunded,
    required this.currentBalance,
    this.notes,
    required this.createdAt,
  });

  factory MarketerBudgetModel.fromMap(Map<String, dynamic> map) {
    return MarketerBudgetModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      marketerId: map['marketer_id'] ?? '',
      fundedByAgmId: map['funded_by_agm_id'] ?? '',
      amountFunded: (map['amount_funded'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'marketer_id': marketerId,
      'funded_by_agm_id': fundedByAgmId,
      'amount_funded': amountFunded,
      'current_balance': currentBalance,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, companyId, marketerId, fundedByAgmId, amountFunded, currentBalance];
}

class AdCampaignModel extends Equatable {
  final String id;
  final String companyId;
  final String marketerId;
  final String productId;
  final String campaignName;
  final String platform;
  final double adSpend;
  final String? pixelId;
  final DateTime createdAt;

  const AdCampaignModel({
    required this.id,
    required this.companyId,
    required this.marketerId,
    required this.productId,
    required this.campaignName,
    required this.platform,
    required this.adSpend,
    this.pixelId,
    required this.createdAt,
  });

  factory AdCampaignModel.fromMap(Map<String, dynamic> map) {
    return AdCampaignModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      marketerId: map['marketer_id'] ?? '',
      productId: map['product_id'] ?? '',
      campaignName: map['campaign_name'] ?? '',
      platform: map['platform'] ?? 'facebook',
      adSpend: (map['ad_spend'] as num?)?.toDouble() ?? 0.0,
      pixelId: map['pixel_id'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'marketer_id': marketerId,
      'product_id': productId,
      'campaign_name': campaignName,
      'platform': platform,
      'ad_spend': adSpend,
      'pixel_id': pixelId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, companyId, marketerId, productId, campaignName, platform, adSpend, pixelId];
}

class CampaignFormModel extends Equatable {
  final String id;
  final String companyId;
  final String marketerEmail;
  final String formTitle;
  final String redirectUrl;
  final String successMessage;
  final String submitButtonText;
  final String quantityDisplayMode; // 'number', 'dropdown', 'radio'
  final String presetCountry;
  final String description;
  final String productId;
  final Map<String, dynamic> fieldOptions;
  final Map<String, dynamic> appearanceOptions;
  final DateTime createdAt;

  const CampaignFormModel({
    required this.id,
    required this.companyId,
    required this.marketerEmail,
    required this.formTitle,
    required this.redirectUrl,
    required this.successMessage,
    required this.submitButtonText,
    required this.quantityDisplayMode,
    required this.presetCountry,
    required this.description,
    required this.productId,
    required this.fieldOptions,
    required this.appearanceOptions,
    required this.createdAt,
  });

  factory CampaignFormModel.fromMap(Map<String, dynamic> map) {
    return CampaignFormModel(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      marketerEmail: map['marketer_email'] ?? '',
      formTitle: map['form_title'] ?? '',
      redirectUrl: map['redirect_url'] ?? '',
      successMessage: map['success_message'] ?? '',
      submitButtonText: map['submit_button_text'] ?? '',
      quantityDisplayMode: map['quantity_display_mode'] ?? 'number',
      presetCountry: map['preset_country'] ?? 'Nigeria',
      description: map['description'] ?? '',
      productId: map['product_id'] ?? '',
      fieldOptions: Map<String, dynamic>.from(map['field_options'] ?? {}),
      appearanceOptions: Map<String, dynamic>.from(map['appearance_options'] ?? {}),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'marketer_email': marketerEmail,
      'form_title': formTitle,
      'redirect_url': redirectUrl,
      'success_message': successMessage,
      'submit_button_text': submitButtonText,
      'quantity_display_mode': quantityDisplayMode,
      'preset_country': presetCountry,
      'description': description,
      'product_id': productId,
      'field_options': fieldOptions,
      'appearance_options': appearanceOptions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, companyId, marketerEmail, formTitle, productId];
}
