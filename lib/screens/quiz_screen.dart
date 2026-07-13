import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  const QuizScreen({super.key, required this.courseId, this.courseTitle = 'Course Quiz'});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int qIndex = 0;
  int? selected;
  int score = 0;
  bool done = false;
  bool saving = false;

  late Future<List<QuizQuestion>> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = FirestoreService.getQuiz(widget.courseId);
  }

  void _select(int i, List<QuizQuestion> quiz) {
    if (selected != null) return;
    setState(() {
      selected = i;
      if (i == quiz[qIndex].answerIndex) score++;
    });
  }

  Future<void> _next(List<QuizQuestion> quiz) async {
    if (qIndex == quiz.length - 1) {
      setState(() {
        done = true;
        saving = true;
      });
      final pct = ((score / quiz.length) * 100).round();
      if (pct >= 70) {
        await FirestoreService.addCertificate(widget.courseTitle, 'FF4C6FFF');
      }
      if (mounted) setState(() => saving = false);
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
      body: SafeArea(
        child: FutureBuilder<List<QuizQuestion>>(
          future: _quizFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No quiz questions found for this course yet.',
                    textAlign: TextAlign.center,
                    style: AppText.body(size: 13.5, color: AppColors.text2),
                  ),
                ),
              );
            }
            final quiz = snapshot.data!;
            return done ? _resultView(context, quiz) : _questionView(context, quiz);
          },
        ),
      ),
    );
  }

  Widget _resultView(BuildContext context, List<QuizQuestion> quiz) {
    final pct = ((score / quiz.length) * 100).round();
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
              good
                  ? 'You scored $score out of ${quiz.length} — certificate earned and saved to your profile!'
                  : 'You scored $score out of ${quiz.length} — score 70% or higher to earn a certificate.',
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
                onPressed: saving ? null : () => Navigator.pop(context),
                child: saving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text('Back to Course', style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionView(BuildContext context, List<QuizQuestion> quiz) {
    final q = quiz[qIndex];
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
            Text('${qIndex + 1}/${quiz.length}', style: AppText.mono()),
          ]),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: qIndex / quiz.length,
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
              onTap: () => _select(i, quiz),
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
                onPressed: () => _next(quiz),
                child: Text(qIndex == quiz.length - 1 ? 'See Results' : 'Next Question',
                    style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}