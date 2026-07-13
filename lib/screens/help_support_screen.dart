import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I earn a certificate?',
      'a': 'Complete a course and pass its quiz. A certificate is automatically generated and added to your profile.',
    },
    {
      'q': 'Is the AI Tutor available 24/7?',
      'a': 'Yes! The AI Tutor is available anytime to help explain robotics, AI, and automation concepts.',
    },
    {
      'q': 'How do I save a course for later?',
      'a': 'Open any course and tap the bookmark icon. It will appear in your Saved Courses list on your profile.',
    },
    {
      'q': 'Can I use the app without an internet connection?',
      'a': 'You need an internet connection to load courses, use the AI Tutor, and sync your progress.',
    },
    {
      'q': 'How do I turn off notifications?',
      'a': 'Go to Profile > Settings > Notifications and toggle push notifications off.',
    },
  ];

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'gujaratharva021@gmail.com',
      query: 'subject=Robotics Academy App - Support Request',
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open your email app.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                _backButton(context),
                Expanded(child: Text('Help & Support', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                const SizedBox(width: 38),
              ],
            ),
            const SizedBox(height: 20),

            Text('FREQUENTLY ASKED QUESTIONS', style: AppText.display(size: 12, weight: FontWeight.w600, color: AppColors.text2).copyWith(letterSpacing: 1.0)),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faq['q']!, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(faq['a']!, style: AppText.muted(size: 12.5)),
                ],
              ),
            )),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => _emailSupport(context),
                icon: const Icon(Icons.email_outlined, color: Colors.white, size: 18),
                label: Text('Email Support', style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
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
}