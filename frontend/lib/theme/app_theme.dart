import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        onPrimary: Colors.white,
        secondary: AppConstants.accentColor,
        onSecondary: Colors.white,
        error: AppConstants.errorColor,
        onError: Colors.white,
        background: Colors.white,
        onBackground: AppConstants.primaryTextColor,
        surface: Colors.white,
        onSurface: AppConstants.primaryTextColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: AppConstants.headingStyle,
      ),
      textTheme: TextTheme(
        titleLarge: AppConstants.headingStyle.copyWith(color: AppConstants.primaryTextColor),
        titleMedium: AppConstants.subheadingStyle.copyWith(color: AppConstants.primaryTextColor),
        bodyMedium: AppConstants.bodyStyle.copyWith(color: AppConstants.secondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.lightPrimaryColor.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
