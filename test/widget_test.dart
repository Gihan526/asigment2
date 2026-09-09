// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asigment2/main.dart';
import 'package:asigment2/widgets/campus_mark.dart';

void main() {
  testWidgets('renders the campus login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLostFoundApp());
    await tester.pumpAndSettle();

    expect(find.byType(CampusMark), findsOneWidget);
    expect(find.descendant(of: find.byType(CampusMark), matching: find.byType(Image)), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Campus email'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('navigates to create account screen and back', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLostFoundApp());
    await tester.pumpAndSettle();

    // Scroll to and tap "Create account" text button on login screen
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    // Verify CreateAccountScreen is displayed
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);

    // Scroll to and tap "Log in" to navigate back
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    // Verify back on login screen
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
