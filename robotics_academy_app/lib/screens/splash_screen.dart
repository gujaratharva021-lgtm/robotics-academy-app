import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.1,
            colors: [Color(0x334C6FFF), AppColors.bg1],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: AppColors.lineHi),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1C2B52), Color(0xFF0C1226)],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.blue.withOpacity(0.25), blurRadius: 50, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: const Icon(Icons.precision_manufacturing_rounded, size: 68, color: AppColors.blueHi),
                ),
                const SizedBox(height: 28),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppText.display(size: 26, weight: FontWeight.w700),
                    children: [
                      const TextSpan(text: 'AI ROBOTICS & AUTOMATION\n'),
                      TextSpan(text: 'ACADEMY', style: AppText.display(size: 26, weight: FontWeight.w700, color: AppColors.gold)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Learn. Build. Automate. An AI-powered learning platform for KG to postgraduate & professionals.',
                  textAlign: TextAlign.center,
                  style: AppText.muted(size: 13.5),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
                    child: Text('Get Started', style: AppText.body(size: 14.5, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lineHi),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
                    child: Text('Login', style: AppText.body(size: 14.5, weight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
