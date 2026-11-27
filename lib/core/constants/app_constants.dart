import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Ganagaseva';
  static const String tagline = 'Seva • Shraddha • Sanskar';
  static const String countryCode = '+91';
  static const int otpLength = 6;
  static const int otpResendSeconds = 30;
  static const String mockOtp = '123456';
  static const String currencySymbol = '₹';
  static const String bookingPrefix = 'GS-';
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  static const double touchTarget = 48;
  static const double cardRadius = 16;
  static const double buttonRadius = 14;
  static const double chipRadius = 20;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF3A2418).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: const Color(0xFF3A2418).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> fab = [
    BoxShadow(
      color: const Color(0xFFC96A24).withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
