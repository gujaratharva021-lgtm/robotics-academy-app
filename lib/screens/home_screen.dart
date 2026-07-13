import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'course_detail_screen.dart';
import 'settings_screen.dart';
import 'career_guidance_screen.dart';
import 'community_screen.dart';
import 'projects_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];
  Map<String, dynamic> _stats = {'courses': 0, 'badges': 0, 'points': 0};
  String? _photoBase64;
  bool _loading = true;
  String? _error;

  final List<CourseCategory> _categories = const [
    CourseCategory(name: 'Robotics', icon: Icons.precision_manufacturing_outlined, color: AppColors.purple),
    CourseCategory(name: 'AI & ML', icon: Icons.smart_toy_outlined, color: AppColors.blue),
    CourseCategory(name: 'PLC & SCADA', icon: Icons.memory_outlined, color: AppColors.cyan),
    CourseCategory(name: 'IoT & Sensors', icon: Icons.sensors_outlined, color: AppColors.green),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final courses = await FirestoreService.getCourses();
      final stats = await FirestoreService.getUserStats();
      final photo = await FirestoreService.getProfilePhotoBase64();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _stats = stats;
        _photoBase64 = photo;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your data. Pull down to retry.';
        _loading = false;
      });
    }
  }

  String get _userName {
    final user = AuthService.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim().split(' ').first;
    }
    if (user?.email != null) {
      return user!.email!.split('@').first;
    }
    return 'there';
  }

  double get _progressPercent {
    final totalCourses = _courses.length;
    final completed = (_stats['courses'] ?? 0) as int;
    if (totalCourses == 0) return 0;
    return ((completed / totalCourses) * 100).clamp(0, 100).toDouble();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon!')),
    );
  }

  void _openNotificationSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppText.muted()),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final hasCourses = _courses.isNotEmpty;
    final continueCourse = hasCourses ? _courses[0] : null;
    final popular = hasCourses && _courses.length > 1
        ? _courses.sublist(1, _courses.length > 3 ? 3 : _courses.length)
        : <Course>[];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.panelHi,
                backgroundImage: _photoBase64 != null ? MemoryImage(base64Decode(_photoBase64!)) : null,
                child: _photoBase64 == null ? const Icon(Icons.person, color: AppColors.text1) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, $_userName 👋', style: AppText.display(size: 16, weight: FontWeight.w600)),
                    Text('Ready to learn today?', style: AppText.muted()),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openNotificationSettings,
                child: _iconButton(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => widget.onNavigate(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
              child: Row(children: [
                const Icon(Icons.search, size: 18, color: AppColors.text2),
                const SizedBox(width: 10),
                Text('Search courses...', style: AppText.muted()),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickAction(Icons.smart_toy_rounded, 'AI Tutor', () => widget.onNavigate(2)),
                const SizedBox(width: 14),
                _quickAction(Icons.vrpano_rounded, 'Simulations', () => _showComingSoon('Simulations')),
                const SizedBox(width: 14),
                _quickAction(Icons.memory_rounded, 'Robot Labs', () => _showComingSoon('Robot Labs')),
                const SizedBox(width: 14),
                _quickAction(Icons.route_rounded, 'Career Path', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerGuidanceScreen()))),
                const SizedBox(width: 14),
                _quickAction(Icons.groups_rounded, 'Community', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()))),
                const SizedBox(width: 14),
                _quickAction(Icons.folder_special_rounded, 'Projects', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen()))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: panelDecoration(),
            child: Row(children: [
              ProgressRing(progress: _progressPercent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Progress', style: AppText.body(size: 14.5, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${_stats['courses'] ?? 0} courses completed · ${_stats['points'] ?? 0} pts',
                      style: AppText.muted(),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          if (hasCourses) ...[
            const SectionTitle('Continue Learning'),
            CourseCard(
              course: continueCourse!,
              showProgress: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: continueCourse))),
            ),
          ],
          const SectionTitle('Course Categories'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: _categories.map((c) => _categoryTile(c, () => widget.onNavigate(1))).toList(),
          ),
          const SectionTitle('Explore More'),
          Row(
            children: [
              Expanded(child: _exploreCard(Icons.route_rounded, 'Career\nGuidance', AppColors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerGuidanceScreen())))),
              const SizedBox(width: 10),
              Expanded(child: _exploreCard(Icons.groups_rounded, 'Community', AppColors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen())))),
              const SizedBox(width: 10),
              Expanded(child: _exploreCard(Icons.emoji_objects_rounded, 'Projects', AppColors.gold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen())))),
            ],
          ),
          if (popular.isNotEmpty) ...[
            const SectionTitle('Popular Courses'),
            ...popular.map((c) => _popularRow(context, c)),
          ],
          if (!hasCourses)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No courses available yet.', style: AppText.muted())),
            ),
        ],
      ),
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

  Widget _categoryTile(CourseCategory cat, VoidCallback onTap) {
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

  Widget _exploreCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: AppText.body(size: 11, weight: FontWeight.w600, color: AppColors.text1)),
          ],
        ),
      ),
    );
  }

  Widget _popularRow(BuildContext context, Course c) {
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
