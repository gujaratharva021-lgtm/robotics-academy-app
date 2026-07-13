import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../data/mock_data.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate; // jump to a bottom-nav tab
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final continueCourse = kCourses[0];
    final popular = kCourses.sublist(1, 3);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Header
        Row(
          children: [
            const CircleAvatar(radius: 22, backgroundColor: AppColors.panelHi, child: Icon(Icons.person, color: AppColors.text1)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, Arjun 👋', style: AppText.display(size: 16, weight: FontWeight.w600)),
                  Text('Ready to learn today?', style: AppText.muted()),
                ],
              ),
            ),
            _iconButton(Icons.notifications_outlined),
          ],
        ),
        const SizedBox(height: 18),
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
          child: Row(children: [
            const Icon(Icons.search, size: 18, color: AppColors.text2),
            const SizedBox(width: 10),
            Text('Search courses, projects, tools...', style: AppText.muted()),
          ]),
        ),
        const SizedBox(height: 20),
        // Quick actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickAction(Icons.smart_toy_rounded, 'AI Tutor', () => onNavigate(2)),
            _quickAction(Icons.vrpano_rounded, 'Simulations', () {}),
            _quickAction(Icons.memory_rounded, 'Robot Labs', () {}),
            _quickAction(Icons.workspace_premium_rounded, 'Certificates', () => onNavigate(3)),
          ],
        ),
        const SizedBox(height: 20),
        // Progress card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: panelDecoration(),
          child: Row(children: [
            const ProgressRing(progress: 68),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Progress', style: AppText.body(size: 14.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Keep learning, keep building!', style: AppText.muted()),
              ],
            ),
          ]),
        ),
        const SectionTitle('Continue Learning'),
        CourseCard(
          course: continueCourse,
          showProgress: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: continueCourse))),
        ),
        const SectionTitle('Course Categories'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: kCategories.map((c) => _categoryTile(c, () => onNavigate(1))).toList(),
        ),
        const SectionTitle('Popular Courses'),
        ...popular.map((c) => _popularRow(context, c)),
      ],
    );
  }

  Widget _iconButton(IconData icon) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: Icon(icon, size: 18, color: AppColors.text1),
      );

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
            child: Icon(icon, color: AppColors.blueHi, size: 22),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(label, textAlign: TextAlign.center, style: AppText.body(size: 10.5, weight: FontWeight.w600, color: AppColors.text1)),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(dynamic cat, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: cat.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(cat.icon, color: cat.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(cat.name, style: AppText.body(size: 13, weight: FontWeight.w600))),
        ]),
      ),
    );
  }

  Widget _popularRow(BuildContext context, dynamic c) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: c.gradient),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                Text(c.level, style: AppText.muted()),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 3),
          Text('${c.rating}', style: AppText.body(size: 12.5, weight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
