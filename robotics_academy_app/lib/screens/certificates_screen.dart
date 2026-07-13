import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../data/mock_data.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Certificates', style: AppText.display(size: 19)),
            const Icon(Icons.more_vert_rounded, color: AppColors.text1),
          ],
        ),
        const SizedBox(height: 18),
        Row(children: [
          Pill(label: 'All', active: true, onTap: () {}),
          Pill(label: 'Completed', active: false, onTap: () {}),
          Pill(label: 'In Progress', active: false, onTap: () {}),
        ]),
        const SizedBox(height: 18),
        ...kCertificates.map((cert) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.lineHi),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A2547), Color(0xFF101833)],
                ),
              ),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: cert.color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.workspace_premium_rounded, color: cert.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.title, style: AppText.body(size: 14, weight: FontWeight.w600)),
                      Text('Certificate of Completion', style: AppText.muted(size: 12)),
                      const SizedBox(height: 2),
                      Text('Issued on: ${cert.date}', style: AppText.muted(size: 11)),
                    ],
                  ),
                ),
                const AppBadge(label: '★', color: AppColors.gold),
              ]),
            )),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.lineHi),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {},
            child: Text('View All Certificates', style: AppText.body(size: 13.5, weight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
