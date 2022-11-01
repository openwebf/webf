/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';

import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

class BoundingClientRect extends BindingObject {
  static BoundingClientRect zero = BoundingClientRect(0, 0, 0, 0, 0, 0, 0, 0);

  final double x;
  final double y;
  final double width;
  final double height;
  final double top;
  final double right;
  final double bottom;
  final double left;

  BoundingClientRect(this.x, this.y, this.width, this.height, this.top, this.right, this.bottom, this.left)
      : _pointer = allocateNewBindingObject(),
        super();

  final Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {}

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['x'] = BindingObjectProperty(getter: () => x);
    properties['y'] = BindingObjectProperty(getter: () => y);
    properties['width'] = BindingObjectProperty(getter: () => width);
    properties['height'] = BindingObjectProperty(getter: () => height);
    properties['left'] = BindingObjectProperty(getter: () => left);
    properties['right'] = BindingObjectProperty(getter: () => right);
    properties['top'] = BindingObjectProperty(getter: () => top);
    properties['bottom'] = BindingObjectProperty(getter: () => bottom);
  }

  Map<String, double> toJSON() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom
    };
  }
}
