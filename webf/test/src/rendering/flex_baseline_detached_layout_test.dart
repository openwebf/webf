/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
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
    await Future.delayed(Duration(milliseconds: 100));
  });

  testWidgets('RenderFlexLayout baseline does not crash in detached layout', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'flex-detached-baseline-${DateTime.now().millisecondsSinceEpoch}',
      html: '<div></div>',
    );

    final dom.Document doc = prepared.controller.view.document;
    final BindingContext ctx =
        BindingContext(prepared.controller.view, prepared.controller.view.contextId, allocateNewBindingObject());
    final dom.Element element = doc.createElement('div', ctx);
    element.renderStyle.setProperty(DISPLAY, CSSDisplay.flex);
    element.renderStyle.setProperty(FLEX_DIRECTION, FlexDirection.row);
    element.renderStyle.setProperty(ALIGN_ITEMS, AlignItems.baseline);

    final RenderFlexLayout flex = RenderFlexLayout(renderStyle: element.renderStyle);
    flex.addAll(<RenderBox>[
      RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 40, height: 20)),
      RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 30, height: 10)),
    ]);

    expect(
      () => flex.layout(const BoxConstraints.tightFor(width: 200, height: 50)),
      returnsNormally,
    );

    // Baseline calculation should not assume parentData is always present
    // (e.g. during detached/intrinsic layout passes).
    final RenderBox? first = flex.firstChild;
    expect(first, isNotNull);
    first!.parentData = null;
    expect(() => flex.calculateBaseline(), returnsNormally);
  });
}
