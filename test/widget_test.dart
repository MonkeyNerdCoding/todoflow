// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todoflow/main.dart';

void main() {
  testWidgets('TodoFlow app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TodoFlowApp(),
      ),
    );

    // Pump a few frames to allow initial rendering
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

  // Verify that our app starts with Home screen (greeting varies by time).
  expect(find.textContaining('Good '), findsOneWidget);

    // Verify bottom navigation is present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    
    // Verify FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
