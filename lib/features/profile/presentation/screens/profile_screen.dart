import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todo_app/presentation/providers/profile_providers.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, ProfileState profile) {
    final nameController = TextEditingController(text: profile.name);
    String tempImagePath = profile.imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            ImageProvider displayImage;
            if (tempImagePath.startsWith('assets/')) {
              displayImage = AssetImage(tempImagePath);
            } else if (tempImagePath.startsWith('http') ||
                tempImagePath.startsWith('blob:') ||
                tempImagePath.startsWith('data:')) {
              displayImage = NetworkImage(tempImagePath);
            } else {
              displayImage = FileImage(File(tempImagePath));
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            tempImagePath = image.path;
                          });
                        }
                      } catch (_) {}
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: displayImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(profileProvider.notifier)
                        .updateProfile(
                          nameController.text.trim(),
                          tempImagePath,
                        );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final completedTasksCount = ref.watch(
      tasksProvider.select((tasks) => tasks.where((t) => t.completed).length),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Avatar with Edit Button & Hero Transition
              GestureDetector(
                onTap: () => _showEditProfileDialog(context, profile),
                child: ScaleTransition(
                  scale: _avatarScale,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: 'user-avatar',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image: DecorationImage(
                              image: profile.imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // User Info
              Text(
                profile.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Grid
              Row(
                children: [
                  Expanded(
                    child: _ProfileStatTile(
                      value: completedTasksCount,
                      suffix: '',
                      label: 'Completed',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatTile(
                      value: 85,
                      suffix: '%',
                      label: 'Focus Rate',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatTile(
                      value: 14,
                      suffix: 'h',
                      label: 'Focus Time',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Settings List (Theme-aware card)
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  ),
                ),
                child: Column(
                  children: [
                    StaggeredEntrance(
                      delay: const Duration(milliseconds: 0),
                      child: _SettingsItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Alerts, task reminders, daily briefing',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                    ),
                    StaggeredEntrance(
                      delay: const Duration(milliseconds: 50),
                      child: _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'National Suicide Help & Support of India',
                        onTap: () async {
                          final Uri url = Uri.parse('tel:14416');
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              final Uri webUrl = Uri.parse(
                                'https://www.telemanas.mohfw.gov.in',
                              );
                              await launchUrl(
                                webUrl,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } catch (_) {}
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Spacing at the bottom so elements don't get covered by the floating navbar
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class CountingText extends StatefulWidget {
  final int targetValue;
  final String suffix;
  final TextStyle? style;

  const CountingText({
    super.key,
    required this.targetValue,
    this.suffix = '',
    this.style,
  });

  @override
  State<CountingText> createState() => _CountingTextState();
}

class _CountingTextState extends State<CountingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = IntTween(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}${widget.suffix}', style: widget.style);
      },
    );
  }
}

class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  final int value;
  final String suffix;
  final String label;
  final Color color;

  const _ProfileStatTile({
    required this.value,
    required this.suffix,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
        ),
      ),
      child: Column(
        children: [
          CountingText(
            targetValue: value,
            suffix: suffix,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: (_) => _pressController.forward(),
          onTapUp: (_) {
            _pressController.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressController.reverse(),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
