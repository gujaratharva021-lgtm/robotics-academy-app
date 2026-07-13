import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'subscription_screen.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loading = true;
  bool _seeding = false;
  bool _seedingCourses = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await FirestoreService.getNotificationSetting();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await FirestoreService.setNotificationSetting(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'Notifications enabled' : 'Notifications disabled')),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://robotics-academy-app-2026.web.app');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the privacy policy link.')),
        );
      }
    }
  }

  Future<void> _seedQuizzes() async {
    setState(() => _seeding = true);
    try {
      await FirestoreService.seedAllCourseQuizzes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All course quizzes updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _seedNewCourses() async {
    setState(() => _seedingCourses = true);
    try {
      await FirestoreService.seedNewCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('6 new courses added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _seedingCourses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                _backButton(context),
                Expanded(child: Text('Settings', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                const SizedBox(width: 38),
              ],
            ),
            const SizedBox(height: 20),

            _sectionLabel('Account'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: AppText.muted(size: 11.5)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'Not signed in', style: AppText.body(size: 14, weight: FontWeight.w600)),
                ],
              ),
            ),

            _sectionLabel('Notifications'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: panelDecoration(),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Push notifications', style: AppText.body(size: 14, weight: FontWeight.w600)),
                      subtitle: Text('Reminders, announcements & updates', style: AppText.muted(size: 11.5)),
                      value: _notificationsEnabled,
                      activeColor: AppColors.blue,
                      onChanged: _toggleNotifications,
                    ),
            ),

            _sectionLabel('Premium'),
            _tile('Upgrade to Premium', Icons.workspace_premium_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),

            _sectionLabel('About'),
            _tile('Privacy Policy', Icons.privacy_tip_outlined, _openPrivacyPolicy),
            _tile('App Version', Icons.info_outline_rounded, null, trailing: '1.0.0'),

            _sectionLabel('Admin (one-time setup)'),
            GestureDetector(
              onTap: _seeding ? null : _seedQuizzes,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: panelDecoration(),
                child: Row(
                  children: [
                    const Icon(Icons.quiz_outlined, size: 18, color: AppColors.text1),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Update Course Quizzes', style: AppText.body(size: 13.5, weight: FontWeight.w600))),
                    if (_seeding)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      const Icon(Icons.chevron_right_rounded, color: AppColors.text2, size: 20),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _seedingCourses ? null : _seedNewCourses,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: panelDecoration(),
                child: Row(
                  children: [
                    const Icon(Icons.library_add_outlined, size: 18, color: AppColors.text1),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Add New Courses', style: AppText.body(size: 13.5, weight: FontWeight.w600))),
                    if (_seedingCourses)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      const Icon(Icons.chevron_right_rounded, color: AppColors.text2, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: AppText.display(size: 12, weight: FontWeight.w600, color: AppColors.text2).copyWith(letterSpacing: 1.0),
        ),
      );

  Widget _tile(String label, IconData icon, VoidCallback? onTap, {String? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: panelDecoration(),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.text1),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppText.body(size: 13.5, weight: FontWeight.w600))),
            if (trailing != null)
              Text(trailing, style: AppText.muted())
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.text2, size: 20),
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
}
