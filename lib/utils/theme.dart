// File Path: sreerajp_authenticator/lib/utils/theme.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: App theme built from the chosen accent colour, with raised card shadows

import 'package:material_ui/material_ui.dart';

/// The accent colours a user can choose in Settings. A fixed list, so every
/// choice is tested for contrast. No red: red means "code about to expire".
/// The saved value is the name, so the order here can change safely.
enum AppAccent {
  blue(Color(0xFF2456C9), Color(0xFF7AA2FF)),
  teal(Color(0xFF0F766E), Color(0xFF4FD1C0)),
  indigo(Color(0xFF5B45C4), Color(0xFFA99BFF)),
  green(Color(0xFF2E7D4F), Color(0xFF6FCF97)),
  copper(Color(0xFFA8521E), Color(0xFFE9A26E)),
  graphite(Color(0xFF3D4656), Color(0xFFAEB8C8));

  const AppAccent(this.light, this.dark);

  final Color light;
  final Color dark;

  static AppAccent fromName(String? name) => AppAccent.values.firstWhere(
    (accent) => accent.name == name,
    orElse: () => AppAccent.blue,
  );
}

class AppTheme {
  // Status colors
  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFA726);
  static const errorCoral = Color(0xFFEF5350);

  // Status colors for small text and icons on a 10% tint of the same color.
  // One color cannot reach 4.5 : 1 on both the light and the dark card.
  static Color statusSuccess(Brightness brightness) =>
      brightness == Brightness.dark ? successGreen : const Color(0xFF1B5E20);
  static Color statusWarning(Brightness brightness) =>
      brightness == Brightness.dark ? warningAmber : const Color(0xFF8A5200);
  static Color statusError(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0xFFFF8A80)
      : const Color(0xFFB71C1C);

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

  // Built once per accent, so a rebuild of the app keeps the same theme object.
  static final _lightThemes = <AppAccent, ThemeData>{};
  static final _darkThemes = <AppAccent, ThemeData>{};

  static ThemeData light(AppAccent accent) =>
      _lightThemes.putIfAbsent(accent, () => _buildLight(accent.light));
  static ThemeData dark(AppAccent accent) =>
      _darkThemes.putIfAbsent(accent, () => _buildDark(accent.dark));

  static final lightTheme = light(AppAccent.blue);
  static final darkTheme = dark(AppAccent.blue);

  // LIGHT THEME
  static ThemeData _buildLight(Color accent) => ThemeData(
    useMaterial3: true,
    fontFamilyFallback: fontFamilyFallback,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      primary: accent,
      onPrimary: Colors.white,
      secondary: Color.lerp(accent, Colors.black, 0.18),
      onSecondary: Colors.white,
      surface: surfaceCard,
      onSurface: const Color(0xFF1A1A2E),
      surfaceContainerHighest: backgroundWhite,
      error: errorCoral,
    ),
    scaffoldBackgroundColor: backgroundLight,

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: accent, size: 24),
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
            backgroundColor: accent,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ).copyWith(
            shadowColor: WidgetStateProperty.all(accent.withValues(alpha: 0.4)),
          ),
    ),

    // 3D Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: accent,
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
        borderSide: BorderSide(color: accent, width: 2),
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
  static ThemeData _buildDark(Color accent) => ThemeData(
    useMaterial3: true,
    fontFamilyFallback: fontFamilyFallback,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: const Color(0xFF0D1117),
      secondary: Color.lerp(accent, Colors.black, 0.18),
      surface: const Color(0xFF1C2333),
      onSurface: const Color(0xFFE1E4E8),
      surfaceContainerHighest: const Color(0xFF252D3D),
      error: const Color(0xFFFF6B6B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1117),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: const Color(0xFF0D1117),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: accent, size: 24),
      titleTextStyle: const TextStyle(
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
        backgroundColor: accent,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: accent,
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

  // Layered soft shadows that lift the account card off the page.
  static List<BoxShadow> cardShadows({
    required bool isDark,
    bool isPressed = false,
  }) {
    final color = isDark ? Colors.black : const Color(0xFF141E32);
    if (isPressed) {
      return [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.5 : 0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return [
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.5 : 0.06),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.35 : 0.07),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.6 : 0.14),
        blurRadius: 20,
        offset: const Offset(0, 12),
        spreadRadius: -6,
      ),
    ];
  }

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
