import 'package:flutter/material.dart';

/// Paleta de cores — Tema industrial vermelho/preto (LoadSecure).
abstract class AppColors {
  // --- Backgrounds ---
  static const Color backgroundDark    = Color(0xFF0D0D0D);
  static const Color backgroundMedium  = Color(0xFF121212);
  static const Color backgroundLight   = Color(0xFF1A1A1A);
  static const Color surface           = Color(0xFF1E1E1E);
  static const Color surfaceElevated   = Color(0xFF252525);
  static const Color fieldBackground   = Color(0xFF1C1C1C);

  // --- Accent / Primary — Vermelho ---
  static const Color red               = Color(0xFFE53935);
  static const Color redDark           = Color(0xFFB71C1C);
  static const Color redLight          = Color(0xFFEF5350);
  static const Color redGlow           = Color(0x44E53935);

  // --- Text ---
  static const Color textPrimary       = Color(0xFFFFFFFF);
  static const Color textSecondary     = Color(0xFF9E9E9E);
  static const Color textDisabled      = Color(0xFF616161);
  static const Color textOnAccent      = Color(0xFFFFFFFF);
  static const Color textHint          = Color(0xFF555555);

  // --- Status ---
  static const Color success           = Color(0xFF4CAF50);
  static const Color warning           = Color(0xFFFF9800);
  static const Color error             = Color(0xFFE53935);
  static const Color info              = Color(0xFF2196F3);

  // --- Border & Divider ---
  static const Color border            = Color(0xFF2A2A2A);
  static const Color borderFocused     = Color(0xFF3A3A3A);
  static const Color divider           = Color(0xFF222222);

  // --- Gradients ---
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A0505), Color(0xFF0D0D0D), Color(0xFF0D0D0D)],
    stops: [0.0, 0.35, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF252525)],
  );

  static const RadialGradient redGlowGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.8,
    colors: [Color(0x33E53935), Color(0x00E53935)],
  );
}
