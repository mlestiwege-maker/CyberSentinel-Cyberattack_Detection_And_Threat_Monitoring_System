// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:cybersentinel_frontend/main.dart';

void main() {
  testWidgets('CyberSentinel shows the auth gate by default', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('CyberSentinel'), findsWidgets);
    expect(find.text('Team Login'), findsOneWidget);
    expect(find.text('Need an account? Register here'), findsOneWidget);
  });
}
