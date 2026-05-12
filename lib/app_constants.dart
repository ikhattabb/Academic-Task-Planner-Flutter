import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ── Spacing ──────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Radius ───────────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // ── Icon Sizes ───────────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;

  // ── Task Card ────────────────────────────────────────────────────────
  static const double cardColorStripWidth = 5.0;
  static const double cardElevation = 0.0;

  // ── Preset Task Colors ───────────────────────────────────────────────
  static const List<Color> taskColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFF00BFA6), // Teal
    Color(0xFFFF6584), // Pink
    Color(0xFFFFB347), // Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Violet
    Color(0xFF26C6DA), // Cyan
    Color(0xFFFF7043), // Deep Orange
  ];

  // ── Notification Offsets ─────────────────────────────────────────────
  static const Duration notifAtEvent = Duration.zero;
  static const Duration notifOneDay = Duration(days: 1);
  static const Duration notifThreeDays = Duration(days: 3);
  static const Duration notifOneWeek = Duration(days: 7);

  // ── Shared Prefs Keys ─────────────────────────────────────────────────
  static const String prefTheme = 'app_theme';
  static const String prefLocale = 'app_locale';

  // ── Isar Collection Names ─────────────────────────────────────────────
  static const String isarTasksCollection = 'tasks';
  static const String isarProgressCollection = 'progress_trackers';
}

/// Semantic label for notification offset — used to map enum → Duration
enum NotificationOffset { atEvent, oneDay, threeDays, oneWeek }

extension NotificationOffsetExtension on NotificationOffset {
  Duration get duration {
    switch (this) {
      case NotificationOffset.atEvent:
        return AppConstants.notifAtEvent;
      case NotificationOffset.oneDay:
        return AppConstants.notifOneDay;
      case NotificationOffset.threeDays:
        return AppConstants.notifThreeDays;
      case NotificationOffset.oneWeek:
        return AppConstants.notifOneWeek;
    }
  }

  String labelKey() {
    switch (this) {
      case NotificationOffset.atEvent:
        return 'atTimeOfEvent';
      case NotificationOffset.oneDay:
        return 'oneDayBefore';
      case NotificationOffset.threeDays:
        return 'threeDaysBefore';
      case NotificationOffset.oneWeek:
        return 'oneWeekBefore';
    }
  }
}