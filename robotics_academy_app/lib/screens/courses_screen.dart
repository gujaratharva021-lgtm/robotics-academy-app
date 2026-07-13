import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String activeLevel = 'All';
  String? activeCategory;

  static const levels = ['All', 'Kids', 'UG', 'PG', 'Professional'];

  @override
  Widget build(BuildContext context) {
    final list = activeCategory == null
        ? kCourses
        : kCourses.where((c) => c.category == activeCategory).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Courses', style: AppText.display(size: 19)),
            const Icon(Icons.search, color: AppColors.text1),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: levels
                .map((l) => Pill(label: l, active: activeLevel == l, onTap: () => setState(() => activeLevel = l)))
                .toList(),
          ),
        ),
        const SectionTitle('Course Categories'),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final c = kCategories[i];
              final active = activeCategory == c.name;
              return GestureDetector(
                onTap: () => setState(() => activeCategory = active ? null : c.name),
                child: Container(
                  width: 84,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: active ? AppColors.blue : AppColors.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: c.color.withOpacity(0.15), borderRadius: BorderRadius.circular(9)),
                        child: Icon(c.icon, color: c.color, size: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(c.name, textAlign: TextAlign.center, style: AppText.body(size: 10.5, weight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SectionTitle(activeCategory != null ? '$activeCategory Courses' : 'All Courses'),
        ...list.map((c) => CourseCard(
              course: c,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
            )),
      ],
    );
  }
}
