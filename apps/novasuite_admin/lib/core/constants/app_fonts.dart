import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  static TextStyle heading({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.outfit(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  static TextStyle body({Color? color, double? fontSize, FontWeight? fontWeight, double? height}) {
    return GoogleFonts.inter(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      height: height,
    );
  }

  static TextStyle mono({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}
