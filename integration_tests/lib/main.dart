/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'custom_elements/main.dart';
import 'test_module.dart';
import 'local_http_server.dart';
import 'utils/mem_leak_detector.dart';
import 'webf_tester.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;

const MOCK_SERVER_PORT = 4567;

Future<Process> startHttpMockServer() async {
  return await Process.start(
      'node', [testDirectory + '/scripts/mock_http_server.js'],
      environment: {'PORT': MOCK_SERVER_PORT.toString()},
      mode: ProcessStartMode.inheritStdio);
}

List<List<int>> mems = [];

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  enableWebFProfileTracking = true;
  // Overrides library name.
  WebFDynamicLibrary.testLibName = 'webf_test';
  defineWebFCustomElements();

  ModuleManager.defineModule((moduleManager) => DemoModule(moduleManager));
  Process mockHttpServer = await startHttpMockServer();
  sleep(Duration(seconds: 2));

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

  runZonedGuarded(() {
    runApp(MaterialApp(
      title: 'webF Integration Tests',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('WebF Integration Tests')),
        body: Wrap(
          children: [
            WebFTester(
              preCode: codeInjection,
              onWillFinish: () {
                mockHttpServer.kill(ProcessSignal.sigkill);
              },
            ),
          ],
        ),
      ),
    ));
  }, (Object error, StackTrace stack) {
    print('$error\n$stack');
  });
}
