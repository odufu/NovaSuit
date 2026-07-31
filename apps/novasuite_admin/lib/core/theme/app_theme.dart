import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accentEmerald,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.textDark,
        outline: AppColors.borderLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surfaceContainerHighest: Color(0xFFEFF6F1),
      ),

      // ── App Bar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        elevation: 1,
        scrolledUnderElevation: 1,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark, size: 22),
      ),

      // ── Text Theme ──────────────────────────────────────────────────────
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(color: AppColors.textDark),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textDark),
        bodySmall: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
        labelLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),

      // ── Input Decoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
        labelStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentEmerald, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.statusCancelled, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.statusCancelled, width: 1.5),
        ),
      ),

      // ── Elevated Button ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentEmerald,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      // ── Data Table ──────────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        headingTextStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentEmerald.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        dataTextStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textDark),
        dividerThickness: 1,
        columnSpacing: 24,
        horizontalMargin: 20,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.accentEmerald.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMuted),
      ),

      // ── Snack Bar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Popup Menu ──────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        textStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textDark),
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Switch ──────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accentEmerald : AppColors.borderLight,
        ),
      ),
    );
  }

  // ─── Dark Theme (OLED Dark Forest) ────────────────────────────────────────
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF132A22);
    const darkBg = Color(0xFF0C1F17);
    const darkBorder = Color(0xFF1E3E33);
    const emerald = Color(0xFF10B981);
    const darkText = Color(0xFFF1F5F9);
    const mutedText = Color(0xFF94A3B8);

    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);

    return base.copyWith(
      primaryColor: emerald,
      scaffoldBackgroundColor: darkBg,

      colorScheme: const ColorScheme.dark(
        primary: emerald,
        secondary: emerald,
        surface: darkSurface,
        onSurface: darkText,
        outline: darkBorder,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surfaceContainerHighest: Color(0xFF0E2419),
      ),

      // ── App Bar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: darkText,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: emerald,
        ),
        iconTheme: const IconThemeData(color: darkText, size: 22),
        shape: const Border(bottom: BorderSide(color: darkBorder, width: 1)),
      ),

      // ── Text Theme ──────────────────────────────────────────────────────
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: darkText, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.outfit(color: darkText, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.outfit(color: darkText, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.outfit(color: darkText, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(color: darkText),
        bodyMedium: GoogleFonts.outfit(color: darkText),
        bodySmall: GoogleFonts.outfit(color: mutedText, fontSize: 12),
        labelLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.outfit(color: mutedText, fontSize: 11, fontWeight: FontWeight.w600),
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),

      // ── Input Decoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0E2419),
        hintStyle: GoogleFonts.outfit(color: mutedText, fontSize: 13),
        labelStyle: GoogleFonts.outfit(color: mutedText, fontSize: 13),
        prefixIconColor: mutedText,
        suffixIconColor: mutedText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: emerald, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),

      // ── Elevated Button ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: emerald,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: emerald,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      // ── Data Table ──────────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF0E2419)),
        headingTextStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: mutedText,
          letterSpacing: 0.5,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emerald.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        dataTextStyle: GoogleFonts.outfit(fontSize: 13, color: darkText),
        dividerThickness: 1,
        columnSpacing: 24,
        horizontalMargin: 20,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        decoration: BoxDecoration(
          color: darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: darkBorder),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF0E2419),
        selectedColor: emerald.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: darkText),
        side: const BorderSide(color: darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
        contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: mutedText),
      ),

      // ── Snack Bar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: GoogleFonts.outfit(color: darkText, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: darkBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Popup Menu ──────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder),
        ),
        textStyle: GoogleFonts.outfit(fontSize: 13, color: darkText),
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Switch ──────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : mutedText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? emerald : darkBorder,
        ),
      ),
    );
  }
}
