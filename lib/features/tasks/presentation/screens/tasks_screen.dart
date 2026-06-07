import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
    );
  }

  Widget _buildTaskList(ThemeData theme, {bool? showCompleted}) {
    // Simulated tasks list
    final List<Map<String, dynamic>> allTasks = [
      {
        'title': 'Design Bottom Navigation mockup',
        'isCompleted': true,
        'category': 'Work',
        'prio': 'High',
        'prioColor': Colors.red,
      },
      {
        'title': 'Integrate StatefulShellRoute in GoRouter',
        'isCompleted': true,
        'category': 'Work',
        'prio': 'High',
        'prioColor': Colors.red,
      },
      {
        'title': 'Write unit tests for Router branches',
        'isCompleted': false,
        'category': 'Work',
        'prio': 'Medium',
        'prioColor': Colors.orange,
      },
      {
        'title': 'Prepare presentation deck',
        'isCompleted': false,
        'category': 'Work',
        'prio': 'Low',
        'prioColor': Colors.green,
      },
      {
        'title': 'Buy birthday present for Mom',
        'isCompleted': false,
        'category': 'Personal',
        'prio': 'Medium',
        'prioColor': Colors.orange,
      },
      {
        'title': 'Cardio training session',
        'isCompleted': false,
        'category': 'Health',
        'prio': 'High',
        'prioColor': Colors.red,
      },
      {
        'title': 'Clean kitchen & wash dishes',
        'isCompleted': true,
        'category': 'Personal',
        'prio': 'Low',
        'prioColor': Colors.green,
      },
    ];

    // Filter tasks based on completed state & active filter chip
    final filteredTasks = allTasks.where((task) {
      if (showCompleted != null && task['isCompleted'] != showCompleted) {
        return false;
      }
      if (_selectedFilter != 'All' && task['category'] != _selectedFilter) {
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

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 90),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final isCompleted = task['isCompleted'] as bool;
        final prioColor = task['prioColor'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Custom Checkbox
              GestureDetector(
                onTap: () {
                  // Simulate checking/unchecking
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Task Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task['category'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: prioColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task['prio'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: prioColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // More Actions Arrow/Button
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
