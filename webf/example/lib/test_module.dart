import 'dart:async';

import 'package:webf/bridge.dart';
import 'package:webf/module.dart';

class TestModule extends WebFBaseModule {
  TestModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params) {
    print('method: $method, params: $params');
    if (params is NativeByteData) {
      Completer<String> completer = Completer();
      String log = 'Received bytes from JS, length: ${params.bytes.length}';
      print(log);
      // You can use params.bytes (Uint8List) here to process the binary data
      completer.complete(log);
      return completer.future;
    }
    return 'method not found';
  }

  @override
  String get name => 'TestBlob';
}
