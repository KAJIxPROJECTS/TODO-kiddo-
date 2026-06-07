import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/profile_providers.dart';
import 'package:todo_app/data/models/task_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedDateIndex = 3; // Defaults to Thu 10

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
    final isDark = theme.brightness == Brightness.dark;
    final tasks = ref.watch(tasksProvider);
    final profile = ref.watch(profileProvider);

    // Filter today's tasks based on the selected date chip
    final dates = [7, 8, 9, 10, 11, 12, 13];
    final selectedDay = dates[_selectedDateIndex];
    final todayTasks = tasks.where((task) {
      final dateToCheck = task.dueDate ?? task.createdAt;
      return dateToCheck.day == selectedDay;
    }).toList();

    // Stats calculations
    final totalCount = todayTasks.length;
    final completedCount = todayTasks.where((t) => t.completed).length;
    final pendingCount = totalCount - completedCount;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0.0, (1.0 - value) * 20.0),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section & User Avatar with Hero transition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi, ${profile.name}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // User can navigate to profile tab or tap to trigger transition
                      },
                      child: Hero(
                        tag: 'user-avatar',
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFBBF24), // Yellow accent border
                              width: 1.5,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(profile.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Horizontal Date Selector (Animate selection and expands smoothly)
                DateSelector(
                  selectedIndex: _selectedDateIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedDateIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Main Motivational Card ("My Journal") Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Journal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Scroll for Motivational Card & Evening Card (Fades & slides when changing dates)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeSlideTransition(
                    animation: animation,
                    child: child,
                  ),
                  child: SizedBox(
                    key: ValueKey(_selectedDateIndex),
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Main Motivational Card showing completed tasks progress
                        Container(
                          width: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD97D), // Main Yellow Accent Card
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD97D).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Let\'s start your day',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      totalCount > 0
                                          ? '$completedCount of $totalCount tasks completed ($pendingCount pending)'
                                          : 'No tasks scheduled for today.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B4E1B),
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.black.withValues(alpha: 0.08),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4E1B)),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Cute Sun & Hill Illustration (CustomPainter)
                              const MorningSunIllustration(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Evening Card
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C35) : const Color(0xFFDDD7CD),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  'Evening',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white70 : const Color(0xFF5A554C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Today's Tasks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Tasks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dynamic List of Today's Tasks (Animate when changing dates/data)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeSlideTransition(
                    animation: animation,
                    child: child,
                  ),
                  child: totalCount == 0 && tasks.isEmpty
                      ? const SkeletonTaskLoader(key: ValueKey('skeleton'))
                      : todayTasks.isEmpty
                          ? Container(
                              key: ValueKey('empty_$_selectedDateIndex'),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'All caught up!',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No tasks scheduled for today. Tap the + button to add one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : AnimatedTodayTaskList(
                              key: ValueKey('list_$_selectedDateIndex'),
                              tasks: todayTasks,
                              onToggle: (id) {
                                ref.read(tasksProvider.notifier).toggleTaskCompletion(id);
                              },
                              onDelete: (id) {
                                ref.read(tasksProvider.notifier).deleteTask(id);
                              },
                              getCategoryColor: _getCategoryColor,
                            ),
                ),
                const SizedBox(height: 32),

                // Quick Actions / Journal Cards Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Journal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Scroll View of Quick Action Cards (Animate when changing dates)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeSlideTransition(
                    animation: animation,
                    child: child,
                  ),
                  child: SizedBox(
                    key: ValueKey(_selectedDateIndex),
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionCard(
                          title: 'Pause & reflect 🌱',
                          subtitle: 'What are you grateful for today?',
                          cardColor: isDark ? const Color(0xFF3B2E2E) : const Color(0xFFFEE2E2),
                          tagText: 'Personal',
                          tagColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                        ),
                        const SizedBox(width: 16),
                        _QuickActionCard(
                          title: 'Set Intentions 😊',
                          subtitle: 'How do you want to feel?',
                          cardColor: isDark ? const Color(0xFF2E323F) : const Color(0xFFEEF2FF),
                          tagText: 'Family',
                          tagColor: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
                        ),
                        const SizedBox(width: 16),
                        _QuickActionCard(
                          title: 'Emotions 📊',
                          subtitle: 'Reflect on your mood.',
                          cardColor: isDark ? const Color(0xFF2E3B35) : const Color(0xFFECFDF5),
                          tagText: 'Self',
                          tagColor: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacing at the bottom to prevent floating navbar overlap
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DateSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = [7, 8, 9, 10, 11, 12, 13];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = days[index];
        final date = dates[index];
        final isSelected = index == selectedIndex;

        return Column(
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              child: Text(day),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 48 : 40,
                    height: isSelected ? 48 : 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFFBBF24)
                          : theme.cardTheme.color,
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: isSelected ? 10 : 6,
                          offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 16 : 14,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: isSelected
                              ? Colors.black
                              : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        child: Text('$date'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class SkeletonTaskLoader extends StatefulWidget {
  const SkeletonTaskLoader({super.key});

  @override
  State<SkeletonTaskLoader> createState() => _SkeletonTaskLoaderState();
}

class _SkeletonTaskLoaderState extends State<SkeletonTaskLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class MorningSunIllustration extends StatelessWidget {
  const MorningSunIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _SunPainter(),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Center of the Sun rising from the bottom
    final sunCenter = Offset(width * 0.5, height * 1.05);
    final sunRadius = height * 0.45;

    // Draw soft outer sun rays rings
    paint.color = const Color(0xFFFBBF24).withValues(alpha: 0.3);
    canvas.drawCircle(sunCenter, sunRadius * 1.4, paint);
    paint.color = const Color(0xFFFBBF24).withValues(alpha: 0.15);
    canvas.drawCircle(sunCenter, sunRadius * 1.8, paint);

    // Draw Sun body
    paint.color = const Color(0xFFF59E0B);
    canvas.drawCircle(sunCenter, sunRadius, paint);

    // Draw Sun face (eyes, smile, cheeks)
    final eyePaint = Paint()
      ..color = const Color(0xFF6B4E1B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.5 - 6, height * 0.82), 2.2, eyePaint);
    canvas.drawCircle(Offset(width * 0.5 + 6, height * 0.82), 2.2, eyePaint);

    final cheekPaint = Paint()
      ..color = const Color(0xFFFCA5A5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.5 - 11, height * 0.85), 2.5, cheekPaint);
    canvas.drawCircle(Offset(width * 0.5 + 11, height * 0.85), 2.5, cheekPaint);

    final smilePaint = Paint()
      ..color = const Color(0xFF6B4E1B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(width * 0.5 - 3.5, height * 0.86)
      ..quadraticBezierTo(width * 0.5, height * 0.89, width * 0.5 + 3.5, height * 0.86);
    canvas.drawPath(smilePath, smilePaint);

    // Draw back hill (softer olive-green)
    paint.color = const Color(0xFF8BA682);
    final backHillPath = Path()
      ..moveTo(0, height * 0.82)
      ..quadraticBezierTo(width * 0.25, height * 0.68, width * 0.6, height * 0.87)
      ..quadraticBezierTo(width * 0.8, height * 0.95, width, height * 0.77)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(backHillPath, paint);

    // Draw front hill (darker forest-green)
    paint.color = const Color(0xFF6E8E64);
    final frontHillPath = Path()
      ..moveTo(0, height * 0.92)
      ..quadraticBezierTo(width * 0.4, height * 0.77, width * 0.75, height * 0.92)
      ..quadraticBezierTo(width * 0.9, height * 0.97, width, height * 0.87)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(frontHillPath, paint);

    // Draw pine trees on the hills
    _drawPineTree(canvas, Offset(width * 0.1, height * 0.78), 14, 28);
    _drawPineTree(canvas, Offset(width * 0.18, height * 0.84), 10, 20);
    _drawPineTree(canvas, Offset(width * 0.85, height * 0.82), 12, 24);
  }

  void _drawPineTree(Canvas canvas, Offset bottomCenter, double width, double height) {
    final paint = Paint()
      ..color = const Color(0xFF4C6A43)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(bottomCenter.dx, bottomCenter.dy - height)
      ..lineTo(bottomCenter.dx - width / 2, bottomCenter.dy)
      ..lineTo(bottomCenter.dx + width / 2, bottomCenter.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedTodayTaskList extends StatefulWidget {
  final List<Task> tasks;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final Color Function(String category) getCategoryColor;

  const AnimatedTodayTaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.getCategoryColor,
  });

  @override
  State<AnimatedTodayTaskList> createState() => _AnimatedTodayTaskListState();
}

class _AnimatedTodayTaskListState extends State<AnimatedTodayTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _displayedTasks = [];
  final Set<String> _swipedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _displayedTasks.addAll(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant AnimatedTodayTaskList oldWidget) {
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
    return _TaskRowItem(
      key: ValueKey(task.id),
      task: task,
      categoryColor: widget.getCategoryColor(task.category),
      onToggle: () => widget.onToggle(task.id),
      onDelete: () => widget.onDelete(task.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _displayedTasks.length,
      padding: EdgeInsets.zero,
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

class _TaskRowItem extends StatefulWidget {
  final Task task;
  final Color categoryColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskRowItem({
    super.key,
    required this.task,
    required this.categoryColor,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_TaskRowItem> createState() => _TaskRowItemState();
}

class _TaskRowItemState extends State<_TaskRowItem> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant _TaskRowItem oldWidget) {
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
        ),
        child: Row(
          children: [
            // Checkbox circle
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

            // Title & Category
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color cardColor;
  final String tagText;
  final Color tagColor;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.tagText,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          
          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
