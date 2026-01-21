import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:webf/widget.dart';
import 'package:webf/rendering.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

const String _kExpandedProbeTagName = 'WEBF-TEST-FLEX-EXPANDED-PROBE';

class _ExpandedProbeWidgetElement extends WidgetElement {
  _ExpandedProbeWidgetElement(BindingContext? context) : super(context);

  static BoxConstraints? lastLayoutConstraints;

  @override
  WebFWidgetElementState createState() => _ExpandedProbeWidgetElementState(this);
}

class _ExpandedProbeWidgetElementState extends WebFWidgetElementState {
  _ExpandedProbeWidgetElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const _ConstraintsCapture();
  }
}

class _ConstraintsCapture extends LeafRenderObjectWidget {
  const _ConstraintsCapture();

  @override
  RenderObject createRenderObject(BuildContext context) => _ConstraintsCaptureRenderBox();
}

class _ConstraintsCaptureRenderBox extends RenderBox {
  @override
  void performLayout() {
    _ExpandedProbeWidgetElement.lastLayoutConstraints = constraints;
    size = constraints.constrain(Size.zero);
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}

class _UnboundedWidthEmbedder extends StatefulWidget {
  const _UnboundedWidthEmbedder({
    required this.controllerName,
    required this.webf,
  });

  final String controllerName;
  final Widget webf;

  @override
  State<_UnboundedWidthEmbedder> createState() => _UnboundedWidthEmbedderState();
}

class _UnboundedWidthEmbedderState extends State<_UnboundedWidthEmbedder> {
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
        _ExpandedProbeWidgetElement.lastLayoutConstraints = null;
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
            top: 0,
            child: UnconstrainedBox(
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
  setUpAll(() {
    setupTest();
    if (!dom.getAllWidgetElements().containsKey(_kExpandedProbeTagName)) {
      dom.defineWidgetElement(
        _kExpandedProbeTagName,
        (context) => _ExpandedProbeWidgetElement(context),
      );
    }
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

  testWidgets('RenderWidget clamps unbounded width even when min-width is set', (WidgetTester tester) async {
    _ExpandedProbeWidgetElement.lastLayoutConstraints = null;

    final String controllerName = 'widget-min-width-unbounded-${DateTime.now().millisecondsSinceEpoch}';
    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: controllerName,
      html: '''
        <body style="margin: 0; padding: 0;">
          <webf-test-flex-expanded-probe id="probe" style="min-width: 0;"></webf-test-flex-expanded-probe>
        </body>
      ''',
      wrap: (Widget webf) => Directionality(
        textDirection: TextDirection.ltr,
        child: _UnboundedWidthEmbedder(controllerName: controllerName, webf: webf),
      ),
    );

    // Ensure any framework exceptions are surfaced.
    expect(tester.takeException(), isNull);

    final BoxConstraints? constraints = _ExpandedProbeWidgetElement.lastLayoutConstraints;
    expect(constraints, isNotNull);
    expect(constraints!.hasBoundedWidth, isTrue);
    expect(constraints.maxWidth.isFinite, isTrue);
  });
}
