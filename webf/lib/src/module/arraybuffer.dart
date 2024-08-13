import 'dart:typed_data';

import 'package:webf/webf.dart';
/// A simplified version of the Blob class for demonstration purposes.
class ArrayBufferData extends BaseModule {
  Uint8List? buffer;
  static final Map<String, dynamic> _instanceMap = {};
  static int _autoId=0; 
  /// Creates a new FormData instance.
  ArrayBufferData(ModuleManager? moduleManager) : super(moduleManager);
  int get length => buffer!.length;
  
  @override
  void dispose() {
  }

  static String fromBytes(Uint8List buffer){
     String id=(_autoId++).toString();
        _instanceMap[id.toString()]={
          buffer:buffer
        };
        return id;
  }
  static ArrayBufferData getInstance(String id){
    return _instanceMap[id.toString()];
  }
  
  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    if(_instanceMap[params[0]]==null){
      print('Failed to execute \'$method\' on \'fromData\': nullInstance ');
    }
    else {
      switch (method) {
        case 'init':
          String id=(_autoId++).toString();
          _instanceMap[id.toString()]={
            buffer:Uint8List(params.length==0?0:params[0])
          };
          return id;
        case 'fromBytes':
          String id=(_autoId++).toString();
          _instanceMap[id.toString()]={
            buffer:params[1]
          };
          return id;
      case 'toString':
        return _instanceMap[params[0]]?.toString()??'';
      default:
        print('Failed to execute \'$method\' on \'fromData\': NoSuchMethod ');
    }
    }
    return EMPTY_STRING;
  }
  
  @override
  String get name => 'ArrayBuffer';
}