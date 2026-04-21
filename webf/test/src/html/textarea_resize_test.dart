import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('textarea exposes resize handle and updates dimensions after drag',
      (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'textarea-resize-test-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) =>
          MaterialApp(home: Scaffold(body: SizedBox.expand(child: child))),
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <textarea id="ta" rows="5" style="width: 220px;">Resize me</textarea>
          </body>
        </html>
      ''',
    );

    final Finder shell = find.byKey(const ValueKey('webf-textarea-resize-shell'));
    final Finder handle = find.byKey(const ValueKey('webf-textarea-resize-handle'));

    expect(shell, findsOneWidget);
    expect(handle, findsOneWidget);

    final Size before = tester.getSize(shell);
    final Offset dragStart = tester.getBottomRight(shell) - const Offset(4, 4);
    await tester.dragFrom(dragStart, const Offset(36, 28));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final Size after = tester.getSize(shell);
    expect(after.height, greaterThan(before.height));

    final textarea = prepared.getElementById('ta');
    expect(textarea.style.getPropertyValue(WIDTH), isNotEmpty);
    expect(textarea.style.getPropertyValue(HEIGHT), isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('textarea respects resize vertical by preserving width styles',
      (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'textarea-vertical-resize-test-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) =>
          MaterialApp(home: Scaffold(body: SizedBox.expand(child: child))),
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <textarea id="ta" rows="4" style="width: 220px; resize: vertical;">Resize me</textarea>
          </body>
        </html>
      ''',
    );

    final Finder shell = find.byKey(const ValueKey('webf-textarea-resize-shell'));
    final Size before = tester.getSize(shell);
    final Offset dragStart = tester.getBottomRight(shell) - const Offset(4, 4);
    await tester.dragFrom(dragStart, const Offset(36, 28));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final Size after = tester.getSize(shell);
    expect(after.height, greaterThan(before.height));
    expect(after.width, before.width);

    final textarea = prepared.getElementById('ta');
    expect(textarea.style.getPropertyValue(WIDTH), '220px');
    expect(textarea.style.getPropertyValue(HEIGHT), isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
