import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:path/path.dart' as path;

import 'local_http_server.dart';

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
  
  // Mock path_provider channel for dio_cache_interceptor_hive_store
  const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getTemporaryDirectory') {
      return tempDirectory.path;
    }
    throw FlutterError('Not implemented for method ${methodCall.method}.');
  });
  
  return tempDirectory;
}
