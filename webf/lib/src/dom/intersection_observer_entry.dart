/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'dart:ui';
import 'package:webf/bridge.dart';
import 'element.dart';

class DartIntersectionObserverEntry {
  //final DOMHighResTimeStamp time;
  //final DOMRectReadOnly? rootBounds;
  //final DOMRectReadOnly boundingClientRect;
  //final DOMRectReadOnly intersectionRect;
  final bool isIntersecting;

  //final bool isVisible;
  final double intersectionRatio;
  final Element element;
  final Rect boundingClientRect;
  final Rect rootBounds;
  final Rect intersectionRect;

  DartIntersectionObserverEntry(
    this.isIntersecting,
    this.intersectionRatio,
    this.element,
    this.boundingClientRect,
    this.rootBounds,
    this.intersectionRect,
  );

  DartIntersectionObserverEntry copy() {
    return DartIntersectionObserverEntry(
      isIntersecting,
      intersectionRatio,
      element,
      boundingClientRect,
      rootBounds,
      intersectionRect,
    );
  }
}

base class NativeIntersectionObserverEntry extends Struct {
  @Int8()
  external int isIntersecting;

  @Double()
  external double intersectionRatio;

  external Pointer<NativeBindingObject> element;

  external Pointer<NativeBindingObject> boundingClientRect;

  external Pointer<NativeBindingObject> rootBounds;

  external Pointer<NativeBindingObject> intersectionRect;
}

base class NativeIntersectionObserverEntryList extends Struct {
  external Pointer<NativeIntersectionObserverEntry> entries;

  @Int32()
  external int length;
}
