/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
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
  WebFDynamicLibrary.libName = 'libwebf_test';

  WebFWebSocket.initialize();

  // FIXME: This is a workaround for testcase
  ParagraphElement.defaultStyle = {
    DISPLAY: BLOCK,
  };

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  File specs = File(path.join(testDirectory, '.specs/plugin.build.js'));

  List<Map<String, String>> allSpecsPayload = [
    {'filename': path.basename(specs.path), 'filepath': specs.path, 'code': specs.readAsStringSync()}
  ];
  List<Widget> widgets = [];

  for (int i = 0; i < WEBF_NUM; i++) {
    var webf = webfMap[i] = WebF(
      viewportWidth: 360,
      viewportHeight: 640,
      bundle: WebFBundle.fromContent('console.log("Starting Plugin tests...")'),
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      uriParser: IntegrationTestUriParser(),
    );
    widgets.add(webf);
  }

  runApp(MaterialApp(
    title: 'WebF Plugin Tests',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(title: Text('WebF Plugin Tests')),
      body: Wrap(
        children: widgets,
      ),
    ),
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    registerDartTestMethodsToCpp();

    List<Future<String>> testResults = [];

    for (int i = 0; i < widgets.length; i++) {
      int contextId = i;
      initTestFramework(contextId);
      addJSErrorListener(contextId, (String err) {
        print(err);
      });

      Map<String, String> payload = allSpecsPayload[i];

      // Preload load test cases
      String filename = payload['filename']!;
      String code = payload['code']!;
      evaluateTestScripts(contextId, code, url: filename);

      testResults.add(executeTest(contextId));
    }

    List<String> results = await Future.wait(testResults);

    for (int i = 0; i < results.length; i++) {
      String status = results[i];
      if (status == 'failed') {
        exit(1);
      }
    }

    exit(0);
  });
}
