import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const OneRoboticsAiApp());
}

class OneRoboticsAiApp extends StatelessWidget {
  const OneRoboticsAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Robotics Ai',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
