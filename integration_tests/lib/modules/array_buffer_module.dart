import 'dart:async';
import 'package:webf/webf.dart';
import 'package:webf/bridge.dart';

class ArrayBufferModule extends WebFBaseModule {
  ArrayBufferModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  String get name => "ArrayBufferTest";

  @override
  dynamic invoke(String method, params) {
    print('method: $method $params');
    switch (method) {
      case 'receiveArrayBuffer':
        if (params is NativeByteData) {
          final bytes = params.bytes;
          // Return information about the received array buffer
          return {
            'received': true,
            'byteLength': bytes.length,
            'firstByte': bytes.isNotEmpty ? bytes[0] : null,
            'lastByte': bytes.isNotEmpty ? bytes[bytes.length - 1] : null
          };
        } else {
          return {
            'received': false,
            'error': 'Expected NativeByteData but got ${params.runtimeType}'
          };
        }
      
      case 'receiveAndCallback':
        if (params is NativeByteData) {
          Completer<dynamic> completer = Completer();
          final bytes = params.bytes;
          Timer(Duration(milliseconds: 50), () {
            completer.complete({
              'byteLength': bytes.length,
              'asyncProcessed': true
            });
          });
          
          return completer.future;
        } else {
          return {
            'received': false,
            'error': 'Expected NativeByteData but got ${params.runtimeType}'
          };
        }
    }
    
    return {
      'error': 'Method not found: $method'
    };
  }

  @override
  void dispose() {}
}