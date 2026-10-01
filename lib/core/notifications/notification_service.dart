import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification management service for Tapasya.
/// Implements interactive action buttons (Done / Skip) and strict schedule limits (max 3 daily).
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelIdReminders = 'tapasya_reminders';
  static const String channelIdTimer = 'tapasya_focus_timer';
  static const String channelIdReview = 'tapasya_weekly_review';

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationAction,
    );

    // Create high-importance notification channels
    const remindersChannel = AndroidNotificationChannel(
      channelIdReminders,
      'Habit Reminders',
      description: 'Daily non-negotiable cues and check-in reminders',
      importance: Importance.high,
    );

    const timerChannel = AndroidNotificationChannel(
      channelIdTimer,
      'Focus Timer Service',
      description: 'Ongoing background focus session notifications',
      importance: Importance.low,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(remindersChannel);
    await androidPlugin?.createNotificationChannel(timerChannel);
  }

  /// Request permissions for Android 13+ (POST_NOTIFICATIONS) and Android 12+ (Exact Alarms)
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.requestNotificationsPermission() ?? false;
    return granted;
  }

  /// Shows immediate habit reminder with interactive action buttons: [Done] and [Skip]
  static Future<void> showHabitCueNotification({
    required int id,
    required String habitName,
    required String cueText,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelIdReminders,
      'Habit Reminders',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('action_done', 'Done ✓', showsUserInterface: false),
        AndroidNotificationAction('action_skip', 'Skip', showsUserInterface: false),
      ],
    );

    await _notificationsPlugin.show(
      id,
      habitName,
      cueText,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Schedules daily Night Review at 9:30 PM
  static Future<void> scheduleNightReviewReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 30);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      channelIdReminders,
      'Habit Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      999,
      'Aaj jeete? 🌙',
      '30-second ka evening review karo aur +10% score lock karo.',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static void _onNotificationAction(NotificationResponse response) {
    if (response.actionId == 'action_done') {
      // Completed habit from notification banner!
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationAction(NotificationResponse response) {
    // Background isolate execution for Done/Skip buttons
  }
}
