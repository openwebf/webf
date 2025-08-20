/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

enum SVGPreserveAspectRatioAlign {
  unknown,
  none,
  xMinYMin,
  xMidYMin,
  xMaxYMin,
  xMinYMid,
  xMidYMid,
  xMaxYMid,
  xMinYMax,
  xMidYMax,
  xMaxYMax;

  get xRatio {
    switch (this) {
      case SVGPreserveAspectRatioAlign.none:
      case SVGPreserveAspectRatioAlign.xMinYMin:
      case SVGPreserveAspectRatioAlign.xMinYMid:
      case SVGPreserveAspectRatioAlign.xMinYMax:
        return 0;
      case SVGPreserveAspectRatioAlign.unknown:
      case SVGPreserveAspectRatioAlign.xMidYMin:
      case SVGPreserveAspectRatioAlign.xMidYMid:
      case SVGPreserveAspectRatioAlign.xMidYMax:
        return 0.5;
      case SVGPreserveAspectRatioAlign.xMaxYMin:
      case SVGPreserveAspectRatioAlign.xMaxYMid:
      case SVGPreserveAspectRatioAlign.xMaxYMax:
        return 1;
    }
  }

  get yRatio {
    switch (this) {
      case SVGPreserveAspectRatioAlign.none:
      case SVGPreserveAspectRatioAlign.xMinYMin:
      case SVGPreserveAspectRatioAlign.xMidYMin:
      case SVGPreserveAspectRatioAlign.xMaxYMin:
        return 0;
      case SVGPreserveAspectRatioAlign.unknown:
      case SVGPreserveAspectRatioAlign.xMinYMid:
      case SVGPreserveAspectRatioAlign.xMidYMid:
      case SVGPreserveAspectRatioAlign.xMaxYMid:
        return 0.5;
      case SVGPreserveAspectRatioAlign.xMinYMax:
      case SVGPreserveAspectRatioAlign.xMidYMax:
      case SVGPreserveAspectRatioAlign.xMaxYMax:
        return 1;
    }
  }
}

enum SVGPreserveAspectRatioMeetOrSlice { unknown, meet, slice }

final _SVGPreserveAspectRatioAlignMap =
    SVGPreserveAspectRatioAlign.values.asNameMap();

final _SVGPreserveAspectRatioMeetOrSlice =
    SVGPreserveAspectRatioMeetOrSlice.values.asNameMap();

// spec: https://svgwg.org/svg2-draft/coords.html#PreserveAspectRatioAttribute
class SVGPreserveAspectRatio {
  static SVGPreserveAspectRatio? parse(String ratio) {
    final splitted = ratio.trim().split(RegExp(r'\s+'));
    final alignToken = splitted[0];
    final align = _SVGPreserveAspectRatioAlignMap[alignToken];
    if (align == null || align == SVGPreserveAspectRatioAlign.unknown) {
      return null;
    }

    if (splitted.length > 1) {
      final meetOrSliceToken = splitted[1];
      final meetOrSlice = _SVGPreserveAspectRatioMeetOrSlice[meetOrSliceToken];
      if (meetOrSlice == null ||
          meetOrSlice == SVGPreserveAspectRatioMeetOrSlice.unknown) {
        return null;
      }
      return SVGPreserveAspectRatio(align, meetOrSlice);
    }

    return SVGPreserveAspectRatio(align);
  }

  final SVGPreserveAspectRatioAlign align;
  final SVGPreserveAspectRatioMeetOrSlice meetOrSlice;

  const SVGPreserveAspectRatio(
      [this.align = SVGPreserveAspectRatioAlign.xMidYMid,
      this.meetOrSlice = SVGPreserveAspectRatioMeetOrSlice.meet]);

  getMatrix(Rect viewBox, Size size) {
    final matrix = Matrix4.identity();

    final xRatio = align.xRatio;
    final yRatio = align.yRatio;
    final scaleX = size.width / viewBox.width;
    final scaleY = size.height / viewBox.height;
    // move to center
    matrix.translate(size.width * xRatio, size.height * yRatio);

    // scale
    if (align == SVGPreserveAspectRatioAlign.none) {
      matrix.scale(scaleX, scaleY);
    } else {
      matrix.scale(meetOrSlice == SVGPreserveAspectRatioMeetOrSlice.slice
          ? max(scaleX, scaleY)
          : min(scaleX, scaleY));
    }

    // move back
    matrix.translate(-viewBox.width * xRatio, -viewBox.height * yRatio);

    return matrix;
  }
}
