/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/bridge.dart';

import 'native_value.dart';

// MUST READ:
// All the class which extends Struct class has a corresponding struct in C++ code.
// All class members include variables and functions must be follow the same order with C++ struct, to keep the same memory layout cross dart and C++ code.

class NativeWebFInfo extends Struct {
  external Pointer<Utf8> app_name;
  external Pointer<Utf8> app_version;
  external Pointer<Utf8> app_revision;
  external Pointer<Utf8> system_name;
}

// An native struct can be directly convert to javaScript String without any conversion cost.
class NativeString extends Struct {
  external Pointer<Uint16> string;

  @Uint32()
  external int length;
}

// For memory compatibility between NativeEvent and other struct which inherit NativeEvent(exp: NativeTouchEvent, NativeGestureEvent),
// We choose to make all this structs have same memory layout. But dart lang did't provide semantically syntax to achieve this (like inheritance a class which extends Struct
// or declare struct memory by value).
// The only worked ways is use raw bytes to store NativeEvent members.
class RawEvent extends Struct {
// Raw bytes represent the NativeEvent fields.
  external Pointer<Uint64> bytes;
  @Int64()
  external int length;
  @Int8()
  external int is_custom_event;
}

class EventDispatchResult extends Struct {
  @Bool()
  external bool canceled;

  @Bool()
  external bool propagationStopped;
}

class AddEventListenerOptions extends Struct {
  @Bool()
  external bool capture;

  @Bool()
  external bool passive;

  @Bool()
  external bool once;
}

class NativeTouchList extends Struct {
  @Int64()
  external int length;
  external Pointer<NativeTouch> touches;
}

class NativeTouch extends Struct {
  @Int64()
  external int identifier;

  external Pointer<NativeBindingObject> target;

  @Double()
  external double clientX;

  @Double()
  external double clientY;

  @Double()
  external double screenX;

  @Double()
  external double screenY;

  @Double()
  external double pageX;

  @Double()
  external double pageY;

  @Double()
  external double radiusX;

  @Double()
  external double radiusY;

  @Double()
  external double rotationAngle;

  @Double()
  external double force;

  @Double()
  external double altitudeAngle;

  @Double()
  external double azimuthAngle;
}

typedef InvokeBindingsMethodsFromNative = Void Function(
    Double contextId,
    Int64 profileId,
    Pointer<NativeBindingObject> binding_object,
    Pointer<NativeValue> return_value,
    Pointer<NativeValue> method,
    Int32 argc,
    Pointer<NativeValue> argv);
typedef NativeInvokeResultCallback = Void Function(Handle object, Pointer<NativeValue> result);

typedef InvokeBindingMethodsFromDart = Void Function(
    Pointer<NativeBindingObject> binding_object,
    Int64 profileId,
    Pointer<NativeValue> method,
    Int32 argc,
    Pointer<NativeValue> argv,
    Handle bindingDartObject,
    Pointer<NativeFunction<NativeInvokeResultCallback>> result_callback);
typedef DartInvokeBindingMethodsFromDart = void Function(
    Pointer<NativeBindingObject> binding_object,
    int profileId,
    Pointer<NativeValue> method,
    int argc,
    Pointer<NativeValue> argv,
    Object bindingDartObject,
    Pointer<NativeFunction<NativeInvokeResultCallback>> result_callback);

class NativeBindingObject extends Struct {
  external Pointer<Void> instance;
  external Pointer<NativeFunction<InvokeBindingMethodsFromDart>> invokeBindingMethodFromDart;
  // Shared method called by JS side.
  external Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> invokeBindingMethodFromNative;
  external Pointer<Void> extra;
  @Bool()
  external bool _disposed;
}

typedef NativeAllocateNativeBindingObject = Pointer<NativeBindingObject> Function();
typedef DartAllocateNativeBindingObject = Pointer<NativeBindingObject> Function();

final DartAllocateNativeBindingObject _allocateNativeBindingObject = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeAllocateNativeBindingObject>>('allocateNativeBindingObject')
    .asFunction();

typedef NativeIsNativeBindingObjectDisposed = Bool Function(Pointer<NativeBindingObject>);
typedef DartIsNativeBindingObjectDisposed = bool Function(Pointer<NativeBindingObject>);

final DartIsNativeBindingObjectDisposed _isNativeBindingObjectDisposed = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeIsNativeBindingObjectDisposed>>('isNativeBindingObjectDisposed')
    .asFunction();

Pointer<NativeBindingObject> allocateNewBindingObject() {
  return _allocateNativeBindingObject();
}

bool isBindingObjectDisposed(Pointer<NativeBindingObject>? nativeBindingObject) {
  if (nativeBindingObject == null) return true;
  return _isNativeBindingObjectDisposed(nativeBindingObject);
}

class NativePerformanceEntry extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> entryType;

  @Double()
  external double startTime;
  @Double()
  external double duration;
}

class NativePerformanceEntryList extends Struct {
  external Pointer<Uint64> entries;

  @Int32()
  external int length;
}
