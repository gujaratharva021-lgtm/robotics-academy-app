import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';
import 'course_detail_screen.dart';

class SavedCoursesScreen extends StatefulWidget {
  const SavedCoursesScreen({super.key});

  @override
  State<SavedCoursesScreen> createState() => _SavedCoursesScreenState();
}

class _SavedCoursesScreenState extends State<SavedCoursesScreen> {
  late Future<List<Course>> _savedFuture;

  @override
  void initState() {
    super.initState();
    _savedFuture = FirestoreService.getSavedCourses();
  }

  void _refresh() {
    setState(() {
      _savedFuture = FirestoreService.getSavedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: FutureBuilder<List<Course>>(
          future: _savedFuture,
          builder: (context, snapshot) {
            final courses = snapshot.data ?? [];
            final loading = snapshot.connectionState == ConnectionState.waiting;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    _backButton(context),
                    Expanded(child: Text('Saved Courses', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 20),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (courses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 40, color: AppColors.text2),
                        const SizedBox(height: 12),
                        Text('No saved courses yet', style: AppText.muted(size: 13.5)),
                        const SizedBox(height: 6),
                        Text('Tap the bookmark icon on any course to save it here.',
                            textAlign: TextAlign.center, style: AppText.muted(size: 11.5)),
                      ],
                    ),
                  )
                else
                  ...courses.map((c) => CourseCard(
                    course: c,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
                      );
                      _refresh();
                    },
                  )),
              ],
            );
          },
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
}