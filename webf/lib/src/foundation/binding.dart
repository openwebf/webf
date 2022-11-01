/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'dart:collection';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/widget.dart';

typedef BindingObjectOperation = void Function(BindingObject bindingObject);

class BindingContext {
  final int contextId;
  final Pointer<NativeBindingObject> pointer;
  const BindingContext(this.contextId, this.pointer);
}

typedef BindingPropertyGetter = dynamic Function();
typedef BindingPropertySetter = void Function(dynamic value);
typedef BindingMethodCallback = dynamic Function(List args);

class BindingObjectProperty {
  BindingObjectProperty({
    required this.getter,
    this.setter
  });
  final BindingPropertyGetter getter;
  final BindingPropertySetter? setter;
}

class BindingObjectMethod {
  BindingObjectMethod({
    required this.call
  });
  final BindingMethodCallback call;
}

abstract class BindingObject {
  static BindingObjectOperation? bind;
  static BindingObjectOperation? unbind;

  final BindingContext? _context;

  int? get contextId => _context?.contextId;
  Pointer<NativeBindingObject>? get pointer => _context?.pointer;

  BindingObject([BindingContext? context]) : _context = context {
    _bind();
    initializeProperties(_properties);
    initializeMethods(_methods);
  }

  final Map<String, BindingObjectProperty> _properties = {};
  final Map<String, BindingObjectMethod> _methods = {};

  @mustCallSuper
  void initializeProperties(Map<String, BindingObjectProperty> properties);

  @mustCallSuper
  void initializeMethods(Map<String, BindingObjectMethod> methods);

  int _functionId = 0;
  final LinkedHashMap<int, AnonymousNativeFunction> _functionMap = LinkedHashMap();
  final LinkedHashMap<int, AsyncAnonymousNativeFunction> _asyncFunctionMap = LinkedHashMap();

  AnonymousNativeFunction? getAnonymousNativeFunctionFromId(int id) {
    return _functionMap[id];
  }
  int setAnonymousNativeFunction(AnonymousNativeFunction fn) {
    int newId = _functionId++;
    _functionMap[newId] = fn;

    if (isEnabledLog) {
      print('store native function for id: $newId bindingObject: $pointer');
    }
    return newId;
  }

  AsyncAnonymousNativeFunction? getAsyncAnonymousNativeFunctionFromId(int id) {
    return _asyncFunctionMap[id];
  }
  int setAsyncAnonymousNativeFunction(AsyncAnonymousNativeFunction fn) {
    int newId = _functionId++;
    _asyncFunctionMap[newId] = fn;

    if (isEnabledLog) {
      print('store async native function for id: $newId bindingObject: $pointer');
    }

    return newId;
  }

  // Bind dart side object method to receive invoking from native side.
  void _bind() {
    if (bind != null) {
      bind!(this);
    }
  }

  void _unbind() {
    if (unbind != null) {
      unbind!(this);
    }
  }

  // Call a method, eg:
  //   el.getContext('2x');
  dynamic _invokeBindingMethod(String method, List args) {
    BindingObjectMethod? fn = _methods[method];
    if (fn == null) {
      return;
    }
    return fn.call(args);
  }

  @mustCallSuper
  void dispose() {
    _unbind();
    _properties.clear();
    _methods.clear();
  }
}

dynamic getterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 1);

  BindingObjectProperty? property = bindingObject._properties[args[0]];

  if (isEnabledLog && property != null) {
    print('$bindingObject getBindingProperty key: ${args[0]} result: ${property.getter()}');
  }

  if (property != null) {
    return property.getter();
  }
  return null;
}

dynamic setterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 2);
  if (isEnabledLog) {
    print('$bindingObject setBindingProperty key: ${args[0]} value: ${args[1]}');
  }

  String key = args[0];
  dynamic value = args[1];
  BindingObjectProperty? property = bindingObject._properties[key];
  if (property != null && property.setter != null) {
    property.setter!(value);

    if (bindingObject is WidgetElement) {
      bool shouldElementRebuild = bindingObject.shouldElementRebuild(key, property.getter(), value);
      if (shouldElementRebuild) {
        bindingObject.setState(() {});
      }
      bindingObject.propertyDidUpdate(key, value);
    }
  }

  return true;
}

dynamic getPropertyNamesBindingCall(BindingObject bindingObject, List<dynamic> args) {
  List<String> properties = bindingObject._properties.keys.toList();

  if (isEnabledLog) {
    print('$bindingObject getPropertyNamesBindingCall value: $properties');
  }

  return properties;
}

// This function receive calling from binding side.
void invokeBindingMethodFromNativeImpl(Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeValue> returnValue, Pointer<NativeValue> nativeMethod, int argc, Pointer<NativeValue> argv) {
  dynamic method = fromNativeValue(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    return fromNativeValue(nativeValue);
  });

  BindingObject bindingObject = BindingBridge.getBindingObject(nativeBindingObject);
  var result = null;
  try {
    // Method is binding call method operations from internal.
    if (method is int) {
      // Get and setter ops
      if (method <= 2) {
        result = bindingCallMethodDispatchTable[method](bindingObject, values);
      } else {
        if (method == BindingMethodCallOperations.AnonymousFunctionCall.index) {
          int id = values[0];
          List<dynamic> functionArguments = values.sublist(1);
          AnonymousNativeFunction? fn = bindingObject.getAnonymousNativeFunctionFromId(id);
          if (fn == null) {
            print('WebF warning: can not find registered anonymous native function for id: $id bindingObject: $nativeBindingObject');
            toNativeValue(returnValue, null, bindingObject);
            return;
          }
          try {
            if (isEnabledLog) {
              String argsStr = functionArguments.map((e) => e.toString()).join(',');
              print('Invoke AnonymousFunction id: $id, arguments: [$argsStr] bindingObject: $nativeBindingObject');
            }

            result = fn(functionArguments);
          } catch (e, stack) {
            print('$e\n$stack');
          }
        } else if (method == BindingMethodCallOperations.AsyncAnonymousFunction.index) {
          int id = values[0];
          AsyncAnonymousNativeFunction? fn = bindingObject.getAsyncAnonymousNativeFunctionFromId(id);
          if (fn == null) {
            print('WebF warning: can not find registered anonymous native async function for id: $id bindingObject: $nativeBindingObject');
            toNativeValue(returnValue, null, bindingObject);
            return;
          }
          int contextId = values[1];
          // Async callback should hold a context to store the current execution environment.
          Pointer<Void> callbackContext = (values[2] as Pointer).cast<Void>();
          DartAsyncAnonymousFunctionCallback callback =
          (values[3] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
          List<dynamic> functionArguments = values.sublist(4);
          if (isEnabledLog) {
            String argsStr = functionArguments.map((e) => e.toString()).join(',');
            print('Invoke AsyncAnonymousFunction id: $id arguments: [$argsStr]');
          }

          Future<dynamic> p = fn(functionArguments);
          p.then((result) {
            if (isEnabledLog) {
              print('AsyncAnonymousFunction call resolved callback: $id arguments:[$result]');
            }
            Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
            toNativeValue(nativeValue, result, bindingObject);
            callback(callbackContext, nativeValue, contextId, nullptr);
          }).catchError((e, stack) {
            String errorMessage = '$e\n$stack';
            if (isEnabledLog) {
              print('AsyncAnonymousFunction call rejected callback: $id, arguments:[$errorMessage]');
            }
            callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
          });
        }
      }
    } else {
      BindingObject bindingObject = BindingBridge.getBindingObject(nativeBindingObject);
      // invokeBindingMethod directly
      if (isEnabledLog) {
        print('$bindingObject invokeBindingMethod method: $method args: $values');
      }
      result = bindingObject._invokeBindingMethod(method, values);
    }
  } catch (e, stack) {
    print('$e\n$stack');
  } finally {
    toNativeValue(returnValue, result, bindingObject);
  }
}
