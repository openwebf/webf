import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/widget.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

class _PortalMarker extends InheritedWidget {
  const _PortalMarker({required super.child});

  static bool isPortal(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PortalMarker>() != null;

  @override
  bool updateShouldNotify(_PortalMarker oldWidget) => false;
}

class _PortalProbeWidgetElement extends WidgetElement {
  _PortalProbeWidgetElement(super.context);

  static BoxConstraints? lastPortalConstraints;

  @override
  WebFWidgetElementState createState() => _PortalProbeWidgetElementState(this);
}

class _PortalProbeWidgetElementState extends WebFWidgetElementState {
  _PortalProbeWidgetElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (_PortalMarker.isPortal(context)) {
          _PortalProbeWidgetElement.lastPortalConstraints = constraints;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PortalEmbedder extends StatefulWidget {
  const _PortalEmbedder({
    required this.controllerName,
    required this.webf,
  });

  final String controllerName;
  final Widget webf;

  @override
  State<_PortalEmbedder> createState() => _PortalEmbedderState();
}

class _PortalEmbedderState extends State<_PortalEmbedder> {
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

      setState(() {
        _PortalProbeWidgetElement.lastPortalConstraints = null;
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 200,
              ),
              child: _PortalMarker(
                child: WebFWidgetElementChild(
                  // Mount the same WidgetElement into a different Flutter subtree (portal)
                  // while it remains in the DOM. Use a unique key to avoid duplicate-key
                  // collisions with the DOM-mounted instance.
                  child: _probe!.toWidget(key: UniqueKey()),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

void main() {
  const String kProbeTagName = 'WEBF-TEST-PORTAL-PROBE';

  setUpAll(() {
    setupTest();
    if (!dom.getAllWidgetElements().containsKey(kProbeTagName)) {
      dom.defineWidgetElement(
        kProbeTagName,
        (context) => _PortalProbeWidgetElement(context),
      );
    }
  });

  testWidgets('WidgetElement width is not clamped by DOM parent in portal subtree',
      (WidgetTester tester) async {
    final String controllerName = 'portal-probe-${DateTime.now().millisecondsSinceEpoch}';
    _PortalProbeWidgetElement.lastPortalConstraints = null;

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: controllerName,
      viewportWidth: 360,
      viewportHeight: 640,
      html: '''
        <body style="margin: 0; padding: 0;">
          <div style="width: 36px;">
            <$kProbeTagName id="probe"></$kProbeTagName>
          </div>
        </body>
      ''',
      wrap: (Widget webf) => Directionality(
        textDirection: TextDirection.ltr,
        child: _PortalEmbedder(controllerName: controllerName, webf: webf),
      ),
    );

    for (int i = 0; i < 10 && _PortalProbeWidgetElement.lastPortalConstraints == null; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final BoxConstraints? portalConstraints = _PortalProbeWidgetElement.lastPortalConstraints;
    expect(portalConstraints, isNotNull);
    expect(portalConstraints!.maxWidth, closeTo(300.0, 0.01));
  });
}
