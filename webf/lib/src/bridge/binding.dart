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
import 'package:webf/geometry.dart';
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

List<BindingCallFunc> bindingCallMethodDispatchTable = [
  getterBindingCall,
  setterBindingCall,
  getPropertyNamesBindingCall,
  invokeBindingMethodSync,
  invokeBindingMethodAsync
];

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

enum CreateBindingObjectType {
  createDOMMatrix
}

abstract class BindingBridge {
  static final Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> _invokeBindingMethodFromNative =
      Pointer.fromFunction(invokeBindingMethodFromNativeImpl);

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

  static void createBindingObject(int contextId, Pointer<NativeBindingObject> pointer, CreateBindingObjectType type, Pointer<NativeValue> args, int argc) {
    List<dynamic> arguments = List.generate(argc, (index) {
      return fromNativeValue(args.elementAt(index));
    });
    switch(type) {
      case CreateBindingObjectType.createDOMMatrix: {
        DOMMatrix domMatrix = DOMMatrix(BindingContext(contextId, pointer), arguments);
        _nativeObjects[pointer.address] = domMatrix;
        return;
      }
    }
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
