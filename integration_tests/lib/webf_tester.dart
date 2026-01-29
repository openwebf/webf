import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:webf/gesture.dart';
import 'package:webf/webf.dart';

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'main.dart';
import 'utils/flutter_error_capture.dart';

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
  static const MethodChannel _windowChannel = MethodChannel('webf_integration/window');
  Pointer<Void>? testContext;
  late WebFController controller;
  late final Widget _webfWidget;
  var width = 360.0;
  var height = 640.0;

  Future<void> _ensureWindowSize(double desiredWidth, double desiredHeight) async {
    if (!Platform.isMacOS) return;
    try {
      await _windowChannel.invokeMethod('ensureWindowSize', [desiredWidth, desiredHeight]);
    } catch (_) {
      // Best-effort: ignore if the platform channel is not implemented.
    }
  }

  Future<void> _restoreWindowSize() async {
    if (!Platform.isMacOS) return;
    try {
      await _windowChannel.invokeMethod('restoreWindowSize');
    } catch (_) {
      // Best-effort: ignore if the platform channel is not implemented.
    }
  }

  bool _isResetViewport(dynamic widthArg, dynamic heightArg) {
    final num? width = widthArg is num ? widthArg : num.tryParse(widthArg.toString());
    final num? height = heightArg is num ? heightArg : num.tryParse(heightArg.toString());
    return width == -1 && height == -1;
  }

  @override
  void initState() {
    super.initState();
    final enableBlink = Platform.environment['WEBF_ENABLE_BLINK'] == 'true';
    _webfWidget = WebF.fromControllerName(
        controllerName: 'tester',
        initialRoute: '/',
        createController: () => WebFController(
            enableBlink: enableBlink,
            // Let the Flutter widget constraints decide the viewport size so
            // integration tests can resize via `resizeViewport`.
            viewportWidth: null,
            viewportHeight: null,
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
              case 'takeFlutterError':
                return Future.value(FlutterErrorCapture.takeAsString());
              case 'clearFlutterError':
                FlutterErrorCapture.clear();
                return Future.value(null);
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
                final bool isReset = _isResetViewport(arguments[0], arguments[1]);
                double newWidth = isReset
                    ? 360
                    : double.tryParse(arguments[0].toString())!;
                double newHeight = isReset
                    ? 640
                    : double.tryParse(arguments[1].toString())!;
                if (newWidth != width || newHeight != height) {
                  setState(() {
                    width = newWidth;
                    height = newHeight;
                  });
                }
                if (isReset) {
                  await _restoreWindowSize();
                } else {
                  await _ensureWindowSize(newWidth, newHeight);
                }
                // Ensure the viewport has been laid out with the new constraints,
                // then sync the native media query cache (Blink) so @media rules
                // are evaluated against the correct innerWidth/innerHeight.
                await WidgetsBinding.instance.endOfFrame;
                controller.view.notifyViewportSizeChangedFromLayout();
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

    // Ensure the window is large enough for the default viewport even if macOS
    // restores a tiny window size from a previous run.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureWindowSize(width, height);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: _webfWidget,
    );
  }

  onLoad(WebFController controller) async {
    int x = 0;
    // Collect the running memory info every per 10s.
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      mems.add([x += 1, ProcessInfo.currentRss / 1024 ~/ 1024]);
    });

    String result = 'failed';
    try {
      // Preload load test cases
      result = await executeTest(testContext!, controller.view.contextId);
    } catch (e) {
      print(e);
    } finally {
      // Manual dispose context for memory leak check.
      try {
        await controller.dispose();
      } catch (_) {}

      // Restore the window size so macOS state restoration does not persist an
      // enlarged window into the next test run.
      await _restoreWindowSize();

      // Check running memorys
      // Temporary disabled due to exist memory leaks
      // if (isMemLeaks(mems)) {
      //   print('Memory leaks found. ${mems.map((e) => e[1]).toList()}');
      //   exit(1);
      // }
      widget.onWillFinish?.call();

      exit(result == 'failed' ? 1 : 0);
    }
  }
}
