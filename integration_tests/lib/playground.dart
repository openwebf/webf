/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';

import 'bridge/from_native.dart';
import 'bridge/test_input.dart';
import 'bridge/to_native.dart';
import 'custom_elements/main.dart';
import 'test_module.dart';
import 'local_http_server.dart';
import 'utils/mem_leak_detector.dart';
import 'webf_tester.dart';
import 'modules/array_buffer_module.dart';

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  // Inline formatter + paragraph logs (placeholders, baselines, lines)
  InlineLayoutLog.enableAll();
  FlexLog.enableAll();
  FlowLog.enableAll();
  CSSPositionedLayout.debugLogPositionedEnabled = true;
  DebugFlags.enableDomLogs = true;

  // debugPaintBaselinesEnabled = true;
  // DebugFlags.enableDomLogs = true;
  // DebugFlags.enableCssLogs = true;
  // DebugFlags.debugPaintInlineLayoutEnabled = true;
  // Flow layout baseline logs

  // Initialize the controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
      maxAliveInstances: 1,
      useDioForNetwork: false,
      maxAttachedInstances: 1,
      onControllerDisposed: (String name, WebFController controller) {
        print('controller disposed: $name $controller');
      }));

  defineWebFCustomElements();

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  testTextInput = TestTextInput();

  runZonedGuarded(() {
    runApp(MaterialApp(
      title: 'webF Integration Tests',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('WebF Integration Tests')),
        body: SimplePage(),
      ),
    ));
  }, (Object error, StackTrace stack) {
    print('$error\n$stack');
  });
}

class SimplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return WebFPage();
          }));
        },
        child: Text('RUN'));
  }
}

class WebFPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            WebF.fromControllerName(
                controllerName: 'test',
                bundle: WebFBundle.fromUrl('http://127.0.0.1:3300/webf_debug_server.js'),
                createController: () => WebFController(
                    viewportWidth: 360,
                    viewportHeight: 640,
                    background: Colors.black12,
                    onControllerInit: (controller) async {
                      double contextId = controller.view.contextId;
                      Pointer<Void> testContext = initTestFramework(contextId);
                      registerDartTestMethodsToCpp(contextId);
                      // Timer(Duration(seconds: 1), () {
                      //   executeTest(testContext, contextId);
                      // });
                    })),
            WebFInspectorFloatingPanel()
          ],
        ));
  }
}
