import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_mi_skill/main.dart';

void main() {
  testWidgets('App starts and shows main page', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(sharedPreferences: sharedPreferences));

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
