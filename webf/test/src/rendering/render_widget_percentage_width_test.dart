import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:webf/widget.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

class _TestPercentageWidthWidgetElement extends WidgetElement {
  _TestPercentageWidthWidgetElement(super.context);

  static BoxConstraints? lastLayoutConstraints;

  @override
  WebFWidgetElementState createState() {
    return _TestPercentageWidthWidgetElementState(this);
  }
}

class _TestPercentageWidthWidgetElementState extends WebFWidgetElementState {
  _TestPercentageWidthWidgetElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      _TestPercentageWidthWidgetElement.lastLayoutConstraints = constraints;
      return const SizedBox.shrink();
    });
  }
}

void main() {
  const String kProbeTagName = 'WEBF-TEST-PERCENTAGE-WIDTH-WIDGET';

  setUpAll(() {
    setupTest();
    if (!dom.getAllWidgetElements().containsKey(kProbeTagName)) {
      dom.defineWidgetElement(
        kProbeTagName,
        (context) => _TestPercentageWidthWidgetElement(context),
      );
    }
  });

  testWidgets('RenderWidget tightens percentage width when definite', (WidgetTester tester) async {
    final String controllerName = 'render-widget-percentage-width-${DateTime.now().millisecondsSinceEpoch}';
    _TestPercentageWidthWidgetElement.lastLayoutConstraints = null;

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: controllerName,
      viewportWidth: 360,
      viewportHeight: 640,
      html: '''
        <body style="margin: 0">
          <div style="width: 320px;">
            <webf-test-percentage-width-widget
              id="probe"
              style="display: block; width: 100%;"
            ></webf-test-percentage-width-widget>
          </div>
        </body>
      ''',
      wrap: (Widget webf) => Directionality(
        textDirection: TextDirection.ltr,
        child: webf,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final BoxConstraints? constraints = _TestPercentageWidthWidgetElement.lastLayoutConstraints;
    expect(constraints, isNotNull);
    expect(constraints!.minWidth, closeTo(320.0, 0.01));
    expect(constraints.maxWidth, closeTo(320.0, 0.01));
  });
}
