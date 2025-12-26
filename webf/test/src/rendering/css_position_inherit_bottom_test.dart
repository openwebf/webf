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
        maxAliveInstances: 3,
        maxAttachedInstances: 3,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 50));
  });

  testWidgets('bottom:inherit resolves to parent used offset', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '''
<style>*{box-sizing:border-box}body{margin:0;padding:0}</style>
<div id="parent" style="position:relative;height:96px;margin-top:192px;box-sizing:border-box;">
  <div id="div1" style="position:relative;border-top:1in solid red;height:96px;bottom:100%;box-sizing:border-box;">
    <div id="div2" style="position:relative;border-top:1in solid black;bottom:inherit;box-sizing:border-box;"></div>
  </div>
</div>
''',
    );

    final div2 = prepared.getElementById('div2');

    expect(div2.style.getPropertyValue('bottom'), equals('inherit'));
    expect(div2.renderStyle.bottom.isNotAuto, isTrue);
    // Parent computed value is `100%` (not the parent's used px), so for div2 the percentage
    // resolves against div1's padding-box height. Here div1's border consumes the entire 96px
    // height, so padding-box height is 0 and the used offset is 0.
    expect(div2.renderStyle.bottom.computedValue, closeTo(0, 0.001));
  });
}
