// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Create and initialize the HabitProvider
    final habitProvider = HabitProvider();
    await habitProvider.initialize();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(habitProvider: habitProvider));

    // Verify that the splash screen is shown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
