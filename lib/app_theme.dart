import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Palette
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4B44C9);
  static const Color accent = Color(0xFF00BFA6);

  // Light Mode
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F8);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightCardBorder = Color(0xFFE8EAF6);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkOnSurface = Color(0xFFF1F1FB);
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF2D2D4A);
  static const Color darkCardBorder = Color(0xFF2A2A45);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

// ─────────────────────────────────────────────────────────────────────────────
// Text Styles
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextTheme latinTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return GoogleFonts.interTextTheme(base);
  }

  /// Cairo font for Arabic — loaded via pubspec assets
  static TextTheme arabicTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return base.apply(fontFamily: 'Cairo');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Builder
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData light({bool isArabic = false}) =>
      _build(Brightness.light, isArabic: isArabic);

  static ThemeData dark({bool isArabic = false}) =>
      _build(Brightness.dark, isArabic: isArabic);

  static ThemeData _build(Brightness brightness, {required bool isArabic}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? AppColors.primaryDark.withOpacity(0.3)
          : AppColors.primaryLight.withOpacity(0.2),
      onPrimaryContainer: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accent.withOpacity(0.15),
      onSecondaryContainer: AppColors.accent,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      surfaceContainerHighest: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      onSurfaceVariant: isDark
          ? AppColors.darkOnSurfaceVariant
          : AppColors.lightOnSurfaceVariant,
      outline: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      error: AppColors.error,
      onError: Colors.white,
      shadow: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
    );

    final textTheme = isArabic
        ? AppTextStyles.arabicTextTheme(brightness)
        : AppTextStyles.latinTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,

      // ── AppBar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // ── Input Decoration ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.darkOnSurfaceVariant
              : AppColors.lightOnSurfaceVariant,
        ),
        hintStyle: TextStyle(
          color: (isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant)
              .withOpacity(0.6),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primary.withOpacity(0.15),
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color:
              isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 8,
      ),

      // ── Drawer ────────────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? AppColors.darkOnSurfaceVariant : Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return isDark ? AppColors.darkSurfaceVariant : Colors.grey[300];
        }),
      ),

      // ── Checkbox ─────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: BorderSide(
          color: isDark
              ? AppColors.darkOnSurfaceVariant
              : AppColors.lightOnSurfaceVariant,
          width: 1.5,
        ),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ── ListTile ─────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceVariant : const Color(0xFF1A1A2E),
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}