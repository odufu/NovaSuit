import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

/// Provider for resolving active tenant company branding, custom subdomains, and dynamic White-Label themes.
class TenantBrandProvider extends ChangeNotifier {
  CompanyModel? _currentCompany;
  final bool _isLoading = false;

  CompanyModel? get currentCompany => _currentCompany;
  bool get isLoading => _isLoading;

  /// Default fallback brand config
  BrandingConfig get activeBranding =>
      _currentCompany?.branding ?? const BrandingConfig();

  CompanyType get companyType =>
      _currentCompany?.type ?? CompanyType.eCommerce;

  bool get isLogisticsCompany => companyType == CompanyType.logistics;
  bool get isEcommerceCompany => companyType == CompanyType.eCommerce;

  /// Helper to convert Hex String (#10B981) to Flutter Color
  static Color hexToColor(String hexString, {Color fallback = const Color(0xFF10B981)}) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Color get primaryColor => hexToColor(activeBranding.primaryColorHex);
  Color get secondaryColor => hexToColor(activeBranding.secondaryColorHex, fallback: const Color(0xFF09140E));
  Color get accentColor => hexToColor(activeBranding.accentColorHex, fallback: const Color(0xFFF59E0B));
  Color get darkSurfaceColor => hexToColor(activeBranding.darkSurfaceHex, fallback: const Color(0xFF0C1F17));
  Color get lightSurfaceColor => hexToColor(activeBranding.lightSurfaceHex, fallback: const Color(0xFFF8FAFC));

  /// Sets the active tenant company and triggers white-label UI theme update.
  void setTenantCompany(CompanyModel company) {
    _currentCompany = company;
    notifyListeners();
  }

  /// Generates dynamic Flutter ThemeData based on active Tenant Branding Configuration
  ThemeData buildDynamicTheme(bool isDarkMode) {
    final baseColor = primaryColor;
    final surfaceColor = isDarkMode ? darkSurfaceColor : lightSurfaceColor;
    final backgroundColor = isDarkMode ? secondaryColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: baseColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: baseColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.outfit(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
