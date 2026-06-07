import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/data/repositories/hive_task_repository.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Task Repository and register adapters
  final taskRepository = HiveTaskRepository();
  await taskRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepository),
      ],
      child: const TodoApp(),
    ),
  );
}
