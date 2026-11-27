import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFC96A24);
  static const Color sacredGold = Color(0xFFD4A64A);
  static const Color deepMaroon = Color(0xFF6B2635);
  static const Color darkBrown = Color(0xFF3A2418);

  // Surfaces
  static const Color warmCream = Color(0xFFFFF8EC);
  static const Color softBeige = Color(0xFFF6EFE3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFBF4);

  // Text
  static const Color textPrimary = Color(0xFF241A15);
  static const Color textSecondary = Color(0xFF5C4A3D);
  static const Color textMuted = Color(0xFF8A7464);
  static const Color textOnDark = Color(0xFFFFF8EC);

  // Semantic
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFD4A017);
  static const Color info = Color(0xFF2F6F9F);

  // Status
  static const Color statusPending = Color(0xFFD4A017);
  static const Color statusAccepted = Color(0xFFB8860B);
  static const Color statusUpcoming = Color(0xFF7B5EA7);
  static const Color statusInProgress = Color(0xFFC96A24);
  static const Color statusCompleted = Color(0xFF2E7D5B);
  static const Color statusCancelled = Color(0xFFC0392B);
  static const Color statusRejected = Color(0xFF5A524C);

  // Dark mode
  static const Color darkBg = Color(0xFF17120F);
  static const Color darkSurface = Color(0xFF241A15);
  static const Color darkCard = Color(0xFF33241C);
  static const Color darkBorder = Color(0xFF4A3728);

  // Borders & shadows
  static const Color border = Color(0xFFE8DCC8);
  static const Color borderStrong = Color(0xFFD4C4A8);
  static const Color divider = Color(0xFFEDE3D2);
  static const Color shimmerBase = Color(0xFFEDE3D2);
  static const Color shimmerHighlight = Color(0xFFF8F2E8);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, sacredGold],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A2418), Color(0xFF6B2635), Color(0xFFC96A24)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient goldSoftGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33D4A64A), Color(0x00D4A64A)],
  );
}
