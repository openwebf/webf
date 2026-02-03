import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import '../../setup.dart';
import '../widget/test_utils.dart';

class _FlutterIFCHostElement extends WidgetElement {
  _FlutterIFCHostElement(super.context);

  @override
  WebFWidgetElementState createState() => _FlutterIFCHostState(this);
}

class _FlutterIFCHostState extends WebFWidgetElementState {
  _FlutterIFCHostState(super.widgetElement);

  _FlutterIFCHostElement get host => widgetElement as _FlutterIFCHostElement;

  @override
  Widget build(BuildContext context) {
    // Render the first DOM child directly under RenderWidget without inserting
    // an extra block container that would establish an ancestor IFC.
    dom.Element? firstElementChild;
    for (final node in host.childNodes) {
      if (node is dom.Element) {
        firstElementChild = node;
        break;
      }
    }
    return WebFWidgetElementChild(
      child: firstElementChild != null ? firstElementChild.toWidget() : const SizedBox.shrink(),
    );
  }
}

void main() {
  setUpAll(() {
    setupTest();
    WebF.defineCustomElement('flutter-ifc-host', (context) => _FlutterIFCHostElement(context));
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

  testWidgets('inline <span> under RenderWidget establishes local IFC', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'inline-span-local-ifc-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <flutter-ifc-host id="host" style="height: 48px;">
          <span id="s" style="font-size: 20px; line-height: 24px;">
            USD<!-- -->/<!-- -->USDT
          </span>
        </flutter-ifc-host>
      ''',
    );

    await tester.pump();
    await tester.pump();

    final span = prepared.getElementById('s');
    expect(span, isNotNull);

    final renderBox = span.attachedRenderer;
    expect(renderBox, isA<RenderFlowLayout>());

    final RenderFlowLayout flow = renderBox as RenderFlowLayout;
    expect(flow.establishIFC, isTrue);
    expect(flow.hasSize, isTrue);
    final ifc = flow.inlineFormattingContext;
    expect(ifc, isNotNull);
    expect(ifc!.paragraphLineMetrics.length, 1);
    expect(ifc.paragraphLineMetrics.first.height, moreOrLessEquals(24.0, epsilon: 0.8));
  });
}
