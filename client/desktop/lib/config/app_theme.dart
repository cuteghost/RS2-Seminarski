// Nocturne design tokens za desktop klijenta, prevedeni iz
// `Desktop-redesign/_ds/nocturne-.../styles.css` + `readme.md`.
//
// Ovaj fajl nosi ISKLJUČIVO tokene -> ThemeData. Nikakve odluke o
// ekranima/widgetima ne žive ovdje; one se donose po ekranu, prema
// mockupima u `Desktop-redesign/eBooking Admin.dc.html`.
//
// Tokeni su namjerno identični mobilnom klijentu (`client/mobile/lib/config/
// app_theme.dart`) — isti design system, ista paleta. Razlika je isključivo
// u gustoći: desktop koristi kompaktniji spacing scale (density 0.70x iz
// readme.md) jer prikazuje tabelarne podatke, dok je mobilni prozračniji.
import 'package:flutter/material.dart';

/// Sirovi color tokeni. U widgetima preferirati `Theme.of(context)`
/// (colorScheme, textTheme); direktno posezati za ovima samo kad dizajn
/// traži nijansu koju ColorScheme ne izlaže (npr. tint chat balončića).
class AppColors {
  AppColors._();

  // ── Grounds ────────────────────────────────────────────────────────────
  static const bg = Color(0xFF161826); // --color-bg
  static const surface = Color(0xFF232532); // --color-surface (kartice, inputi)
  static const surfaceRaised = Color(0xFF1B1D2C); // sidebar / trake

  // ── Text ───────────────────────────────────────────────────────────────
  static const text = Color(0xFFE9E9ED); // --color-text
  static const textSecondary = Color(0xFF9397AB); // neutral-500
  static const textTertiary = Color(0xFF75798C); // neutral-600

  // ── Accent (mono shema — akcenat kao linija/sjaj, nikada kao poplava) ──
  static const accent = Color(0xFF9184D9); // --color-accent
  static const accentText = Color(0xFFD2CEFD); // accent-300, siguran za body tekst
  static const accentLink = Color(0xFFB5ABFC); // accent-400, linkovi
  static const accentTint = Color(0xFF2B2741); // accent-900, chip / avatar bg
  static const accentBorder = Color(0xFF423A6A); // accent-800, tinted border
  static const accentBar = Color(0xFF5D5294); // accent-700, barovi u grafovima

  // ── Neutral ramp ───────────────────────────────────────────────────────
  static const neutral700 = Color(0xFF595D6C);
  static const neutral800 = Color(0xFF3F424D);
  static const neutral900 = Color(0xFF292B31);

  // ── Borders & dividers ─────────────────────────────────────────────────
  static const border = neutral800;
  static const borderStrong = neutral700;
  static Color divider = text.withValues(alpha: 0.10);

  // ── Status (van formalnog mono ramp-a — koristiti štedljivo) ───────────
  static const error = Color(0xFFF0A0A0);
  static const success = Color(0xFF7FC9A0);
  static const warning = Color(0xFFE0C088);

  // ── Radii (readme.md: radius 8px baked into scale) ─────────────────────
  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 14.0;
}

/// Spacing scale, density 0.70x — direktno iz `styles.css` `--space-*`.
/// Koristiti ove konstante umjesto sirovih brojeva.
class AppSpace {
  AppSpace._();

  static const x1 = 2.8;
  static const x2 = 5.6;
  static const x3 = 8.4;
  static const x4 = 11.2;
  static const x6 = 16.8;
  static const x8 = 22.4;
  static const x12 = 33.6;
}

class AppTheme {
  AppTheme._();

  static const fontFamily = 'Inter';

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
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

    // Type scale iz styles.css (h1 42 / h2 32 / h3 25 / h4 20 / h5 16 / h6 13),
    // skaliran naniže za desktop gustoću: naslovi ekrana su h2-h3 nivo.
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.48,
        height: 1.12,
        color: AppColors.text,
      ),
      // Naslov ekrana ("Dashboard", "Properties"…)
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 25,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.37,
        height: 1.15,
        color: AppColors.text,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        color: AppColors.text,
      ),
      // .card-title
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.text,
      ),
      // Osnovni tekst tabela / inputa — .table i .input su oba 14px
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      ),
      // .card-body / meta
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      // .card-kicker — 10px / .1em / uppercase / accent.
      // `.toUpperCase()` pozvati na stringu; TextStyle to ne može.
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: AppColors.accent,
      ),
      // .table th — 11px / .08em / uppercase / 60% text
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.88,
        color: AppColors.textSecondary,
      ),
      // .btn — 14px / w500
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
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
      visualDensity: VisualDensity.compact,

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

      // Design system: "the primary is an accent outline, never a fill".
      // Primarne akcije = OutlinedButton.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentText,
          side: const BorderSide(color: AppColors.accent, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentLink,
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Zadržano konfigurisano (disabled opacity, shape) za slučaj da ekran
      // stvarno treba ispunjenu kontrolu — ali pravilo sistema je "never a
      // flood": prvo posegnuti za OutlinedButton.
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
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        // Upute 4: validacijske poruke ISPOD kontrole, ne unutar polja.
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          height: 1.3,
        ),
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

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.text,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        width: 420,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: AppColors.text,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.neutral900,
        circularTrackColor: Colors.transparent,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.neutral700),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(8),
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 18),
    );
  }
}
