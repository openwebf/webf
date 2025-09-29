import 'package:flutter_test/flutter_test.dart';
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
        maxAliveInstances: 3,
        maxAttachedInstances: 3,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('img min-height scales width by intrinsic ratio', (WidgetTester tester) async {
    final name = 'img-min-height-scale-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin:0">
            <div id="box" style="width:200px;height:200px;background:#999;box-sizing:border-box;">
              <img id="img" style="min-height:200px;box-sizing:border-box;background:green;"
                   src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAAFElEQVR4nO3BMQEAAADCoPVPbQhPoAAAAAAAAKkKc7cAAZK7J0EAAAAASUVORK5CYII=" />
            </div>
          </body>
        </html>
      ''',
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    final img = prepared.getElementById('img');
    expect(img.offsetHeight, equals(200.0));
    expect(img.offsetWidth, equals(200.0), reason: 'Width should scale with min-height preserving 1:1 ratio');
  });

  testWidgets('img min-width scales height by intrinsic ratio', (WidgetTester tester) async {
    final name = 'img-min-width-scale-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin:0">
            <div id="box" style="width:200px;height:200px;background:#999;box-sizing:border-box;">
              <img id="img" style="min-width:200px;box-sizing:border-box;background:green;"
                   src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAAFElEQVR4nO3BMQEAAADCoPVPbQhPoAAAAAAAAKkKc7cAAZK7J0EAAAAASUVORK5CYII=" />
            </div>
          </body>
        </html>
      ''',
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    final img = prepared.getElementById('img');
    expect(img.offsetWidth, equals(200.0));
    expect(img.offsetHeight, equals(200.0), reason: 'Height should scale with min-width preserving 1:1 ratio');
  });
}
