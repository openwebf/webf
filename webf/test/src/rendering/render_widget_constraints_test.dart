import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/widget.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

class _TestConstraintsWidgetElement extends WidgetElement {
  _TestConstraintsWidgetElement(super.context);

  static BoxConstraints? lastLayoutConstraints;

  @override
  WebFWidgetElementState createState() {
    return _TestConstraintsWidgetElementState(this);
  }
}

class _TestConstraintsWidgetElementState extends WebFWidgetElementState {
  _TestConstraintsWidgetElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      _TestConstraintsWidgetElement.lastLayoutConstraints = constraints;
      // Avoid SizedBox.expand so this test widget remains safe even if a bug
      // accidentally forwards unbounded constraints.
      return const SizedBox.shrink();
    });
  }
}

class _TestConstraintsHostWidgetElement extends WidgetElement {
  _TestConstraintsHostWidgetElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return _TestConstraintsHostWidgetElementState(this);
  }
}

class _TestConstraintsHostWidgetElementState extends WebFWidgetElementState {
  _TestConstraintsHostWidgetElementState(super.widgetElement);

  @override
  _TestConstraintsHostWidgetElement get widgetElement => super.widgetElement as _TestConstraintsHostWidgetElement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}

class _ProbeEmbedder extends StatefulWidget {
  const _ProbeEmbedder({
    required this.controllerName,
    required this.webf,
  });

  final String controllerName;
  final Widget webf;

  @override
  State<_ProbeEmbedder> createState() => _ProbeEmbedderState();
}

class _ProbeEmbedderState extends State<_ProbeEmbedder> {
  WidgetElement? _probe;

  @override
  void initState() {
    super.initState();
    _scheduleProbeMount();
  }

  void _scheduleProbeMount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _probe != null) return;

      final WebFController? controller =
          WebFControllerManager.instance.getControllerSync(widget.controllerName);
      final dom.Element? element = controller?.view.document.getElementById(const ['probe']);
      if (element is! WidgetElement) {
        _scheduleProbeMount();
        return;
      }

      element.parentNode?.removeChild(element);
      setState(() {
        _TestConstraintsWidgetElement.lastLayoutConstraints = null;
        _probe = element;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.webf),
        if (_probe != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: WebFWidgetElementChild(
                child: _probe!.toWidget(),
              ),
            ),
          ),
      ],
    );
  }
}

void main() {
  const String kProbeTagName = 'WEBF-TEST-CONSTRAINTS-WIDGET';
  const String kHostTagName = 'WEBF-TEST-CONSTRAINTS-HOST';

  setUpAll(() {
    setupTest();
    if (!dom.getAllWidgetElements().containsKey(kProbeTagName)) {
      dom.defineWidgetElement(
        kProbeTagName,
        (context) => _TestConstraintsWidgetElement(context),
      );
    }
    if (!dom.getAllWidgetElements().containsKey(kHostTagName)) {
      dom.defineWidgetElement(
        kHostTagName,
        (context) => _TestConstraintsHostWidgetElement(context),
      );
    }
  });

  testWidgets('RenderWidget clamps child constraints to parent max', (WidgetTester tester) async {
    final String controllerName = 'render-widget-constraints-${DateTime.now().millisecondsSinceEpoch}';
    _TestConstraintsWidgetElement.lastLayoutConstraints = null;

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: controllerName,
      viewportWidth: 360,
      viewportHeight: 640,
        html: '''
        <body>
          <webf-test-constraints-widget id="probe"></webf-test-constraints-widget>
        </body>
      ''',
      wrap: (Widget webf) => Directionality(
        textDirection: TextDirection.ltr,
        child: _ProbeEmbedder(controllerName: controllerName, webf: webf),
      ),
    );

    // Give the embedder time to detach the probe from DOM and remount it under a bounded parent.
    for (int i = 0; i < 10 && _TestConstraintsWidgetElement.lastLayoutConstraints == null; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final BoxConstraints? constraints = _TestConstraintsWidgetElement.lastLayoutConstraints;
    expect(constraints, isNotNull);
    expect(constraints!.maxHeight, closeTo(200.0, 0.01));
  });

  testWidgets('RenderWidget uses WebFWidgetElementChild constraints when unbounded', (WidgetTester tester) async {
    final String controllerName = 'render-widget-wrapper-constraints-${DateTime.now().millisecondsSinceEpoch}';
    _TestConstraintsWidgetElement.lastLayoutConstraints = null;

    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: controllerName,
      viewportWidth: 360,
      viewportHeight: 640,
      html: '''
        <body>
          <webf-test-constraints-host id="host">
            <div id="wrapper">
              <webf-test-constraints-widget id="probe"></webf-test-constraints-widget>
            </div>
          </webf-test-constraints-host>
        </body>
      ''',
      wrap: (Widget webf) => Directionality(
        textDirection: TextDirection.ltr,
        child: webf,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Ensure the widget element is being laid out with an unbounded height by WebF layout.
    final dom.Element probe = prepared.getElementById('probe');
    final RenderObject? probeRenderer = probe.attachedRenderer;
    expect(probeRenderer, isNotNull);
    RenderObject? current = probeRenderer;
    while (current != null && current is! RenderBoxModel) {
      current = current.parent as RenderObject?;
    }
    expect(current, isA<RenderBoxModel>());
    expect((current! as RenderBoxModel).constraints.maxHeight.isInfinite, isTrue);

    // Despite the unbounded WebF constraints, the hosted Flutter widget must be clamped
    // by the outer WebFWidgetElementChild (SizedBox(height: 200)).
    final BoxConstraints? constraints = _TestConstraintsWidgetElement.lastLayoutConstraints;
    expect(constraints, isNotNull);
    expect(constraints!.maxHeight, closeTo(200.0, 0.01));
  });
}
