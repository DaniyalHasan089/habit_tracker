import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // no icon for now, using null will use the default app icon
      [
        NotificationChannel(
          channelKey: 'habit_reminders',
          channelName: 'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'streak_achievements',
          channelName: 'Streak Achievements',
          channelDescription: 'Notifications for streak achievements',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'inactivity_reminders',
          channelName: 'Inactivity Reminders',
          channelDescription: 'Notifications for habit inactivity',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required DateTime scheduledTime,
    String? body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: habitId.hashCode,
        channelKey: 'habit_reminders',
        title: 'Habit Reminder: $title',
        body: body ?? 'Time to complete your habit!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  Future<void> cancelHabitReminder(String habitId) async {
    await AwesomeNotifications().cancel(habitId.hashCode);
  }

  Future<void> scheduleStreakNotification({
    required String habitId,
    required String title,
    required int streak,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: habitId.hashCode + 1000, // Offset to avoid conflict with reminders
        channelKey: 'streak_achievements',
        title: 'Achievement Unlocked! 🏆',
        body: '$streak day streak for "$title"! Keep it up!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> scheduleInactivityReminder({
    required String habitId,
    required String title,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: habitId.hashCode + 2000, // Offset to avoid conflict
        channelKey: 'inactivity_reminders',
        title: 'Don\'t Break Your Streak! 🔥',
        body: 'Don\'t forget to complete "$title" today!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> requestNotificationPermissions() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'habit_reminders',
          channelName: 'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: const Color(0xFF9B59B6),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'streak_achievements',
          channelName: 'Streak Achievements',
          channelDescription: 'Notifications for streak achievements',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: const Color(0xFFFFD700),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'inactivity_reminders',
          channelName: 'Inactivity Reminders',
          channelDescription: 'Notifications for habit inactivity',
          defaultColor: const Color(0xFF9B59B6),
          ledColor: const Color(0xFFFF0000),
          importance: NotificationImportance.High,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> createNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'streak_achievements',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
