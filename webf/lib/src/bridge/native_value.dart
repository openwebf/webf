/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:webf/css.dart';
import 'package:webf/src/geometry/dom_point.dart';
import 'package:webf/src/html/canvas/canvas_context.dart';
import 'package:webf/src/html/canvas/canvas_text_metrics.dart';
import 'package:webf/webf.dart';

final class NativeValue extends Struct {
  @Int64()
  external int u;

  @Uint32()
  external int uint32;

  @Int32()
  external int tag;
}

enum JSValueType {
  tagString,
  tagInt,
  tagBool,
  tagNull,
  tagFloat64,
  tagJson,
  tagList,
  tagPointer,
  tagFunction,
  tagAsyncFunction,
  tagUint8Bytes,
  tagUndefined
}

enum JSPointerType {
  nativeBindingObject,
  domMatrix,
  boundingClientRect,
  textMetrics,
  screen,
  computedCSSStyleDeclaration,
  domPoint,
  canvasGradient,
  canvasPattern,
  nativeByteData,
  others
}


JSPointerType getPointerTypeOfBindingObject(BindingObject bindingObject) {
  if (bindingObject.pointer?.ref.instance != nullptr) {
    return JSPointerType.nativeBindingObject;
  }

  if (bindingObject is DOMMatrix) {
    return JSPointerType.domMatrix;
  } else if (bindingObject is BoundingClientRect) {
    return JSPointerType.boundingClientRect;
  } else if (bindingObject is TextMetrics) {
    return JSPointerType.textMetrics;
  } else if (bindingObject is Screen) {
    return JSPointerType.screen;
  } else if (bindingObject is ComputedCSSStyleDeclaration) {
    return JSPointerType.computedCSSStyleDeclaration;
  } else if (bindingObject is DOMPoint) {
    return JSPointerType.domPoint;
  } else if (bindingObject is CanvasGradient) {
    return JSPointerType.canvasGradient;
  } else if (bindingObject is CanvasPattern) {
    return JSPointerType.canvasPattern;
  }

  return JSPointerType.others;
}

typedef AnonymousNativeFunction = dynamic Function(List<dynamic> args);
typedef AsyncAnonymousNativeFunction = Future<dynamic> Function(List<dynamic> args);

dynamic fromNativeValue(WebFViewController view, Pointer<NativeValue> nativeValue) {
  if (nativeValue == nullptr) return null;

  JSValueType type = JSValueType.values[nativeValue.ref.tag];
  switch (type) {
    case JSValueType.tagString:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      String result = nativeStringToString(nativeString);
      freeNativeString(nativeString);
      return result;
    case JSValueType.tagInt:
      return nativeValue.ref.u;
    case JSValueType.tagBool:
      return nativeValue.ref.u == 1;
    case JSValueType.tagNull:
      return null;
    case JSValueType.tagUndefined:
      return null; // Dart doesn't have undefined, so we return null but the caller can check the tag
    case JSValueType.tagFloat64:
      return uInt64ToDouble(nativeValue.ref.u);
    case JSValueType.tagPointer:
      JSPointerType pointerType = JSPointerType.values[nativeValue.ref.uint32];

      if (pointerType == JSPointerType.nativeByteData) {
        return NativeByteData(Pointer.fromAddress(nativeValue.ref.u));
      }

      if (pointerType.index < JSPointerType.nativeByteData.index) {
        return view.getBindingObject(Pointer.fromAddress(nativeValue.ref.u));
      }

      return Pointer.fromAddress(nativeValue.ref.u);
    case JSValueType.tagList:
      Pointer<NativeValue> head = Pointer.fromAddress(nativeValue.ref.u).cast<NativeValue>();
      List result = List.generate(nativeValue.ref.uint32, (index) {
        return fromNativeValue(view, head + index);
      });
      malloc.free(head);
      return result;
    case JSValueType.tagFunction:
    case JSValueType.tagAsyncFunction:
      break;
    case JSValueType.tagJson:
      Pointer<NativeString> nativeString = Pointer.fromAddress(nativeValue.ref.u);
      dynamic value = jsonDecode(nativeStringToString(nativeString));
      freeNativeString(nativeString);
      return value;
    case JSValueType.tagUint8Bytes:
      Pointer<Uint8> buffer = Pointer.fromAddress(nativeValue.ref.u);
      return buffer.asTypedList(nativeValue.ref.uint32);
  }
}

void toNativeValue(Pointer<NativeValue> target, value, [BindingObject? ownerBindingObject]) {
  if (value == null) {
    target.ref.tag = JSValueType.tagNull.index;
  } else if (value is int) {
    target.ref.tag = JSValueType.tagInt.index;
    target.ref.u = value;
  } else if (value is bool) {
    target.ref.tag = JSValueType.tagBool.index;
    target.ref.u = value ? 1 : 0;
  } else if (value is double) {
    target.ref.tag = JSValueType.tagFloat64.index;
    target.ref.u = doubleToInt64(value);
  } else if (value is String) {
    Pointer<NativeString> nativeString = stringToNativeString(value);
    target.ref.tag = JSValueType.tagString.index;
    target.ref.u = nativeString.address;
  } else if (value is Pointer) {
    target.ref.tag = JSValueType.tagPointer.index;
    target.ref.uint32 = JSPointerType.others.index;
    target.ref.u = value.address;
  } else if (value is Uint8List) {
    Pointer<Uint8> buffer = malloc.allocate(sizeOf<Uint8>() * value.length);
    final bytes = buffer.asTypedList(value.length);
    bytes.setAll(0, value);
    target.ref.tag = JSValueType.tagUint8Bytes.index;
    target.ref.uint32 = value.length;
    target.ref.u = buffer.address;
  } else if (value is BindingObject) {
    assert((value.pointer)!.address != 0);
    target.ref.tag = JSValueType.tagPointer.index;
    target.ref.uint32 = getPointerTypeOfBindingObject(value).index;
    target.ref.u = (value.pointer)!.address;
  } else if (value is List) {
    target.ref.tag = JSValueType.tagList.index;
    target.ref.uint32 = value.length;
    Pointer<NativeValue> lists = malloc.allocate(sizeOf<NativeValue>() * value.length);
    target.ref.u = lists.address;
    for(int i = 0; i < value.length; i ++) {
      toNativeValue(lists + i, value[i], ownerBindingObject);
    }
  } else if (value is Object) {
    String str = jsonEncode(value);
    target.ref.tag = JSValueType.tagJson.index;
    target.ref.u = str.toNativeUtf8().address;
  }
}

Pointer<NativeValue> makeNativeValueArguments(BindingObject ownerBindingObject, List<dynamic> args) {
  Pointer<NativeValue> buffer = malloc.allocate(sizeOf<NativeValue>() * args.length);

  for(int i = 0; i < args.length; i ++) {
    toNativeValue(buffer + i, args[i], ownerBindingObject);
  }

  return buffer.cast<NativeValue>();
}
