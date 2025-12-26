import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  Future<ui.Image> _capture(WidgetTester tester) async {
    final boundary = tester.firstRenderObject(find.byType(RepaintBoundary)) as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: 1);
  }

  Future<Color> _readPixel(ui.Image image, int x, int y) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw TestFailure('Failed to read image byte data');
    }
    final int offset = (y * image.width + x) * 4;
    final data = byteData.buffer.asUint8List();
    return Color.fromARGB(data[offset + 3], data[offset], data[offset + 1], data[offset + 2]);
  }

  testWidgets('paints thick border-top (1in) when height equals border', (tester) async {
    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '''
<style>html,body{margin:0;padding:0;background:#fff}*{box-sizing:border-box}</style>
<div id="d" style="width:100px;height:96px;border-top:1in solid red;"></div>
''',
      wrap: (child) => MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(child: child),
        ),
      ),
      viewportWidth: 200,
      viewportHeight: 200,
    );

    await tester.pump(Duration(milliseconds: 50));

    final ui.Image image = (await tester.runAsync(() => _capture(tester)))!;
    addTearDown(image.dispose);

    // The first 96px rows should be red due to the 1in top border filling the entire 96px box.
    final Color pixel = (await tester.runAsync(() => _readPixel(image, 10, 10)))!;
    expect(pixel.red, greaterThan(200));
    expect(pixel.green, lessThan(80));
    expect(pixel.blue, lessThan(80));
    expect(pixel.alpha, equals(255));
  });

  testWidgets('paints border-top on relatively positioned element (bottom:100%)', (tester) async {
    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '''
<style>html,body{margin:0;padding:0;background:#fff}*{box-sizing:border-box}</style>
<div id="parent" style="position:relative;height:96px;margin-top:192px;">
  <div id="div1" style="position:relative;border-top:1in solid red;height:96px;bottom:100%;"></div>
</div>
''',
      wrap: (child) => MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(child: child),
        ),
      ),
      viewportWidth: 240,
      viewportHeight: 260,
    );

    await tester.pump(Duration(milliseconds: 50));

    final ui.Image image = (await tester.runAsync(() => _capture(tester)))!;
    addTearDown(image.dispose);

    // Parent is at y=192; div1 is shifted up by 100% (96px) => y=96.
    final Color pixel = (await tester.runAsync(() => _readPixel(image, 10, 110)))!;
    expect(pixel.red, greaterThan(200));
    expect(pixel.green, lessThan(80));
    expect(pixel.blue, lessThan(80));
    expect(pixel.alpha, equals(255));
  });
}
