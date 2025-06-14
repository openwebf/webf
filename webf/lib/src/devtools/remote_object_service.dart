/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:webf/src/devtools/console_store.dart';
import 'package:webf/webf.dart';

// Function pointers that will be set from the C++ side
typedef GetObjectPropertiesFunc = Pointer<NativeValue> Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId, int includePrototype);
typedef GetObjectPropertiesAsyncFunc = void Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId, int includePrototype, Object object, Pointer<NativeFunction<NativeGetObjectPropertiesCallback>> callback);
typedef NativeGetObjectPropertiesCallback = Void Function(Handle object, Pointer<NativeValue> result);
typedef EvaluatePropertyPathFunc = Pointer<NativeValue> Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId, Pointer<Utf8> propertyPath);
typedef ReleaseObjectFunc = void Function(Pointer<Void> dartIsolateContext, double contextId, Pointer<Utf8> objectId);

/// Service for interacting with remote JavaScript objects
class RemoteObjectService {
  static final RemoteObjectService instance = RemoteObjectService._();
  
  RemoteObjectService._();
  
  static GetObjectPropertiesFunc? _getObjectProperties;
  static GetObjectPropertiesAsyncFunc? _getObjectPropertiesAsync;
  static EvaluatePropertyPathFunc? _evaluatePropertyPath;
  static ReleaseObjectFunc? _releaseObject;
  
  /// Set the native function pointers (called from native side)
  static void setNativeFunctions(
    GetObjectPropertiesFunc getObjectProperties,
    GetObjectPropertiesAsyncFunc getObjectPropertiesAsync,
    EvaluatePropertyPathFunc evaluatePropertyPath,
    ReleaseObjectFunc releaseObject,
  ) {
    _getObjectProperties = getObjectProperties;
    _getObjectPropertiesAsync = getObjectPropertiesAsync;
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
    if (_getObjectPropertiesAsync == null) {
      print('[RemoteObjectService] ERROR: _getObjectPropertiesAsync is null');
      return [];
    }
    
    final completer = Completer<List<RemoteObjectProperty>>();
    final objectIdPtr = objectId.toNativeUtf8();
    
    // Create callback context
    final context = _GetObjectPropertiesContext(completer, contextId, objectIdPtr);
    
    // Create native callback
    final callback = Pointer.fromFunction<NativeGetObjectPropertiesCallback>(_handleGetObjectPropertiesCallback);
    
    // Call async function
    _getObjectPropertiesAsync!(
      dartContext!.pointer,
      contextId.toDouble(),
      objectIdPtr,
      includePrototype ? 1 : 0,
      context,
      callback,
    );
    
    return completer.future;
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

// Context class for async callback
class _GetObjectPropertiesContext {
  final Completer<List<RemoteObjectProperty>> completer;
  final int contextId;
  final Pointer<Utf8> objectIdPtr;
  
  _GetObjectPropertiesContext(this.completer, this.contextId, this.objectIdPtr);
}

// Callback handler for GetObjectPropertiesAsync
void _handleGetObjectPropertiesCallback(Object handle, Pointer<NativeValue> resultPtr) {
  final context = handle as _GetObjectPropertiesContext;
  
  try {
    if (resultPtr == nullptr) {
      context.completer.complete([]);
      return;
    }
    
    // Parse the result from NativeValue
    final WebFController? controller = WebFController.getControllerOfJSContextId(context.contextId.toDouble());
    if (controller == null) {
      context.completer.complete([]);
      return;
    }
    
    final result = fromNativeValue(controller.view, resultPtr);
    
    if (result is List) {
      final properties = result.map((item) {
        if (item is Map<String, dynamic>) {
          return RemoteObjectProperty(
            name: item['name'] ?? '',
            valueId: item['valueId'] ?? '',
            enumerable: item['enumerable'] ?? true,
            configurable: item['configurable'] ?? true,
            writable: item['writable'] ?? true,
            isOwn: item['isOwn'] ?? true,
            value: RemoteObjectService.instance._parsePropertyValue(item['value']),
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
      
      context.completer.complete(properties);
    } else {
      context.completer.complete([]);
    }
  } catch (e) {
    print('[RemoteObjectService] Error in callback: $e');
    context.completer.completeError(e);
  } finally {
    // Free the objectIdPtr
    malloc.free(context.objectIdPtr);
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