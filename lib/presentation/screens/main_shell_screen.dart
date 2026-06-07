import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/task_model.dart';
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

class _MainShellScreenState extends State<MainShellScreen> {
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

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 250),
      ),
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentNavIndex = _getNavItemIndex(widget.navigationShell.currentIndex);

    return Scaffold(
      body: Stack(
        children: [
          // Screen content - extends under the transparent bottom bar
          Positioned.fill(
            child: widget.navigationShell,
          ),
          
          // Floating Navigation Bar (White, Rounded, Soft Shadow matching reference)
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
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
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
    final activeColor = Colors.black; // Reference design uses deep dark/black for selected tab
    final inactiveColor = Colors.black38;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 76,
        width: 60,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            final scale = 1.0 + (val * 0.1); // Subtle icon scale up when active

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: Color.lerp(inactiveColor, activeColor, val),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                    color: Color.lerp(inactiveColor, activeColor, val),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloatingActionButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingActionButton({required this.onTap});

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
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFBBF24), // Reference design yellow accent FAB
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.black,
            size: 28,
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

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Work';
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'icon': Icons.work_outline_rounded, 'color': Colors.blue},
    {'name': 'Personal', 'icon': Icons.person_outline_rounded, 'color': Colors.green},
    {'name': 'Health', 'icon': Icons.favorite_border_rounded, 'color': Colors.red},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined, 'color': Colors.amber},
    {'name': 'Finance', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.purple},
  ];

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Create New Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Task Title Input
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Description Input
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Add details or notes...',
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selection
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
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
                              color: Colors.black87,
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
                  const SizedBox(height: 20),

                  // Row for Date Picker & Priority
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Picker
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Due Date',
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.05),
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
                                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
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
                      const SizedBox(width: 16),
                      // Priority
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority',
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.05),
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
                                            color: isSelected ? Colors.white : Colors.black87,
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
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
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

                          // Save to Hive storage via Riverpod
                          await ref.read(tasksProvider.notifier).addTask(task);

                          // Close Bottom Sheet
                          navigator.pop();
                          
                          // Show success SnackBar
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.black),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Task "${task.title}" created!',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFFFBBF24),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
