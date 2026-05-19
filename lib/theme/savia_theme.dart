import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'savia_colors.dart';

abstract final class SaviaTheme {
  static const _radius = 12.0;

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SaviaColors.background,
      colorScheme: const ColorScheme.dark(
        primary: SaviaColors.primary,
        onPrimary: SaviaColors.onPrimary,
        secondary: SaviaColors.primary,
        surface: SaviaColors.surface,
        onSurface: SaviaColors.textPrimary,
        error: SaviaColors.error,
        outline: SaviaColors.border,
      ),
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: SaviaColors.background,
        foregroundColor: SaviaColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SaviaColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: SaviaColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: SaviaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: SaviaColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SaviaColors.inputFill,
        hintStyle: const TextStyle(color: SaviaColors.textHint),
        labelStyle: const TextStyle(color: SaviaColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: SaviaColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: SaviaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: SaviaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: SaviaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: SaviaColors.error),
        ),
        prefixIconColor: SaviaColors.textMuted,
        suffixIconColor: SaviaColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SaviaColors.primary,
          foregroundColor: SaviaColors.onPrimary,
          disabledBackgroundColor: SaviaColors.border,
          disabledForegroundColor: SaviaColors.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SaviaColors.textSecondary,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SaviaColors.primary,
        foregroundColor: SaviaColors.onPrimary,
        elevation: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SaviaColors.onPrimary;
          }
          return SaviaColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SaviaColors.primary;
          }
          return SaviaColors.border;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SaviaColors.primary;
          }
          return SaviaColors.inputFill;
        }),
        side: const BorderSide(color: SaviaColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SaviaColors.surfaceElevated,
        labelStyle: const TextStyle(color: SaviaColors.textPrimary, fontSize: 13),
        side: const BorderSide(color: SaviaColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        selectedColor: SaviaColors.primary.withValues(alpha: 0.25),
        checkmarkColor: SaviaColors.primary,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: SaviaColors.primary,
        unselectedLabelColor: SaviaColors.textMuted,
        indicatorColor: SaviaColors.primary,
        dividerColor: SaviaColors.border,
      ),
      dividerTheme: const DividerThemeData(
        color: SaviaColors.border,
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: SaviaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: SaviaColors.border),
        ),
        textStyle: const TextStyle(color: SaviaColors.textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SaviaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SaviaColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: SaviaColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: SaviaColors.surfaceElevated,
        contentTextStyle: TextStyle(color: SaviaColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SaviaColors.primary,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: SaviaColors.textMuted,
        textColor: SaviaColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: SaviaColors.textMuted),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: SaviaColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: SaviaColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: SaviaColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: SaviaColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: SaviaColors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: SaviaColors.textMuted, fontSize: 12),
        labelSmall: TextStyle(
          color: SaviaColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
