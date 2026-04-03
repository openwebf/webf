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

  testWidgets('block child inside inline content should not trip atomic inline assertion', (WidgetTester tester) async {
    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'inline-atomic-block-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <div style="width: 300px;">
          <span id="inline">
            before
            <div id="block" style="height: 30px;">block child</div>
            after
          </span>
        </div>
      ''',
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
