import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/course_videos.dart';
import '../services/firestore_service.dart';
import 'quiz_screen.dart';
import 'main_shell.dart';
import 'subscription_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _saved = false;
  bool _loadingSaved = true;
  bool _hasSubscription = false;
  bool _loadingSubscription = true;
  double _avgRating = 0;
  int _ratingCount = 0;
  int _studentCount = 0;
  int? _myRating;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _loadStatsAndEnroll();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final status = await FirestoreService.getSubscriptionStatus();
    if (!mounted) return;
    setState(() {
      _hasSubscription = status['active'] == true;
      _loadingSubscription = false;
    });
  }

  Future<void> _loadSavedState() async {
    final saved = await FirestoreService.isCourseSaved(widget.course.id);
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _loadingSaved = false;
    });
  }

  Future<void> _loadStatsAndEnroll() async {
    await FirestoreService.markEnrolled(widget.course.id);
    final stats = await FirestoreService.getCourseRatingStats(widget.course.id);
    final students = await FirestoreService.getStudentCount(widget.course.id);
    final myRating = await FirestoreService.getUserRating(widget.course.id);
    if (!mounted) return;
    setState(() {
      _avgRating = (stats['average'] ?? 0.0).toDouble();
      _ratingCount = stats['count'] ?? 0;
      _studentCount = students;
      _myRating = myRating;
      _loadingStats = false;
    });
  }

  Future<void> _submitRating(int stars) async {
    setState(() => _myRating = stars);
    await FirestoreService.rateCourse(widget.course.id, stars);
    final stats = await FirestoreService.getCourseRatingStats(widget.course.id);
    if (!mounted) return;
    setState(() {
      _avgRating = (stats['average'] ?? 0.0).toDouble();
      _ratingCount = stats['count'] ?? 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for rating this course!')),
    );
  }

  Future<void> _toggleSave() async {
    final newState = !_saved;
    setState(() => _saved = newState);
    await FirestoreService.toggleSaveCourse(widget.course.id, newState);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'Course saved' : 'Removed from saved courses')),
      );
    }
  }

  Future<void> _watchVideo(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the video.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final videoUrl = kCourseVideoLinks[course.title];
    final thumbnailUrl = kCourseVideoThumbnails[course.title];
    final isLocked = course.isPremium && !_loadingSubscription && !_hasSubscription;

    final displayRating = _loadingStats
        ? course.rating
        : (_ratingCount > 0 ? _avgRating : course.rating);
    final displayStudents = _loadingStats ? course.students : '$_studentCount';

    if (isLocked) {
      return Scaffold(
        backgroundColor: AppColors.bg1,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _backButton(context),
                    Expanded(child: Text('Course Details', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                    const SizedBox(width: 38),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.lock_rounded, color: AppColors.gold, size: 32),
                        ),
                        const SizedBox(height: 20),
                        Text(course.title, style: AppText.display(size: 18), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          'This is a Premium course. Subscribe to unlock full access.',
                          textAlign: TextAlign.center,
                          style: AppText.muted(size: 13),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                              _loadSubscriptionStatus();
                            },
                            child: Text('Unlock with Premium', style: AppText.body(size: 13.5, weight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                GestureDetector(
                  onTap: _loadingSaved ? null : _toggleSave,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                    child: Icon(
                      _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 18,
                      color: _saved ? AppColors.blueHi : AppColors.text1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: videoUrl != null ? () => _watchVideo(videoUrl) : null,
              child: Container(
                height: 180,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                  gradient: thumbnailUrl == null
                      ? LinearGradient(colors: course.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                ),
                child: Stack(fit: StackFit.expand, children: [
                  if (thumbnailUrl != null)
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: course.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                      ),
                    ),
                  if (thumbnailUrl != null)
                    Container(color: Colors.black.withOpacity(0.25)),
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
            ),
            const SizedBox(height: 18),
            Text(course.title, style: AppText.display(size: 20)),
            const SizedBox(height: 4),
            Text(course.subtitle, style: AppText.muted(size: 13)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text(displayRating.toStringAsFixed(1), style: AppText.body(size: 13, weight: FontWeight.w600)),
              const SizedBox(width: 6),
              Text('($displayStudents students)', style: AppText.muted()),
              if (_ratingCount > 0) ...[
                const SizedBox(width: 6),
                Text('· $_ratingCount ratings', style: AppText.muted()),
              ],
            ]),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_myRating != null ? 'Your rating' : 'Rate this course', style: AppText.body(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      final filled = _myRating != null && starIndex <= _myRating!;
                      return GestureDetector(
                        onTap: () => _submitRating(starIndex),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.gold,
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(courseId: course.id, courseTitle: course.title))),
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
