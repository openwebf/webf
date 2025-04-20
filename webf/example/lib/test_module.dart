import 'package:webf/bridge.dart';
import 'package:webf/module.dart';

class TestModule extends WebFBaseModule {
  TestModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params, InvokeModuleCallback callback) {
    print('method: $method, params: $params');
    if (params is NativeByteData) {
      String log = 'Received bytes from JS, length: ${params.bytes.length}';
      print(log);
      callback(data: log);
      // You can use params.bytes (Uint8List) here to process the binary data
    }
    return 'method not found';
  }

  @override
  String get name => 'TestBlob';
}
