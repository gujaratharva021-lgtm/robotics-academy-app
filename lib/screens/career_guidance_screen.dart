import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/career_roadmaps.dart';
import '../models/roadmap_model.dart';

/// Career Guidance — Roadmaps tab.
/// Shows a horizontal category selector and a vertical timeline of steps
/// (course -> skill -> project) for the selected career path.
class CareerGuidanceScreen extends StatefulWidget {
  const CareerGuidanceScreen({super.key});

  @override
  State<CareerGuidanceScreen> createState() => _CareerGuidanceScreenState();
}

class _CareerGuidanceScreenState extends State<CareerGuidanceScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final roadmap = careerRoadmaps[_selected];

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Career Roadmaps', style: AppText.display(size: 17)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: careerRoadmaps.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final r = careerRoadmaps[i];
                  final active = i == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? r.color.withOpacity(0.18) : AppColors.panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? r.color : AppColors.line),
                      ),
                      child: Row(
                        children: [
                          Icon(r.icon, size: 15, color: active ? r.color : AppColors.text1),
                          const SizedBox(width: 6),
                          Text(
                            r.category,
                            style: AppText.body(
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: active ? AppColors.text0 : AppColors.text1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: panelDecoration(),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: roadmap.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(roadmap.icon, color: roadmap.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(roadmap.description, style: AppText.muted(size: 12.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (int i = 0; i < roadmap.steps.length; i++)
                    _stepCard(
                      roadmap.steps[i],
                      i,
                      roadmap.color,
                      isLast: i == roadmap.steps.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard(RoadmapStep step, int index, Color color, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '${index + 1}',
                  style: AppText.body(size: 12.5, weight: FontWeight.w700, color: AppColors.bg0),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.line)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: panelDecoration(radius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: AppText.body(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _tagRow(Icons.menu_book_outlined, 'Course', step.course, color),
                    const SizedBox(height: 6),
                    _tagRow(Icons.bolt_outlined, 'Skill', step.skill, color),
                    const SizedBox(height: 6),
                    _tagRow(Icons.build_outlined, 'Project', step.project, color),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppText.body(size: 12, weight: FontWeight.w600, color: AppColors.text1),
                ),
                TextSpan(text: value, style: AppText.muted(size: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}