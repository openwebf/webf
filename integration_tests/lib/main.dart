/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:webf/css.dart';
import 'package:webf/bridge.dart';
import 'package:webf/webf.dart';

import 'bridge/from_native.dart';
import 'bridge/test_input.dart';
import 'custom_elements/main.dart';
import 'binding_objects/test_binding_object.dart';
import 'test_module.dart';
import 'local_http_server.dart';
import 'utils/mem_leak_detector.dart';
import 'webf_tester.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';
import 'modules/array_buffer_module.dart';
import 'modules/method_channel_callback_module.dart';

String? pass = (AnsiPen()
  ..green())('[TEST PASS]');
String? err = (AnsiPen()
  ..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;

// A repaint boundary that wraps the entire Flutter app so integration specs can
// capture screenshots that include Flutter overlays (e.g. CupertinoContextMenu).
final GlobalKey integrationRootRepaintBoundaryKey = GlobalKey();
final GlobalKey<NavigatorState> integrationNavigatorKey = GlobalKey<NavigatorState>();

Future<int> findAvailablePort({int startPort = 4000, int endPort = 5000}) async {
  for (var port = startPort; port <= endPort; port++) {
    try {
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

      // Handle incoming connections
      server.listen((Socket client) {});
      server.close();
      return port; // Exit once successfully bound to a port
    } catch (e) {}
  }
  return -1;
}


Future<Process> startHttpMockServer(int port) async {
  if (Platform.isWindows) {
    testDirectory = testDirectory.replaceAllMapped(RegExp('^/([A-Z]):'), (match) => '${match.group(1)}:');
  }

  return await Process.start(
      'node', [testDirectory + '/scripts/mock_http_server.js'],
      environment: {'PORT': port.toString()},
      mode: ProcessStartMode.inheritStdio);
}

List<List<int>> mems = [];

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  // Initialize the controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
      maxAliveInstances: 1,
      maxAttachedInstances: 1,
      enableDevTools: false,
      onControllerDisposed: (String name, WebFController controller) {
        print('controller disposed: $name $controller');
      }));

  defineWebFCustomElements();
  installWebFCupertinoUI();

  int mockServerPort = await findAvailablePort();

  ModuleManager.defineModule((moduleManager) => DemoModule(moduleManager));
  ModuleManager.defineModule(
          (moduleManager) => ArrayBufferModule(moduleManager));
  ModuleManager.defineModule((moduleManager) => MethodChannelCallbackModule(moduleManager));
  WebF.defineBindingObject('TestBindingObject', (context, args) => TestBindingObject(context, args));
  Process mockHttpServer = await startHttpMockServer(mockServerPort);
  sleep(Duration(seconds: 2));

  // Start local HTTP server.
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP server started at: ${httpServer.getUri()}');

  String codeInjection = '''
    // This segment inject variables for test environment.
    window.LOCAL_HTTP_SERVER = '${httpServer.getUri().toString()}';
    window.SERVER_PORT = ${mockServerPort};
    window.WEBSOCKET_PORT = ${Platform.environment['WEBF_WEBSOCKET_SERVER_PORT']};
  ''';

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.defaultFontFamilyFallback = ['AlibabaPuHuiTi'];

  testTextInput = TestTextInput();

  runZonedGuarded(() {
    runApp(
      RepaintBoundary(
        key: integrationRootRepaintBoundaryKey,
        child: MaterialApp(
          title: 'webF Integration Tests',
          debugShowCheckedModeBanner: false,
          navigatorKey: integrationNavigatorKey,
          home: Scaffold(
            appBar: AppBar(title: Text('WebF Integration Tests')),
            body: Wrap(
              children: [
                WebFTester(
                  preCode: codeInjection,
                  mockServerPort: mockServerPort,
                  onWillFinish: () {
                    mockHttpServer.kill(ProcessSignal.sigkill);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }, (Object error, StackTrace stack) {
    print('$error\n$stack');
  });
}
