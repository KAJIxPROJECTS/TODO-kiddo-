import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      final dueDate = task.dueDate;
      if (dueDate == null) return false;
      return dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day;
    }).toList();
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
    final allTasks = ref.watch(tasksProvider);
    final selectedDayTasks = _selectedDay != null
        ? _getTasksForDay(_selectedDay!, allTasks)
        : <Task>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6), // Warm light background
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Monthly Calendar Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.03),
              ),
            ),
            child: TableCalendar<Task>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update focusedDay as well
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) => _getTasksForDay(day, allTasks),
              
              // Styling TableCalendar to match Material 3 & yellow accent theme
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
                leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Colors.black),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                weekendStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                weekendTextStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                todayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                
                // Today styling: soft yellow border/ring
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                ),
                // Selected styling: solid yellow circle
                selectedDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFBBF24),
                ),
                markerSize: 5.0,
                markersAnchor: 1.3,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
              ),
              
              // Custom markers builder to show colored dots based on tasks
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((task) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPriorityColor(task.priority),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          
          // Tasks Header
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay == null
                      ? 'Tasks'
                      : 'Tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedDayTasks.length} total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B4E1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List under Calendar
          Expanded(
            child: selectedDayTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: Colors.black.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No tasks for this day',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap the + button below to create a new task.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : AnimatedCalendarTaskList(
                    tasks: selectedDayTasks,
                    onToggle: (id) {
                      ref.read(tasksProvider.notifier).toggleTaskCompletion(id);
                    },
                    onDelete: (id) {
                      ref.read(tasksProvider.notifier).deleteTask(id);
                    },
                    getPriorityColor: _getPriorityColor,
                    getCategoryColor: _getCategoryColor,
                  ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCalendarTaskList extends StatefulWidget {
  final List<Task> tasks;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final Color Function(TaskPriority priority) getPriorityColor;
  final Color Function(String category) getCategoryColor;

  const AnimatedCalendarTaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.getPriorityColor,
    required this.getCategoryColor,
  });

  @override
  State<AnimatedCalendarTaskList> createState() => _AnimatedCalendarTaskListState();
}

class _AnimatedCalendarTaskListState extends State<AnimatedCalendarTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _displayedTasks = [];
  final Set<String> _swipedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _displayedTasks.addAll(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant AnimatedCalendarTaskList oldWidget) {
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

    return CalendarTaskCardItem(
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
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
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

class CalendarTaskCardItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color categoryColor;
  final Color prioColor;

  const CalendarTaskCardItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.categoryColor,
    required this.prioColor,
  });

  @override
  State<CalendarTaskCardItem> createState() => _CalendarTaskCardItemState();
}

class _CalendarTaskCardItemState extends State<CalendarTaskCardItem> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant CalendarTaskCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.completed != oldWidget.task.completed) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.completed;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.02),
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
                    color: isCompleted ? const Color(0xFFFBBF24) : Colors.black26,
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
                          color: isCompleted ? Colors.black45 : Colors.black87,
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
                                  color: Colors.black45,
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
          ],
        ),
      ),
    );
  }
}
