// File Path: sreerajp_authenticator/lib/utils/theme.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: Enhanced theme with vibrant colors and professional 3D neumorphic design

import 'package:material_ui/material_ui.dart';

class AppTheme {
  // MODERN VIBRANT COLOR PALETTE
  // Dark enough for small text and white-on-blue to pass 4.5 : 1 (§7.2).
  static const primaryBlue = Color(0xFF2B6CB8);
  static const deepBlue = Color(0xFF2E5C8A);
  static const mintGreen = Color(0xFF6BCF9F);
  static const sageGreen = Color(0xFF5FA575);
  static const lavender = Color(0xFF9C88FF);
  static const goldAccent = Color(0xFFFFD700);

  // Status colors
  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFA726);
  static const errorCoral = Color(0xFFEF5350);

  // About-screen signature badge heart (guideline.md §1.7)
  static const heartRed = Color(0xFFE53935);

  // Malayalam and Devanagari (Sanskrit) glyphs are not on every device, so
  // the bundled Noto fonts are the fallback (engineering standard §8.3.3).
  static const fontFamilyFallback = <String>[
    'NotoSansMalayalam',
    'NotoSansDevanagari',
  ];

  // Background colors
  static const backgroundLight = Color(0xFFF5F7FA);
  static const backgroundWhite = Color(0xFFFDFEFF);
  static const surfaceCard = Color(0xFFFFFFFF);

  // LIGHT THEME
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamilyFallback: fontFamilyFallback,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: mintGreen,
      onSecondary: Colors.white,
      tertiary: lavender,
      surface: surfaceCard,
      onSurface: const Color(0xFF1A1A2E),
      surfaceContainerHighest: backgroundWhite,
      error: errorCoral,
      primaryContainer: const Color(0xFFD4E4F7),
      secondaryContainer: const Color(0xFFD4F5E3),
    ),
    scaffoldBackgroundColor: backgroundLight,

    // Enhanced AppBar with gradient
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: deepBlue, size: 24),
      titleTextStyle: const TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),

    // Professional 3D card theme
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      color: surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // 3D elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            foregroundColor: Colors.white,
            backgroundColor: primaryBlue,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ).copyWith(
            shadowColor: WidgetStateProperty.all(
              primaryBlue.withValues(alpha: 0.4),
            ),
          ),
    ),

    // 3D Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: mintGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE4EA), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE4EA), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF374151),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: Color(0xFF4B5563), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
    ),

    dividerColor: const Color(0xFFE5E7EB),
    disabledColor: const Color(0xFFD1D5DB),
  );

  // DARK THEME
  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamilyFallback: fontFamilyFallback,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF64B5F6),
      onPrimary: const Color(0xFF0D1117),
      secondary: const Color(0xFF81C784),
      surface: const Color(0xFF1C2333),
      onSurface: const Color(0xFFE1E4E8),
      surfaceContainerHighest: const Color(0xFF252D3D),
      error: const Color(0xFFFF6B6B),
      primaryContainer: const Color(0xFF1E3A5F),
      secondaryContainer: const Color(0xFF2D4A3D),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1117),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0D1117),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFF64B5F6), size: 24),
      titleTextStyle: TextStyle(
        color: Color(0xFFE1E4E8),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      color: const Color(0xFF1C2333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: const Color(0xFF0D1117),
        backgroundColor: const Color(0xFF64B5F6),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF81C784),
      foregroundColor: const Color(0xFF0D1117),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFE1E4E8),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: Color(0xFFE1E4E8),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Color(0xFFB1BAC4), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF8B949E), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF6E7681), fontSize: 12),
    ),
  );

  // PROFESSIONAL 3D NEUMORPHIC DECORATION
  static BoxDecoration get3DDecoration({
    required BuildContext context,
    bool isPressed = false,
    Color? backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? const Color(0xFF1C2333) : const Color(0xFFF5F7FA));

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFE0E7FF).withValues(alpha: 0.6),
        width: 1,
      ),
      boxShadow: isPressed
          ? [
              // Pressed state - subtle inner shadow effect
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0xFFB8C5D6).withValues(alpha: 0.4),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ]
          : [
              // Normal state - prominent 3D effect
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : const Color(0xFFB8C5D6).withValues(alpha: 0.5),
                offset: const Offset(8, 8),
                blurRadius: 16,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDark
                    ? const Color(0xFF2A3447).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                offset: const Offset(-6, -6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              // Additional depth shadow
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFFD1D9E6).withValues(alpha: 0.3),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
    );
  }
}
