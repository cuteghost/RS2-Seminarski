// Nocturne design tokens, translated from
// `Mobile redesign scope/_ds/nocturne-.../styles.css` + `readme.md`.
//
// This file only carries tokens -> ThemeData. No screen/widget decisions
// live here; those get made per-screen against the mockups in
// `Mobile redesign scope/eBooking Redesign.dc.html`.
import 'package:flutter/material.dart';

/// Raw colour tokens. Prefer [AppTheme.dark] properties (colorScheme, etc.)
/// in widgets; reach for these directly only when a design calls for a
/// tint the ColorScheme doesn't expose (e.g. the chat bubble accent tint).
class AppColors {
  AppColors._();

  // Grounds
  static const bg = Color(0xFF161826); // --color-bg
  static const surface = Color(0xFF232532); // --color-surface (cards, inputs)
  static const surfaceRaised = Color(0xFF1B1D2C); // bottom nav / bottom bars

  // Text
  static const text = Color(0xFFE9E9ED); // --color-text
  static const textSecondary = Color(0xFF9397AB); // neutral-500
  static const textTertiary = Color(0xFF75798C); // neutral-600

  // Accent (mono scheme -- one accent voice, used as line/glow, never a flood)
  static const accent = Color(0xFF9184D9); // --color-accent
  static const accentText = Color(0xFFD2CEFD); // accent-300, safe for body-size text
  static const accentLink = Color(0xFFB5ABFC); // accent-400, links / "See all"
  static const accentTint = Color(0xFF2B2741); // accent-900, filled chip / avatar bg

  // Borders & dividers
  static const border = Color(0xFF3F424D); // neutral-800
  static const borderStrong = Color(0xFF595D6C); // neutral-700
  static Color divider = text.withValues(alpha: 0.10);

  // Status (outside the formal mono ramp -- used sparingly, e.g. "Live" dot)
  static const error = Color(0xFFF0A0A0);
  static const success = Color(0xFF7FC9A0);

  // Radii
  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 14.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const fontFamily = 'Inter';

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.bg,
      secondary: AppColors.accent,
      onSecondary: AppColors.bg,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.error,
      onError: AppColors.bg,
      outline: AppColors.border,
    );

    final textTheme = const TextTheme(
      // "Screen title" -- 26 / w500 / -0.02em
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: AppColors.text,
      ),
      // "Section title" -- 19 / w500
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
      // "Body copy" -- 14.5 / w400
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      ),
      // "Meta and captions" -- 12.5 / w400 / secondary
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      // "Group label" -- 11.5 / w400 / .08em / uppercase / tertiary
      // Apply `.toUpperCase()` on the string yourself; TextStyle can't do it.
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.9,
        color: AppColors.textTertiary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.accentText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),

      // Design system: "primary is an accent outline, never a fill."
      // Use OutlinedButton for primary actions (Continue, Reserve, Search...).
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentText,
          side: const BorderSide(color: AppColors.accent, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Ghost / secondary actions (Facebook, Google buttons on login, etc.)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentLink,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Kept configured (disabled opacity, shape) in case a screen needs a
      // filled control -- but the system's rule is "never a flood": default
      // to OutlinedButton first and only reach for this with a real reason.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Design system uses a 4-destination bottom bar w/ a real selected
      // state, 64px + safe area, instead of the current 48px row.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        indicatorColor: Colors.transparent,
        height: 64,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.accent : AppColors.textTertiary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 10.5,
            color: selected ? AppColors.accentLink : AppColors.textTertiary,
          );
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: AppColors.text, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.5,
          color: AppColors.textSecondary,
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    );
  }
}
