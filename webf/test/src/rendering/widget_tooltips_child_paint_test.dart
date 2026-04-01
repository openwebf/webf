import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

class _FlutterToolTipsElement extends WidgetElement {
  _FlutterToolTipsElement(super.context);

  @override
  WebFWidgetElementState createState() => _FlutterToolTipsElementState(this);
}

class _FlutterToolTipsElementState extends WebFWidgetElementState {
  _FlutterToolTipsElementState(super.widgetElement);

  _FlutterToolTipsElement get tooltipsElement =>
      widgetElement as _FlutterToolTipsElement;

  @override
  Widget build(BuildContext context) {
    dom.Element? firstElementChild;
    for (final dom.Node node in tooltipsElement.childNodes) {
      if (node is dom.Element) {
        firstElementChild = node;
        break;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: firstElementChild != null
          ? WebFWidgetElementChild(child: firstElementChild.toWidget())
          : const SizedBox.shrink(),
    );
  }
}

class _FlutterAutoSizeTextElement extends WidgetElement {
  _FlutterAutoSizeTextElement(super.context);

  @override
  WebFWidgetElementState createState() =>
      _FlutterAutoSizeTextElementState(this);
}

class _FlutterAutoSizeTextElementState extends WebFWidgetElementState {
  _FlutterAutoSizeTextElementState(super.widgetElement);

  static int buildCount = 0;
  static String lastBuiltText = '';

  _FlutterAutoSizeTextElement get autoSizeTextElement =>
      widgetElement as _FlutterAutoSizeTextElement;

  @override
  Widget build(BuildContext context) {
    final String text = autoSizeTextElement.getAttribute('text') ?? '';
    buildCount++;
    lastBuiltText = text;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1,
          ),
        );
      },
    );
  }
}

Future<ui.Image> _capture(WidgetTester tester) async {
  final RenderRepaintBoundary boundary =
      tester.firstRenderObject(find.byType(RepaintBoundary));
  return boundary.toImage(pixelRatio: 1);
}

Future<int> _countBrightPixels(
  ui.Image image, {
  required Rect rect,
}) async {
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    throw TestFailure('Failed to read image byte data');
  }
  final Uint8List data = byteData.buffer.asUint8List();
  int count = 0;
  for (int y = rect.top.floor(); y < rect.bottom.ceil(); y++) {
    for (int x = rect.left.floor(); x < rect.right.ceil(); x++) {
      final int offset = (y * image.width + x) * 4;
      final int r = data[offset];
      final int g = data[offset + 1];
      final int b = data[offset + 2];
      final int a = data[offset + 3];
      if (a > 0 && r > 180 && g > 180 && b > 180) {
        count++;
      }
    }
  }
  return count;
}

void main() {
  const String kTooltipsTag = 'flutter-tooltips';
  const String kAutoSizeTextTag = 'webf-test-auto-size-text';

  setUpAll(() {
    setupTest();
    if (!dom.getAllWidgetElements().containsKey(kTooltipsTag.toUpperCase())) {
      WebF.defineCustomElement(
        kTooltipsTag,
        (context) => _FlutterToolTipsElement(context),
      );
    }
    if (!dom
        .getAllWidgetElements()
        .containsKey(kAutoSizeTextTag.toUpperCase())) {
      WebF.defineCustomElement(
        kAutoSizeTextTag,
        (context) => _FlutterAutoSizeTextElement(context),
      );
    }
  });

  setUp(() {
    _FlutterAutoSizeTextElementState.buildCount = 0;
    _FlutterAutoSizeTextElementState.lastBuiltText = '';
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
    await Future.delayed(const Duration(milliseconds: 50));
  });

  testWidgets(
      'tooltip child widget text still paints after nested widget text update in flex layout',
      (WidgetTester tester) async {
    final PreparedWidgetTest prepared =
        await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName:
          'widget-tooltips-paint-${DateTime.now().millisecondsSinceEpoch}',
      viewportWidth: 260,
      viewportHeight: 180,
      html: '''
        <style>
          html, body {
            margin: 0;
            padding: 0;
            background: #000;
          }
        </style>
        <div style="display:flex; width:240px; padding: 12px; background:#000;">
          <div style="display:flex; flex-direction:column; min-width:0; flex:1;">
            <div style="display:flex; width:100%; align-items:center;">
              <flutter-tooltips id="tips" style="display:block; width:100%;">
                <webf-test-auto-size-text
                  id="amount"
                  text="1,200.686 USDT"></webf-test-auto-size-text>
              </flutter-tooltips>
            </div>
          </div>
        </div>
      ''',
      wrap: (Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: RepaintBoundary(child: child),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final dom.Element amount = prepared.getElementById('amount');
    expect(amount.attachedRenderer, isNotNull);

    ui.Image image = (await tester.runAsync(() => _capture(tester)))!;
    addTearDown(image.dispose);

    int brightPixels = (await tester.runAsync(() {
      return _countBrightPixels(
        image,
        rect: const Rect.fromLTWH(8, 8, 220, 60),
      );
    }))!;
    expect(brightPixels, greaterThan(150));
    expect(_FlutterAutoSizeTextElementState.buildCount, greaterThan(0));
    expect(_FlutterAutoSizeTextElementState.lastBuiltText, '1,200.686 USDT');

    amount.setAttribute('text', '9,999.999 USDT');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(_FlutterAutoSizeTextElementState.lastBuiltText, '9,999.999 USDT');

    image = (await tester.runAsync(() => _capture(tester)))!;
    addTearDown(image.dispose);

    brightPixels = (await tester.runAsync(() {
      return _countBrightPixels(
        image,
        rect: const Rect.fromLTWH(8, 8, 220, 60),
      );
    }))!;

    expect(brightPixels, greaterThan(150));
  });
}
