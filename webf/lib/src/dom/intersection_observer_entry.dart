/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/foundation.dart';
import 'element.dart';

class DartIntersectionObserverEntry {
  //final DOMHighResTimeStamp time;
  //final DOMRectReadOnly? rootBounds;
  //final DOMRectReadOnly boundingClientRect;
  //final DOMRectReadOnly intersectionRect;
  final bool isIntersecting;

  //final bool isVisible;
  //final double intersectionRatio;
  final Element element;

  DartIntersectionObserverEntry(this.isIntersecting, this.element);

  DartIntersectionObserverEntry copy() {
    return DartIntersectionObserverEntry(isIntersecting, element);
  }
}

class NativeIntersectionObserverEntry extends DynamicBindingObject {
  //final DOMHighResTimeStamp time;
  //final DOMRectReadOnly? rootBounds;
  //final DOMRectReadOnly boundingClientRect;
  //final DOMRectReadOnly intersectionRect;
  final bool isIntersecting;

  //final bool isVisible;
  //final double intersectionRatio;
  final Element target;

  NativeIntersectionObserverEntry(BindingContext context, this.isIntersecting, this.target) : super(context);

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    // TODO: implement initializeMethods
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    // TODO: implement initializeProperties
  }
}
