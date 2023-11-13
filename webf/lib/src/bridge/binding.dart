/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/geometry.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';

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
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  if (contextId != null &&
      pointer != null &&
      pointer.ref.invokeBindingMethodFromDart != nullptr &&
      event.target?.pointer?.ref.disposed != true &&
      event.currentTarget?.pointer?.ref.disposed != true
  ) {
    BindingObject bindingObject = controller.view.getBindingObject(pointer);
    // Call methods implements at C++ side.
    DartInvokeBindingMethodsFromDart f = pointer.ref.invokeBindingMethodFromDart.asFunction();

    Pointer<RawEvent> rawEvent = event.toRaw().cast<RawEvent>();
    List<dynamic> dispatchEventArguments = [event.type, rawEvent, isCapture];

    Stopwatch? stopwatch;
    if (isEnabledLog) {
      stopwatch = Stopwatch()..start();
    }

    Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'dispatchEvent');
    Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEventArguments);

    Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());
    f(pointer, returnValue, method, dispatchEventArguments.length, allocatedNativeArguments, event);
    Pointer<EventDispatchResult> dispatchResult = fromNativeValue(controller.view, returnValue).cast<EventDispatchResult>();
    event.cancelable = dispatchResult.ref.canceled;
    event.propagationStopped = dispatchResult.ref.propagationStopped;

    event.sharedJSProps = Pointer.fromAddress(rawEvent.ref.bytes.elementAt(8).value);
    event.propLen = rawEvent.ref.bytes.elementAt(9).value;
    event.allocateLen = rawEvent.ref.bytes.elementAt(10).value;

    if (isEnabledLog) {
      print('dispatch event to native side: target: ${event.target} arguments: $dispatchEventArguments time: ${stopwatch!.elapsedMicroseconds}us');
    }

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

  static void createBindingObject(int contextId, Pointer<NativeBindingObject> pointer, CreateBindingObjectType type, Pointer<NativeValue> args, int argc) {
    WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
    List<dynamic> arguments = List.generate(argc, (index) {
      return fromNativeValue(controller.view, args.elementAt(index));
    });
    switch(type) {
      case CreateBindingObjectType.createDOMMatrix: {
        DOMMatrix domMatrix = DOMMatrix(BindingContext(controller.view, contextId, pointer), arguments);
        controller.view.setBindingObject(pointer, domMatrix);
        return;
      }
    }
  }

  // For compatible requirement, we set the WebFViewController to nullable due to the historical reason.
  // exp: We can not break the types for WidgetElement which will break all the codes for Users.
  static void _bindObject(WebFViewController? view, BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null) {
      if (view != null) {
        view.setBindingObject(nativeBindingObject, object);
      }

      if (!nativeBindingObject.ref.disposed) {
        nativeBindingObject.ref.invokeBindingMethodFromNative = _invokeBindingMethodFromNative;
      }
    }
  }

  // For compatible requirement, we set the WebFViewController to nullable due to the historical reason.
  // exp: We can not break the types for WidgetElement which will break all the codes for Users.
  static void _unbindObject(WebFViewController? view, BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null) {
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
