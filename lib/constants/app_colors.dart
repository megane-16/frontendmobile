import 'package:flutter/material.dart';

class AppColors {
  // Couleurs Principales (Brand)
  static const Color primary = Color(0xFF6366F1);   // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFEC4899); // Rose

  // Couleurs de Fond et Base
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white24 = Colors.white24;
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Palette Slate (Gris neutres modernes)
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  
  // Status & Feedbacks
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Couleurs spécifiques UI
  static const Color amber = Color(0xFFFBBF24); // Pour les étoiles
  static const Color purple = Color(0xFFA855F7);
  static const Color orange = Color(0xFFF97316);
  static const Color green = Color(0xFF10B981);

  // Gradients
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> infoGradient = [Color(0xFF1D4ED8), Color(0xFF60A5FA)];
}
