/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

// We have some integrated built-in behavior starting with string prefix reuse the callNativeMethod implements.
enum BindingMethodCallOperations {
  GetProperty,
  SetProperty,
  GetAllPropertyNames,
  AnonymousFunctionCall,
  AsyncAnonymousFunction,
}

typedef NativeAsyncAnonymousFunctionCallback = Void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncAnonymousFunctionCallback = void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, int contextId, Pointer<Utf8> errmsg);

typedef BindingCallFunc = dynamic Function(BindingObject bindingObject, List<dynamic> args);

dynamic getterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 1);
  if (isEnabledLog) {
    print('$bindingObject getBindingProperty key: ${args[0]} result: ${bindingObject.getBindingProperty(args[0])}');
  }

  return bindingObject.getBindingProperty(args[0]);
}

dynamic setterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 2);
  if (isEnabledLog) {
    print('$bindingObject setBindingProperty key: ${args[0]} value: ${args[1]}');
  }

  bindingObject.setBindingProperty(args[0], args[1]);
  return true;
}

dynamic getPropertyNamesBindingCall(BindingObject bindingObject, List<dynamic> args) {
  List<String> properties = List.empty(growable: true);
  bindingObject.getAllBindingPropertyNames(properties);

  if (isEnabledLog) {
    print('$bindingObject getPropertyNamesBindingCall value: $properties');
  }

  return properties;
}

List<BindingCallFunc> bindingCallMethodDispatchTable = [
  getterBindingCall,
  setterBindingCall,
  getPropertyNamesBindingCall,
];

// This function receive calling from binding side.
void _invokeBindingMethodFromNativeImpl(Pointer<NativeBindingObject> nativeBindingObject,
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
      result = bindingObject.invokeBindingMethod(method, values);
    }
  } catch (e, stack) {
    print('$e\n$stack');
  } finally {
    toNativeValue(returnValue, result, bindingObject);
  }
}

// Dispatch the event to the binding side.
void _dispatchEventToNative(Event event) {
  Pointer<NativeBindingObject>? pointer = event.currentTarget?.pointer;
  int? contextId = event.target?.contextId;
  if (contextId != null && pointer != null && pointer.ref.invokeBindingMethodFromDart != nullptr) {
    BindingObject bindingObject = BindingBridge.getBindingObject(pointer);
    // Call methods implements at C++ side.
    DartInvokeBindingMethodsFromDart f = pointer.ref.invokeBindingMethodFromDart.asFunction();

    Pointer<Void> rawEvent = event.toRaw().cast<Void>();
    List<dynamic> dispatchEventArguments = [event.type, rawEvent];

    if (isEnabledLog) {
      print('dispatch event to native side: target: ${event.target} arguments: $dispatchEventArguments');
    }

    Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'dispatchEvent');
    Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEventArguments);

    Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());
    f(pointer, returnValue, method, dispatchEventArguments.length, allocatedNativeArguments);
    Pointer<EventDispatchResult> dispatchResult = fromNativeValue(returnValue).cast<EventDispatchResult>();
    event.cancelable = dispatchResult.ref.canceled;
    event.propagationStopped = dispatchResult.ref.propagationStopped;

    // Free the allocated arguments.
    malloc.free(rawEvent);
    malloc.free(method);
    malloc.free(allocatedNativeArguments);
    malloc.free(dispatchResult);
    malloc.free(returnValue);
  }
}

abstract class BindingBridge {
  static final Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> _invokeBindingMethodFromNative =
      Pointer.fromFunction(_invokeBindingMethodFromNativeImpl);

  static Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> get nativeInvokeBindingMethod =>
      _invokeBindingMethodFromNative;

  static final SplayTreeMap<int, BindingObject> _nativeObjects = SplayTreeMap();

  static BindingObject getBindingObject(Pointer pointer) {
    BindingObject? target = _nativeObjects[pointer.address];
    if (target == null) {
      throw FlutterError('Can not get binding object: $pointer');
    }
    return target;
  }

  static void _bindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null && !nativeBindingObject.ref.disposed) {
      _nativeObjects[nativeBindingObject.address] = object;
      nativeBindingObject.ref.invokeBindingMethodFromNative = _invokeBindingMethodFromNative;
    }
  }

  static void _unbindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null) {
      _nativeObjects.remove(nativeBindingObject.address);
      nativeBindingObject.ref.invokeBindingMethodFromNative = nullptr;
    }
  }

  static void setup() {
    BindingObject.bind = _bindObject;
    BindingObject.unbind = _unbindObject;
  }

  static void teardown() {
    BindingObject.bind = null;
    BindingObject.unbind = null;
  }

  static void listenEvent(EventTarget target, String type) {
    assert(_debugShouldNotListenMultiTimes(target, type),
        'Failed to listen event \'$type\' for $target, for which is already bound.');
    target.addEventListener(type, _dispatchEventToNative);
  }

  static void unlistenEvent(EventTarget target, String type) {
    assert(_debugShouldNotUnlistenEmpty(target, type),
        'Failed to unlisten event \'$type\' for $target, for which is already unbound.');
    target.removeEventListener(type, _dispatchEventToNative);
  }

  static bool _debugShouldNotListenMultiTimes(EventTarget target, String type) {
    Map<String, List<EventHandler>> eventHandlers = target.getEventHandlers();
    List<EventHandler>? handlers = eventHandlers[type];
    if (handlers != null) {
      return !handlers.contains(_dispatchEventToNative);
    }
    return true;
  }

  static bool _debugShouldNotUnlistenEmpty(EventTarget target, String type) {
    Map<String, List<EventHandler>> eventHandlers = target.getEventHandlers();
    List<EventHandler>? handlers = eventHandlers[type];
    if (handlers != null) {
      return handlers.contains(_dispatchEventToNative);
    }
    return false;
  }
}
