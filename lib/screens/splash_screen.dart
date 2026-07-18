import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [AppColors.blue, AppColors.purple]),
              ),
              child: const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'One Robotics Ai',
              textAlign: TextAlign.center,
              style: AppText.display(size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn. Build. Automate.',
              style: AppText.muted(size: 13),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
