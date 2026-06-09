import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task_model.dart';
import '../../data/services/focus_session_service.dart';
import '../../features/explore/presentation/screens/focus_session_screen.dart';
import '../providers/task_providers.dart';

class MainShellScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> with TickerProviderStateMixin {
  late AnimationController _tabTransitionController;
  AnimationController? _addTaskSheetController;

  @override
  void initState() {
    super.initState();
    _tabTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabTransitionController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex) {
      _tabTransitionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _tabTransitionController.dispose();
    _addTaskSheetController?.dispose();
    super.dispose();
  }

  int _getNavItemIndex(int branchIndex) {
    if (branchIndex < 2) return branchIndex;
    return branchIndex + 1; // Skip index 2 (center FAB)
  }

  int _getBranchIndex(int navItemIndex) {
    if (navItemIndex < 2) return navItemIndex;
    if (navItemIndex == 2) return widget.navigationShell.currentIndex;
    return navItemIndex - 1;
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      _showAddTaskBottomSheet();
    } else {
      widget.navigationShell.goBranch(_getBranchIndex(index));
    }
  }

  bool _isModalOpen = false;

  void _showAddTaskBottomSheet() {
    setState(() => _isModalOpen = true);
    _addTaskSheetController?.dispose();
    _addTaskSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );
    showModalBottomSheet<Task?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionAnimationController: _addTaskSheetController,
      builder: (context) => const AddTaskBottomSheet(),
    ).then((task) {
      if (mounted) {
        setState(() => _isModalOpen = false);
        if (task != null) {
          _showFocusModeDialog(task);
        }
      }
      _addTaskSheetController = null;
    });
  }

  void _showFocusModeDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          title: Text(
            'Start Focus Mode for this task?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('current_focus_task_id', task.id);
                await prefs.setString('current_focus_task_title', task.title);
                await prefs.setInt('current_focus_start_timestamp', DateTime.now().millisecondsSinceEpoch);
                await prefs.setBool('current_focus_session_active', true);
                FocusSessionService().setFocusSessionActive(true);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FocusSessionScreen(durationMinutes: 25),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
              ),
              child: const Text('Start Focus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentNavIndex = _getNavItemIndex(widget.navigationShell.currentIndex);

    return Scaffold(
      body: Stack(
        children: [
          // Screen content - extends under the transparent bottom bar
          Positioned.fill(
            child: FadeTransition(
              opacity: _tabTransitionController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.015),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _tabTransitionController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: widget.navigationShell,
              ),
            ),
          ),
          
          // Floating Navigation Bar (Theme-aware, Rounded, Soft Shadow matching reference)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavBarItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        isActive: currentNavIndex == 0,
                        onTap: () => _onNavItemTapped(0),
                      ),
                      _NavBarItem(
                        icon: Icons.explore_outlined,
                        activeIcon: Icons.explore_rounded,
                        label: 'Explore',
                        isActive: currentNavIndex == 1,
                        onTap: () => _onNavItemTapped(1),
                      ),
                      // Spacing placeholder for FAB
                      const SizedBox(width: 56),
                      _NavBarItem(
                        icon: Icons.assignment_outlined,
                        activeIcon: Icons.assignment_rounded,
                        label: 'Journey',
                        isActive: currentNavIndex == 3,
                        onTap: () => _onNavItemTapped(3),
                      ),
                      _NavBarItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                        isActive: currentNavIndex == 4,
                        onTap: () => _onNavItemTapped(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Yellow Floating Action Button floating above the navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 44, // Floating exactly in the middle of the navbar
            child: Center(
              child: _FloatingActionButton(
                isModalOpen: _isModalOpen,
                onTap: _showAddTaskBottomSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 76,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey<bool>(isActive),
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingActionButton extends StatefulWidget {
  final bool isModalOpen;
  final VoidCallback onTap;

  const _FloatingActionButton({
    required this.isModalOpen,
    required this.onTap,
  });

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFBBF24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFBBF24).withValues(alpha: _isPressed ? 0.45 : 0.35),
                blurRadius: _isPressed ? 18 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              customBorder: const CircleBorder(),
              splashColor: Colors.black12,
              child: Center(
                child: AnimatedRotation(
                  turns: widget.isModalOpen ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Work';
  DateTime? _selectedDate;
  late AnimationController _staggerController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'icon': Icons.work_outline_rounded, 'color': Colors.blue},
    {'name': 'Personal', 'icon': Icons.person_outline_rounded, 'color': Colors.green},
    {'name': 'Health', 'icon': Icons.favorite_border_rounded, 'color': Colors.red},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined, 'color': Colors.amber},
    {'name': 'Finance', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFFBBF24),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = index * 50 / 450.0;
    final end = (index * 50 + 200) / 450.0;

    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0.0, (1.0 - animation.value) * 15.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: mediaQuery.viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Header
                  Text(
                    'Create New Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Task Title Input
                  _buildAnimatedItem(
                    index: 0,
                    child: TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Description Input
                  _buildAnimatedItem(
                    index: 1,
                    child: TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.9)),
                      decoration: InputDecoration(
                        hintText: 'Add details or notes...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selection
                  _buildAnimatedItem(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 42,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat['name'];
                              final color = cat['color'] as Color;

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  avatar: Icon(
                                    cat['icon'],
                                    size: 16,
                                    color: isSelected ? Colors.black : color,
                                  ),
                                  label: Text(cat['name']),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFFBBF24),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedCategory = cat['name']);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row for Date Picker & Priority
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Picker
                      Expanded(
                        flex: 1,
                        child: _buildAnimatedItem(
                          index: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color: Color(0xFFFBBF24),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null
                                              ? 'Select Date'
                                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Priority
                      Expanded(
                        flex: 1,
                        child: _buildAnimatedItem(
                          index: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Priority',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Row(
                                  children: ['Low', 'Medium', 'High'].map((prio) {
                                    final isSelected = _selectedPriority == prio;
                                    Color prioColor = Colors.green;
                                    if (prio == 'Medium') prioColor = Colors.orange;
                                    if (prio == 'High') prioColor = Colors.red;

                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedPriority = prio),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected ? prioColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            prio,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  _buildAnimatedItem(
                    index: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                              return;
                            }
                            
                            // Convert Priority string to Enum
                            TaskPriority prio = TaskPriority.medium;
                            if (_selectedPriority == 'Low') prio = TaskPriority.low;
                            if (_selectedPriority == 'High') prio = TaskPriority.high;

                            // Create task object
                            final task = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              priority: prio,
                              category: _selectedCategory,
                              dueDate: _selectedDate,
                              completed: false,
                              createdAt: DateTime.now(),
                            );

                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            await ref.read(tasksProvider.notifier).addTask(task);
                            navigator.pop(task);
                            
                            // Show success SnackBar
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: isDark ? Colors.white : Colors.black),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Task "${task.title}" created!',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: isDark ? Colors.grey[850] : const Color(0xFFFBBF24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBBF24),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Create Task',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
