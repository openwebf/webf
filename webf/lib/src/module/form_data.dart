import 'dart:convert';

import 'package:webf/webf.dart';

/// A simple implementation of the FormData interface.
class FormData extends BaseModule {
  /// Creates a new FormData instance.
  FormData(ModuleManager? moduleManager) : super(moduleManager);
  static final Map<String, dynamic> _instanceMap = {};
  static int _autoId=0; 
  /// The list that holds the data.
  final List<List<dynamic>> _list = [];
 
  /// Adds a key-value pair to the FormData.
  void append(String name, value) {
     _list.add([name, value]);
  }

  /// Returns the first value associated with the given key.
  dynamic getFirst(String name) {
    for (var entry in _list) {
      if (entry[0] == name) {
        return entry[1];
      }
    }
    return null;
  }

  /// Returns all values associated with the given key.
  List<dynamic> getAll(String name) {
    return _list.where((entry) => entry[0] == name).map((entry) => entry[1]).toList();
  }

  /// Serializes the FormData into a string.
  @override
  String toString() {
    var entries = _list.map((entry) {
      if (entry[1] is String) {
        return '${Uri.encodeComponent(entry[0])}=${Uri.encodeComponent(entry[1] as String)}';
      } else if (entry[1] is Blob) {
        // Handle Blob serialization.
        return '${Uri.encodeComponent(entry[0])}=${Uri.encodeComponent(entry[1].Base64Result())}';
      } else {
        return '${Uri.encodeComponent(entry[0])}=${Uri.encodeComponent(jsonEncode(entry[1]))}';
      }
    }).join('&');

    return entries;
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
        _instanceMap[id.toString()]={};
        return id;
      case 'append':
        _instanceMap[params[0]]?.append(params[1], params[2]);
        break;
      case 'getFirst':
        return jsonEncode(_instanceMap[params[0]]?.getFirst(params[1]));
      case 'getAll':
        return jsonEncode(_instanceMap[params[0]]?.getAll(params[1]));
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

  @override
  String get name => 'FormData';
}