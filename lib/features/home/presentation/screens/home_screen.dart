import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6), // Warm light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section & User Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, Jose Maria',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFBBF24), // Yellow accent border
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        ),
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
                      color: Colors.black,
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
                    // Main Motivational Card
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
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Let\'s start your day',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Begin with a mindful morning reflections.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B4E1B),
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
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
                        color: const Color(0xFFDDD7CD), // Soft warm grey-beige
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
                          // Rotated text matching reference design
                          RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              'Evening',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF5A554C),
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
                      color: Colors.black,
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

              // Simple Beautiful Task Cards (UI only, no functionality yet)
              _TaskRowItem(
                title: 'Mindful Morning Meditation',
                category: 'Mind',
                categoryColor: const Color(0xFF0F9D58),
                isCompleted: true,
              ),
              _TaskRowItem(
                title: 'Write down 3 gratitude points',
                category: 'Journal',
                categoryColor: const Color(0xFFFBBF24),
                isCompleted: false,
              ),
              _TaskRowItem(
                title: 'Review weekly budget goals',
                category: 'Finance',
                categoryColor: Colors.purple,
                isCompleted: false,
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
                      color: Colors.black,
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
                  children: const [
                    _QuickActionCard(
                      title: 'Pause & reflect 🌱',
                      subtitle: 'What are you grateful for today?',
                      cardColor: Color(0xFFFEE2E2), // Light soft red/pink
                      tagText: 'Personal',
                      tagColor: Color(0xFF991B1B),
                    ),
                    SizedBox(width: 16),
                    _QuickActionCard(
                      title: 'Set Intentions 😊',
                      subtitle: 'How do you want to feel?',
                      cardColor: Color(0xFFEEF2FF), // Light soft indigo
                      tagText: 'Family',
                      tagColor: Color(0xFF3730A3),
                    ),
                    SizedBox(width: 16),
                    _QuickActionCard(
                      title: 'Emotions 📊',
                      subtitle: 'Reflect on your mood.',
                      cardColor: Color(0xFFECFDF5), // Light soft green
                      tagText: 'Self',
                      tagColor: Color(0xFF065F46),
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
                    ? Colors.black
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
                    : Colors.white,
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
                    color: isSelected ? Colors.black : Colors.black87,
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
        size: const Size(double.infinity, 95),
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

  const _TaskRowItem({
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
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
                    color: isCompleted ? Colors.black45 : Colors.black87,
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          
          // Tags
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
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
