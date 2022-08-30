/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

class NativeValue extends Struct {
  // Or Float64
  @Uint64()
  external int u;

  @Int64()
  external int int64;

  @Int64()
  external int tag;
}

enum JSValueType {
  TAG_STRING,
  TAG_INT,
  TAG_BOOL,
  TAG_NULL,
  TAG_FLOAT64,
  TAG_JSON,
  TAG_LIST,
  TAG_POINTER,
  TAG_FUNCTION,
  TAG_ASYNC_FUNCTION
}

enum JSPointerType {
  AsyncFunctionContext,
  NativeFunctionContext,
  NativeBoundingClientRect,
  NativeCanvasRenderingContext2D,
  NativeBindingObject
}

typedef AnonymousNativeFunction = dynamic Function(List<dynamic> args);
typedef AsyncAnonymousNativeFunction = Future<dynamic> Function(List<dynamic> args);

int _functionId = 0;
LinkedHashMap<int, AnonymousNativeFunction> _functionMap = LinkedHashMap();
LinkedHashMap<int, AsyncAnonymousNativeFunction> _asyncFunctionMap = LinkedHashMap();

AnonymousNativeFunction? getAnonymousNativeFunctionFromId(int id) {
  return _functionMap[id];
}

AsyncAnonymousNativeFunction? getAsyncAnonymousNativeFunctionFromId(int id) {
  return _asyncFunctionMap[id];
}

void removeAnonymousNativeFunctionFromId(int id) {
  _functionMap.remove(id);
}

void removeAsyncAnonymousNativeFunctionFromId(int id) {
  _asyncFunctionMap.remove(id);
}

dynamic fromNativeValue(Pointer<NativeValue> nativeValue) {
  if (nativeValue == nullptr) return null;

  JSValueType type = JSValueType.values[nativeValue.ref.tag];
  switch (type) {
    case JSValueType.TAG_STRING:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      String result = nativeStringToString(nativeString);
      freeNativeString(nativeString);
      return result;
    case JSValueType.TAG_INT:
      return nativeValue.ref.int64;
    case JSValueType.TAG_BOOL:
      return nativeValue.ref.int64 == 1;
    case JSValueType.TAG_NULL:
      return null;
    case JSValueType.TAG_FLOAT64:
      return uInt64ToDouble(nativeValue.ref.u);
    case JSValueType.TAG_POINTER:
      JSPointerType pointerType = JSPointerType.values[nativeValue.ref.int64];
      switch (pointerType) {
        case JSPointerType.NativeBoundingClientRect:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeBoundingClientRect>();
        case JSPointerType.NativeCanvasRenderingContext2D:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeCanvasRenderingContext2D>();
        case JSPointerType.NativeBindingObject:
          return Pointer.fromAddress(nativeValue.ref.u).cast<NativeBindingObject>();
        default:
          return Pointer.fromAddress(nativeValue.ref.u);
      }
    case JSValueType.TAG_FUNCTION:
    case JSValueType.TAG_ASYNC_FUNCTION:
      break;
    case JSValueType.TAG_JSON:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      dynamic value = jsonDecode(nativeStringToString(nativeString));
      freeNativeString(nativeString);
      return value;
  }
}

void toNativeValue(Pointer<NativeValue> target, value) {
  if (value == null) {
    target.ref.tag = JSValueType.TAG_NULL.index;
  } else if (value is int) {
    target.ref.tag = JSValueType.TAG_INT.index;
    target.ref.int64 = value;
  } else if (value is bool) {
    target.ref.tag = JSValueType.TAG_BOOL.index;
    target.ref.int64 = value ? 1 : 0;
  } else if (value is double) {
    target.ref.tag = JSValueType.TAG_FLOAT64.index;
    target.ref.u = doubleToUint64(value);
  } else if (value is List) {
    target.ref.tag = JSValueType.TAG_LIST.index;
    target.ref.int64 = value.length;
    Pointer<Pointer<NativeValue>> lists = malloc.allocate<Pointer<NativeValue>>(sizeOf<NativeValue>() * value.length);
    target.ref.u = lists.address;
    for(int i = 0; i < value.length; i ++) {
      Pointer<NativeValue> list_item = malloc.allocate(sizeOf<NativeValue>());
      toNativeValue(list_item, value[i]);
      lists[i] = list_item;
    }
  } else if (value is String) {
    target.ref.tag = JSValueType.TAG_STRING.index;
    target.ref.u = stringToNativeString(value).address;
  } else if (value is Pointer) {
    target.ref.tag = JSValueType.TAG_POINTER.index;
    target.ref.u = value.address;
    if (value is Pointer<NativeBoundingClientRect>) {
      target.ref.int64 = JSPointerType.NativeBoundingClientRect.index;
    } else if (value is Pointer<NativeCanvasRenderingContext2D>) {
      target.ref.int64 = JSPointerType.NativeCanvasRenderingContext2D.index;
    } else if (value is Pointer<NativeBindingObject>) {
      target.ref.int64 = JSPointerType.NativeBindingObject.index;
    }
  } else if (value is BindingObject) {
    target.ref.tag = JSValueType.TAG_POINTER.index;
    assert(value.pointer is Pointer);
    target.ref.u = (value.pointer as Pointer).address;
    target.ref.int64 = JSPointerType.NativeBindingObject.index;
  } else if (value is AsyncAnonymousNativeFunction) {
    int id = _functionId++;
    _asyncFunctionMap[id] = value;
    target.ref.tag = JSValueType.TAG_ASYNC_FUNCTION.index;
    target.ref.u = id;
  } else if (value is AnonymousNativeFunction) {
    int id = _functionId++;
    _functionMap[id] = value;
    target.ref.tag = JSValueType.TAG_FUNCTION.index;
    target.ref.int64 = id;
  } else if (value is Object) {
    String str = jsonEncode(value);
    target.ref.tag = JSValueType.TAG_JSON.index;
    target.ref.int64 = str.toNativeUtf8().address;
  }
}
