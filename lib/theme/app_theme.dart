import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system: colours, gradients, spacing, radii, typography and
/// the Material 3 [ThemeData]. Every screen draws from here for consistency.
class AppColors {
  // Background gradient stops (top -> bottom)
  static const bgTop = Color(0xFF071633);
  static const bgMid = Color(0xFF0E2A5C);
  static const bgBottom = Color(0xFF1B4A8F);

  static const primary = Color(0xFF2D7DD2);
  static const primaryDark = Color(0xFF1B5BA8);
  static const accent = Color(0xFFFFC65C); // warm yellow highlight
  static const danger = Color(0xFFFF5A5F); // coral / referee
  static const success = Color(0xFF4ECDC4); // teal

  static const surface = Color(0xFF153463);
  static const surfaceLight = Color(0xFF1E4585);
  static const stroke = Color(0xFF0C1B3A);

  static const onSurface = Colors.white;
  static const onSurfaceMuted = Color(0xB3FFFFFF);
  static const onSurfaceFaint = Color(0x66FFFFFF);

  // Vibrant can palette
  static const can1 = Color(0xFFFF6B6B);
  static const can2 = Color(0xFF4ECDC4);
  static const can3 = Color(0xFFFFD166);
  static const can4 = Color(0xFFA06CD5);
}

class AppRadius {
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 36.0;
}

class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
    stops: [0.0, 0.55, 1.0],
  );

  static LinearGradient button(Color base) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, Colors.white, 0.18)!,
          base,
          Color.lerp(base, Colors.black, 0.20)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

  static const surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.surfaceLight, AppColors.surface],
  );
}

class AppText {
  static TextStyle display(double size, {Color color = AppColors.onSurface}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.0,
        height: 1.05,
      );

  static TextStyle heading(double size, {Color color = AppColors.onSurface}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(double size,
          {Color color = AppColors.onSurfaceMuted,
          FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}

class AppTheme {
  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgMid,
      textTheme: GoogleFonts.fredokaTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.primaryDark,
        ),
      ),
    );
  }
}
