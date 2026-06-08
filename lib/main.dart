import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/data/repositories/hive_task_repository.dart';
import 'package:todo_app/data/services/notification_service.dart';
import 'package:todo_app/data/services/focus_session_service.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FocusSessionService().init();

  await Hive.initFlutter();

  final taskRepository = HiveTaskRepository();
  final notificationService = NotificationService();

  await Future.wait([
    Hive.openBox('profile_box'),
    taskRepository.init(),
    notificationService.init(),
  ]);

  notificationService.requestPermissions().then((_) {
    int hour = 9;
    int minute = 0;
    bool enabled = true;
    try {
      final box = Hive.box('profile_box');
      enabled = box.get('notif_enabled', defaultValue: true) as bool;
      hour = box.get('notif_hour', defaultValue: 9) as int;
      minute = box.get('notif_minute', defaultValue: 0) as int;
    } catch (_) {}

    if (enabled) {
      notificationService.scheduleDailyReminder(hour: hour, minute: minute);
    } else {
      notificationService.cancelDailyReminder();
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepository),
      ],
      child: const TodoApp(),
    ),
  );
}
