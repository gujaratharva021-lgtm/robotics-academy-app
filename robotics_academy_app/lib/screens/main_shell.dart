import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'tutor_screen.dart';
import 'certificates_screen.dart';
import 'profile_screen.dart';

/// Holds the 5 bottom-nav tabs and lets any screen jump between them
/// (e.g. Home's "AI Tutor" quick action jumps straight to the Tutor tab).
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigate: switchTab),
      const CoursesScreen(),
      const TutorScreen(),
      const CertificatesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(child: IndexedStack(index: _index, children: screens)),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: switchTab),
    );
  }
}
