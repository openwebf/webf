/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import 'package:webf_websocket/webf_websocket.dart';

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;

const int WEBF_NUM = 1;
Map<int, WebF> webfMap = Map();

// Test for UriParser.
class IntegrationTestUriParser extends UriParser {
  @override
  Uri resolve(Uri base, Uri relative) {
    if (base.toString().isEmpty && relative.path.startsWith('assets/')) {
      return Uri.file(relative.path);
    } else {
      return super.resolve(base, relative);
    }
  }
}

// By CLI: `WEBF_ENABLE_TEST=true flutter run`
void main() async {
  // Overrides library name.
  WebFDynamicLibrary.libName = 'webf_test';

  WebFWebSocket.initialize();

  // FIXME: This is a workaround for testcase
  debugOverridePDefaultStyle({DISPLAY: BLOCK});

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  final String specTarget = '.specs/plugin.build.js';
  final File spec = File(path.join(testDirectory, specTarget));

  late WebF webF = WebF(
    viewportWidth: 360,
    viewportHeight: 640,
    bundle: WebFBundle.fromContent('console.log("Starting Plugin tests...")'),
    disableViewportWidthAssertion: true,
    disableViewportHeightAssertion: true,
    uriParser: IntegrationTestUriParser(),
  );

  runApp(MaterialApp(
    title: 'WebF Plugin Tests',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(title: Text('WebF Plugin Tests')),
      body: Wrap(
        children: [
          webF
        ],
      ),
    ),
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    int contextId = webF.controller!.view.contextId;
    Pointer<Void> testContext = initTestFramework(contextId);
    registerDartTestMethodsToCpp(contextId);
    addJSErrorListener(contextId, print);

    // Preload load test cases
    String code = spec.readAsStringSync();
    evaluateTestScripts(contextId, code, url: 'assets://plugin.js');
    String result = await executeTest(testContext, contextId);
    webF.controller!.dispose();
    exit(result == 'failed' ? 1 : 0);
  });
}
