import 'dart:typed_data';
import 'dart:convert';

import 'package:webf/webf.dart';


/// A simplified version of the Blob class for demonstration purposes.
class Blob extends BaseModule {
    @override
  String get name => 'Blob';
  static final Map<String, dynamic> _instanceMap = {};
  static int _autoId=0; 
  /// Creates a new FormData instance.
  Blob(ModuleManager? moduleManager) : super(moduleManager);

  Uint8List? _data;
  final String type='application/octet-stream';

  int get size => _data!.length;

  Uint8List get bytes => _data!;

  String StringResult() {
    return String.fromCharCodes(_data!);
  }

  String Base64Result() {
    return 'data:$type;base64,${base64Encode(_data!)}';
  }

  // String ArrayBufferResult() {
  //   ArrayBufferData  ArrayBuffer = moduleManager?.getModule<ArrayBufferData>('ArrayBuffer')!;
  //   return ArrayBuffer.fromBytes(_data!.buffer.asUint8List());
  // }

  Uint8List slice(int start, int end, [String contentType = '']) {
    if (start < 0) start = 0;
    if (end < 0) end = 0;
    if (end > _data!.length) end = _data!.length;
    if (start > end) start = end;
    final slicedData = _data!.sublist(start, end);
    return slicedData;
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
          _data:params[1],
          type:params[2]
        };
        return id;
      case 'StringResult':
        return _instanceMap[params[0]]?.StringResult();
      case 'Base64Result':
        return _instanceMap[params[0]]?.Base64Result();
      case 'ArrayBufferResult':
        return _instanceMap[params[0]]?.ArrayBufferResult();
      case 'slice':
        String id=(_autoId++).toString();
        Uint8List sliceData=_instanceMap[_autoId.toString()]?.slice(params[1],params[2]);
        _instanceMap[id.toString()]={
            _data:sliceData,
            type:_instanceMap[_autoId.toString()]!.type
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
  void dispose() {}
}