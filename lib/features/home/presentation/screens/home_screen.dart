import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tasks = ref.watch(tasksProvider);
    final profile = ref.watch(profileProvider);

    // Filter today's tasks
    final now = DateTime.now();
    final todayTasks = tasks.where((task) {
      final dueDate = task.dueDate;
      if (dueDate != null) {
        return dueDate.year == now.year &&
            dueDate.month == now.month &&
            dueDate.day == now.day;
      }
      final createdAt = task.createdAt;
      return createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;
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

                // Horizontal Date Selector
                const DateSelector(),
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

                // Horizontal Scroll for Motivational Card & Evening Card
                SizedBox(
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

                // Dynamic List of Today's Tasks with Skeleton loader
                if (totalCount == 0 && tasks.isEmpty)
                  const SkeletonTaskLoader()
                else if (todayTasks.isEmpty)
                  Container(
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
                else
                  Column(
                    children: todayTasks.map((task) {
                      return _TaskRowItem(
                        title: task.title,
                        category: task.category,
                        categoryColor: _getCategoryColor(task.category),
                        isCompleted: task.completed,
                        onToggle: () {
                          ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id);
                        },
                      );
                    }).toList(),
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

                // Horizontal Scroll View of Quick Action Cards
                SizedBox(
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

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

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
        final isSelected = date == 10; // "Thu 10" selected in reference design

        return Column(
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFFBBF24) // Yellow Accent color
                    : theme.cardTheme.color,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected
                        ? Colors.black
                        : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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

class _TaskRowItem extends StatelessWidget {
  final String title;
  final String category;
  final Color categoryColor;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _TaskRowItem({
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
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
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 16,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.45) : theme.colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
