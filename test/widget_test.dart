import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:robotics_academy_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RoboticsAcademyApp());

    // Just verify the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}