import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Work', 'Personal', 'Health', 'Shopping'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'shopping':
        return Colors.amber;
      case 'finance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0.0, (1.0 - value) * 15.0),
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                child: Text(
                  'My Tasks',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Modern Custom TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),

              // Filter Chips Bar
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                        },
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: theme.colorScheme.primary,
                        checkmarkColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // TabBar View for lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(theme, showCompleted: null),
                    _buildTaskList(theme, showCompleted: false),
                    _buildTaskList(theme, showCompleted: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme, {bool? showCompleted}) {
    final allTasks = ref.watch(tasksProvider);

    // Filter tasks based on completed state & active filter chip
    final filteredTasks = allTasks.where((task) {
      if (showCompleted != null && task.completed != showCompleted) {
        return false;
      }
      if (_selectedFilter != 'All' && task.category.toLowerCase() != _selectedFilter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks here!',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedTaskList(
      tasks: filteredTasks,
      onToggle: (id) => ref.read(tasksProvider.notifier).toggleTaskCompletion(id),
      onDelete: (id) => ref.read(tasksProvider.notifier).deleteTask(id),
      getPriorityColor: _getPriorityColor,
      getCategoryColor: _getCategoryColor,
    );
  }
}

class AnimatedTaskList extends StatefulWidget {
  final List<Task> tasks;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final Color Function(TaskPriority priority) getPriorityColor;
  final Color Function(String category) getCategoryColor;

  const AnimatedTaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.getPriorityColor,
    required this.getCategoryColor,
  });

  @override
  State<AnimatedTaskList> createState() => _AnimatedTaskListState();
}

class _AnimatedTaskListState extends State<AnimatedTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _displayedTasks = [];
  final Set<String> _swipedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _displayedTasks.addAll(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant AnimatedTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final oldTasks = List<Task>.from(_displayedTasks);
    final newTasks = widget.tasks;

    for (int i = oldTasks.length - 1; i >= 0; i--) {
      final task = oldTasks[i];
      final newIndex = newTasks.indexWhere((t) => t.id == task.id);
      if (newIndex == -1) {
        _displayedTasks.removeAt(i);
        if (_swipedTaskIds.contains(task.id)) {
          _swipedTaskIds.remove(task.id);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => const SizedBox.shrink(),
            duration: Duration.zero,
          );
        } else {
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: animation,
                child: _buildItem(task),
              ),
            ),
            duration: const Duration(milliseconds: 250),
          );
        }
      }
    }

    for (int i = 0; i < newTasks.length; i++) {
      final task = newTasks[i];
      final oldIndex = _displayedTasks.indexWhere((t) => t.id == task.id);
      if (oldIndex == -1) {
        _displayedTasks.insert(i, task);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      } else if (oldIndex != i) {
        _displayedTasks.removeAt(oldIndex);
        _listKey.currentState?.removeItem(
          oldIndex,
          (context, animation) => const SizedBox.shrink(),
          duration: Duration.zero,
        );
        _displayedTasks.insert(i, task);
        _listKey.currentState?.insertItem(
          i,
          duration: Duration.zero,
        );
      } else {
        _displayedTasks[i] = task;
      }
    }
  }

  Widget _buildItem(Task task) {
    final categoryColor = widget.getCategoryColor(task.category);
    final prioColor = widget.getPriorityColor(task.priority);

    return TaskCardItem(
      key: ValueKey(task.id),
      task: task,
      onToggle: () => widget.onToggle(task.id),
      onDelete: () => widget.onDelete(task.id),
      categoryColor: categoryColor,
      prioColor: prioColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _displayedTasks.length,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 90),
      itemBuilder: (context, index, animation) {
        if (index >= _displayedTasks.length) return const SizedBox.shrink();
        final task = _displayedTasks[index];

        final fadeTransition = FadeTransition(
          opacity: animation,
          child: _buildItem(task),
        );

        final slideTransition = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: fadeTransition,
        );

        final scaleTransition = ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: slideTransition,
        );

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          onDismissed: (direction) {
            _swipedTaskIds.add(task.id);
            widget.onDelete(task.id);
          },
          child: scaleTransition,
        );
      },
    );
  }
}

class TaskCardItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color categoryColor;
  final Color prioColor;

  const TaskCardItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.categoryColor,
    required this.prioColor,
  });

  @override
  State<TaskCardItem> createState() => _TaskCardItemState();
}

class _TaskCardItemState extends State<TaskCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TaskCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.completed != oldWidget.task.completed) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.task.completed;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? const Color(0xFFFBBF24) : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? const Color(0xFFFBBF24) : theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            color: Colors.black,
                            size: 16,
                          )
                        : const SizedBox(key: ValueKey('empty')),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.45) : theme.colorScheme.onSurface,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: isCompleted ? 1.0 : 0.0),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return FractionallySizedBox(
                                widthFactor: value,
                                child: Container(
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.task.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.prioColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.task.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.prioColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
                size: 20,
              ),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
