import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Color constants
  static const Color primaryColor = Color(0xFFFF6E40);
  static const Color secondaryColor = Color(0xFF2979FF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1976D2);
  
  // Light theme text colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);
  
  // Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF636363);
  
  // Light theme background colors
  static const Color lightBackgroundPrimary = Color(0xFFFFFFFF);
  static const Color lightBackgroundSecondary = Color(0xFFF5F5F5);
  static const Color lightBackgroundTertiary = Color(0xFFEEEEEE);
  
  // Dark theme background colors
  static const Color darkBackgroundPrimary = Color(0xFF121212);
  static const Color darkBackgroundSecondary = Color(0xFF1E1E1E);
  static const Color darkBackgroundTertiary = Color(0xFF2C2C2C);
  
  // Text themes
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      displayMedium: base.displayMedium!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: base.displaySmall!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall!.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: base.labelMedium!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall!.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: lightBackgroundPrimary,
      surface: lightBackgroundSecondary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: lightTextPrimary,
      onSurface: lightTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackgroundPrimary,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundPrimary,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: lightTextPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: lightBackgroundPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackgroundTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        color: lightTextSecondary,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        color: lightTextDisabled,
      ),
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    dividerTheme: const DividerThemeData(
      color: lightBackgroundTertiary,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightBackgroundPrimary,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
  
  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: darkBackgroundPrimary,
      surface: darkBackgroundSecondary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkTextPrimary,
      onSurface: darkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundPrimary,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundPrimary,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: darkTextPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: darkBackgroundSecondary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkBackgroundTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        color: darkTextSecondary,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        color: darkTextDisabled,
      ),
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    dividerTheme: const DividerThemeData(
      color: darkBackgroundTertiary,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackgroundPrimary,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
}