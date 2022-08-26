/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';

import 'package:ffi/ffi.dart';
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
      : _pointer = malloc.allocate<NativeBindingObject>(sizeOf<NativeBindingObject>()),
        super();

  final Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  @override
  dynamic getBindingProperty(String key) {
    switch(key) {
      case 'x':
        return x;
      case 'y':
        return y;
      case 'width':
        return width;
      case 'height':
        return height;
      case 'left':
        return left;
      case 'right':
        return right;
      case 'top':
        return top;
      case 'bottom':
        return bottom;
    }
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
