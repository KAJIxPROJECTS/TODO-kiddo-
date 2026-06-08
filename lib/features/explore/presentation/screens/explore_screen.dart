import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'focus_session_screen.dart';
import 'article_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _scrollOffsetNotifier.value = _scrollController.offset;
    }
  }

  void _showDurationPicker(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController(text: '25');

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Focus Duration',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a preset or enter a custom duration in minutes.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 25, 30, 45, 60].map((minutes) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FocusSessionScreen(durationMinutes: minutes),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      ),
                      child: Text(
                        '$minutes min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Custom Minutes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.timer_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final mins = int.tryParse(textController.text) ?? 25;
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FocusSessionScreen(durationMinutes: mins > 0 ? mins : 25),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const article1Content = 
        'We live in a culture that glorifies busyness. We often feel compelled to say yes to every request, project, or social invitation, leading to burnout. '
        'Saying no to the unimportant allows you to say yes to the essential. It protects your time and energy for what truly matters.\n\n'
        'How to say no:\n'
        '• Be direct but polite: "Thank you for thinking of me, but I don\'t have the capacity for this right now."\n'
        '• Suggest an alternative: "I can\'t do this, but I can point you to someone else who might help."\n'
        '• Buy yourself time: "Let me check my calendar and get back to you."\n\n'
        'Decluttering your schedule isn\'t about being lazy; it\'s about being intentional. Start small and practice boundary setting.';

    const article2Content =
        '1. Stick to a sleep schedule: Go to bed and wake up at the same time every day, even on weekends. This reinforces your body\'s sleep-wake cycle.\n\n'
        '2. Create a restful environment: Keep your bedroom dark, quiet, and cool. Consider blackout curtains, earplugs, or white noise.\n\n'
        '3. Limit screen time before bed: Avoid blue light from phones, tablets, and TVs for at least an hour before sleep. Blue light suppresses melatonin production.\n\n'
        '4. Watch what you eat and drink: Avoid heavy meals, caffeine, and alcohol close to bedtime.\n\n'
        '5. Develop a wind-down routine: Read a physical book, take a warm bath, or practice light stretching to signal your body it\'s time to rest.\n\n'
        '6. Manage worries: Write down your thoughts or to-do lists before bed so you don\'t ruminate on them in the dark.\n\n'
        '7. Get daily sunlight: Exposure to natural light during the day helps regulate your circadian rhythm.\n\n'
        '8. Incorporate physical activity: Regular exercise improves sleep quality, but avoid working out right before bed.\n\n'
        '9. Optimize your bedding: Invest in a comfortable mattress and pillows that support your posture.\n\n'
        '10. Keep naps short: Limit daytime naps to 20-30 minutes to avoid disrupting night-time sleep.';

    const article3Content =
        'A cluttered desk leads to a cluttered mind. Keeping only the essentials on your desk helps minimize visual distractions.\n\n'
        'Ergonomics Matter: Set up your chair and desk height so your elbows are at a 90-degree angle and your eyes are level with the top of your screen.\n\n'
        'Let There Be Light: Position your desk near a window to receive natural light, which boosts mood and energy. Supplement with a warm, adjustable desk lamp.\n\n'
        'Digital Organization: Clean up your computer desktop, close unnecessary browser tabs, and organize files into clean folders.\n\n'
        'Add a Touch of Greenery: A small indoor plant (like a succulent or snake plant) improves air quality and adds a refreshing visual element to your workspace.';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Boost your daily productivity & mental focus',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Focus Mode Card with entry and floating animations
              ViewportAnimatedCard(
                scrollController: _scrollController,
                child: GestureDetector(
                  onTap: () => _showDurationPicker(context),
                  child: FloatingCard(
                    child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'RECOMMENDED',
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Deep Focus Mode',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Lock distraction apps and enter a 25-minute Pomodoro focus block.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: 0.7,
                                strokeWidth: 6,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                              ),
                            ),
                            Text(
                              '25m',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
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
              const SizedBox(height: 32),

              // Recommended Articles Header
              Text(
                'Productivity Articles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Article List with entry animations
              ViewportAnimatedCard(
                scrollController: _scrollController,
                child: const _ArticleItem(
                  title: 'The Art of Saying No: Decluttering Your Schedule',
                  readTime: '5 min read',
                  category: 'Workplace',
                  gradientColors: [Colors.purple, Colors.pink],
                  content: article1Content,
                ),
              ),
              ViewportAnimatedCard(
                scrollController: _scrollController,
                child: const _ArticleItem(
                  title: '10 Easy Ways to Improve Your Sleeping Habit',
                  readTime: '8 min read',
                  category: 'Well-being',
                  gradientColors: [Colors.teal, Colors.green],
                  content: article2Content,
                ),
              ),
              ViewportAnimatedCard(
                scrollController: _scrollController,
                child: const _ArticleItem(
                  title: 'Setting Up the Perfect Workspace for Productivity',
                  readTime: '6 min read',
                  category: 'Minimalism',
                  gradientColors: [Colors.blue, Colors.cyan],
                  content: article3Content,
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewportAnimatedCard extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  const ViewportAnimatedCard({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<ViewportAnimatedCard> createState() => _ViewportAnimatedCardState();
}

class _ViewportAnimatedCardState extends State<ViewportAnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    widget.scrollController.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_checkVisibility);
    _animController.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _isVisible) return;
    final context = this.context;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    if (position.dy < screenHeight - 40) {
      setState(() {
        _isVisible = true;
      });
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
    );
  }
}

class FloatingCard extends StatefulWidget {
  final Widget child;

  const FloatingCard({super.key, required this.child});

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      setState(() {
        _lifecycleState = state;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = false;
    try {
      isSelected = StatefulNavigationShell.of(context).currentIndex == 1;
    } catch (_) {
      isSelected = true;
    }

    if (isSelected && _lifecycleState == AppLifecycleState.resumed) {
      if (!_floatController.isAnimating) {
        _floatController.repeat(reverse: true);
      }
    } else {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    }

    return AnimatedBuilder(
      animation: _floatAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _floatAnimation.value),
          child: child,
        );
      },
    );
  }
}

class _ArticleItem extends StatelessWidget {
  final String title;
  final String readTime;
  final String category;
  final List<Color> gradientColors;
  final String content;

  const _ArticleItem({
    required this.title,
    required this.readTime,
    required this.category,
    required this.gradientColors,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              title: title,
              readTime: readTime,
              category: category,
              gradientColors: gradientColors,
              content: content,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    readTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
