/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/dom.dart';
import 'package:webf/widget.dart';
import 'package:webf/bridge.dart';

class WidgetElementShape extends Struct {
  external Pointer<Utf8> name;
  external Pointer<NativeValue> properties;
  external Pointer<NativeValue> methods;
  external Pointer<NativeValue> asyncMethods;
}

Pointer<WidgetElementShape>? _cachedWidgetElementShape;

Pointer<WidgetElementShape> createWidgetElementShape(Map<String, ElementCreator> creators) {
  if (_cachedWidgetElementShape != null) return _cachedWidgetElementShape!;

  Pointer<WidgetElementShape> nativeShapes = malloc.allocate(sizeOf<WidgetElementShape>() * creators.length);
  int shapeIndex = 0;

  creators.forEach((tagName, creator) {
    WidgetElement widgetElement = creator(null) as WidgetElement;

    List<String> properties = [];
    if (!Element.isElementStaticProperties(widgetElement.properties.last)) {
      properties.addAll(widgetElement.properties.last.keys);
    }
    properties.addAll(widgetElement.dynamicProperties.keys.toList(growable: false));

    List<String> syncMethods = [];
    List<String> asyncMethods = [];

    if (!Element.isElementStaticSyncMethods(widgetElement.methods.last)) {
      syncMethods.addAll(widgetElement.methods.last.keys);
    }

    widgetElement.dynamicMethods.forEach((key, method) {
      if (method is BindingObjectMethodSync) {
        syncMethods.add(key);
      } else if (method is AsyncBindingObjectMethod) {
        asyncMethods.add(key);
      }
    });

    Pointer<WidgetElementShape> shape = nativeShapes + shapeIndex;

    shape.ref.name = tagName.toNativeUtf8();
    shape.ref.properties = malloc.allocate(sizeOf<NativeValue>());
    shape.ref.methods = malloc.allocate(sizeOf<NativeValue>());
    shape.ref.asyncMethods = malloc.allocate(sizeOf<NativeValue>());

    toNativeValue(shape.ref.properties, properties);
    toNativeValue(shape.ref.methods, syncMethods);
    toNativeValue(shape.ref.asyncMethods, asyncMethods);

    shapeIndex++;
  });

  _cachedWidgetElementShape = nativeShapes;

  return nativeShapes;
}

void clearCachedWidgetElementShape() {
  if (_cachedWidgetElementShape != null) {
    malloc.free(_cachedWidgetElementShape!);
  }
  _cachedWidgetElementShape = null;
}
