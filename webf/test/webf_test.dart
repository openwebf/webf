/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:path/path.dart' as path;

import 'local_http_server.dart';
import 'src/css/style_animations_parser.dart' as style_animations_parser;
import 'src/css/style_rule_parser.dart' as style_rule_parser;
import 'src/css/style_sheet_parser.dart' as style_sheet_parser;
import 'src/css/style_inline_parser.dart' as style_inline_parser;
import 'src/css/values.dart' as css_values;
import 'src/foundation/bundle.dart' as bundle;
import 'src/foundation/convert.dart' as convert;
import 'src/foundation/environment.dart' as environment;
import 'src/foundation/http_cache.dart' as http_cache;
import 'src/foundation/http_cache_validation_test.dart' as http_cache_validation;
import 'src/foundation/http_cache_integration_test.dart' as http_cache_integration;
import 'src/foundation/http_client.dart' as http_client;
import 'src/foundation/http_client_interceptor.dart' as http_client_interceptor;
import 'src/foundation/mock_bundle_test.dart' as mock_bundle_test;
import 'src/foundation/uri_parser.dart' as uri_parser;
import 'src/launcher/controller_manager.dart' as controller_manager;
import 'src/module/fetch.dart' as fetch;
import 'src/html/link_preload_test.dart' as link_preload;
import 'src/widget/webf_clear_cache_test.dart' as webf_clear_cache;
import 'src/widget/contentful_widget_detector_test.dart' as contentful_widget_detector;

final String __dirname = path.dirname(Platform.script.path);

Directory setupTest() {
  // Setup environment.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Start local HTTP server.
  LocalHttpServer.basePath = 'test/fixtures';
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP Server started at ${httpServer.getUri()}');

  // Inject a custom user agent, to avoid reading from bridge.
  NavigatorModule.setCustomUserAgent('webf/test');

  WebFDynamicLibrary.dynamicLibraryPath = path.join(__dirname, '../bridge/build/macos/lib/x86_64');

  // Work around with path_provider.
  Directory tempDirectory = Directory('./temp');
  MethodChannel webfChannel = getWebFMethodChannel();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(webfChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getTemporaryDirectory') {
      return tempDirectory.path;
    }
    throw FlutterError('Not implemented for method ${methodCall.method}.');
  });
  return tempDirectory;
}

// The main entry for kraken unit test.
// Setup all common logic.
void main() {

  Directory? tempDirectory;
  setUp(() {
    tempDirectory = setupTest();
  });

  setupTest();
  // Start tests.
  group('foundation', () {
    bundle.main();
    convert.main();
    http_cache.main();
    http_cache_validation.main();
    http_cache_integration.main();
    http_client.main();
    http_client_interceptor.main();
    environment.main();
    mock_bundle_test.main();
    uri_parser.main();
  });

  group('launcher', () {
    controller_manager.main();
  });

  group('html', () {
    link_preload.main();
  });

  group('module', () {
    fetch.main();
  });

  group('css', () {
    style_rule_parser.main();
    style_sheet_parser.main();
    style_inline_parser.main();
    style_animations_parser.main();
    css_values.main();
  });

  group('widget', () {
    webf_clear_cache.main();
    contentful_widget_detector.main();
  });

  tearDownAll(() {
    if (tempDirectory!.existsSync()) {
      tempDirectory!.deleteSync(recursive: true);
    }
  });
}
