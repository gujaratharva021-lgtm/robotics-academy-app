import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/profile_photo_service.dart';
import 'auth_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'achievements_screen.dart';
import 'saved_courses_screen.dart';
import 'certificates_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const ProfileScreen({super.key, required this.onNavigate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  String? _photoBase64;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _statsFuture = FirestoreService.getUserStats();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final photo = await FirestoreService.getProfilePhotoBase64();
    if (!mounted) return;
    setState(() => _photoBase64 = photo);
  }

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.panel,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.text1),
              title: Text('Take a photo', style: AppText.body(size: 14)),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.text1),
              title: Text('Choose from gallery', style: AppText.body(size: 14)),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                title: Text('Remove photo', style: AppText.body(size: 14, color: AppColors.red)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    if (choice == 'remove') {
      setState(() => _photoBase64 = null);
      await FirestoreService.removeProfilePhoto();
      return;
    }

    setState(() => _uploadingPhoto = true);
    try {
      final encoded = await ProfilePhotoService.pickAndEncode(fromCamera: choice == 'camera');
      if (encoded != null) {
        setState(() => _photoBase64 = encoded);
        await FirestoreService.setProfilePhotoBase64(encoded);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text('Log out?', style: AppText.display(size: 18)),
        content: Text('Are you sure you want to log out?', style: AppText.body(size: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppText.body(size: 14, color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: AppText.body(size: 14, color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    }
  }

  void _handleMenuTap(String label) {
    switch (label) {
      case 'My Certificates':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificatesScreen()));
        break;
      case 'My Courses':
        widget.onNavigate(1);
        break;
      case 'Achievements':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
        break;
      case 'Saved Courses':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedCoursesScreen()));
        break;
      case 'Settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 'Help & Support':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'Student';
    final email = user?.email ?? '';

    final menu = ['My Certificates', 'My Courses', 'Achievements', 'Saved Courses', 'Settings', 'Help & Support'];

    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'courses': 0, 'badges': 0, 'points': 0};

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: AppText.display(size: 19)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: const Icon(Icons.more_vert_rounded, color: AppColors.text1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : _pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.panelHi,
                          backgroundImage: _photoBase64 != null
                              ? MemoryImage(base64Decode(_photoBase64!))
                              : null,
                          child: _uploadingPhoto
                              ? const CircularProgressIndicator()
                              : (_photoBase64 == null
                              ? const Icon(Icons.person, size: 36, color: AppColors.text1)
                              : null),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bg1, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(displayName, style: AppText.display(size: 18)),
                  Text(email, style: AppText.muted()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: panelDecoration(),
              child: Row(children: [
                _stat('${stats['courses']}', 'Courses'),
                _divider(),
                _stat('${stats['badges']}', 'Badges'),
                _divider(),
                _stat('${stats['points']}', 'Points'),
              ]),
            ),
            const SizedBox(height: 8),
            ...menu.map((label) => GestureDetector(
              onTap: () => _handleMenuTap(label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: AppText.body(size: 13.5)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.text2, size: 20),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Log Out', style: AppText.body(size: 13.5, color: AppColors.red)),
                    const Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String value, String label) => Expanded(
    child: Column(children: [
      Text(value, style: AppText.display(size: 17)),
      Text(label, style: AppText.muted(size: 11.5)),
    ]),
  );

  Widget _divider() => Container(width: 1, height: 30, color: AppColors.line);
}
