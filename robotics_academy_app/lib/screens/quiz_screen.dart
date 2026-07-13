import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int qIndex = 0;
  int? selected;
  int score = 0;
  bool done = false;

  void _select(int i) {
    if (selected != null) return;
    setState(() {
      selected = i;
      if (i == kQuiz[qIndex].answerIndex) score++;
    });
  }

  void _next() {
    if (qIndex == kQuiz.length - 1) {
      setState(() => done = true);
    } else {
      setState(() {
        qIndex++;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(child: done ? _resultView(context) : _questionView(context)),
    );
  }

  Widget _resultView(BuildContext context) {
    final pct = ((score / kQuiz.length) * 100).round();
    final good = pct >= 70;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (good ? AppColors.green : AppColors.red).withOpacity(0.14),
              ),
              child: Center(child: Text('$pct%', style: AppText.display(size: 26, color: good ? AppColors.green : AppColors.red))),
            ),
            const SizedBox(height: 22),
            Text(good ? 'Great job! 🎉' : 'Keep practicing!', style: AppText.display(size: 18)),
            const SizedBox(height: 8),
            Text(
              'You scored $score out of ${kQuiz.length} — earn your certificate by completing the full course.',
              textAlign: TextAlign.center,
              style: AppText.muted(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Course', style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionView(BuildContext context) {
    final q = kQuiz[qIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
              ),
            ),
            Expanded(child: Text('Quiz', textAlign: TextAlign.center, style: AppText.display(size: 17))),
            Text('${qIndex + 1}/${kQuiz.length}', style: AppText.mono()),
          ]),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: qIndex / kQuiz.length,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.blue),
            ),
          ),
          const SizedBox(height: 24),
          Text(q.question, style: AppText.display(size: 17)),
          const SizedBox(height: 20),
          ...List.generate(q.options.length, (i) {
            Color border = AppColors.line;
            Color? bg;
            if (selected != null) {
              if (i == q.answerIndex) {
                border = AppColors.green;
                bg = AppColors.green.withOpacity(0.12);
              } else if (i == selected) {
                border = AppColors.red;
                bg = AppColors.red.withOpacity(0.12);
              }
            }
            return GestureDetector(
              onTap: () => _select(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg ?? AppColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                child: Text(q.options[i], style: AppText.body(size: 14)),
              ),
            );
          }),
          if (selected != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _next,
                child: Text(qIndex == kQuiz.length - 1 ? 'See Results' : 'Next Question',
                    style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
