import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default to system; will be overridden by _loadSavedTheme
    _loadSavedTheme();
    return ThemeMode.system;
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefTheme);
    if (saved != null) {
      state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final newMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefTheme,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefTheme,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  bool get isDark => state == ThemeMode.dark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Locale Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('en');
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefLocale);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLocale, locale.languageCode);
  }

  Future<void> toggle() async {
    final newLocale =
        state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    await setLocale(newLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isRTL => isArabic;
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);