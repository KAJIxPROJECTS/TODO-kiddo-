import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);

    // Dynamic stats calculations
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.completed).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;

    // Category distribution calculations
    final workTasks = tasks.where((t) => t.category.toLowerCase() == 'work').toList();
    final personalTasks = tasks.where((t) => t.category.toLowerCase() == 'personal').toList();
    final healthTasks = tasks.where((t) => t.category.toLowerCase() == 'health').toList();
    final otherTasks = tasks.where((t) {
      final cat = t.category.toLowerCase();
      return cat != 'work' && cat != 'personal' && cat != 'health';
    }).toList();

    double getCategoryCompletionRate(List<dynamic> categoryTasks) {
      if (categoryTasks.isEmpty) return 0.0;
      final completed = categoryTasks.where((t) => t.completed).length;
      return completed / categoryTasks.length;
    }

    final workRate = getCategoryCompletionRate(workTasks);
    final personalRate = getCategoryCompletionRate(personalTasks);
    final healthRate = getCategoryCompletionRate(healthTasks);
    final otherRate = getCategoryCompletionRate(otherTasks);

    // Mock Weekly Productivity (for 7 days)
    final List<Map<String, dynamic>> weeklyData = [
      {'day': 'Mon', 'completed': 3, 'total': 4},
      {'day': 'Tue', 'completed': 5, 'total': 6},
      {'day': 'Wed', 'completed': 2, 'total': 5},
      {'day': 'Thu', 'completed': 6, 'total': 6},
      {'day': 'Fri', 'completed': 4, 'total': 5},
      {'day': 'Sat', 'completed': 1, 'total': 2},
      {'day': 'Sun', 'completed': completedTasks, 'total': totalTasks}, // Today
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6), // Warm light background
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Completion Summary Card (matching the "420" large stat layout)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$completionRate%',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Overall Completion Rate',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Celebrate your focus and micro-wins today.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Overview Cards Row (Pending Tasks & Total Completed)
              Row(
                children: [
                  Expanded(
                    child: _OverviewMiniCard(
                      value: '$pendingTasks',
                      label: 'Pending Tasks',
                      color: const Color(0xFF5A554C), // Charcoal
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OverviewMiniCard(
                      value: '$completedTasks',
                      label: 'Tasks Solved',
                      color: const Color(0xFFFBBF24), // Yellow accent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Category Distribution Chart (matching reference Emotions chart style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Analytics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completion rate broken down by category',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Row of Pill Bar Charts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CategoryBarChart(
                          label: 'Work',
                          rate: workRate,
                          color: const Color(0xFFFBBF24), // Yellow
                        ),
                        _CategoryBarChart(
                          label: 'Personal',
                          rate: personalRate,
                          color: const Color(0xFF8D5B4C), // Terracotta/Brown
                        ),
                        _CategoryBarChart(
                          label: 'Health',
                          rate: healthRate,
                          color: const Color(0xFF8AA682), // Green
                        ),
                        _CategoryBarChart(
                          label: 'Other',
                          rate: otherRate,
                          color: const Color(0xFF5A554C), // Charcoal Grey
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Weekly Productivity Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Productivity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed tasks per day this week',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Horizontal weekly productivity chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyData.map((data) {
                        final completed = data['completed'] as int;
                        final total = data['total'] as int;
                        final double barHeightFactor = total > 0 ? (completed / 6) : 0.0; // scale against max 6 tasks
                        final isToday = data['day'] == 'Sun';

                        return Column(
                          children: [
                            Container(
                              height: 100,
                              width: 14,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  FractionallySizedBox(
                                    heightFactor: barHeightFactor.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? const Color(0xFFFBBF24)
                                            : const Color(0xFFDDD7CD),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['day'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                                color: isToday ? Colors.black : Colors.black45,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Spacing at the bottom so it doesn't get covered by the bottom bar
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewMiniCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _OverviewMiniCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.015)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final String label;
  final double rate;
  final Color color;

  const _CategoryBarChart({
    required this.label,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (rate * 100).round();

    return Column(
      children: [
        // Pill-shaped container
        Container(
          height: 150,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F3), // Soft grey background capsule
            borderRadius: BorderRadius.circular(19),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Filled progress block
              FractionallySizedBox(
                heightFactor: rate.clamp(0.0, 1.0),
                child: Container(
                  width: 38,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
              // Percentage text inside pill (just like screenshot)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: rate > 0.15 ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Category Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
