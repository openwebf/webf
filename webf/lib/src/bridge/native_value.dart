/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:convert';
import 'dart:ffi';
import 'dart:collection';

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

enum JSPointerType { AsyncFunctionContext, NativeFunctionContext, Others }

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

typedef ToNativeValueCallback = void Function(Pointer<NativeValue> target,
    // ignore: avoid_annotating_with_dynamic
    {dynamic value, BindingObject? ownerBindingObject});

final HashMap<Type, ToNativeValueCallback> _nativeToValueMap = HashMap();
bool _nativeToNativeValueMapInit = false;

void _initNativeToValueMap() {
  _nativeToValueMap[null.runtimeType] = (target, {value, ownerBindingObject}) {
    target.ref.tag = JSValueType.TAG_NULL.index;
  };
  _nativeToValueMap[int] = (target, {ownerBindingObject, value}) {
    target.ref.tag = JSValueType.TAG_INT.index;
    target.ref.u = value;
  };
  _nativeToValueMap[bool] = (target, {ownerBindingObject, value}) {
    target.ref.tag = JSValueType.TAG_BOOL.index;
    target.ref.u = value ? 1 : 0;
  };
  _nativeToValueMap[double] = (target, {ownerBindingObject, value}) {
    target.ref.tag = JSValueType.TAG_FLOAT64.index;
    target.ref.u = doubleToInt64(value);
  };
  _nativeToValueMap[String] = (target, {ownerBindingObject, value}) {
    target.ref.tag = JSValueType.TAG_STRING.index;
    target.ref.u = stringToNativeString(value).address;
  };
}

void toNativeValue(Pointer<NativeValue> target, value, [BindingObject? ownerBindingObject]) {
  if (!_nativeToNativeValueMapInit) {
    _initNativeToValueMap();
    _nativeToNativeValueMapInit = true;
  }

  ToNativeValueCallback? fn = _nativeToValueMap[value.runtimeType];
  bool isComplexTypes = fn == null;
  if (isComplexTypes) {
    if (value is Pointer) {
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
        toNativeValue(lists.elementAt(i), value[i], ownerBindingObject);
      }
    } else if (value is Object) {
      String str = jsonEncode(value);
      target.ref.tag = JSValueType.TAG_JSON.index;
      target.ref.u = str.toNativeUtf8().address;
    }
  } else {
    fn(target, value: value, ownerBindingObject: ownerBindingObject);
  }
}

Pointer<NativeValue> makeNativeValueArguments(BindingObject ownerBindingObject, List<dynamic> args) {
  Pointer<NativeValue> buffer = malloc.allocate(sizeOf<NativeValue>() * args.length);

  for(int i = 0; i < args.length; i ++) {
    toNativeValue(buffer.elementAt(i), args[i], ownerBindingObject);
  }

  return buffer.cast<NativeValue>();
}
