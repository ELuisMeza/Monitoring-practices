import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryLight = Color(0xFF818CF8);

  static const secondary = Color(0xFF0D9488);
  static const secondaryLight = Color(0xFF2DD4BF);

  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const surface = Color(0xFFF8FAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const background = Color(0xFFF1F5F9);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  static const gradientStart = Color(0xFF4F46E5);
  static const gradientEnd = Color(0xFF7C3AED);

  static const gradientSecondaryStart = Color(0xFF0D9488);
  static const gradientSecondaryEnd = Color(0xFF0891B2);

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientSecondaryStart, gradientSecondaryEnd],
      );

  static LinearGradient get subtleGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primary.withValues(alpha: 0.08),
          background,
        ],
      );
}
