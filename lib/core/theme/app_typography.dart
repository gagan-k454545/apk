import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme(bool isDark) {
    final Color textColor = isDark ? const Color(0xFFEAEFEA) : const Color(0xFF14231C);
    final Color secondaryTextColor = isDark ? const Color(0xFFA2B0A5) : const Color(0xFF4B5550);

    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: textColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: textColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: secondaryTextColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: textColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: secondaryTextColor,
      ),
    );
  }

  /// High-contrast editorial display serif strictly for the Hero Headline.
  /// Section 4.3: Playfair Display 800, tight, letter-spacing -0.5px.
  static TextStyle heroHeadline({Color? color, double fontSize = 38}) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: -0.5,
      color: color,
    );
  }

  /// Stat number with tabular figures (Section 4.3).
  static TextStyle statNumber({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
