import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asigment2/widgets/profile_action_button.dart';
import 'package:asigment2/widgets/theme_toggle_button.dart';

void main() {
  testWidgets('ThemeToggleButton and ProfileActionButton have matching dimensions', (
    WidgetTester tester,
  ) async {
    bool themeToggled = false;
    bool profileOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              ThemeToggleButton(
                size: 42.0,
                onPressed: () => themeToggled = true,
              ),
              const SizedBox(width: 8),
              ProfileActionButton(
                size: 42.0,
                onPressed: () => profileOpened = true,
              ),
            ],
          ),
        ),
      ),
    );

    // Verify both widgets exist
    expect(find.byType(ThemeToggleButton), findsOneWidget);
    expect(find.byType(ProfileActionButton), findsOneWidget);

    // Verify both render with 42x42 dimensions
    final themeButtonSize = tester.getSize(find.byType(ThemeToggleButton));
    final profileButtonSize = tester.getSize(find.byType(ProfileActionButton));

    expect(themeButtonSize.width, 42.0);
    expect(themeButtonSize.height, 42.0);
    expect(profileButtonSize.width, 42.0);
    expect(profileButtonSize.height, 42.0);

    // Test tap interactions
    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();
    expect(themeToggled, isTrue);

    await tester.tap(find.byType(ProfileActionButton));
    await tester.pumpAndSettle();
    expect(profileOpened, isTrue);
  });
}
