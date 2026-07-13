import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

/// ---------- Bottom navigation ----------
class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const List<NavItem> kNavItems = [
  NavItem(Icons.home_rounded, 'Home'),
  NavItem(Icons.menu_book_rounded, 'Courses'),
  NavItem(Icons.smart_toy_rounded, 'AI Tutor'),
  NavItem(Icons.workspace_premium_rounded, 'Certificates'),
  NavItem(Icons.person_rounded, 'Profile'),
];

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg0.withOpacity(0.92),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        children: List.generate(kNavItems.length, (i) {
          final active = i == currentIndex;
          final item = kNavItems[i];
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 21, color: active ? AppColors.blueHi : AppColors.text2),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: AppText.body(
                      size: 10.5,
                      weight: FontWeight.w600,
                      color: active ? AppColors.blueHi : AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ---------- Progress ring ----------
class ProgressRing extends StatelessWidget {
  final double progress; // 0-100
  final double size;
  const ProgressRing({super.key, required this.progress, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Text('${progress.toInt()}%', style: AppText.display(size: 15, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final track = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final sweep = Paint()
      ..shader = const LinearGradient(colors: [AppColors.blue, AppColors.cyan])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * 3.14159265 * (progress / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159265 / 2, sweepAngle, false, sweep);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

/// ---------- Pill selector ----------
class Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const Pill({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.blue : AppColors.panel,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? Colors.transparent : AppColors.line),
        ),
        child: Text(label, style: AppText.body(size: 13, weight: FontWeight.w600, color: active ? Colors.white : AppColors.text1)),
      ),
    );
  }
}

/// ---------- Badge ----------
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  const AppBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: AppText.body(size: 11, weight: FontWeight.w700, color: color)),
    );
  }
}

/// ---------- Course card (wide) ----------
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool showProgress;
  const CourseCard({super.key, required this.course, required this.onTap, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 108,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: course.gradient,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: AppBadge(label: course.level, color: AppColors.blueHi)),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title, style: AppText.body(size: 14.5, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(course.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.muted(size: 11.5)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: course.progress / 100,
                  minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation(AppColors.blue),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 3),
                  Text('${course.rating}', style: AppText.body(size: 12.5, weight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('(${course.students} students)', style: AppText.muted()),
                  const Spacer(),
                  Text('${course.modules} modules', style: AppText.muted()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------- Section title ----------
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: AppText.display(size: 13, weight: FontWeight.w600, color: AppColors.text1)
            .copyWith(letterSpacing: 1.0),
      ),
    );
  }
}
