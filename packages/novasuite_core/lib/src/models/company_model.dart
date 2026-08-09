import 'package:equatable/equatable.dart';

/// Enum representing the primary business domain of a registered NovaSuite tenant.
enum CompanyType {
  /// E-Commerce merchant selling physical goods (e.g., NovaCare, Leafora).
  eCommerce('ecommerce', 'E-Commerce Merchant'),

  /// Logistics and delivery fulfillment firm (e.g., Nova Express, GIG Logistics).
  logistics('logistics', 'Logistics & Fleet Provider');

  final String dbValue;
  final String label;
  const CompanyType(this.dbValue, this.label);

  static CompanyType fromDbValue(String value) {
    return CompanyType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CompanyType.eCommerce,
    );
  }
}

/// White-Label Branding Configuration for personalizing tenant domains, themes, and apps.
class BrandingConfig extends Equatable {
  final String primaryColorHex;
  final String secondaryColorHex;
  final String accentColorHex;
  final String darkSurfaceHex;
  final String lightSurfaceHex;
  final String? logoUrl;
  final String? faviconUrl;
  final String idpAppTitle;
  final String? supportHotline;

  const BrandingConfig({
    this.primaryColorHex = '#10B981',
    this.secondaryColorHex = '#09140E',
    this.accentColorHex = '#F59E0B',
    this.darkSurfaceHex = '#0C1F17',
    this.lightSurfaceHex = '#F8FAFC',
    this.logoUrl,
    this.faviconUrl,
    this.idpAppTitle = 'Nova Express Rider App',
    this.supportHotline,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      primaryColorHex: json['primary_color'] ?? '#10B981',
      secondaryColorHex: json['secondary_color'] ?? '#09140E',
      accentColorHex: json['accent_color'] ?? '#F59E0B',
      darkSurfaceHex: json['dark_surface'] ?? '#0C1F17',
      lightSurfaceHex: json['light_surface'] ?? '#F8FAFC',
      logoUrl: json['logo_url'],
      faviconUrl: json['favicon_url'],
      idpAppTitle: json['idp_app_title'] ?? 'Nova Express Rider App',
      supportHotline: json['support_hotline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColorHex,
      'secondary_color': secondaryColorHex,
      'accent_color': accentColorHex,
      'dark_surface': darkSurfaceHex,
      'light_surface': lightSurfaceHex,
      'logo_url': logoUrl,
      'favicon_url': faviconUrl,
      'idp_app_title': idpAppTitle,
      'support_hotline': supportHotline,
    };
  }

  @override
  List<Object?> get props => [
        primaryColorHex,
        secondaryColorHex,
        accentColorHex,
        darkSurfaceHex,
        lightSurfaceHex,
        logoUrl,
        faviconUrl,
        idpAppTitle,
        supportHotline,
      ];
}

/// Core domain model representing a registered NovaSuite Tenant Company.
class CompanyModel extends Equatable {
  final String id;
  final String name;
  final CompanyType type;
  final String subdomain;
  final String? customDomain;
  final String? webhookUrl;
  final String? webhookSecret;
  final BrandingConfig branding;
  final bool isActive;
  final DateTime createdAt;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subdomain,
    this.customDomain,
    this.webhookUrl,
    this.webhookSecret,
    this.branding = const BrandingConfig(),
    this.isActive = true,
    required this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CompanyType.fromDbValue(json['company_type'] ?? 'ecommerce'),
      subdomain: json['subdomain'] ?? '',
      customDomain: json['custom_domain'],
      webhookUrl: json['webhook_url'],
      webhookSecret: json['webhook_secret'],
      branding: json['branding'] != null && json['branding'] is Map<String, dynamic>
          ? BrandingConfig.fromJson(json['branding'])
          : const BrandingConfig(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_type': type.dbValue,
      'subdomain': subdomain,
      'custom_domain': customDomain,
      'webhook_url': webhookUrl,
      'webhook_secret': webhookSecret,
      'branding': branding.toJson(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        subdomain,
        customDomain,
        webhookUrl,
        webhookSecret,
        branding,
        isActive,
        createdAt,
      ];
}
