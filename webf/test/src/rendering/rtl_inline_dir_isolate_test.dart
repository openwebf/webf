/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/src/rendering/flow.dart';
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

  group('rtl/ltr inline direction', () {
    testWidgets('dir=ltr span isolates phone number in rtl container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'rtl-ltr-isolate-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="c" dir="rtl" style="font-size: 16px;">
                <span id="s" dir="ltr">+86987123456</span>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element container = prepared.getElementById('c');
      final dom.Element span = prepared.getElementById('s');
      expect(container.renderStyle.direction, TextDirection.rtl);
      expect(span.renderStyle.direction, TextDirection.ltr);

      final renderBoxModel = container.renderStyle.attachedRenderBoxModel;
      expect(renderBoxModel, isNotNull);
      expect(renderBoxModel, isA<RenderFlowLayout>());

      final RenderFlowLayout flow = renderBoxModel as RenderFlowLayout;
      final ifc = flow.inlineFormattingContext;
      expect(ifc, isNotNull);
      expect(ifc!.paragraph, isNotNull);

      final String textContent = ifc.textContent;
      final int plusIndex = textContent.indexOf('+');
      expect(plusIndex, greaterThanOrEqualTo(0));

      int lastDigitIndex = -1;
      for (int i = textContent.length - 1; i >= 0; i--) {
        final int cu = textContent.codeUnitAt(i);
        if (cu >= 0x30 && cu <= 0x39) {
          lastDigitIndex = i;
          break;
        }
      }
      expect(lastDigitIndex, greaterThan(plusIndex));

      final paragraph = ifc.paragraph!;
      final plusBoxes = paragraph.getBoxesForRange(plusIndex, plusIndex + 1);
      final lastDigitBoxes = paragraph.getBoxesForRange(lastDigitIndex, lastDigitIndex + 1);

      expect(plusBoxes, isNotEmpty);
      expect(lastDigitBoxes, isNotEmpty);

      final double plusCenter = (plusBoxes.first.left + plusBoxes.first.right) / 2.0;
      final double lastDigitCenter = (lastDigitBoxes.first.left + lastDigitBoxes.first.right) / 2.0;
      expect(plusCenter, lessThan(lastDigitCenter));
    });
  });
}
