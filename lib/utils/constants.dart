import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = 'TaskFlow';

  // API Config (Placeholder for future step)
  static const String apiBaseUrl = 'http://localhost:5000/api'; // Or your deployed backend URL

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Sizing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Responsive breakpoints
  static const double mobileBreakPoint = 600.0;
  static const double tabletBreakPoint = 900.0;

  // Modern Professional Slate Theme Colors
  static const Color primary = Color(0xFF1E293B);      // Slate 800
  static const Color primaryDark = Color(0xFF0F172A);  // Slate 900
  static const Color primaryLight = Color(0xFF334155); // Slate 700
  
  static const Color secondary = Color(0xFF475569);    // Slate 600
  
  static const Color accent = Color(0xFF0EA5E9);       // Sky 500
  static const Color accentDark = Color(0xFF0284C7);   // Sky 600
  
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF64748B);// Slate 500
  
  static const Color error = Color(0xFFEF4444);        // Red 500
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color info = Color(0xFF3B82F6);         // Blue 500

  // Tasks Priority Colors
  static const Color priorityLow = Color(0xFF10B981);    // Emerald
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityHigh = Color(0xFFEF4444);   // Red
}
