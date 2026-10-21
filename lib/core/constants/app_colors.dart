import 'package:flutter/material.dart';

/// App color palette matching design-system/learn-korean/MASTER.md.
/// Cheerful Sky Blue (Single-Tone 60-30-10 color ratio):
/// - 60% Dominant Base: Airy Ice Blue (#F0F9FF) light / Deep Midnight Sky (#0C4A6E) dark
/// - 30% Structural Surfaces & Cards: Pure White (#FFFFFF) cards, Soft Sky-100 (#E0F2FE) containers
/// - 10% Unified Accent: Cheerful Bright Sky Blue (#0EA5E9) primary, Ocean Sky (#0284C7) secondary
/// - Zero gradients, zero glassmorphism, flat solid fills.
class AppColors {
  // Brand colors — Single-tone Cheerful Sky Blue family
  static const Color primary = Color(0xFF0EA5E9); // Sky-500 (Cheerful Bright Sky Blue)
  static const Color primaryContainer = Color(0xFFE0F2FE); // Sky-100 (Soft Sky Tint)
  static const Color secondary = Color(0xFF0284C7); // Sky-600 (Crisp Ocean Sky)
  static const Color secondaryContainer = Color(0xFFF0F9FF); // Sky-50 (Airy Sky Tint)
  static const Color accentYellow = Color(0xFF38BDF8); // Sky-400 (Bright Sunny Sky)
  static const Color accentPurple = Color(0xFF0369A1); // Sky-700 (Deep Sky Accent)

  // Feedback colors
  static const Color success = Color(0xFF10B981); // Cheerful Emerald
  static const Color error = Color(0xFFF43F5E); // Friendly Coral Rose
  static const Color starGold = Color(0xFF0EA5E9); // Sky-500

  // Light surfaces ("Airy Sky Morning")
  static const Color lightBg = Color(0xFFF0F9FF); // Sky-50 cheerful airy background
  static const Color lightCard = Color(0xFFFFFFFF); // Solid pure white card
  static const Color lightCardBorder = Color(0xFFBAE6FD); // Sky-200 soft border
  static const Color lightTextPrimary = Color(0xFF0C4A6E); // Sky-900 (High contrast)
  static const Color lightTextSecondary = Color(0xFF0369A1); // Sky-700

  // Dark surfaces ("Starry Sky Study")
  static const Color darkBg = Color(0xFF082F49); // Sky-950
  static const Color darkCard = Color(0xFF0C4A6E); // Sky-900
  static const Color darkCardBorder = Color(0xFF0369A1); // Sky-700
  static const Color darkTextPrimary = Color(0xFFF0F9FF); // Sky-50
  static const Color darkTextSecondary = Color(0xFF7DD3FC); // Sky-300

  // Flat subtle card shadows (No glass, no glow)
  static const List<BoxShadow> lightBentoShadow = [
    BoxShadow(
      color: Color(0x0A0284C7),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkBentoShadow = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];
}
