import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String activeLevel = 'All';
  String? activeCategory; // null = no category filter (i.e. "All")
  String searchQuery = '';
  late Future<List<Course>> _coursesFuture;

  static const List<CourseCategory> kCategories = [
    CourseCategory(name: 'Robotics', icon: Icons.precision_manufacturing_outlined, color: AppColors.purple),
    CourseCategory(name: 'AI & ML', icon: Icons.smart_toy_outlined, color: AppColors.blue),
    CourseCategory(name: 'PLC & SCADA', icon: Icons.memory_outlined, color: AppColors.cyan),
    CourseCategory(name: 'IoT & Sensors', icon: Icons.sensors_outlined, color: AppColors.green),
  ];

  @override
  void initState() {
    super.initState();
    _coursesFuture = FirestoreService.getCourses();
  }

  void _selectLevel(String level) {
    setState(() {
      activeLevel = level;
      // Tapping "All" clears the category filter too, so it truly shows everything.
      if (level == 'All') {
        activeCategory = null;
      }
    });
  }

  void _selectCategory(String name) {
    setState(() {
      final isAlreadyActive = activeCategory == name;
      activeCategory = isAlreadyActive ? null : name;
      // Selecting/deselecting a category resets level back to "All"
      // so the two filters don't silently conflict.
      activeLevel = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load courses. Please check your connection.',
                textAlign: TextAlign.center,
                style: AppText.body(size: 13.5, color: AppColors.text2),
              ),
            ),
          );
        }

        final allCourses = snapshot.data ?? [];

        // Build level pills dynamically from real course data (case-normalized,
        // deduplicated), so labels always match what's actually in Firestore.
        final levelSet = <String>{};
        for (final c in allCourses) {
          if (c.level.trim().isNotEmpty) levelSet.add(c.level.trim());
        }
        final levels = ['All', ...levelSet];

        // Case-insensitive filtering so "Beginner" vs "beginner" still matches.
        var list = allCourses;
        if (activeCategory != null) {
          list = list.where((c) => c.category.trim().toLowerCase() == activeCategory!.trim().toLowerCase()).toList();
        }
        if (activeLevel != 'All') {
          list = list.where((c) => c.level.trim().toLowerCase() == activeLevel.trim().toLowerCase()).toList();
        }
        if (searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          list = list.where((c) =>
          c.title.toLowerCase().contains(q) ||
              c.subtitle.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q)
          ).toList();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Courses', style: AppText.display(size: 19)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
              child: Row(children: [
                const Icon(Icons.search, size: 18, color: AppColors.text2),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    style: AppText.body(size: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      hintStyle: AppText.muted(),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => searchQuery = ''),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.text2),
                  ),
              ]),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: levels
                    .map((l) => Pill(label: l, active: activeLevel == l, onTap: () => _selectLevel(l)))
                    .toList(),
              ),
            ),
            const SectionTitle('Course Categories'),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final c = kCategories[i];
                  final active = activeCategory == c.name;
                  return GestureDetector(
                    onTap: () => _selectCategory(c.name),
                    child: Container(
                      width: 84,
                      padding: const EdgeInsets.all(8),
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
                          Text(
                            c.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(size: 9.5, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SectionTitle(activeCategory != null ? '$activeCategory Courses' : 'All Courses'),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text('No courses match this filter.', style: AppText.muted(size: 13)),
                ),
              )
            else
              ...list.map((c) => CourseCard(
                course: c,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
              )),
          ],
        );
      },
    );
  }
}