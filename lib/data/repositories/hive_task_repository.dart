import 'package:hive/hive.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class HiveTaskRepository implements TaskRepository {
  static const String _boxName = 'tasks_box';
  late Box<Task> _box;

  @override
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    _box = await Hive.openBox<Task>(_boxName);
  }

  @override
  List<Task> getTasks() {
    return _box.values.toList();
  }

  @override
  Future<void> saveTask(Task task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
