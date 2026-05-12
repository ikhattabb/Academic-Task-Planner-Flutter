import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'task_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification Service
// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized || kIsWeb) return; // Skip on web

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation handled via app's router if needed
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    if (kIsWeb) return true; // No permissions needed on web

    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? true;
  }

  // ── Channel Config ────────────────────────────────────────────────────────

  static const _channel = AndroidNotificationDetails(
    'task_reminders',
    'Task Reminders',
    channelDescription: 'Reminds you about upcoming tasks and assignments',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    playSound: true,
    enableVibration: true,
  );

  static const _notifDetails = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── Schedule notifications for a task ─────────────────────────────────────

  Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (kIsWeb) return; // Skip notifications on web

    await cancelTaskNotifications(task.uuid);

    if (task.deadline == null) return;

    int baseId = task.uuid.hashCode.abs() % 100000;

    Future<void> schedule(int offsetIndex, Duration before, String titleSuffix) async {
      final scheduledTime = task.deadline!.subtract(before);
      if (scheduledTime.isBefore(DateTime.now())) return;

      await _plugin.zonedSchedule(
        baseId + offsetIndex,
        '📚 ${task.title}',
        titleSuffix,
        tz.TZDateTime.from(scheduledTime, tz.local),
        _notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (task.notifyAtEvent) {
      await schedule(0, Duration.zero, 'Your task is due now!');
    }
    if (task.notifyOneDay) {
      await schedule(1, const Duration(days: 1), 'Due tomorrow!');
    }
    if (task.notifyThreeDays) {
      await schedule(2, const Duration(days: 3), 'Due in 3 days');
    }
    if (task.notifyOneWeek) {
      await schedule(3, const Duration(days: 7), 'Due in 1 week');
    }
  }

  // ── Cancel notifications for a task ──────────────────────────────────────

  Future<void> cancelTaskNotifications(String uuid) async {
    if (kIsWeb) return; // Skip on web

    final baseId = uuid.hashCode.abs() % 100000;
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  // ── Cancel all notifications ──────────────────────────────────────────────

  Future<void> cancelAll() async {
    if (kIsWeb) return; // Skip on web

    await _plugin.cancelAll();
  }
}
