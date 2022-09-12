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
  @Int64()
  external int u;

  @Uint32()
  external int uint32;

  @Int32()
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
  Others
}

typedef AnonymousNativeFunction = dynamic Function(List<dynamic> args);
typedef AsyncAnonymousNativeFunction = Future<dynamic> Function(List<dynamic> args);

int _functionId = 0;
LinkedHashMap<int, AnonymousNativeFunction> _functionMap = LinkedHashMap();
LinkedHashMap<int, AsyncAnonymousNativeFunction> _asyncFunctionMap = LinkedHashMap();

// Save the relationship between function name and functionId in debug mode.
LinkedHashMap<int, String> debugFunctionMap = LinkedHashMap();

AnonymousNativeFunction? getAnonymousNativeFunctionFromId(int id) {
  return _functionMap[id];
}

AsyncAnonymousNativeFunction? getAsyncAnonymousNativeFunctionFromId(int id) {
  return _asyncFunctionMap[id];
}

void removeAnonymousNativeFunctionFromId(int id) {
  _functionMap.remove(id);
  assert(() {
    debugFunctionMap.remove(id);
    return true;
  }());
}

void removeAsyncAnonymousNativeFunctionFromId(int id) {
  _asyncFunctionMap.remove(id);
  assert(() {
    debugFunctionMap.remove(id);
    return true;
  }());
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
      return nativeValue.ref.u;
    case JSValueType.TAG_BOOL:
      return nativeValue.ref.u == 1;
    case JSValueType.TAG_NULL:
      return null;
    case JSValueType.TAG_FLOAT64:
      return uInt64ToDouble(nativeValue.ref.u);
    case JSValueType.TAG_POINTER:
      return Pointer.fromAddress(nativeValue.ref.u);
    case JSValueType.TAG_LIST:
      return List.generate(nativeValue.ref.uint32, (index) {
        Pointer<NativeValue> head = Pointer.fromAddress(nativeValue.ref.u).cast<NativeValue>();
        return fromNativeValue(head.elementAt(index));
      });
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
    target.ref.u = value;
  } else if (value is bool) {
    target.ref.tag = JSValueType.TAG_BOOL.index;
    target.ref.u = value ? 1 : 0;
  } else if (value is double) {
    target.ref.tag = JSValueType.TAG_FLOAT64.index;
    target.ref.u = doubleToInt64(value);
  } else if (value is String) {
    target.ref.tag = JSValueType.TAG_STRING.index;
    target.ref.u = stringToNativeString(value).address;
  } else if (value is Pointer) {
    target.ref.tag = JSValueType.TAG_POINTER.index;
    target.ref.u = value.address;
  } else if (value is BindingObject) {
    target.ref.tag = JSValueType.TAG_POINTER.index;
    target.ref.u = (value.pointer)!.address;
  } else if (value is List) {
    target.ref.tag = JSValueType.TAG_LIST.index;
    target.ref.uint32 = value.length;
    Pointer<NativeValue> lists = malloc.allocate(sizeOf<NativeValue>() * value.length);
    target.ref.u = lists.address;
    for(int i = 0; i < value.length; i ++) {
      toNativeValue(lists.elementAt(i), value[i]);
    }
  } else if (value is AsyncAnonymousNativeFunction) {
    int id = _functionId++;
    _asyncFunctionMap[id] = value;
    target.ref.tag = JSValueType.TAG_ASYNC_FUNCTION.index;
    target.ref.u = id;
  } else if (value is AnonymousNativeFunction) {
    int id = _functionId++;
    _functionMap[id] = value;
    target.ref.tag = JSValueType.TAG_FUNCTION.index;
    target.ref.u = id;
  } else if (value is Object) {
    String str = jsonEncode(value);
    target.ref.tag = JSValueType.TAG_JSON.index;
    target.ref.u = str.toNativeUtf8().address;
  }
}

Pointer<NativeValue> makeNativeValueArguments(List<dynamic> args) {
  Pointer<NativeValue> buffer = malloc.allocate(sizeOf<NativeValue>() * args.length);

  for(int i = 0; i < args.length; i ++) {
    toNativeValue(buffer.elementAt(i), args[i]);
  }

  return buffer.cast<NativeValue>();
}
