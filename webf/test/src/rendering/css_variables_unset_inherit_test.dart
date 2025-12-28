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
        maxAliveInstances: 3,
        maxAttachedInstances: 3,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });

  testWidgets('custom property `unset` inherits from parent', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'css-var-unset-inherit-test-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <head>
            <style>
              body {
                --a: green;
                color: crimson;
              }
              p { color: red; }
              p {
                color: orange;
                --a: unset;
                color: var(--a);
              }
            </style>
          </head>
          <body style="margin: 0; padding: 0;">
            <p id="t">This text must be green.</p>
          </body>
        </html>
      ''',
    );

    final p = prepared.getElementById('t');
    final expected = CSSColor.parseColor('green')!.toARGB32();
    expect(p.renderStyle.color.value.toARGB32(), equals(expected));
  });
}

