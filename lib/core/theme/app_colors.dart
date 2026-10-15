import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary (Royal Indigo / Deep Blue)
  static const Color primaryLight = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primaryContainerLight = Color(0xFFDBEAFE);
  static const Color primaryContainerDark = Color(0xFF1E293B);

  // Secondary Accent (Teal Emerald)
  static const Color secondaryLight = Color(0xFF0D9488);
  static const Color secondaryDark = Color(0xFF14B8A6);
  static const Color secondaryContainerLight = Color(0xFFCCFBF1);
  static const Color secondaryContainerDark = Color(0xFF134E4A);

  // Accent / Warm Amber (Star ratings, urgent alerts)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color accentDark = Color(0xFFD97706);

  // Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Backgrounds & Surfaces (Dark - OLED slate midnight)
  static const Color backgroundDark = Color(0xFF020617);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Feedback & Semantics
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Verified & Trust Badges
  static const Color verifiedBlue = Color(0xFF0284C7);
  static const Color unverifiedGrey = Color(0xFF64748B);

  // Status Colors for Booking Lifecycle
  static const Color statusRequested = Color(0xFFF59E0B); // Amber
  static const Color statusAccepted = Color(0xFF2563EB); // Blue
  static const Color statusDeclined = Color(0xFFDC2626); // Red
  static const Color statusRescheduled = Color(0xFF8B5CF6); // Purple
  static const Color statusCompleted = Color(0xFF16A34A); // Green
  static const Color statusCancelled = Color(0xFF64748B); // Slate
}
