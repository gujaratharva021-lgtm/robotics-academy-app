import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificatePdfService {
  static final PdfColor _maroon = PdfColor.fromInt(0xFF6B1B3A);
  static final PdfColor _gold = PdfColor.fromInt(0xFFC79A3B);
  static final PdfColor _darkText = PdfColor.fromInt(0xFF1A1A1A);

  static Future<Uint8List> generate({
    required String studentName,
    required String courseTitle,
    required String dateStr,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _gold, width: 3),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _maroon, width: 1.5),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'CERTIFICATE',
                    style: pw.TextStyle(
                      fontSize: 34,
                      fontWeight: pw.FontWeight.bold,
                      color: _darkText,
                      letterSpacing: 6,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'OF ACHIEVEMENT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: _maroon,
                      letterSpacing: 4,
                    ),
                  ),
                  pw.SizedBox(height: 28),
                  pw.Text(
                    'THIS CERTIFICATE IS PROUDLY PRESENTED TO',
                    style: pw.TextStyle(fontSize: 11, color: _darkText, letterSpacing: 2),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    studentName,
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontStyle: pw.FontStyle.italic,
                      color: _maroon,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Container(width: 220, height: 1, color: _gold),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'for successfully completing the course',
                    style: pw.TextStyle(fontSize: 12, color: _darkText),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    courseTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _darkText),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'AI Robotics & Automation Academy',
                    style: pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666)),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(width: 140, height: 1, color: _gold),
                          pw.SizedBox(height: 4),
                          pw.Text('AI Robotics Academy', style: pw.TextStyle(fontSize: 10, color: _darkText)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(width: 140, height: 1, color: _gold),
                          pw.SizedBox(height: 4),
                          pw.Text(dateStr, style: pw.TextStyle(fontSize: 10, color: _darkText)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}