import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/models/class_session.dart';
import '../../domain/models/deadline.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification initialization warning (desktop/test environment): $e');
    }
  }

  Future<bool> requestPermission() async {
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_alerts',
      'Campus Alerts',
      channelDescription: 'Time-sensitive academic reminders and timer updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Could not show notification: $e');
    }
  }

  Future<void> scheduleDeadlineReminders(Deadline deadline, {required bool enabled}) async {
    if (!enabled || deadline.isCompleted) {
      await cancelDeadlineReminders(deadline.id);
      return;
    }

    final now = DateTime.now();
    final due = deadline.dueDateTime;
    if (due.isBefore(now)) return;

    final baseId = deadline.id.hashCode;

    // 1. 3 days before
    final threeDaysBefore = due.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(now)) {
      await _scheduleLocal(
        id: baseId + 1,
        title: 'Deadline in 3 days',
        body: '${deadline.title} is due in 3 days.',
        scheduledDate: threeDaysBefore,
      );
    }

    // 2. 1 day before
    final oneDayBefore = due.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await _scheduleLocal(
        id: baseId + 2,
        title: 'Deadline Tomorrow',
        body: '${deadline.title} is due tomorrow.',
        scheduledDate: oneDayBefore,
      );
    }

    // 3. Morning of due date
    final morningOf = DateTime(due.year, due.month, due.day, 8, 0);
    if (morningOf.isAfter(now) && morningOf.isBefore(due)) {
      await _scheduleLocal(
        id: baseId + 3,
        title: 'Due Today',
        body: '${deadline.title} is due today at ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}.',
        scheduledDate: morningOf,
      );
    }
  }

  Future<void> cancelDeadlineReminders(String deadlineId) async {
    final baseId = deadlineId.hashCode;
    try {
      await _notificationsPlugin.cancel(id: baseId + 1);
      await _notificationsPlugin.cancel(id: baseId + 2);
      await _notificationsPlugin.cancel(id: baseId + 3);
    } catch (_) {}
  }

  Future<void> _scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'campus_deadlines',
            'Academic Deadlines',
            channelDescription: 'Reminders for assignments, quizzes, vivas and exams',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Schedule notification fallback or limitation on platform: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
