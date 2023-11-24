/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

class BindingClientRectData extends Struct {
  @Double()
  external double y;

  @Double()
  external double x;

  @Double()
  external double width;

  @Double()
  external double height;

  @Double()
  external double top;

  @Double()
  external double right;

  @Double()
  external double bottom;

  @Double()
  external double left;
}

class BoundingClientRect extends StaticBindingObject {
  static BoundingClientRect zero(BindingContext context) => BoundingClientRect(context: context, x: 0, y: 0, width: 0, height: 0, top: 0, right: 0, bottom: 0, left: 0);

  final double x;
  final double y;
  final double width;
  final double height;
  final double top;
  final double right;
  final double bottom;
  final double left;

  BoundingClientRect({
    required BindingContext context,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left
  })
      : _pointer = context.pointer,
        super(context);

  @override
  Pointer<Void> buildExtraNativeData() {
    Pointer<BindingClientRectData> extraData = malloc.allocate(sizeOf<BindingClientRectData>());
    extraData.ref.width = width;
    extraData.ref.height = height;
    extraData.ref.x = x;
    extraData.ref.y = y;
    extraData.ref.left = left;
    extraData.ref.top = top;
    extraData.ref.right = right;
    extraData.ref.bottom = bottom;
    return extraData.cast<Void>();
  }

  final Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

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
