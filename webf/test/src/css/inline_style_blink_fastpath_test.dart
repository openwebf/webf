/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

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

  testWidgets('Blink native style updates skip Dart validation', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'blink-inline-style-fastpath-test-${DateTime.now().millisecondsSinceEpoch}',
      createController: () => WebFController(
        enableBlink: true,
        viewportWidth: 360,
        viewportHeight: 640,
      ),
      bundle: WebFBundle.fromContent(
        '<html><body><div id="box"></div></body></html>',
        url: 'test://blink-inline-style-fastpath/',
        contentType: htmlContentType,
      ),
    );

    final box = prepared.getElementById('box');

    box.setInlineStyle('fontSize', '16px');
    expect(box.style.getPropertyValue('fontSize'), equals('16px'));

    // Dart-side validation should still apply for local calls.
    box.setInlineStyle('fontSize', '-1px');
    expect(box.style.getPropertyValue('fontSize'), equals('16px'));

    // Native-side (Blink) validated values should bypass Dart validation.
    box.setInlineStyle('fontSize', '-2px', fromNative: true);
    expect(box.style.getPropertyValue('fontSize'), equals('-2px'));
  });
}

