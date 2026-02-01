import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('Webkit-prefixed flexbox properties', () {
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

    testWidgets('WebkitAlignItems aliases alignItems and triggers relayout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'webkit-align-items-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; height: 100px;">
                <div id="item" style="border: 5px solid green; width: 50px;"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element container = prepared.getElementById('container');
      final dom.Element item = prepared.getElementById('item');

      await tester.pump();
      expect(item.getBoundingClientRect().height, closeTo(100, 0.5));

      container.setInlineStyle('WebkitAlignItems', 'flex-start');
      container.style.flushPendingProperties();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(item.getBoundingClientRect().height, closeTo(10, 0.5));

      container.setInlineStyle('alignItems', 'stretch');
      container.style.flushPendingProperties();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(item.getBoundingClientRect().height, closeTo(100, 0.5));
    });
  });
}
