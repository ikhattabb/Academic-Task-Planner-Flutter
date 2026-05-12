import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Extensions
// ─────────────────────────────────────────────────────────────────────────────

extension ColorX on Color {
  /// Returns black or white depending on luminance (for readable text on top)
  Color get contrastColor {
    return computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
  }

  Color withSaturationBoost(double factor) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withSaturation((hsl.saturation * factor).clamp(0.0, 1.0))
        .toColor();
  }

  Color get lighter => Color.lerp(this, Colors.white, 0.35)!;
  Color get darker => Color.lerp(this, Colors.black, 0.35)!;

  /// Soft translucent version for backgrounds
  Color get softBackground => withOpacity(0.12);
}

// ─────────────────────────────────────────────────────────────────────────────
// DateTime Extensions
// ─────────────────────────────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isOverdue => isBefore(DateTime.now());

  String toReadableDate({bool includeTime = true, String locale = 'en'}) {
    if (includeTime) {
      return DateFormat('MMM d, yyyy • h:mm a', locale).format(this);
    }
    return DateFormat('MMM d, yyyy', locale).format(this);
  }

  String toSmartLabel({required String locale}) {
    if (isToday) return locale == 'ar' ? 'اليوم' : 'Today';
    if (isTomorrow) return locale == 'ar' ? 'غداً' : 'Tomorrow';
    return toReadableDate(locale: locale);
  }

  String toTimeOnly({String locale = 'en'}) {
    return DateFormat('h:mm a', locale).format(this);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext Extensions
// ─────────────────────────────────────────────────────────────────────────────

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  void showSnack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// String Extensions
// ─────────────────────────────────────────────────────────────────────────────

extension StringX on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}