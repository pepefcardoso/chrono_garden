import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(
    0xFF4CAF50,
  );
  static const Color secondary = Color(
    0xFF795548,
  );
  static const Color tertiary = Color(
    0xFF00E5FF,
  );
  static const Color neutral = Color(
    0xFFF1F8E9,
  );

  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFF002B30);
  static const Color onBackground = Color(0xFF3E2723);
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color tertiarySubtle = Color(
    0x3300E5FF,
  );
  static const Color tertiaryOverlay = Color(
    0x1A00E5FF,
  );
  static const Color shadowBrown = Color(0x22795548);
}

abstract final class AppTextStyles {
  static const TextStyle hugeCounter = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 48,
    color: AppColors.onBackground,
    letterSpacing: -1.5,
  );

  static const TextStyle levelTitle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: AppColors.onBackground,
  );

  static const TextStyle hudLabel = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.onBackground,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyDefault = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.onBackground,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.secondary,
    letterSpacing: 0.5,
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.neutral,
        onSurface: AppColors.onBackground,
      ),
      scaffoldBackgroundColor: AppColors.neutral,
      fontFamily: 'PlusJakartaSans',
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          textStyle: AppTextStyles.buttonLabel,
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          side: const BorderSide(color: AppColors.tertiary, width: 2),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          textStyle: AppTextStyles.buttonLabel.copyWith(
            color: AppColors.tertiary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: AppColors.shadowBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.tertiary,
        thumbColor: AppColors.tertiary,
        inactiveTrackColor: AppColors.tertiarySubtle,
        overlayColor: AppColors.tertiaryOverlay,
        trackHeight: 4,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.levelTitle,
      ),

      iconTheme: const IconThemeData(color: AppColors.secondary, size: 24),
    );
  }
}
