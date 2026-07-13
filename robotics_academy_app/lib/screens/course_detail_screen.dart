import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'quiz_screen.dart';
import 'main_shell.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                _backButton(context),
                Expanded(child: Text('Course Details', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                const SizedBox(width: 38),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
                gradient: LinearGradient(colors: course.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.blueHi.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(course.level, style: AppText.body(size: 11, weight: FontWeight.w700, color: AppColors.blueHi)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Text(course.title, style: AppText.display(size: 20)),
            const SizedBox(height: 4),
            Text(course.subtitle, style: AppText.muted(size: 13)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text('${course.rating}', style: AppText.body(size: 13, weight: FontWeight.w600)),
              const SizedBox(width: 6),
              Text('(${course.students} students)', style: AppText.muted()),
            ]),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What you'll learn", style: AppText.body(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    "Learn the fundamentals of ${course.category.toLowerCase()}, hands-on projects, and real-world applications. Build a portfolio-ready project by the end of this course.",
                    style: AppText.muted(size: 13),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _statRow(Icons.menu_book_rounded, '${course.modules} Modules', AppColors.blueHi),
                      _statRow(Icons.play_circle_outline_rounded, '${course.lessons} Lessons', AppColors.blueHi),
                      _statRow(Icons.memory_rounded, '${course.projects} Projects', AppColors.blueHi),
                      _statRow(Icons.workspace_premium_rounded, 'Certificate', AppColors.gold),
                    ],
                  ),
                ],
              ),
            ),
            const SectionTitleLocal('Test your knowledge'),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: panelDecoration(radius: 16),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${course.title} Quiz', style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                        Text('4 questions · earn points', style: AppText.muted()),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.text2),
                ]),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
                  (route) => false,
                ),
                child: Text('Ask AI Tutor about this course', style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
        ),
      );

  Widget _statRow(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(label, style: AppText.body(size: 12.5)),
        ],
      );
}

// Small local section title (kept separate to avoid an extra shared-widget import cycle)
class SectionTitleLocal extends StatelessWidget {
  final String text;
  const SectionTitleLocal(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(text.toUpperCase(), style: AppText.display(size: 13, weight: FontWeight.w600, color: AppColors.text1).copyWith(letterSpacing: 1.0)),
    );
  }
}
