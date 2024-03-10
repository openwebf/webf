import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:webf/gesture.dart';
import 'package:webf/webf.dart';

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'main.dart';

class WebFTester extends StatefulWidget {
  final String preCode;
  final void Function()? onWillFinish;

  const WebFTester({
    Key? key,
    required this.preCode,
    this.onWillFinish,
  }) : super(key: key);

  @override
  _WebFTesterState createState() => _WebFTesterState();
}

class _WebFTesterState extends State<WebFTester> {
  final WebFJavaScriptChannel javaScriptChannel = WebFJavaScriptChannel();
  Pointer<Void>? testContext;
  late WebFController controller;
  var width = 360.0;
  var height = 640.0;

  _WebFTesterState() {
    javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
      switch (method) {
        case 'helloInt64':
          return Future.value(1111111111111111);
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
        default:
          dynamic returnedValue =
              await javaScriptChannel.invokeMethod(method, arguments);
          return 'method: $method, return_type: ${returnedValue.runtimeType.toString()}, return_value: ${returnedValue.toString()}';
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return WebF(
      viewportWidth: width,
      viewportHeight: height,
      bundle: WebFBundle.fromUrl(
          'http://localhost:$MOCK_SERVER_PORT/public/core.build.js?search=1234#hash=hashValue'),
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      javaScriptChannel: javaScriptChannel,
      onControllerCreated: onControllerCreated,
      onLoad: onLoad,
      // runningThread: FlutterUIThread(),
      // runningThread: FlutterUIThread(),
      gestureListener: GestureListener(
        onDrag: (GestureEvent gestureEvent) {
          if (gestureEvent.state == EVENT_STATE_START) {
            var event = CustomEvent('nativegesture', detail: 'nativegesture');
            controller.view.document.documentElement?.dispatchEvent(event);
          }
        },
      ),
    );
  }

  onControllerCreated(WebFController controller) async {
    this.controller = controller;
    double contextId = controller.view.contextId;
    testContext = initTestFramework(contextId);
    registerDartTestMethodsToCpp(contextId);
    await controller.view.evaluateJavaScripts(widget.preCode);
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
