import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:webf/gesture.dart';
import 'package:webf/webf.dart';

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'main.dart';

class WebFTester extends StatefulWidget {
  final String preCode;
  final int mockServerPort;
  final void Function()? onWillFinish;

  const WebFTester({
    Key? key,
    required this.preCode,
    required this.mockServerPort,
    this.onWillFinish,
  }) : super(key: key);

  @override
  _WebFTesterState createState() => _WebFTesterState();
}

class _WebFTesterState extends State<WebFTester> {
  Pointer<Void>? testContext;
  late WebFController controller;
  var width = 360.0;
  var height = 640.0;

  @override
  Widget build(BuildContext context) {
    return WebF.fromControllerName(
        controllerName: 'tester',
        initialRoute: '/',
        createController: () => WebFController(
            enableBlink: true,
            viewportWidth: width,
            viewportHeight: height,
            onLoad: onLoad,
            onControllerInit: (controller) async {
              double contextId = controller.view.contextId;
              testContext = initTestFramework(contextId);
              registerDartTestMethodsToCpp(testContext!);

              // Pass test filter from environment if available
              final testFilter = Platform.environment['WEBF_TEST_NAME_FILTER'];
              if (testFilter != null && testFilter.isNotEmpty) {
                await controller.view.evaluateJavaScripts('window.WEBF_TEST_NAME_FILTER = ${jsonEncode(testFilter)};');
              }

              await controller.view.evaluateJavaScripts(widget.preCode);
            }),
        setup: (controller) {
          WebFNavigationDelegate navigationDelegate = WebFNavigationDelegate();
          navigationDelegate
              .setDecisionHandler((WebFNavigationAction action) async {
            return WebFNavigationActionPolicy.allow; // Allows for all
          });
          controller.navigationDelegate = navigationDelegate;
          controller.javascriptChannel.onMethodCall =
              (String method, dynamic arguments) async {
            switch (method) {
              case 'helloInt64':
                return Future.value(1111111111111111);
              case 'setMethodChannelCallback': {
                final args = arguments is List ? arguments : const [];
                final dynamic first = args.isNotEmpty ? args[0] : null;
                final module = controller.module.moduleManager.getModule('MethodChannelCallback');
                if (module == null) return Future.value(false);

                if (first == null) {
                  (module as dynamic).setCallback(null);
                  return Future.value(true);
                }
                if (first is JSFunction) {
                  (module as dynamic).setCallback(first);
                  return Future.value(true);
                }
                return Future.value(false);
              }
              case 'clearMethodChannelCallback': {
                final module = controller.module.moduleManager.getModule('MethodChannelCallback');
                if (module == null) return Future.value(false);
                (module as dynamic).setCallback(null);
                return Future.value(true);
              }
              case 'resizeViewport':
                double newWidth = arguments[0] == -1
                    ? 360
                    : double.tryParse(arguments[0].toString())!;
                double newHeight = arguments[1] == -1
                    ? 640
                    : double.tryParse(arguments[1].toString())!;
                if (newWidth != width || newHeight != height) {
                  setState(() {
                    width = newWidth;
                    height = newHeight;
                  });
                }
                return Future.value(null);
              case 'captureFlutterScreenshot':
                // Return base64 encoded PNG bytes for the whole Flutter app.
                // This is used by integration specs to snapshot Flutter overlays
                // that are not part of the WebF DOM render tree.
                final RenderObject? ro = integrationRootRepaintBoundaryKey.currentContext?.findRenderObject();
                final RenderRepaintBoundary? boundary = ro is RenderRepaintBoundary ? ro : null;
                if (boundary == null) return Future.value('');

                // Ensure the latest frame has been painted.
                await WidgetsBinding.instance.endOfFrame;

                final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
                final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                if (byteData == null) return Future.value('');

                // Optional crop: args = [x, y, width, height]
                if (arguments is List && arguments.length == 4) {
                  final double x = double.tryParse(arguments[0].toString()) ?? 0;
                  final double y = double.tryParse(arguments[1].toString()) ?? 0;
                  final double w = double.tryParse(arguments[2].toString()) ?? 0;
                  final double h = double.tryParse(arguments[3].toString()) ?? 0;

                  final bytes = byteData.buffer.asUint8List();
                  final img.Image? decoded = img.decodePng(bytes);
                  if (decoded == null) return Future.value(base64Encode(bytes));

                  int left = x.floor();
                  int top = y.floor();
                  int widthPx = w.ceil();
                  int heightPx = h.ceil();

                  left = left.clamp(0, decoded.width).toInt();
                  top = top.clamp(0, decoded.height).toInt();
                  widthPx = widthPx.clamp(0, decoded.width - left).toInt();
                  heightPx = heightPx.clamp(0, decoded.height - top).toInt();

                  final img.Image cropped = img.copyCrop(decoded, left, top, widthPx, heightPx);
                  final List<int> croppedPng = img.encodePng(cropped);
                  return Future.value(base64Encode(croppedPng));
                }

                return Future.value(base64Encode(byteData.buffer.asUint8List()));
              case 'dismissFlutterOverlays':
                // Best-effort close of any modal routes/overlays pushed on the root navigator.
                // Used to avoid leaks across specs (e.g. CupertinoContextMenu popup).
                try {
                  integrationNavigatorKey.currentState?.popUntil((route) => route.isFirst);
                } catch (_) {}
                return Future.value(null);
              default:
                dynamic returnedValue = await controller.javascriptChannel
                    .invokeMethod(method, arguments);
                return 'method: $method, return_type: ${returnedValue.runtimeType.toString()}, return_value: ${returnedValue.toString()}';
            }
          };
        },
        bundle: WebFBundle.fromUrl(
            'http://localhost:${widget.mockServerPort}/public/core.build.js?search=1234#hash=hashValue'));
  }

  onLoad(WebFController controller) async {
    int x = 0;
    // Collect the running memory info every per 10s.
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      mems.add([x += 1, ProcessInfo.currentRss / 1024 ~/ 1024]);
    });

    try {
      // Preload load test cases
      String result =
          await executeTest(testContext!, controller.view.contextId);
      // Manual dispose context for memory leak check.
      await controller.dispose();

      // Check running memorys
      // Temporary disabled due to exist memory leaks
      // if (isMemLeaks(mems)) {
      //   print('Memory leaks found. ${mems.map((e) => e[1]).toList()}');
      //   exit(1);
      // }
      widget.onWillFinish?.call();

      exit(result == 'failed' ? 1 : 0);
    } catch (e) {
      print(e);
    }
  }
}
