/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';
import 'dart:ffi';
import 'dart:math';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/webf.dart';

import 'custom_elements/main.dart';
import 'test_module.dart';
import 'bridge/from_native.dart';
import 'bridge/test_input.dart';
import 'bridge/to_native.dart';
import 'local_http_server.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;

const MOCK_SERVER_PORT = 4567;

Future<void> startHttpMockServer() async {
  await Process.start('node', [testDirectory + '/scripts/mock_http_server.js'], environment: {
    'PORT': MOCK_SERVER_PORT.toString()
  }, mode: ProcessStartMode.inheritStdio);
}


double findSlope(List<List<num>> coordinates) {
  if (coordinates.length < 2) {
    throw ArgumentError("At least two coordinates are required");
  }

  int n = coordinates.length;
  num sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (List<num> coordinate in coordinates) {
    num x = coordinate[0];
    num y = coordinate[1];

    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
  }

  // Calculate the slope of the best-fitting line using the linear regression formula
  double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  return slope;
}

double findAngle(List<List<num>> coordinates) {
  double slope = findSlope(coordinates);
  double angleRadians = atan(slope); // Calculate angle in radians
  return angleRadians;
}

double radiansToDegrees(double radians) {
  return radians * 180 / pi;
}

List<List<int>> mems = [];

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  // Overrides library name.
  WebFDynamicLibrary.libName = 'libwebf_test';
  defineWebFCustomElements();

  ModuleManager.defineModule((moduleManager) => DemoModule(moduleManager));
  await startHttpMockServer();

  // FIXME: This is a workaround for testcases.
  debugOverridePDefaultStyle({DISPLAY: BLOCK});

  // Start local HTTP server.
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP server started at: ${httpServer.getUri()}');

  String codeInjection = '''
    // This segment inject variables for test environment.
    LOCAL_HTTP_SERVER = '${httpServer.getUri().toString()}';
  ''';

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  WebFJavaScriptChannel javaScriptChannel = WebFJavaScriptChannel();
  javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
    if(method == 'helloInt64'){
      return Future.value(1111111111111111);
    } else {
      dynamic returnedValue = await javaScriptChannel.invokeMethod(method, arguments);
      return 'method: $method, return_type: ${returnedValue.runtimeType.toString()}, return_value: ${returnedValue.toString()}';
    }
  };

  // This is a virtual location for test program to test [Location] functionality.
  final String specUrl = 'assets:///test.js';
  late WebF webF;

  Pointer<Void>? testContext;
  webF = WebF(
    viewportWidth: 360,
    viewportHeight: 640,
    bundle: WebFBundle.fromUrl('http://localhost:$MOCK_SERVER_PORT/public/core.build.js'),
    disableViewportWidthAssertion: true,
    disableViewportHeightAssertion: true,
    javaScriptChannel: javaScriptChannel,
    onControllerCreated: (_) async {
      int contextId = webF.controller!.view.contextId;
      testContext = initTestFramework(contextId);
      registerDartTestMethodsToCpp(contextId);
      addJSErrorListener(contextId, print);
      webF.controller!.view.evaluateJavaScripts(codeInjection);
    },
    onLoad: (controller) async {
      Timer(Duration(seconds: 2), () {
        int x = 0;
        // Collect the running memory info every per 10s.
        Timer.periodic(Duration(seconds: 1), (timer) {
          mems.add([x++, ProcessInfo.currentRss / 1024 ~/ 1024]);
        });
      });

      // Preload load test cases
      String result = await executeTest(testContext!, controller.view.contextId);
      // Manual dispose context for memory leak check.
      webF.controller!.dispose();

      // Check running memorys
      double angleRadians = findAngle(mems.map((e) => [e[0], e[1] ~/ 10]).toList());
      double angleDegrees = radiansToDegrees(angleRadians);
      if (angleDegrees > 30) {
        print('Memory leaks found. ${mems.map((e) => e[1]).toList()}');
        exit(1);
      }

      exit(result == 'failed' ? 1 : 0);
    },
    gestureListener: GestureListener(
      onDrag: (GestureEvent gestureEvent) {
        if (gestureEvent.state == EVENT_STATE_START) {
          var event = CustomEvent('nativegesture', detail: 'nativegesture');
          webF.controller!.view.document.documentElement?.dispatchEvent(event);
        }
      },
    ),
  );

  runZonedGuarded(() {
    runApp(MaterialApp(
      title: 'webF Integration Tests',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('WebF Integration Tests')),
        body: Wrap(
          children: [
            webF,
          ],
        ),
      ),
    ));
  }, (Object error, StackTrace stack) {
    print('$error\n$stack');
  });

  testTextInput = TestTextInput();
}
