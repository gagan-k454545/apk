import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Reference Palette Tokens (Cream & Forest/Sage/Gold/Peach) ──
  static const Color creamBase = Color(0xFFF1E8DA); // warm sand page background
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color creamCardAlt = Color(0xFFFBF7F0);
  static const Color creamPedestal = Color(0xFFEADBCA);

  static const Color mossDark = Color(0xFF1E3A2B);
  static const Color mossPrimary = Color(0xFF244835);
  static const Color sageMedium = Color(0xFF456B52);
  static const Color sageLight = Color(0xFFEAF1E9);
  static const Color sageBorder = Color(0xFFD0E0CE);
  static const Color sageOnContainer = Color(0xFF1F3D27);

  static const Color warmBeige = Color(0xFFF6ECE1);
  static const Color softPeach = Color(0xFFFBF3EB);
  static const Color peachBorder = Color(0xFFEEDDCE);
  static const Color peachAccent = Color(0xFFB86A38);

  static const Color warmGold = Color(0xFFD69A2D);
  static const Color goldLight = Color(0xFFFDF7E7);
  static const Color goldBorder = Color(0xFFE8CF96);
  static const Color goldText = Color(0xFF7E540C);

  static const Color textHeadline = Color(0xFF1A2A20);
  static const Color textBody = Color(0xFF5A6C60);
  static const Color textMuted = Color(0xFF88998C);
  static const Color hairline = Color(0xFFE8E2D5);

  static const Color seedColor = Color(0xFF244835);

  // ── Light Theme ──
  static const Color lightPrimary = Color(0xFF244835); // Deep Moss Green
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEAF1E9); // Soft Sage
  static const Color lightOnPrimaryContainer = Color(0xFF1F3D27);

  static const Color lightSecondary = Color(0xFF456B52); // Muted Sage
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFBF3EB); // Warm Peach
  static const Color lightOnSecondaryContainer = Color(0xFF4E331E);

  static const Color lightTertiary = Color(0xFFD69A2D); // Warm Gold
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFDF7E7);
  static const Color lightOnTertiaryContainer = Color(0xFF7E540C);

  static const Color lightSuccess = Color(0xFF2E7D32);

  static const Color lightError = Color(0xFFC62828);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFDEDED);
  static const Color lightOnErrorContainer = Color(0xFF5F2120);

  static const Color lightSurface = Color(0xFFF1E8DA); // warm sand page background
  static const Color lightOnSurface = Color(0xFF14231C); // dark organic spruce
  static const Color lightSurfaceVariant = Color(0xFFF5EFE6); // Warm Beige
  static const Color lightOnSurfaceVariant = Color(0xFF5A6C60);

  static const Color lightOutline = Color(0xFFE8E2D5);
  static const Color lightOutlineVariant = Color(0xFFDDD6C7);
  static const Color lightShadow = Color(0x0C23382B);
  static const Color lightScrim = Color(0xFF000000);
  static const Color lightInverseSurface = Color(0xFF2A3830);
  static const Color lightInverseOnSurface = Color(0xFFF6F8F6);
  static const Color lightInversePrimary = Color(0xFF88B395);

  // ── Dark Theme (Muted Forest Night & Warm Gold) ──
  static const Color darkPrimary = Color(0xFF88B395);
  static const Color darkOnPrimary = Color(0xFF11261B);
  static const Color darkPrimaryContainer = Color(0xFF1F3A2B);
  static const Color darkOnPrimaryContainer = Color(0xFFD6E8DB);

  static const Color darkSecondary = Color(0xFFABC4B3);
  static const Color darkOnSecondary = Color(0xFF1A2B20);
  static const Color darkSecondaryContainer = Color(0xFF2F4436);
  static const Color darkOnSecondaryContainer = Color(0xFFE5EDE6);

  static const Color darkTertiary = Color(0xFFE2B75E);
  static const Color darkOnTertiary = Color(0xFF382903);
  static const Color darkTertiaryContainer = Color(0xFF533F10);
  static const Color darkOnTertiaryContainer = Color(0xFFFDEECB);

  static const Color darkSuccess = Color(0xFF66BB6A);

  static const Color darkError = Color(0xFFEF5350);
  static const Color darkOnError = Color(0xFF3B0B0A);
  static const Color darkErrorContainer = Color(0xFF5C1B1A);
  static const Color darkOnErrorContainer = Color(0xFFFFCDD2);

  static const Color darkSurface = Color(0xFF141C17);
  static const Color darkOnSurface = Color(0xFFEAEFEA);
  static const Color darkSurfaceVariant = Color(0xFF202A23);
  static const Color darkOnSurfaceVariant = Color(0xFFA2B0A5);

  static const Color darkOutline = Color(0xFF37463B);
  static const Color darkOutlineVariant = Color(0xFF26332A);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkScrim = Color(0xFF000000);
  static const Color darkInverseSurface = Color(0xFFEAEFEA);
  static const Color darkInverseOnSurface = Color(0xFF141C17);
  static const Color darkInversePrimary = Color(0xFF244835);
}
