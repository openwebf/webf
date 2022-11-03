/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'package:collection/collection.dart';
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
typedef AsyncBindingMethodCallback = Future<dynamic> Function(List args);

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
    this.call,
    this.asyncCall,
  });
  final BindingMethodCallback? call;
  final AsyncBindingMethodCallback? asyncCall;
}

abstract class BindingObject {
  static BindingObjectOperation? bind;
  static BindingObjectOperation? unbind;
  // To make sure same kind of WidgetElement only sync once.
  static final Map<Type, bool> _alreadySyncWidgetElements = {};

  final BindingContext? _context;

  int? get contextId => _context?.contextId;
  Pointer<NativeBindingObject>? get pointer => _context?.pointer;

  BindingObject([BindingContext? context]) : _context = context {
    _bind();
    initializeProperties(_properties);
    initializeMethods(_methods);

    if (this is WidgetElement && !_alreadySyncWidgetElements.containsKey(runtimeType)) {
      _alreadySyncWidgetElements[runtimeType] = true;
      _syncPropertiesAndMethodsToNativeSlow();
    }
  }

  void _syncPropertiesAndMethodsToNativeSlow() {
    assert(pointer != null);

    List<String> properties = _properties.keys.toList(growable: false);
    List<String> methods = _methods.keys.toList(growable: false);

    Pointer<NativeValue> arguments = malloc.allocate(sizeOf<NativeValue>() * 2);
    toNativeValue(arguments.elementAt(0), properties);
    toNativeValue(arguments.elementAt(1), methods);

    DartInvokeBindingMethodsFromDart f = pointer!.ref.invokeBindingMethodFromDart.asFunction();
    Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());

    Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'syncPropertiesAndMethods');
    f(pointer!, returnValue, method, 2, arguments);
    bool result = fromNativeValue(returnValue);
    assert(result == true);
  }

  final Map<String, BindingObjectProperty> _properties = {};
  final Map<String, BindingObjectMethod> _methods = {};

  @mustCallSuper
  void initializeProperties(Map<String, BindingObjectProperty> properties);

  @mustCallSuper
  void initializeMethods(Map<String, BindingObjectMethod> methods);

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
  dynamic _invokeBindingMethodSync(String method, List args) {
    BindingObjectMethod? fn = _methods[method];
    if (fn == null) {
      return;
    }

    if (fn.call != null) {
      return fn.call!(args);
    }
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
  List<String> methods = bindingObject._methods.keys.toList();
  properties.addAll(methods);

  if (isEnabledLog) {
    print('$bindingObject getPropertyNamesBindingCall value: $properties');
  }

  return properties;
}

dynamic invokeBindingMethodSync(BindingObject bindingObject, List<dynamic> args) {
  bindingObject._invokeBindingMethodSync(args[0], args.slice(1));
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
      if (method < BindingMethodCallOperations.AsyncAnonymousFunction.index) {
        result = bindingCallMethodDispatchTable[method](bindingObject, values);
      } else {
        // if (method == BindingMethodCallOperations.AnonymousFunctionCall.index) {
        //   int id = values[0];
        //   List<dynamic> functionArguments = values.sublist(1);
        //   BindingObjectMethod? fn = bindingObject._methods[method];
        //   // AnonymousNativeFunction? fn = bindingObject.getAnonymousNativeFunctionFromId(id);
        //   if (fn == null) {
        //     print('WebF warning: can not find registered anonymous native function for id: $id bindingObject: $nativeBindingObject');
        //     toNativeValue(returnValue, null, bindingObject);
        //     return;
        //   }
        //   try {
        //     if (isEnabledLog) {
        //       String argsStr = functionArguments.map((e) => e.toString()).join(',');
        //       print('Invoke AnonymousFunction id: $id, arguments: [$argsStr] bindingObject: $nativeBindingObject');
        //     }
        //
        //     result = fn(functionArguments);
        //   } catch (e, stack) {
        //     print('$e\n$stack');
        //   }
        // } else if (method == BindingMethodCallOperations.AsyncAnonymousFunction.index) {
        //   int id = values[0];
        //   AsyncAnonymousNativeFunction? fn = bindingObject.getAsyncAnonymousNativeFunctionFromId(id);
        //   if (fn == null) {
        //     print('WebF warning: can not find registered anonymous native async function for id: $id bindingObject: $nativeBindingObject');
        //     toNativeValue(returnValue, null, bindingObject);
        //     return;
        //   }
        //   int contextId = values[1];
        //   // Async callback should hold a context to store the current execution environment.
        //   Pointer<Void> callbackContext = (values[2] as Pointer).cast<Void>();
        //   DartAsyncAnonymousFunctionCallback callback =
        //   (values[3] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
        //   List<dynamic> functionArguments = values.sublist(4);
        //   if (isEnabledLog) {
        //     String argsStr = functionArguments.map((e) => e.toString()).join(',');
        //     print('Invoke AsyncAnonymousFunction id: $id arguments: [$argsStr]');
        //   }
        //
        //   Future<dynamic> p = fn(functionArguments);
        //   p.then((result) {
        //     if (isEnabledLog) {
        //       print('AsyncAnonymousFunction call resolved callback: $id arguments:[$result]');
        //     }
        //     Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
        //     toNativeValue(nativeValue, result, bindingObject);
        //     callback(callbackContext, nativeValue, contextId, nullptr);
        //   }).catchError((e, stack) {
        //     String errorMessage = '$e\n$stack';
        //     if (isEnabledLog) {
        //       print('AsyncAnonymousFunction call rejected callback: $id, arguments:[$errorMessage]');
        //     }
        //     callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
        //   });
        // }
      }
    } else {
      BindingObject bindingObject = BindingBridge.getBindingObject(nativeBindingObject);
      // invokeBindingMethod directly
      if (isEnabledLog) {
        print('$bindingObject invokeBindingMethod method: $method args: $values');
      }
      result = bindingObject._invokeBindingMethodSync(method, values);
    }
  } catch (e, stack) {
    print('$e\n$stack');
  } finally {
    toNativeValue(returnValue, result, bindingObject);
  }
}
