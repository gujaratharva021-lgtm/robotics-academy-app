import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = ['My Certificates', 'My Courses', 'Achievements', 'Saved Courses', 'Settings', 'Help & Support'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Profile', style: AppText.display(size: 19)),
            const Icon(Icons.more_vert_rounded, color: AppColors.text1),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const CircleAvatar(radius: 40, backgroundColor: AppColors.panelHi, child: Icon(Icons.person, size: 36, color: AppColors.text1)),
              const SizedBox(height: 12),
              Text('Arjun Sharma', style: AppText.display(size: 18)),
              Text('arjun.sharma@email.com', style: AppText.muted()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: panelDecoration(),
          child: Row(children: [
            _stat('12', 'Courses'),
            _divider(),
            _stat('15', 'Badges'),
            _divider(),
            _stat('1250', 'Points'),
          ]),
        ),
        const SizedBox(height: 8),
        ...menu.map((label) => Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppText.body(size: 13.5)),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.text2, size: 20),
                ],
              ),
            )),
      ],
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
