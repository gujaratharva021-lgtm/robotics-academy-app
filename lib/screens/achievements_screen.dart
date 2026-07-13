import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<_AchievementData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_AchievementData> _loadData() async {
    final stats = await FirestoreService.getUserStats();
    final certs = await FirestoreService.getCertificates();
    return _AchievementData(
      coursesCompleted: stats['courses'] ?? 0,
      points: stats['points'] ?? 0,
      certificatesCount: certs.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: FutureBuilder<_AchievementData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? _AchievementData(coursesCompleted: 0, points: 0, certificatesCount: 0);
            final badges = _buildBadges(data);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    _backButton(context),
                    Expanded(child: Text('Achievements', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${badges.where((b) => b.unlocked).length} of ${badges.length} badges unlocked',
                  style: AppText.muted(size: 13),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: badges.map((b) => _badgeTile(b)).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_Badge> _buildBadges(_AchievementData data) {
    return [
      _Badge('First Steps', 'Complete your first course', Icons.flag_rounded, AppColors.blueHi, data.coursesCompleted >= 1),
      _Badge('Certified', 'Earn your first certificate', Icons.workspace_premium_rounded, AppColors.gold, data.certificatesCount >= 1),
      _Badge('Point Collector', 'Reach 100 points', Icons.stars_rounded, AppColors.purple, data.points >= 100),
      _Badge('Rising Star', 'Reach 300 points', Icons.auto_awesome_rounded, AppColors.cyan, data.points >= 300),
      _Badge('Course Explorer', 'Complete 3 courses', Icons.explore_rounded, AppColors.green, data.coursesCompleted >= 3),
      _Badge('Academy Graduate', 'Complete 5 courses', Icons.school_rounded, AppColors.blue, data.coursesCompleted >= 5),
    ];
  }

  Widget _badgeTile(_Badge badge) {
    final unlocked = badge.unlocked;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: panelDecoration().copyWith(
        color: unlocked ? AppColors.panel : AppColors.panel.withOpacity(0.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: unlocked ? badge.color.withOpacity(0.15) : AppColors.text2.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, color: unlocked ? badge.color : AppColors.text2, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: AppText.body(size: 12.5, weight: FontWeight.w700, color: unlocked ? AppColors.text0 : AppColors.text2),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.muted(size: 10.5),
          ),
        ],
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

class _AchievementData {
  final int coursesCompleted;
  final int points;
  final int certificatesCount;
  _AchievementData({required this.coursesCompleted, required this.points, required this.certificatesCount});
}

class _Badge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  _Badge(this.title, this.description, this.icon, this.color, this.unlocked);
}