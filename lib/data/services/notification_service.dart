import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle when notification is tapped
      },
    );
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    bool? androidGranted;
    if (androidImplementation != null) {
      androidGranted = await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    bool? iosGranted;
    if (iosImplementation != null) {
      iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (kIsWeb) return;
    
    bool enabled = true;
    String filter = 'All';
    try {
      if (Hive.isBoxOpen('profile_box')) {
        final box = Hive.box('profile_box');
        enabled = box.get('notif_enabled', defaultValue: true) as bool;
        filter = box.get('notif_filter', defaultValue: 'All') as String;
      }
    } catch (_) {}

    if (!enabled) return;
    if (filter == 'High' && task.priority != TaskPriority.high) return;

    if (task.dueDate == null || task.completed) return;

    final scheduledDate = tz.TZDateTime.from(task.dueDate!.toUtc(), tz.UTC);
    
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.UTC))) {
      return;
    }

    final int notificationId = task.id.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminders_channel',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming task deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Task Reminder',
      body: 'Your task "${task.title}" is due now!',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(Task task) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: task.id.hashCode);
  }

  Future<void> cancelTaskNotificationById(String id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: id.hashCode);
  }

  Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: 0);
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationsPlugin.show(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from your Advanced settings!',
      notificationDetails: platformDetails,
    );
  }

  Future<void> scheduleDailyReminder({int hour = 9, int minute = 0}) async {
    if (kIsWeb) return;
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final scheduledDate = tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminders_channel',
      'Daily Reminders',
      channelDescription: 'Morning digest of your tasks for today',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Good Morning!',
      body: 'Check your tasks for today and stay productive!',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
