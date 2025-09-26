import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String imageBaseUrl = 'http://10.0.2.2:5000/uploads/';

  // JWT Token keys
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';

  // User Types
  static const String studentType = 'Student';
  static const String companyType = 'Company';

  // Colors
  static const Color darkPrimaryColor = Color(0xFF1976D2);
  static const Color lightPrimaryColor = Color(0xFFBBDEFB);
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
}
