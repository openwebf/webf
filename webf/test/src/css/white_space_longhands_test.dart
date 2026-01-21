/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
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

  testWidgets('white-space longhands update render style', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'white-space-longhands-test-${DateTime.now().millisecondsSinceEpoch}',
      createController: () => WebFController(
        enableBlink: true,
        viewportWidth: 360,
        viewportHeight: 640,
      ),
      bundle: WebFBundle.fromContent(
        '<html><body><div id="box">hello</div></body></html>',
        url: 'test://white-space-longhands/',
        contentType: htmlContentType,
      ),
    );

    final box = prepared.getElementById('box');

    Future<void> pumpStyle() async {
      box.style.flushPendingProperties();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    box.setInlineStyle('whiteSpaceCollapse', 'preserve');
    box.setInlineStyle('textWrap', 'wrap');
    await pumpStyle();

    expect(box.renderStyle.whiteSpaceCollapse, equals(WhiteSpaceCollapse.preserve));
    expect(box.renderStyle.textWrapMode, equals(TextWrapMode.wrap));
    expect(box.renderStyle.textWrapStyle, equals(TextWrapStyle.auto));
    expect(box.renderStyle.textWrap, equals(TextWrap.wrap));
    expect(box.renderStyle.whiteSpace, equals(WhiteSpace.preWrap));

    // Shorthand updates both longhands.
    box.setInlineStyle('textWrap', 'pretty');
    await pumpStyle();
    expect(box.renderStyle.textWrapMode, equals(TextWrapMode.wrap));
    expect(box.renderStyle.textWrapStyle, equals(TextWrapStyle.pretty));
    expect(box.renderStyle.textWrap, equals(TextWrap.pretty));

    // white-space shorthand updates collapse + mode but preserves style.
    box.setInlineStyle('whiteSpace', 'nowrap');
    await pumpStyle();
    expect(box.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
    expect(box.renderStyle.textWrapStyle, equals(TextWrapStyle.pretty));

    box.setInlineStyle('whiteSpace', 'normal');
    await pumpStyle();
    expect(box.renderStyle.whiteSpace, equals(WhiteSpace.normal));
    expect(box.renderStyle.textWrapStyle, equals(TextWrapStyle.pretty));
    expect(box.renderStyle.textWrap, equals(TextWrap.pretty));
  });
}
