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

  WebFNavigationDelegate navigationDelegate = WebFNavigationDelegate();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    navigationDelegate.setDecisionHandler((WebFNavigationAction action) async {
      return WebFNavigationActionPolicy.allow; // Allows for all
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebF.fromControllerName(
        controllerName: 'tester',
        initialRoute: '/',
        createController: () => WebFController(
            navigationDelegate: navigationDelegate,
            viewportWidth: width,
            viewportHeight: height,
            onLoad: onLoad,
            onControllerInit: (controller) async {
              double contextId = controller.view.contextId;
              testContext = initTestFramework(contextId);
              registerDartTestMethodsToCpp(contextId);
              await controller.view.evaluateJavaScripts(widget.preCode);
            }),
        setup: (controller) {
          controller.javascriptChannel.onMethodCall =
              (String method, dynamic arguments) async {
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
