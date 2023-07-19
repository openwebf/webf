/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
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
void _dispatchNomalEventToNative(Event event) {
  _dispatchEventToNative(event, false);
}
void _dispatchCaptureEventToNative(Event event) {
  _dispatchEventToNative(event, true);
}
void _dispatchEventToNative(Event event, bool isCapture) {
  Pointer<NativeBindingObject>? pointer = event.currentTarget?.pointer;
  int? contextId = event.target?.contextId;
  if (contextId != null && pointer != null && pointer.ref.invokeBindingMethodFromDart != nullptr) {
    BindingObject bindingObject = BindingBridge.getBindingObject(pointer);
    // Call methods implements at C++ side.
    DartInvokeBindingMethodsFromDart f = pointer.ref.invokeBindingMethodFromDart.asFunction();

    Pointer<RawEvent> rawEvent = event.toRaw().cast<RawEvent>();
    List<dynamic> dispatchEventArguments = [event.type, rawEvent, isCapture];

    if (isEnabledLog) {
      print('dispatch event to native side: target: ${event.target} arguments: $dispatchEventArguments');
    }

    Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'dispatchEvent');
    Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEventArguments);

    Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());
    f(pointer, returnValue, method, dispatchEventArguments.length, allocatedNativeArguments, event);
    Pointer<EventDispatchResult> dispatchResult = fromNativeValue(returnValue).cast<EventDispatchResult>();
    event.cancelable = dispatchResult.ref.canceled;
    event.propagationStopped = dispatchResult.ref.propagationStopped;

    event.sharedJSProps = Pointer.fromAddress(rawEvent.ref.bytes.elementAt(8).value);
    event.propLen = rawEvent.ref.bytes.elementAt(9).value;
    event.allocateLen = rawEvent.ref.bytes.elementAt(10).value;

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

  static T? getBindingObject<T>(Pointer pointer) {
    return _nativeObjects[pointer.address] as T?;
  }
  static bool hasBindingObject(Pointer pointer) {
    return _nativeObjects.containsKey(pointer.address);
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
    if (nativeBindingObject != null) {
      _nativeObjects[nativeBindingObject.address] = object;
      if (!nativeBindingObject.ref.disposed) {
        nativeBindingObject.ref.invokeBindingMethodFromNative = _invokeBindingMethodFromNative;
      }
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

  static void listenEvent(EventTarget target, String type, {Pointer<AddEventListenerOptions>? addEventListenerOptions}) {
    bool isCapture = addEventListenerOptions != null ? addEventListenerOptions.ref.capture : false;
    if (!hasListener(target, type, isCapture: isCapture)) {
      EventListenerOptions? eventListenerOptions;
      if (addEventListenerOptions != null && addEventListenerOptions.ref.capture) {
        eventListenerOptions = EventListenerOptions(addEventListenerOptions.ref.capture, addEventListenerOptions.ref.passive, addEventListenerOptions.ref.once);
        target.addEventListener(type, _dispatchCaptureEventToNative, addEventListenerOptions: eventListenerOptions);
      } else
        target.addEventListener(type, _dispatchNomalEventToNative, addEventListenerOptions: eventListenerOptions);
    }
  }

  static void unlistenEvent(EventTarget target, String type, {bool isCapture = false}) {
    if (isCapture)
      target.removeEventListener(type, _dispatchCaptureEventToNative, isCapture: isCapture);
    else
      target.removeEventListener(type, _dispatchNomalEventToNative, isCapture: isCapture);

  }

  static bool hasListener(EventTarget target, String type, {bool isCapture = false}) {
    Map<String, List<EventHandler>> eventHandlers = isCapture ? target.getCaptureEventHandlers() : target.getEventHandlers();
    List<EventHandler>? handlers = eventHandlers[type];
    if (handlers != null) {
      return isCapture ? handlers.contains(_dispatchCaptureEventToNative) : handlers.contains(_dispatchNomalEventToNative);
    }
    return false;
  }
}
