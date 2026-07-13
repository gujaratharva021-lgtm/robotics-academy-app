import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/certificate_pdf_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late Future<List<Map<String, dynamic>>> _certsFuture;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _certsFuture = FirestoreService.getCertificates();
  }

  Future<void> _downloadCertificate(Map<String, dynamic> cert) async {
    setState(() => _generating = true);
    try {
      final user = AuthService.currentUser;
      final studentName = (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'Student';

      final dateStr = cert['date'] ?? '';
      String formattedDate = dateStr;
      try {
        final dt = DateTime.parse(dateStr);
        formattedDate = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}

      final bytes = await CertificatePdfService.generate(
        studentName: studentName,
        courseTitle: cert['title'] ?? 'Course',
        dateStr: formattedDate,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${(cert['title'] ?? 'certificate').toString().replaceAll(' ', '_')}_certificate.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate certificate: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  TextStyle _noUnderline(TextStyle style) => style.copyWith(decoration: TextDecoration.none);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _certsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final certs = snapshot.data ?? [];

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Certificates', style: _noUnderline(AppText.display(size: 19))),
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
                if (certs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No certificates yet.\nComplete a course quiz with 70%+ to earn one!',
                        textAlign: TextAlign.center,
                        style: _noUnderline(AppText.muted(size: 13)),
                      ),
                    ),
                  ),
                ...certs.map((cert) {
                  final colorHex = cert['color'] ?? 'FFF5B942';
                  final color = Color(int.parse(colorHex, radix: 16));
                  final dateStr = cert['date'] ?? '';
                  String formattedDate = dateStr;
                  try {
                    final dt = DateTime.parse(dateStr);
                    formattedDate = '${dt.day}/${dt.month}/${dt.year}';
                  } catch (_) {}

                  return Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.workspace_premium_rounded, color: color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cert['title'] ?? '',
                                style: _noUnderline(AppText.body(size: 14, weight: FontWeight.w600)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Certificate of Completion',
                                style: _noUnderline(AppText.muted(size: 12)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Issued on: $formattedDate',
                                style: _noUnderline(AppText.muted(size: 11)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _generating ? null : () => _downloadCertificate(cert),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.download_rounded, color: AppColors.blueHi, size: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            if (_generating)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
