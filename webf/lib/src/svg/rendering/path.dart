/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'shape.dart';

class RenderSVGPath extends RenderSVGShape {
  RenderSVGPath({required super.renderStyle, super.element});

  @override
  Path asPath() {
    final d = renderStyle.d;
    final path = Path();
    d.applyTo(path);
    return path;
  }
}
