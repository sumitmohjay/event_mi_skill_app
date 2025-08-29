import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_mi_skill/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
