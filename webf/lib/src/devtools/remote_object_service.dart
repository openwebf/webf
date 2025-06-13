/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:webf/src/devtools/console_store.dart';
import 'package:webf/webf.dart';

// Function pointers that will be set from the C++ side
typedef GetObjectPropertiesFunc = Pointer<NativeValue> Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId, int includePrototype);
typedef EvaluatePropertyPathFunc = Pointer<NativeValue> Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId, Pointer<Utf8> propertyPath);
typedef ReleaseObjectFunc = void Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId);

/// Service for interacting with remote JavaScript objects
class RemoteObjectService {
  static final RemoteObjectService instance = RemoteObjectService._();
  
  RemoteObjectService._();
  
  static GetObjectPropertiesFunc? _getObjectProperties;
  static EvaluatePropertyPathFunc? _evaluatePropertyPath;
  static ReleaseObjectFunc? _releaseObject;
  
  /// Set the native function pointers (called from native side)
  static void setNativeFunctions(
    GetObjectPropertiesFunc getObjectProperties,
    EvaluatePropertyPathFunc evaluatePropertyPath,
    ReleaseObjectFunc releaseObject,
  ) {
    _getObjectProperties = getObjectProperties;
    _evaluatePropertyPath = evaluatePropertyPath;
    _releaseObject = releaseObject;
  }
  
  /// Get properties of a remote object
  Future<List<RemoteObjectProperty>> getObjectProperties(
    int contextId, 
    String objectId, 
    {bool includePrototype = false}
  ) async {
    print('[RemoteObjectService] getObjectProperties called: contextId=$contextId, objectId=$objectId, includePrototype=$includePrototype');
    if (_getObjectProperties == null) {
      print('[RemoteObjectService] ERROR: _getObjectProperties is null');
      return [];
    }
    
    final objectIdPtr = objectId.toNativeUtf8();
    try {
      final resultPtr = _getObjectProperties!(
        dartContext!.pointer,
        contextId.toDouble(),
        objectIdPtr,
        includePrototype ? 1 : 0,
      );
      
      if (resultPtr == nullptr) {
        return [];
      }
      
      // Parse the result from NativeValue
      final WebFController? controller = WebFController.getControllerOfJSContextId(contextId.toDouble());
      if (controller == null) {
        return [];
      }
      final result = fromNativeValue(controller.view, resultPtr);
      
      if (result is List) {
        return result.map((item) {
          if (item is Map<String, dynamic>) {
            return RemoteObjectProperty(
              name: item['name'] ?? '',
              valueId: item['valueId'] ?? '',
              enumerable: item['enumerable'] ?? true,
              configurable: item['configurable'] ?? true,
              writable: item['writable'] ?? true,
              isOwn: item['isOwn'] ?? true,
              value: _parsePropertyValue(item['value']),
            );
          }
          return RemoteObjectProperty(
            name: 'unknown',
            valueId: '',
            enumerable: false,
            configurable: false,
            writable: false,
            isOwn: false,
            value: null,
          );
        }).toList();
      }
      
      return [];
    } finally {
      malloc.free(objectIdPtr);
    }
  }
  
  /// Evaluate a property path on a remote object
  Future<ConsoleValue?> evaluatePropertyPath(
    int contextId,
    String objectId,
    String propertyPath,
  ) async {
    if (_evaluatePropertyPath == null) {
      return null;
    }
    
    final objectIdPtr = objectId.toNativeUtf8();
    final propertyPathPtr = propertyPath.toNativeUtf8();
    
    try {
      final resultPtr = _evaluatePropertyPath!(
        dartContext!.pointer,
        contextId.toDouble(),
        objectIdPtr,
        propertyPathPtr,
      );
      
      if (resultPtr == nullptr) {
        return null;
      }
      
      // Parse the result
      final WebFController? controller = WebFController.getControllerOfJSContextId(contextId.toDouble());
      if (controller == null) {
        return null;
      }
      final result = fromNativeValue(controller.view, resultPtr);
      
      return _parseConsoleValue(result);
    } finally {
      malloc.free(objectIdPtr);
      malloc.free(propertyPathPtr);
    }
  }
  
  /// Release a remote object reference
  void releaseObject(int contextId, String objectId) {
    if (_releaseObject == null) {
      return;
    }
    
    final objectIdPtr = objectId.toNativeUtf8();
    try {
      _releaseObject!(dartContext!.pointer, contextId.toDouble(), objectIdPtr);
    } finally {
      malloc.free(objectIdPtr);
    }
  }
  
  ConsoleValue? _parsePropertyValue(dynamic value) {
    if (value == null) return null;
    
    if (value is Map<String, dynamic>) {
      if (value['type'] == 'remote-object') {
        return ConsoleRemoteObject(
          objectId: value['objectId'] ?? '',
          className: value['className'] ?? 'Object',
          description: value['description'] ?? 'Object',
          objectType: RemoteObjectType.values[value['objectType'] ?? 0],
        );
      } else if (value['type'] == 'primitive') {
        final primitiveValue = value['value'];
        String type = 'unknown';
        if (primitiveValue == null) {
          type = 'null';
        } else if (primitiveValue == 'undefined') {
          type = 'undefined';
        } else if (primitiveValue is bool) {
          type = 'boolean';
        } else if (primitiveValue is num) {
          type = 'number';
        } else if (primitiveValue is String) {
          type = 'string';
        }
        
        return ConsolePrimitiveValue(primitiveValue, type);
      }
    }
    
    return null;
  }
  
  ConsoleValue? _parseConsoleValue(dynamic result) {
    if (result is Map<String, dynamic>) {
      return _parsePropertyValue(result);
    }
    
    // Handle direct primitive values
    if (result == null) {
      return ConsolePrimitiveValue(null, 'null');
    } else if (result is bool) {
      return ConsolePrimitiveValue(result, 'boolean');
    } else if (result is num) {
      return ConsolePrimitiveValue(result, 'number');
    } else if (result is String) {
      return ConsolePrimitiveValue(result, 'string');
    }
    
    return null;
  }
}

/// Extended RemoteObjectProperty with value
class RemoteObjectProperty {
  final String name;
  final String valueId;
  final bool enumerable;
  final bool configurable;
  final bool writable;
  final bool isOwn;
  final ConsoleValue? value;
  
  RemoteObjectProperty({
    required this.name,
    required this.valueId,
    required this.enumerable,
    required this.configurable,
    required this.writable,
    required this.isOwn,
    this.value,
  });
  
  @override
  String toString() {
    final attrs = <String>[];
    if (!enumerable) attrs.add('non-enumerable');
    if (!configurable) attrs.add('non-configurable');
    if (!writable) attrs.add('read-only');
    if (!isOwn) attrs.add('inherited');
    
    final attrStr = attrs.isEmpty ? '' : ' (${attrs.join(', ')})';
    final valueStr = value?.toString() ?? 'undefined';
    
    return '$name: $valueStr$attrStr';
  }
}