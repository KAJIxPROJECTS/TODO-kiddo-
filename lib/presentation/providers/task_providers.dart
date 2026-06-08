import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/analytics_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('Override taskRepositoryProvider in ProviderScope');
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;
  final NotificationService _notificationService = NotificationService();

  TasksNotifier(this._repository) : super([]) {
    loadTasks();
  }

  void loadTasks() {
    state = _repository.getTasks();
  }

  Future<void> addTask(Task task) async {
    await _repository.saveTask(task);
    await AnalyticsService().incrementTasksCreated();
    if (task.completed) {
      await _notificationService.cancelTaskNotification(task);
    } else {
      await _notificationService.scheduleTaskNotification(task);
    }
    loadTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final tasks = state;
    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final updatedTask = task.copyWith(completed: !task.completed);
      await _repository.saveTask(updatedTask);
      if (updatedTask.completed) {
        await _notificationService.cancelTaskNotification(updatedTask);
        await AnalyticsService().incrementTasksCompleted();
      } else {
        await _notificationService.scheduleTaskNotification(updatedTask);
      }
      loadTasks();
    }
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await _notificationService.cancelTaskNotificationById(id);
    loadTasks();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository);
});
