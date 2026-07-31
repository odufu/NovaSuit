import 'package:flutter/material.dart';

/// Dynamic Whitelabel Theme Config loaded per Tenant Company from Supabase `tenant_settings`
class TenantTheme {
  final String companyId;
  final String appTitle;
  final String logoUrl;
  final String faviconUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String fontFamily;
  final String currencyCode;
  final String currencySymbol;

  const TenantTheme({
    required this.companyId,
    required this.appTitle,
    required this.logoUrl,
    required this.faviconUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.currencyCode,
    required this.currencySymbol,
  });

  /// Default NovaCare Theme Token Fallback
  factory TenantTheme.defaultNovaCare() {
    return const TenantTheme(
      companyId: 'default-novacare-id',
      appTitle: 'NovaCare CRM',
      logoUrl: '',
      faviconUrl: '',
      primaryColor: Color(0xFF1B4D3E),    // Deep Emerald Forest Green
      secondaryColor: Color(0xFFD4AF37),  // Gold Accent
      accentColor: Color(0xFFE67E22),     // Energetic Warm Orange
      backgroundColor: Color(0xFFF8F9FA),
      fontFamily: 'Outfit',
      currencyCode: 'NGN',
      currencySymbol: '₦',
    );
  }

  /// Deserializes database JSON payload from `tenant_settings` table
  factory TenantTheme.fromMap(Map<String, dynamic> map) {
    return TenantTheme(
      companyId: map['company_id'] ?? '',
      appTitle: map['app_title'] ?? 'NovaSuite CRM',
      logoUrl: map['logo_url'] ?? '',
      faviconUrl: map['favicon_url'] ?? '',
      primaryColor: _colorFromHex(map['primary_color'], const Color(0xFF1B4D3E)),
      secondaryColor: _colorFromHex(map['secondary_color'], const Color(0xFFD4AF37)),
      accentColor: _colorFromHex(map['accent_color'], const Color(0xFFE67E22)),
      backgroundColor: _colorFromHex(map['background_color'], const Color(0xFFF8F9FA)),
      fontFamily: map['font_family'] ?? 'Outfit',
      currencyCode: map['currency_code'] ?? 'NGN',
      currencySymbol: map['currency_symbol'] ?? '₦',
    );
  }

  /// Converts Dynamic Tenant Theme into Flutter `ThemeData`
  ThemeData toThemeData({Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  static Color _colorFromHex(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
