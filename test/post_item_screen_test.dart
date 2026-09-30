import 'package:asigment2/screens/post_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fontLoader = FontLoader('SF Pro')
      ..addFont(rootBundle.load('assets/fonts/SF-Pro-Text-Regular.otf'));
    await fontLoader.load();
  });

  for (final width in [320.0, 393.0]) {
    testWidgets('form hints fit on a ${width.toInt()}px phone', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'SF Pro'),
          home: const PostItemScreen(),
        ),
      );

      for (final hint in [
        'e.g. Blue backpack',
        'e.g. Library, 2nd floor',
        'e.g. Main security desk',
      ]) {
        final renderParagraph = tester.renderObject<RenderParagraph>(
          find.text(hint),
        );
        expect(renderParagraph.didExceedMaxLines, isFalse, reason: hint);
      }

      expect(tester.takeException(), isNull);
    });
  }
}
