/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui' as ui show Image, PathMetrics;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
// logger import removed (no direct logging in this file)

// A circular list implementation that allows access in a circular fashion.
class CircularIntervalList<T> {
  CircularIntervalList(this._values);

  final List<T> _values;
  int _index = 0;

  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}

enum _BorderDirection { top, bottom, left, right }

// Dashed border sizing constraints.
// Nominal dash unit relative to border width.
// Increase to make each dashed segment longer on average.
// Example: 1.8 means nominal unit ≈ 1.8 × border width.
const double _kDashedBorderAvgUnitRatio = 1.8;
// Minimum gap length as a ratio of border width to avoid micro-gaps.
const double _kDashedBorderMinGapWidthRatio = 0.5;

/// An object that paints a [BoxDecoration] into a canvas.
class BoxDecorationPainter extends BoxPainter {
  BoxDecorationPainter(this.padding, this.renderStyle, VoidCallback onChanged) : super(onChanged);

  EdgeInsets? padding;
  CSSRenderStyle renderStyle;
  CSSBoxDecoration get _decoration => renderStyle.decoration!;
  // Override destination size for the current layer when resolving
  // percentages in background-position calc(). Layered backgrounds can
  // have different destination sizes per layer.
  Size? _currentLayerDestSizeForPercent;

  // Whether background-image contains any gradient layers.
  bool _hasGradientLayers() {
    final img = renderStyle.backgroundImage;
    if (img == null) return false;
    return img.functions.any((f) => f.name.contains('gradient'));
  }

  // Returns true when the element should propagate fixed backgrounds to the
  // viewport clip (root/background propagation behavior). We treat <html> and
  // <body> as root targets.
  bool _isRootBackgroundTarget(dynamic element) {
    try {
      final String tag = element.tagName;
      return tag == 'HTML' || tag == 'BODY' || element is RouterLinkElement;
    } catch (_) {
      return false;
    }
  }

  bool _hasImageLayers() {
    final img = renderStyle.backgroundImage;
    if (img == null) return false;
    return img.functions.any((f) => f.name == 'url') && _decoration.image != null;
  }

  // Report the destination background-image size after applying background-size.
  // This is used by percentage resolution of background-position to compute the
  // remaining space (container - destination). If the background-size is keyword
  // based (auto/contain/cover) and the container size is needed, we fall back to
  // the intrinsic image size since the final destination will be resolved during
  // paint with the actual rect.
  Size? get backgroundImageSize {
    // Prefer the per-layer destination size when provided by the painter.
    if (_currentLayerDestSizeForPercent != null) {
      return _currentLayerDestSizeForPercent;
    }
    final ui.Image? image = _imagePainter?._image?.image;
    if (image == null) return null;

    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();
    final double aspectRatio = imageWidth / imageHeight;

    final CSSBackgroundSize bs = renderStyle.backgroundSize;
    final CSSLengthValue? backgroundWidth = bs.width;
    final CSSLengthValue? backgroundHeight = bs.height;

    // Only width is set (e.g., `100px` or `100px auto`).
    if (backgroundWidth != null &&
        !backgroundWidth.isAuto &&
        backgroundWidth.computedValue > 0 &&
        (backgroundHeight == null || backgroundHeight.isAuto)) {
      final double w = backgroundWidth.computedValue;
      final double h = w / aspectRatio;
      return Size(w, h);
    }

    // Only height is set (e.g., `auto 100px`).
    if (backgroundHeight != null &&
        !backgroundHeight.isAuto &&
        backgroundHeight.computedValue > 0 &&
        (backgroundWidth == null || backgroundWidth.isAuto)) {
      final double h = backgroundHeight.computedValue;
      final double w = h * aspectRatio;
      return Size(w, h);
    }

    // Both width and height are set (e.g., `100px 100px`).
    if (backgroundWidth != null &&
        !backgroundWidth.isAuto &&
        backgroundWidth.computedValue > 0 &&
        backgroundHeight != null &&
        !backgroundHeight.isAuto &&
        backgroundHeight.computedValue > 0) {
      return Size(backgroundWidth.computedValue, backgroundHeight.computedValue);
    }

    // For keyword values (auto/contain/cover) we cannot compute without the
    // painting rect; return intrinsic size as a fallback.
    return Size(imageWidth, imageHeight);
  }

  Paint? _cachedBackgroundPaint;
  Rect? _rectForCachedBackgroundPaint;
  Gradient? _cachedGradient;

  Paint? _getBackgroundPaint(Rect rect, TextDirection? textDirection) {
    assert(_decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
        _decoration.color != null ||
        (_decoration.gradient != null &&
            (_rectForCachedBackgroundPaint != rect || _cachedGradient != _decoration.gradient))) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null) paint.blendMode = _decoration.backgroundBlendMode!;
      if (_decoration.color != null) paint.color = _decoration.color!;
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient!.createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
        _cachedGradient = _decoration.gradient;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint;
  }

  void _paintBox(Canvas canvas, Rect rect, Paint? paint, TextDirection? textDirection) {
    switch (_decoration.shape) {
      case BoxShape.circle:
        assert(!_decoration.hasBorderRadius);
        final Offset center = rect.center;
        final double radius = rect.shortestSide / 2.0;
        canvas.drawCircle(center, radius, paint!);
        break;
      case BoxShape.rectangle:
        if (!_decoration.hasBorderRadius) {
          canvas.drawRect(rect, paint!);
        } else {
          canvas.drawRRect(_decoration.borderRadius!.toRRect(rect), paint!);
        }
        break;
    }
  }

  void _paintShadows(Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.boxShadow == null) return;
    bool hasShadow = false;
    for (final WebFBoxShadow boxShadow in _decoration.boxShadow!) {
      if (boxShadow.inset) {
        _paintInsetBoxShadow(canvas, rect, textDirection, boxShadow);
        hasShadow = true;
      } else {
        _paintBoxShadow(canvas, rect, textDirection, boxShadow);
        hasShadow = true;
      }
    }
    // Report FP when box shadows are painted
    if (hasShadow) {
      renderStyle.target.ownerDocument.controller.reportFP();
    }
  }

  void _paintDashedBorder(Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.border == null) return;

    // Get the border instance
    Border border = _decoration.border as Border;

    // Check if borders are uniform (same style, width, and color for all sides)
    bool isUniform = _isUniformDashedBorder(border);

    if (isUniform) {
      // Uniform borders: if rounded corners are present, paint as a single
      // continuous dashed path around the rounded rectangle to match browsers
      // (natural ~45° appearance at extreme points). Otherwise, paint per side
      // to preserve crisp "L" corners on rectangular borders.
      final ExtendedBorderSide side = border.top as ExtendedBorderSide;
      if (side.extendBorderStyle != CSSBorderStyleType.dashed || side.width == 0.0) return;

      if (_decoration.hasBorderRadius && _decoration.borderRadius != null) {
        final Paint paint = Paint()
          ..color = side.color
          ..strokeWidth = side.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter;

        final double inset = side.width / 2.0;
        final RRect rr = _decoration.borderRadius!.toRRect(rect).deflate(inset);

        final Path borderPath = Path()..addRRect(rr);
        final double baseDash = (side.width * _kDashedBorderAvgUnitRatio).clamp(side.width, double.infinity);
        final dashArray = CircularIntervalList<double>([baseDash, baseDash]);

        canvas.drawPath(
          dashPath(borderPath, dashArray: dashArray),
          paint,
        );
      } else {
        // No border radius: per-side painting for sharp corners.
        _paintDashedBorderSide(canvas, rect, null, border.top as ExtendedBorderSide, _BorderDirection.top);
        _paintDashedBorderSide(canvas, rect, null, border.right as ExtendedBorderSide, _BorderDirection.right);
        _paintDashedBorderSide(canvas, rect, null, border.bottom as ExtendedBorderSide, _BorderDirection.bottom);
        _paintDashedBorderSide(canvas, rect, null, border.left as ExtendedBorderSide, _BorderDirection.left);
      }
    } else {
      // Handle non-uniform borders - draw each side individually if it's dashed
      // Check which sides have dashed borders
      bool hasTopDashedBorder = border.top is ExtendedBorderSide &&
          (border.top as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed &&
          border.top.width > 0;

      bool hasRightDashedBorder = border.right is ExtendedBorderSide &&
          (border.right as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed &&
          border.right.width > 0;

      bool hasBottomDashedBorder = border.bottom is ExtendedBorderSide &&
          (border.bottom as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed &&
          border.bottom.width > 0;

      bool hasLeftDashedBorder = border.left is ExtendedBorderSide &&
          (border.left as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed &&
          border.left.width > 0;

      // Return early if no dashed borders
      if (!hasTopDashedBorder && !hasRightDashedBorder && !hasBottomDashedBorder && !hasLeftDashedBorder) return;

      // Handle border radius
      RRect? rrect;
      if (_decoration.hasBorderRadius && _decoration.borderRadius != null) {
        rrect = _decoration.borderRadius!.toRRect(rect);
      }

      // Draw each dashed border side individually
      if (hasTopDashedBorder) {
        _paintDashedBorderSide(canvas, rect, rrect, border.top as ExtendedBorderSide, _BorderDirection.top);
      }

      if (hasRightDashedBorder) {
        _paintDashedBorderSide(canvas, rect, rrect, border.right as ExtendedBorderSide, _BorderDirection.right);
      }

      if (hasBottomDashedBorder) {
        _paintDashedBorderSide(canvas, rect, rrect, border.bottom as ExtendedBorderSide, _BorderDirection.bottom);
      }

      if (hasLeftDashedBorder) {
        _paintDashedBorderSide(canvas, rect, rrect, border.left as ExtendedBorderSide, _BorderDirection.left);
      }
    }
  }

  // Check if all four borders have the same style, width, and color
  bool _isUniformDashedBorder(Border border) {
    // Check if all sides are ExtendedBorderSide
    if (border.top is! ExtendedBorderSide ||
        border.right is! ExtendedBorderSide ||
        border.bottom is! ExtendedBorderSide ||
        border.left is! ExtendedBorderSide) {
      return false;
    }

    ExtendedBorderSide topSide = border.top as ExtendedBorderSide;
    ExtendedBorderSide rightSide = border.right as ExtendedBorderSide;
    ExtendedBorderSide bottomSide = border.bottom as ExtendedBorderSide;
    ExtendedBorderSide leftSide = border.left as ExtendedBorderSide;

    // Check if all sides have the same style
    if (topSide.extendBorderStyle != rightSide.extendBorderStyle ||
        topSide.extendBorderStyle != bottomSide.extendBorderStyle ||
        topSide.extendBorderStyle != leftSide.extendBorderStyle) {
      return false;
    }

    // Check if all sides have the same width
    if (topSide.width != rightSide.width || topSide.width != bottomSide.width || topSide.width != leftSide.width) {
      return false;
    }

    // Check if all sides have the same color
    if (topSide.color != rightSide.color || topSide.color != bottomSide.color || topSide.color != leftSide.color) {
      return false;
    }

    return true;
  }

  // Helper method to paint a dashed border on a specific side
  void _paintDashedBorderSide(
      Canvas canvas, Rect rect, RRect? rrect, ExtendedBorderSide side, _BorderDirection direction) {
    // Create a paint object for the border
    final Paint paint = Paint()
      ..color = side.color
      ..strokeWidth = side.width
      ..style = PaintingStyle.stroke
      // Square caps create proper right-angle corner dashes ("L" shape)
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    // Fallback when the stroke is thicker than the side length. In this case,
    // producing a dashed stroked path is numerically unstable (negative/zero
    // path length). Browsers effectively fill the side area with the border
    // color. Emulate that by drawing a filled rectangle for the side.
    final double sideExtent = (direction == _BorderDirection.top || direction == _BorderDirection.bottom)
        ? rect.width
        : rect.height;
    if (side.width >= sideExtent) {
      final Paint fill = Paint()
        ..color = side.color
        ..style = PaintingStyle.fill;
      switch (direction) {
        case _BorderDirection.top:
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, side.width), fill);
          break;
        case _BorderDirection.bottom:
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - side.width, rect.width, side.width), fill);
          break;
        case _BorderDirection.left:
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, side.width, rect.height), fill);
          break;
        case _BorderDirection.right:
          canvas.drawRect(Rect.fromLTWH(rect.right - side.width, rect.top, side.width, rect.height), fill);
          break;
      }
      return;
    }

    // Define dash pattern (dash length, gap length)
    // Prefer to start and end sides with a dash to form a right angle at corners.
    late final CircularIntervalList<double> dashArray;

    if (rrect == null) {
      // Non-rounded corners: compute dash/gap to start and end with a dash.
      final double sideLength;
      if (direction == _BorderDirection.top || direction == _BorderDirection.bottom) {
        // Path goes from left+sw/2 to right-sw/2
        sideLength = rect.width - side.width;
      } else {
        // Left/Right: from top+sw/2 to bottom-sw/2
        sideLength = rect.height - side.width;
      }

      final List<double> pattern = _computeDashPattern(sideLength, side.width);
      dashArray = CircularIntervalList<double>([pattern[0], pattern[1]]);
    } else {
      // Rounded corners: use constrained ratio for both dash and gap.
      final double dashLength = side.width * _kDashedBorderAvgUnitRatio;
      final double dashGap = side.width * _kDashedBorderAvgUnitRatio;
      dashArray = CircularIntervalList<double>([dashLength, dashGap]);
    }

    // Create the path for just this side
    Path borderPath = Path();

    if (rrect != null) {
      // Align stroke inside by deflating half the stroke width
      final double inset = side.width / 2.0;
      final RRect rr = rrect.deflate(inset);
      // Handle rounded corners. Assign corner arcs only to horizontal sides
      // (top and bottom) to avoid duplication and direction reversals.
      switch (direction) {
        case _BorderDirection.top:
          // Include both top-left and top-right arcs on the top side.
          borderPath.moveTo(rr.left, rr.top + rr.tlRadiusY);
          borderPath.arcToPoint(
            Offset(rr.left + rr.tlRadiusX, rr.top),
            radius: Radius.elliptical(rr.tlRadiusX, rr.tlRadiusY),
            clockwise: false,
          );
          borderPath.lineTo(rr.right - rr.trRadiusX, rr.top);
          borderPath.arcToPoint(
            Offset(rr.right, rr.top + rr.trRadiusY),
            radius: Radius.elliptical(rr.trRadiusX, rr.trRadiusY),
            clockwise: true,
          );
          break;
        case _BorderDirection.right:
          // Vertical segment only; corner arcs handled by top/bottom.
          borderPath.moveTo(rr.right, rr.top + rr.trRadiusY);
          borderPath.lineTo(rr.right, rr.bottom - rr.brRadiusY);
          break;
        case _BorderDirection.bottom:
          // Include both bottom-right and bottom-left arcs on the bottom side.
          borderPath.moveTo(rr.right, rr.bottom - rr.brRadiusY);
          borderPath.arcToPoint(
            Offset(rr.right - rr.brRadiusX, rr.bottom),
            radius: Radius.elliptical(rr.brRadiusX, rr.brRadiusY),
            clockwise: true,
          );
          borderPath.lineTo(rr.left + rr.blRadiusX, rr.bottom);
          borderPath.arcToPoint(
            Offset(rr.left, rr.bottom - rr.blRadiusY),
            radius: Radius.elliptical(rr.blRadiusX, rr.blRadiusY),
            clockwise: true,
          );
          break;
        case _BorderDirection.left:
          // Vertical segment only; corner arcs handled by top/bottom.
          borderPath.moveTo(rr.left, rr.bottom - rr.blRadiusY);
          borderPath.lineTo(rr.left, rr.top + rr.tlRadiusY);
          break;
      }
    } else {
      // Handle non-rounded corners
      switch (direction) {
        case _BorderDirection.top:
          borderPath.moveTo(rect.left + side.width / 2.0, rect.top + side.width / 2.0);
          borderPath.lineTo(rect.right - side.width / 2.0, rect.top + side.width / 2.0);
          break;
        case _BorderDirection.right:
          borderPath.moveTo(rect.right - side.width / 2.0, rect.top + side.width / 2.0);
          borderPath.lineTo(rect.right - side.width / 2.0, rect.bottom - side.width / 2.0);
          break;
        case _BorderDirection.bottom:
          borderPath.moveTo(rect.right - side.width / 2.0, rect.bottom - side.width / 2.0);
          borderPath.lineTo(rect.left + side.width / 2.0, rect.bottom - side.width / 2.0);
          break;
        case _BorderDirection.left:
          borderPath.moveTo(rect.left + side.width / 2.0, rect.bottom - side.width / 2.0);
          borderPath.lineTo(rect.left + side.width / 2.0, rect.top + side.width / 2.0);
          break;
      }
    }

    // Draw the dashed border for this side
    canvas.drawPath(
      dashPath(
        borderPath,
        dashArray: dashArray,
      ),
      paint,
    );
  }

  // Compute dash/gap so a side starts and ends with a dash.
  // Keep dash length ≈ border-width × _kDashedBorderAvgUnitRatio and adjust gap to fit.
  List<double> _computeDashPattern(double length, double strokeWidth) {
    // Base dash length target with constraint.
    final double baseDash = (strokeWidth * _kDashedBorderAvgUnitRatio)
        .clamp(strokeWidth, double.infinity)
        .toDouble();

    // If the side is very short, draw a single dash covering the length.
    if (length <= baseDash) {
      final double dash = length.clamp(0.0, double.infinity);
      final double gap = baseDash; // gap value unused for a single dash
      return <double>[dash, gap];
    }

    // We want: length = n * dash + (n - 1) * gap, starting and ending with dash.
    // Fix dash = baseDash and solve for n (integer) and gap >= 0.
    // For feasibility: n <= (length + dash) / (2 * dash).
    int n = ((length + baseDash) / (2 * baseDash)).floor();
    if (n < 1) n = 1;

    // If n==1, just one dash across the side.
    if (n == 1) {
      return <double>[length, baseDash];
    }

    double gap = (length - n * baseDash) / (n - 1);
    // Ensure non-negative gap; if negative, reduce n until it fits.
    while (gap < 0 && n > 1) {
      n -= 1;
      if (n == 1) break;
      gap = (length - n * baseDash) / (n - 1);
    }

    if (n == 1) {
      return <double>[length, baseDash];
    }

    // Optional: Avoid excessively tiny gaps by reducing n.
    final double minGap = strokeWidth * _kDashedBorderMinGapWidthRatio;
    while (gap < minGap && n > 1) {
      n -= 1;
      if (n == 1) {
        return <double>[length, baseDash];
      }
      gap = (length - n * baseDash) / (n - 1);
    }

    return <double>[baseDash, gap];
  }

  // Helper function to create a dashed path
  Path dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    final ui.PathMetrics metrics = source.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final double length = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    return dest;
  }

  /// An outer box-shadow casts a shadow as if the border-box of the element were opaque.
  /// It is clipped inside the border-box of the element.
  void _paintBoxShadow(Canvas canvas, Rect rect, TextDirection? textDirection, BoxShadow boxShadow) {
    final Paint paint = Paint()
      ..color = boxShadow.color
      // Following W3C spec, blur sigma is exactly half the blur radius
      // which is different from the value of Flutter:
      // https://www.w3.org/TR/css-backgrounds-3/#shadow-blur
      // https://html.spec.whatwg.org/C/#when-shadows-are-drawn
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, boxShadow.blurRadius / 2);

    // Rect of box shadow not including blur radius
    final Rect shadowRect = rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
    // Rect of box shadow including blur radius, add 1 pixel to avoid the fill bleed in (due to antialiasing)
    final Rect shadowBlurRect = rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius + boxShadow.blurRadius + 1);
    // Path of border rect
    Path borderPath;
    // Path of box shadow rect
    Path shadowPath;
    // Path of box shadow including blur rect
    Path shadowBlurPath;

    if (!_decoration.hasBorderRadius) {
      borderPath = Path()..addRect(rect);
      shadowPath = Path()..addRect(shadowRect);
      shadowBlurPath = Path()..addRect(shadowBlurRect);
    } else {
      borderPath = Path()..addRRect(_decoration.borderRadius!.toRRect(rect));
      shadowPath = Path()..addRRect(_decoration.borderRadius!.resolve(textDirection).toRRect(shadowRect));
      shadowBlurPath = Path()..addRRect(_decoration.borderRadius!.resolve(textDirection).toRRect(shadowBlurRect));
    }

    // Path of shadow blur rect subtract border rect of which the box shadow should paint
    final Path clippedPath = Path.combine(PathOperation.difference, shadowBlurPath, borderPath);
    canvas.save();
    canvas.clipPath(clippedPath);
    canvas.drawPath(shadowPath, paint);
    canvas.restore();
  }

  /// An inner box-shadow casts a shadow as if everything outside the padding edge were opaque.
  /// It is clipped outside the padding box of the element.
  void _paintInsetBoxShadow(Canvas canvas, Rect rect, TextDirection? textDirection, BoxShadow boxShadow) {
    final Paint paint = Paint()
      ..color = boxShadow.color
      // Following W3C spec, blur sigma is exactly half the blur radius
      // which is different from the value of Flutter:
      // https://www.w3.org/TR/css-backgrounds-3/#shadow-blur
      // https://html.spec.whatwg.org/C/#when-shadows-are-drawn
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, boxShadow.blurRadius / 2);

    // The normal box-shadow is drawn outside the border box edge while
    // the inset box-shadow is drawn inside the padding box edge.
    // https://drafts.csswg.org/css-backgrounds-3/#shadow-shape
    Rect paddingBoxRect = Rect.fromLTRB(
        rect.left + renderStyle.effectiveBorderLeftWidth.computedValue,
        rect.top + renderStyle.effectiveBorderTopWidth.computedValue,
        rect.right - renderStyle.effectiveBorderRightWidth.computedValue,
        rect.bottom - renderStyle.effectiveBorderBottomWidth.computedValue);

    Path paddingBoxPath;
    if (!_decoration.hasBorderRadius) {
      paddingBoxPath = Path()..addRect(paddingBoxRect);
    } else {
      RRect borderBoxRRect = _decoration.borderRadius!.toRRect(rect);
      // A borderRadius can only be given for a uniform Border in Flutter.
      // https://github.com/flutter/flutter/issues/12583
      double uniformBorderWidth = renderStyle.effectiveBorderTopWidth.computedValue;
      RRect paddingBoxRRect = borderBoxRRect.deflate(uniformBorderWidth);
      paddingBoxPath = Path()..addRRect(paddingBoxRRect);
    }

    // 1. Create a shadow rect shifted by boxShadow and spread radius and get the
    // difference path subtracted from the padding box path.
    Rect shadowOffsetRect =
        paddingBoxRect.shift(Offset(boxShadow.offset.dx, boxShadow.offset.dy)).deflate(boxShadow.spreadRadius);
    Path shadowOffsetPath = _decoration.hasBorderRadius
        ? (Path()..addRRect(_decoration.borderRadius!.toRRect(shadowOffsetRect)))
        : (Path()..addRect(shadowOffsetRect));

    Path innerShadowPath = Path.combine(PathOperation.difference, paddingBoxPath, shadowOffsetPath);

    // 2. Create shadow rect in four directions and get the difference path
    // subtracted from the padding box path.
    Path topRectPath = _getOuterPaddingBoxPathByDirection(
        paddingBoxPath, paddingBoxRect, textDirection, boxShadow, _BorderDirection.top);
    Path bottomRectPath = _getOuterPaddingBoxPathByDirection(
        paddingBoxPath, paddingBoxRect, textDirection, boxShadow, _BorderDirection.bottom);
    Path leftRectPath = _getOuterPaddingBoxPathByDirection(
        paddingBoxPath, paddingBoxRect, textDirection, boxShadow, _BorderDirection.left);
    Path rightRectPath = _getOuterPaddingBoxPathByDirection(
        paddingBoxPath, paddingBoxRect, textDirection, boxShadow, _BorderDirection.right);

    // 3. Combine all the paths in step 1 and step 2 as the final shadow path.
    List<Path> paintPaths = [
      innerShadowPath,
      topRectPath,
      bottomRectPath,
      leftRectPath,
      rightRectPath,
    ];
    Path? shadowPath = _combinePaths(paintPaths);

    // 4. Restrict the shadow painted in padding box and paint the shadow path with blur radius.
    canvas.save();
    canvas.clipPath(paddingBoxPath);
    canvas.drawPath(shadowPath!, paint);
    canvas.restore();
  }

  /// Get the shadow path outside padding box in each direction.
  Path _getOuterPaddingBoxPathByDirection(
    Path paddingBoxPath,
    Rect paddingBoxRect,
    TextDirection? textDirection,
    BoxShadow boxShadow,
    _BorderDirection direction,
  ) {
    Rect offsetRect;
    Size paddingBoxSize = paddingBoxRect.size;

    if (direction == _BorderDirection.left) {
      offsetRect = paddingBoxRect
          .shift(Offset(-paddingBoxSize.width + boxShadow.offset.dx + boxShadow.spreadRadius, boxShadow.offset.dy));
    } else if (direction == _BorderDirection.right) {
      offsetRect = paddingBoxRect
          .shift(Offset(paddingBoxSize.width + boxShadow.offset.dx - boxShadow.spreadRadius, boxShadow.offset.dy));
    } else if (direction == _BorderDirection.top) {
      offsetRect = paddingBoxRect
          .shift(Offset(boxShadow.offset.dx, -paddingBoxSize.height + boxShadow.offset.dy + boxShadow.spreadRadius));
    } else {
      offsetRect = paddingBoxRect
          .shift(Offset(boxShadow.offset.dx, paddingBoxSize.height + boxShadow.offset.dy - boxShadow.spreadRadius));
    }
    Path offsetRectPath = _decoration.hasBorderRadius
        ? (Path()..addRRect(_decoration.borderRadius!.toRRect(offsetRect)))
        : (Path()..addRect(offsetRect));

    Path outerBorderPath = Path.combine(PathOperation.difference, offsetRectPath, paddingBoxPath);
    return outerBorderPath;
  }

  /// Combine multiple non overlapped path into one path.
  Path? _combinePaths(List<Path> paths) {
    Path? finalPath;
    for (Path path in paths) {
      if (finalPath != null) {
        finalPath = Path.combine(PathOperation.xor, finalPath, path);
      } else {
        finalPath = path;
      }
    }
    return finalPath;
  }

  void _paintBackgroundColor(Canvas canvas, Rect rect, TextDirection? textDirection) {
    // Special handling: CSS gradients respect background-size/position/repeat per layer.
    // When background-image uses gradient functions, Flutter's BoxDecoration.gradient
    // paints full-rect and ignores background-size/position. To emulate CSS,
    // detect gradient usage and paint per-layer with clipping based on
    // background-size and background-position values.
    final hasGradientBgImage = _hasGradientLayers();

    if (hasGradientBgImage) {
      if (DebugFlags.enableBackgroundLogs) {
        try {
          final el = renderStyle.target;
          final id = (el.id != null && el.id!.isNotEmpty) ? '#${el.id}' : '';
          final cls = (el.className != null && el.className!.isNotEmpty) ? '.${el.className}' : '';
          final rawAttach = el.style.getPropertyValue(BACKGROUND_ATTACHMENT);
          renderingLogger.finer('[Background] gradient-only path for <${el.tagName.toLowerCase()}$id$cls> rect=$rect raw-attachment="$rawAttach"');
        } catch (_) {}
      }
      _paintLayeredGradients(canvas, rect, textDirection);
      // Report FP for non-default backgrounds
      renderStyle.target.ownerDocument.controller.reportFP();
      return;
    }

    if (_decoration.color != null || _decoration.gradient != null) {
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection), textDirection);

      // Report FP when non-default background color is painted
      // Check if this is a non-default background (not transparent or white)
      if (_decoration.color != null && _decoration.color!.alpha > 0) {
        renderStyle.target.ownerDocument.controller.reportFP();
      } else if (_decoration.gradient != null) {
        // Gradients always count as non-default backgrounds
        renderStyle.target.ownerDocument.controller.reportFP();
      }
    }
  }

  // Split a CSS list by top-level commas, ignoring nested function commas.
  List<String> _splitByTopLevelCommas(String input) {
    final List<String> out = [];
    int depth = 0;
    int start = 0;
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '(') depth++;
      if (ch == ')') depth = depth > 0 ? depth - 1 : 0;
      if (ch == ',' && depth == 0) {
        out.add(input.substring(start, i).trim());
        start = i + 1;
      }
    }
    if (start < input.length) {
      out.add(input.substring(start).trim());
    }
    return out.where((s) => s.isNotEmpty).toList();
  }

  // Parse background-position for the full layer list and map to gradient layers by index.
  List<(CSSBackgroundPosition, CSSBackgroundPosition)> _parsePositionsMapped(
    List<int> gradientIndices,
    int fullCount,
  ) {
    final String raw = renderStyle.target.style.getPropertyValue(BACKGROUND_POSITION);
    final List<String> tokens = raw.isNotEmpty ? _splitByTopLevelCommas(raw) : <String>[];
    if (DebugFlags.enableBackgroundLogs) {
      renderingLogger.finer('[Background] parse positions raw="$raw" tokens=${tokens.length > 0 ? tokens : <String>['<none>']} fullCount=$fullCount mapIdx=${gradientIndices.toString()}');
    }

    // Prefer computed longhands when a transition is actively running for
    // background-position or its axes, so that animation-driven values take
    // effect even if the shorthand string was authored in stylesheet.
    final bool animatingPos = (renderStyle is CSSRenderStyle)
        ? (renderStyle as CSSRenderStyle).isTransitionRunning(BACKGROUND_POSITION) ||
            (renderStyle as CSSRenderStyle).isTransitionRunning(BACKGROUND_POSITION_X) ||
            (renderStyle as CSSRenderStyle).isTransitionRunning(BACKGROUND_POSITION_Y)
        : false;

    // Build full list first
    final List<(CSSBackgroundPosition, CSSBackgroundPosition)> full = [];
    for (int j = 0; j < fullCount; j++) {
      if (!animatingPos && tokens.isNotEmpty) {
        // Cycle provided list across images.
        final String token = tokens[j % tokens.length];
        final List<String> pair = CSSPosition.parsePositionShorthand(token);
        final x = CSSPosition.resolveBackgroundPosition(pair[0], renderStyle, BACKGROUND_POSITION_X, true);
        final y = CSSPosition.resolveBackgroundPosition(pair[1], renderStyle, BACKGROUND_POSITION_Y, false);
        full.add((x, y));
      } else {
        // Use computed longhands (animated or computed) and apply to all layers.
        full.add((renderStyle.backgroundPositionX, renderStyle.backgroundPositionY));
      }
    }
    // Map to gradient-only order
    final List<(CSSBackgroundPosition, CSSBackgroundPosition)> mapped =
        gradientIndices.map((idx) => full[idx]).toList(growable: false);
    return mapped;
  }

  // Parse background-size for the full layer list and map to gradient layers by index.
  List<CSSBackgroundSize> _parseSizesMapped(List<int> gradientIndices, int fullCount) {
    final String raw = renderStyle.target.style.getPropertyValue(BACKGROUND_SIZE);
    final List<String> tokens = raw.isNotEmpty ? _splitByTopLevelCommas(raw) : <String>[];
    if (DebugFlags.enableBackgroundLogs) {
      renderingLogger.finer('[Background] parse sizes raw="$raw" tokens=${tokens.length > 0 ? tokens : <String>['<none>']} fullCount=$fullCount mapIdx=${gradientIndices.toString()}');
    }
    final bool animatingSize = (renderStyle is CSSRenderStyle)
        ? (renderStyle as CSSRenderStyle).isTransitionRunning(BACKGROUND_SIZE)
        : false;
    final List<CSSBackgroundSize> full = [];
    for (int j = 0; j < fullCount; j++) {
      if (!animatingSize && tokens.isNotEmpty) {
        // Repeat list cyclically.
        final String token = tokens[j % tokens.length];
        full.add(CSSBackground.resolveBackgroundSize(token, renderStyle, BACKGROUND_SIZE));
      } else {
        // Use computed single background-size and apply to all layers.
        full.add(renderStyle.backgroundSize);
      }
    }
    final List<CSSBackgroundSize> mapped = gradientIndices.map((idx) => full[idx]).toList(growable: false);
    return mapped;
  }

  // Parse background-repeat for the full layer list and map to gradient layers by index.
  List<ImageRepeat> _parseRepeatsMapped(List<int> gradientIndices, int fullCount) {
    final String raw = renderStyle.target.style.getPropertyValue(BACKGROUND_REPEAT);
    final List<String> tokens = raw.isNotEmpty ? _splitByTopLevelCommas(raw) : <String>[];
    if (DebugFlags.enableBackgroundLogs) {
      renderingLogger.finer('[Background] parse repeats raw="$raw" tokens=${tokens.length > 0 ? tokens : <String>['<none>']} fullCount=$fullCount mapIdx=${gradientIndices.toString()}');
    }
    final List<ImageRepeat> full = [];
    for (int j = 0; j < fullCount; j++) {
      if (tokens.isNotEmpty) {
        final String token = tokens[j % tokens.length];
        full.add(CSSBackground.resolveBackgroundRepeat(token).imageRepeat());
      } else {
        // Use computed single repeat and apply to all layers.
        full.add(renderStyle.backgroundRepeat.imageRepeat());
      }
    }
    final List<ImageRepeat> mapped = gradientIndices.map((idx) => full[idx]).toList(growable: false);
    return mapped;
  }

  // Parse background-attachment for the full layer list and map by index.
  // Supports comma-separated list. If fewer tokens than layers, values repeat cyclically.
  List<CSSBackgroundAttachmentType> _parseAttachmentsMapped(List<int> mapIndices, int fullCount) {
    final String raw = renderStyle.target.style.getPropertyValue(BACKGROUND_ATTACHMENT);
    final List<String> tokens = raw.isNotEmpty ? _splitByTopLevelCommas(raw) : <String>[];
    if (DebugFlags.enableBackgroundLogs) {
      renderingLogger.finer('[Background] parse attachments raw="$raw" tokens=${tokens.length > 0 ? tokens : <String>['<none>']} fullCount=$fullCount mapIdx=${mapIndices.toString()}');
    }
    final List<CSSBackgroundAttachmentType> full = [];
    for (int j = 0; j < fullCount; j++) {
      if (tokens.isNotEmpty) {
        final String token = tokens[j % tokens.length].trim();
        full.add(CSSBackground.resolveBackgroundAttachment(token));
      } else {
        // Default initial value per spec
        full.add(CSSBackgroundAttachmentType.scroll);
      }
    }
    final List<CSSBackgroundAttachmentType> mapped = mapIndices.map((idx) => full[idx]).toList(growable: false);
    return mapped;
  }

  // Compute destination size for a gradient layer from background-size.
  Size _computeGradientDestinationSize(Rect rect, CSSBackgroundSize size) {
    // Only support explicit width/height or contain/cover/auto heuristics similar to _paintImage.
    CSSLengthValue? backgroundWidth = size.width;
    CSSLengthValue? backgroundHeight = size.height;
    BoxFit fit = size.fit;

    Size outputSize = rect.size;
    Size destinationSize = outputSize;

    if (backgroundWidth != null &&
        !backgroundWidth.isAuto &&
        backgroundWidth.computedValue > 0 &&
        (backgroundHeight == null || backgroundHeight.isAuto)) {
      double width = backgroundWidth.computedValue;
      destinationSize = Size(width, outputSize.height);
    } else if (backgroundWidth != null &&
        backgroundWidth.isAuto &&
        backgroundHeight != null &&
        !backgroundHeight.isAuto &&
        backgroundHeight.computedValue > 0) {
      double height = backgroundHeight.computedValue;
      destinationSize = Size(outputSize.width, height);
    } else if (backgroundWidth != null &&
        !backgroundWidth.isAuto &&
        backgroundWidth.computedValue > 0 &&
        backgroundHeight != null &&
        !backgroundHeight.isAuto &&
        backgroundHeight.computedValue > 0) {
      destinationSize = Size(backgroundWidth.computedValue, backgroundHeight.computedValue);
    } else {
      // contain/cover/auto: for gradients, treat as no scaling (cover full rect for cover/auto).
      // contain behaves similar to cover for gradients as there's no intrinsic size.
      switch (fit) {
        case BoxFit.contain:
        case BoxFit.cover:
        case BoxFit.none:
        default:
          destinationSize = outputSize;
      }
    }
    return destinationSize;
  }

  // Compute destination rect from position and size, similar to _paintImage logic.
  Rect _computeDestinationRect(Rect rect, Size destSize, CSSBackgroundPosition posX, CSSBackgroundPosition posY) {
    final Size outputSize = rect.size;
    final double halfWidthDelta = (outputSize.width - destSize.width) / 2.0;
    final double halfHeightDelta = (outputSize.height - destSize.height) / 2.0;

    final double dx = posX.calcValue != null
        ? (posX.calcValue!.computedValue(BACKGROUND_POSITION_X) ?? 0)
        : posX.length != null
            ? posX.length!.computedValue
            : halfWidthDelta + posX.percentage! * halfWidthDelta;
    final double dy = posY.calcValue != null
        ? (posY.calcValue!.computedValue(BACKGROUND_POSITION_Y) ?? 0)
        : posY.length != null
            ? posY.length!.computedValue
            : halfHeightDelta + posY.percentage! * halfHeightDelta;

    return (rect.topLeft.translate(dx, dy)) & destSize;
  }

  void _paintLayeredGradients(Canvas canvas, Rect rect, TextDirection? textDirection) {
    final img = renderStyle.backgroundImage;
    if (img == null) return;

    // Extract gradient functions (each represents a layer)
    final List<CSSFunctionalNotation> fullFns = img.functions;
    final List<CSSFunctionalNotation> fns = fullFns.where((f) => f.name.contains('gradient')).toList();
    // Map each gradient to its index in the full background list
    final List<int> gIndices = [];
    for (int i = 0; i < fullFns.length; i++) {
      if (fullFns[i].name.contains('gradient')) gIndices.add(i);
    }
    if (fns.isEmpty) return;

    // Resolve per-layer lists separately for gradients and images.
    // Build image layer indices in full list order.
    final List<int> imgIndices = [];
    for (int i = 0; i < fullFns.length; i++) {
      if (fullFns[i].name == 'url') imgIndices.add(i);
    }

    // Gradients mapping
    final positionsGrad = _parsePositionsMapped(gIndices, fullFns.length);
    final sizesGrad = _parseSizesMapped(gIndices, fullFns.length);
    final repeatsGrad = _parseRepeatsMapped(gIndices, fullFns.length);
    // Also map background-attachment per gradient layer for debugging (and future correctness).
    final attachmentsGrad = _parseAttachmentsMapped(gIndices, fullFns.length);

    // Images mapping
    final positionsImg = _parsePositionsMapped(imgIndices, fullFns.length);
    final sizesImg = _parseSizesMapped(imgIndices, fullFns.length);
    final repeatsImg = _parseRepeatsMapped(imgIndices, fullFns.length);



    // Paint from bottom-most (last) to top-most (first) per CSS layering rules.
    for (int i = fns.length - 1; i >= 0; i--) {
      final fn = fns[i];
      // Build a temporary CSSBackgroundImage for this single function to reuse parsing logic.
      // Compute destination size and rect first to derive a length hint for px stops.
      final (CSSBackgroundPosition px, CSSBackgroundPosition py) = positionsGrad[i];
      final CSSBackgroundSize size = sizesGrad[i];
      final ImageRepeat repeat = repeatsGrad[i];
      final CSSBackgroundAttachmentType attach = attachmentsGrad[i];
      final bool useViewport = attach == CSSBackgroundAttachmentType.fixed;
      final Rect viewportRect = Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? rect.size);
      final bool propagateToViewport = useViewport && _isRootBackgroundTarget(renderStyle.target);

      // When fixed, anchor to viewport for positioning; otherwise use the element clip rect.
      final Rect positioningRect = useViewport ? viewportRect : rect;
      // For root background propagation with fixed, expand clip to viewport; otherwise clip to element rect.
      final Rect layerClipRect = propagateToViewport ? viewportRect : rect;

      final Size destSize = _computeGradientDestinationSize(positioningRect, size);
      double? lengthHint;
      if (fn.name.contains('linear-gradient')) {
        lengthHint = _linearGradientLengthHint(fn, destSize);
      } else if (fn.name.contains('radial-gradient')) {
        lengthHint = _radialGradientLengthHint(fn, positioningRect);
      }

      final single = CSSBackgroundImage([fn], renderStyle, renderStyle.target.ownerDocument.controller,
          baseHref: renderStyle.target.style.getPropertyBaseHref(BACKGROUND_IMAGE), gradientLengthHint: lengthHint);
      final Gradient? gradient = single.gradient;
      if (gradient == null) continue;

      // Mapping this gradient layer's positioning/size/repeat from precomputed lists.
      Rect destRect = _computeDestinationRect(positioningRect, destSize, px, py);

      if (DebugFlags.enableBackgroundLogs) {
        // Extract a compact view of colors/stops if available
        List<String> cs = const [];
        List<String>? st;
        if (gradient is LinearGradient) {
          cs = gradient.colors
              .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
              .toList();
          st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
        } else if (gradient is RadialGradient) {
          cs = gradient.colors
              .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
              .toList();
          st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
        } else if (gradient is SweepGradient) {
          cs = gradient.colors
              .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
              .toList();
          st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
        }
        final tag = () {
          try {
            final el = renderStyle.target;
            final id = (el.id != null && el.id!.isNotEmpty) ? '#${el.id}' : '';
            final cls = (el.className != null && el.className!.isNotEmpty) ? '.${el.className}' : '';
            return '<${el.tagName.toLowerCase()}$id$cls>';
          } catch (_) { return '<unknown>'; }
        }();
        renderingLogger.finer('[Background] layer(gradient) i=$i target=$tag fn=${fn.name} attach=${attach.cssText()} useViewport=$useViewport '
            'clip=${layerClipRect} positionRect=${positioningRect} viewport=${viewportRect} pos=(${px.cssText()}, ${py.cssText()}) size=${size.cssText()} repeat=$repeat');
        renderingLogger.finer('[Background]   dest=${destRect} colors=${cs} stops=${st ?? const []}');
      }

      // Clip to background painting area. Respect border-radius when present to
      // avoid leaking color outside rounded corners (matches CSS background-clip).
      canvas.save();
      if (_decoration.hasBorderRadius && _decoration.borderRadius != null && !propagateToViewport) {
        final Path rounded = Path()..addRRect(_decoration.borderRadius!.toRRect(layerClipRect));
        canvas.clipPath(rounded);
      } else {
        canvas.clipRect(layerClipRect);
      }

      if (destRect.isEmpty) {
        // Nothing to paint for empty destination.
      } else if (repeat == ImageRepeat.noRepeat) {
        final paint = Paint()..shader = gradient.createShader(destRect, textDirection: textDirection);
        canvas.drawRect(destRect, paint);
      } else {
        // Tile the gradient rect similar to image tiling.
        // Important: per CSS, each tile's image space restarts at the tile origin.
        // Create a shader per tile so the gradient aligns with the tile's rect.
        int tCount = 0;
        for (final Rect tile in _generateImageTileRects(layerClipRect, destRect, repeat)) {
          final paint = Paint()..shader = gradient.createShader(tile, textDirection: textDirection);
          canvas.drawRect(tile, paint);
          if (DebugFlags.enableBackgroundLogs) {
            tCount++;
          }
        }
        if (DebugFlags.enableBackgroundLogs) {
          renderingLogger.finer('[Background]   tiled ${tCount} rects for gradient layer');
        }
      }

      canvas.restore();
    }
  }

  // Compute a per-layer linear-gradient length hint from the tile dest size.
  // This allows px color-stops to normalize against the final tile instead of
  // the element box. Follows the same projection as shader (|sin|*w + |cos|*h).
  double? _linearGradientLengthHint(CSSFunctionalNotation fn, Size destSize) {
    if (!fn.name.contains('linear-gradient')) return null;
    if (fn.args.isEmpty) return destSize.height; // default top->bottom
    final String arg0 = fn.args[0].trim();
    if (CSSAngle.isAngle(arg0)) {
      final double angle = CSSAngle.parseAngle(arg0)!;
      final double sin = math.sin(angle).abs();
      final double cos = math.cos(angle).abs();
      return sin * destSize.width + cos * destSize.height;
    }
    if (arg0.startsWith('to ')) {
      final parts = arg0.split(splitRegExp);
      bool toH = parts.contains(LEFT) || parts.contains(RIGHT);
      bool toV = parts.contains(TOP) || parts.contains(BOTTOM);
      if (toH && toV) {
        return math.sqrt(destSize.width * destSize.width + destSize.height * destSize.height);
      }
      if (toH) return destSize.width;
      if (toV) return destSize.height;
    }
    // First token is a color stop: default orientation is vertical.
    return destSize.height;
  }

  // Compute a radial-gradient length hint (device px) for px stops normalization.
  // Approximates the shader's effective radius (farthest-corner with radius=0.5)
  // based on the positioning rect and optional "at <position>" prelude.
  double _radialGradientLengthHint(CSSFunctionalNotation fn, Rect positioningRect) {
    double atX = 0.5;
    double atY = 0.5;
    if (fn.args.isNotEmpty) {
      final String prelude = fn.args[0].trim();
      if (prelude.isNotEmpty) {
        final List<String> tokens = prelude.split(splitRegExp).where((s) => s.isNotEmpty).toList();
        final int atIndex = tokens.indexOf('at');
        if (atIndex != -1) {
          List<String> pos = tokens.sublist(atIndex + 1);
          double parseX(String s) {
            if (s == LEFT) return 0.0;
            if (s == CENTER) return 0.5;
            if (s == RIGHT) return 1.0;
            if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
            return 0.5;
          }
          double parseY(String s) {
            if (s == TOP) return 0.0;
            if (s == CENTER) return 0.5;
            if (s == BOTTOM) return 1.0;
            if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
            return 0.5;
          }
          if (pos.isNotEmpty) {
            if (pos.length == 1) {
              final String v = pos.first;
              if (v == TOP || v == BOTTOM) {
                atY = parseY(v);
                atX = 0.5;
              } else {
                atX = parseX(v);
                atY = 0.5;
              }
            } else {
              atX = parseX(pos[0]);
              atY = parseY(pos[1]);
            }
          }
        }
      }
    }

    final double cx = positioningRect.left + atX * positioningRect.width;
    final double cy = positioningRect.top + atY * positioningRect.height;
    final double w = math.max((cx - positioningRect.left).abs(), (positioningRect.right - cx).abs());
    final double h = math.max((cy - positioningRect.top).abs(), (positioningRect.bottom - cy).abs());
    return math.sqrt(w * w + h * h);
  }

  void _paintLayeredMixedBackgrounds(
    Canvas canvas,
    Rect clipRect,
    Rect originRect,
    ImageConfiguration configuration,
    TextDirection? textDirection,
  ) {
    final CSSBackgroundImage? bg = renderStyle.backgroundImage;
    if (bg == null) return;
    final List<CSSFunctionalNotation> fullFns = bg.functions;
    final int count = fullFns.length;
    if (count == 0) return;
    if (DebugFlags.enableBackgroundLogs) {
      final names = fullFns.map((f) => f.name).toList();
      renderingLogger.finer('[Background] layered begin count=$count layers=$names');
    }

    // If there are image layers, resolve the stream once now. If unresolved,
    // we still paint color/gradients and skip url layers this frame.
    final bool hasUrlLayer = fullFns.any((f) => f.name == 'url');
    bool canPaintUrl = true;
    if (hasUrlLayer) {
      if (_decoration.image == null) {
        canPaintUrl = false;
      } else {
        _imagePainter ??= BoxDecorationImagePainter._(_decoration.image!, renderStyle, onChanged!);
        _imagePainter!.image = _decoration.image!;
        if (_imagePainter!._image == null) {
          final ImageStream newImageStream = _imagePainter!._details.image.resolve(configuration);
          if (newImageStream.key != _imagePainter!._imageStream?.key) {
            final ImageStreamListener listener = ImageStreamListener(
              _imagePainter!._handleImage,
              onError: _imagePainter!._details.onError,
            );
            _imagePainter!._imageStream = newImageStream;
            _imagePainter!._imageStream!.addListener(listener);
          }
          canPaintUrl = _imagePainter!._image != null;
          if (DebugFlags.enableBackgroundLogs) {
            renderingLogger.finer('[Background] layered pre-resolve: image ' + (canPaintUrl ? 'resolved synchronously' : 'unresolved; painting only non-url layers'));
          }
        }
      }
    }

    // Resolve full per-layer lists (not filtered) with fallback to computed values during animation.
    final List<int> allIdx = List<int>.generate(count, (i) => i);
    final positions = _parsePositionsMapped(allIdx, count);
    final sizes = _parseSizesMapped(allIdx, count);
    final repeats = _parseRepeatsMapped(allIdx, count);
    final attachments = _parseAttachmentsMapped(allIdx, count);

    // Paint background-color under all layers if present.
    final Color? bgColor = renderStyle.backgroundColor?.value;
    if (bgColor != null && bgColor.alpha > 0) {
      final Paint p = Paint()..color = bgColor;
      switch (_decoration.shape) {
        case BoxShape.circle:
          final Offset center = clipRect.center;
          final double radius = clipRect.shortestSide / 2.0;
          canvas.drawCircle(center, radius, p);
          break;
        case BoxShape.rectangle:
          if (_decoration.hasBorderRadius) {
            canvas.drawRRect(_decoration.borderRadius!.toRRect(clipRect), p);
          } else {
            canvas.drawRect(clipRect, p);
          }
          break;
      }
    }

    if (DebugFlags.enableBackgroundLogs) {
      final order = List<String>.generate(count, (i) => fullFns[i].name).reversed.toList();
      renderingLogger.finer('[Background] mixed layering count=$count paint order bottom->top=${order.join(' -> ')}');
    }

    // Paint from bottom-most (last) to top-most (first) per CSS layering rules.
    for (int i = count - 1; i >= 0; i--) {
      final name = fullFns[i].name;
      var pair = positions[i];
      CSSBackgroundPosition px = pair.$1;
      CSSBackgroundPosition py = pair.$2;
      CSSBackgroundSize size = sizes[i];
      ImageRepeat repeat = repeats[i];

      if (name == 'url') {
        if (!canPaintUrl) continue;
        // Stream should already be resolved by the pre-check above; paint all url layers now.
        final ui.Image img = _imagePainter!._image!.image;
        final double scale = _decoration.image!.scale * _imagePainter!._image!.scale;
        bool flipHorizontally = false;
        if (_decoration.image!.matchTextDirection) {
          if (configuration.textDirection == null) {
            // skip flipping without direction.
          } else if (configuration.textDirection == TextDirection.rtl) {
            flipHorizontally = true;
          }
        }

        // Clip to background painting area (respect border-radius) per layer.
        // For root/background propagation targets with fixed attachment, expand
        // the clip to the viewport so the row at top is visible (matches UA behavior).
        final CSSBackgroundAttachmentType attach = attachments[i];
        final bool useViewport = attach == CSSBackgroundAttachmentType.fixed;
        final Rect viewportRect = Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? configuration.size!);
        final bool propagateToViewport = useViewport && _isRootBackgroundTarget(renderStyle.target);
        final Rect layerClipRect = propagateToViewport ? viewportRect : clipRect;

        canvas.save();
        if (_decoration.hasBorderRadius && _decoration.borderRadius != null && !propagateToViewport) {
          final Path rounded = Path()..addRRect(_decoration.borderRadius!.toRRect(layerClipRect));
          canvas.clipPath(rounded);
        } else {
          canvas.clipRect(layerClipRect);
        }

        // For attachment: fixed, position relative to the viewport (initial containing block),
        // while still clipping to the element's background painting area.
        final Rect positioningRect = useViewport
            ? (Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? configuration.size!))
            : originRect;

        // Paint the image with per-layer overrides.
        _paintImage(
          painterRef: this,
          canvas: canvas,
          rect: positioningRect,
          image: img,
          debugImageLabel: _imagePainter!._image!.debugLabel,
          scale: scale,
          colorFilter: _decoration.image!.colorFilter,
          positionX: px,
          positionY: py,
          backgroundSize: size,
          centerSlice: _decoration.image!.centerSlice,
          repeat: repeat,
          flipHorizontally: flipHorizontally,
          filterQuality: FilterQuality.low,
        );

        canvas.restore();

        if (DebugFlags.enableBackgroundLogs) {
          renderingLogger.finer('[Background] layer(url) i=$i pos=(${px.cssText()}, ${py.cssText()}) size=${size.cssText()} '
              'repeat=$repeat originRect=$originRect clipRect=${layerClipRect} attachRect=${positioningRect} attach=${attach.cssText()}');
        }
        continue;
      }

      if (name.contains('gradient')) {
        // For attachment: fixed, compute destination relative to the viewport
        // (positioning area). For root/background propagation targets, also expand
        // the clip to the viewport so the top row is visible.
        final CSSBackgroundAttachmentType attach = attachments[i];
        final bool useViewport = attach == CSSBackgroundAttachmentType.fixed;
        final Rect viewportRect = Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? configuration.size!);
        final bool propagateToViewport = useViewport && _isRootBackgroundTarget(renderStyle.target);
        final Rect positioningRect = useViewport
            ? (Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? configuration.size!))
            : clipRect;
        // Build gradient for this layer and paint.
        final CSSFunctionalNotation fn = fullFns[i];
        // Compute destination size now to derive a per-layer length hint for px stops.
        final Size destSize = _computeGradientDestinationSize(positioningRect, size);
        double? lengthHint;
        if (fn.name.contains('linear-gradient')) {
          lengthHint = _linearGradientLengthHint(fn, destSize);
        } else if (fn.name.contains('radial-gradient')) {
          lengthHint = _radialGradientLengthHint(fn, positioningRect);
        }

        final single = CSSBackgroundImage([fn], renderStyle, renderStyle.target.ownerDocument.controller,
            baseHref: renderStyle.target.style.getPropertyBaseHref(BACKGROUND_IMAGE), gradientLengthHint: lengthHint);
        final Gradient? gradient = single.gradient;
        if (gradient == null) continue;

        Rect destRect = _computeDestinationRect(positioningRect, destSize, px, py);
        if (DebugFlags.enableBackgroundLogs) {
          List<String> cs = const [];
          List<String>? st;
          if (gradient is LinearGradient) {
            cs = gradient.colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
          } else if (gradient is RadialGradient) {
            cs = gradient.colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
          } else if (gradient is SweepGradient) {
            cs = gradient.colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            st = gradient.stops?.map((v) => v.toStringAsFixed(4)).toList();
          }
          renderingLogger.finer('[Background] layer(gradient) i=$i fn=${fullFns[i].name} rect=${positioningRect.size} '
              'destRect=${destRect.size} pos=(${px.cssText()}, ${py.cssText()}) size=${size.cssText()} repeat=$repeat '
              'colors=${cs} stops=${st ?? const []}');
        }

        canvas.save();
        final Rect layerClipRect = propagateToViewport ? viewportRect : clipRect;
        if (_decoration.hasBorderRadius && _decoration.borderRadius != null && !propagateToViewport) {
          final Path rounded = Path()..addRRect(_decoration.borderRadius!.toRRect(layerClipRect));
          canvas.clipPath(rounded);
        } else {
          canvas.clipRect(layerClipRect);
        }

        if (destRect.isEmpty) {
          // nothing
        } else if (repeat == ImageRepeat.noRepeat) {
          final paint = Paint()..shader = gradient.createShader(destRect, textDirection: textDirection);
          canvas.drawRect(destRect, paint);
        } else {
          int tCount = 0;
          for (final Rect tile in _generateImageTileRects(clipRect, destRect, repeat)) {
            final paint = Paint()..shader = gradient.createShader(tile, textDirection: textDirection);
            canvas.drawRect(tile, paint);
            if (DebugFlags.enableBackgroundLogs) tCount++;
          }
          if (DebugFlags.enableBackgroundLogs) {
            renderingLogger.finer('[Background]   tiled ${tCount} rects for gradient layer');
          }
        }
        canvas.restore();

        if (DebugFlags.enableBackgroundLogs) {
          renderingLogger.finer('[Background] layer(gradient) i=$i pos=(${px.cssText()}, ${py.cssText()}) size=${size.cssText()} repeat=$repeat rect=$destRect attachRect=${positioningRect} attach=${attach.cssText()}');
        }
      }
    }
  }

  BoxDecorationImagePainter? _imagePainter;

  void _paintBackgroundImage(Canvas canvas, Rect clipRect, Rect originRect, ImageConfiguration configuration) {
    if (_decoration.image == null) return;
    if (_imagePainter == null) {
      _imagePainter = BoxDecorationImagePainter._(_decoration.image!, renderStyle, onChanged!);
    } else {
      _imagePainter!.image = _decoration.image!;
    }
    if (DebugFlags.enableBackgroundLogs) {
      final px = renderStyle.backgroundPositionX;
      final py = renderStyle.backgroundPositionY;
      renderingLogger.finer('[Background] before painter: posX=${px.cssText()} (len=${px.length != null} pct=${px.percentage != null} calc=${px.calcValue != null}) '
          'posY=${py.cssText()} (len=${py.length != null} pct=${py.percentage != null} calc=${py.calcValue != null}) '
          'originRect=$originRect clipRect=$clipRect attach=${renderStyle.backgroundAttachment?.cssText() ?? 'scroll'}');
    }
    _imagePainter ??= BoxDecorationImagePainter._(_decoration.image!, renderStyle, onChanged!);
    Path? clipPath;
    switch (_decoration.shape) {
      case BoxShape.circle:
        clipPath = Path()..addOval(clipRect);
        break;
      case BoxShape.rectangle:
        if (_decoration.hasBorderRadius && _decoration.borderRadius != null) {
          clipPath = Path()..addRRect(_decoration.borderRadius!.toRRect(clipRect));
        } else {
          // Clip to rectangular content/padding/border box when no radius.
          clipPath = Path()..addRect(clipRect);
        }
        break;
    }
    // For attachment: fixed, use the viewport as the positioning rect so that
    // background-position is relative to the viewport (initial containing block).
    final bool useViewport = renderStyle.backgroundAttachment == CSSBackgroundAttachmentType.fixed;
    final Rect positioningRect = useViewport
        ? (Offset.zero & (renderStyle.target.ownerDocument.viewport?.viewportSize ?? configuration.size!))
        : originRect;

    _imagePainter!.paint(canvas, positioningRect, clipPath, configuration);

    // Report FCP when background image is painted (excluding CSS gradients)
    if (_imagePainter!._image != null && !originRect.isEmpty) {
      // Report FP first (if not already reported)
      renderStyle.target.ownerDocument.controller.reportFP();
      renderStyle.target.ownerDocument.controller.reportFCP();

      // Report LCP candidate for background images
      // Calculate the visible area of the background image
      double visibleArea = originRect.width * originRect.height;
      if (visibleArea > 0) {
        renderStyle.target.ownerDocument.controller.reportLCPCandidate(renderStyle.target, visibleArea);
      }
    }
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  bool _hasLocalBackgroundImage() {
    if (renderStyle.backgroundImage == null) return false;
    final String raw = renderStyle.target.style.getPropertyValue(BACKGROUND_ATTACHMENT);
    if (raw.isEmpty) return renderStyle.backgroundAttachment == CSSBackgroundAttachmentType.local;
    // Check comma-separated list for any 'local'.
    final List<String> tokens = _splitByTopLevelCommas(raw);
    for (final t in tokens) {
      if (CSSBackground.resolveBackgroundAttachment(t.trim()) == CSSBackgroundAttachmentType.local) {
        return true;
      }
    }
    return false;
  }

  void paintBackground(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    Offset baseOffset = Offset.zero;

    final TextDirection? textDirection = configuration.textDirection;
    bool hasLocalAttachment = _hasLocalBackgroundImage();

    // When background-clip: text is specified, the background should be applied
    // to glyphs only (handled in InlineFormattingContext). Skip painting box
    // background color/image here to avoid a solid rectangle behind the text.
    if (renderStyle.backgroundClip == CSSBackgroundBoundary.text) {
      return;
    }

    // Rects for color and image
    Rect backgroundColorRect = _getBackgroundClipRect(baseOffset, configuration);
    // Background image of background-attachment local scroll with content
    Offset backgroundImageOffset = hasLocalAttachment ? offset : baseOffset;
    // Rect of background image
    Rect backgroundClipRect = _getBackgroundClipRect(backgroundImageOffset, configuration);
    Rect backgroundOriginRect = _getBackgroundOriginRect(backgroundImageOffset, configuration);
    Rect backgroundImageRect = backgroundClipRect.intersect(backgroundOriginRect);

    if (DebugFlags.enableBackgroundLogs) {
      final clip = renderStyle.backgroundClip;
      final origin = renderStyle.backgroundOrigin;
      final rep = renderStyle.backgroundRepeat;
      renderingLogger.finer('[Background] container=${configuration.size} offset=$offset '
          'clipRect=$backgroundClipRect originRect=$backgroundOriginRect imageRect=$backgroundImageRect '
          'clip=${clip ?? CSSBackgroundBoundary.borderBox} origin=${origin ?? CSSBackgroundBoundary.paddingBox} '
          'repeat=${rep.cssText()}');
    }

    final bool hasGradients = _hasGradientLayers();
    final bool hasImages = _hasImageLayers();
    if (hasGradients && hasImages) {
      _paintLayeredMixedBackgrounds(canvas, backgroundClipRect, backgroundOriginRect, configuration, textDirection);
    } else if (hasGradients) {
      _paintBackgroundColor(canvas, backgroundColorRect, textDirection);
    } else {
      _paintBackgroundColor(canvas, backgroundColorRect, textDirection);
      _paintBackgroundImage(canvas, backgroundClipRect, backgroundOriginRect, configuration);
    }
  }

  Rect _getBackgroundOriginRect(Offset offset, ImageConfiguration configuration) {
    Size? size = configuration.size;

    EdgeInsets borderEdge = renderStyle.border;
    double borderTop = borderEdge.top;
    double borderLeft = borderEdge.left;

    double paddingTop = 0;
    double paddingLeft = 0;
    if (padding != null) {
      paddingTop = padding!.top;
      paddingLeft = padding!.left;
    }
    // Background origin moves background image from specified origin
    Rect backgroundOriginRect;
    CSSBackgroundBoundary? backgroundOrigin = renderStyle.backgroundOrigin;
    switch (backgroundOrigin) {
      case CSSBackgroundBoundary.borderBox:
        backgroundOriginRect = offset & size!;
        break;
      case CSSBackgroundBoundary.contentBox:
        backgroundOriginRect = offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) & size!;
        break;
      default:
        backgroundOriginRect = offset.translate(borderLeft, borderTop) & size!;
        break;
    }
    return backgroundOriginRect;
  }

  Rect _getBackgroundClipRect(Offset offset, ImageConfiguration configuration) {
    Size? size = configuration.size;
    EdgeInsets borderEdge = renderStyle.border;
    double borderTop = borderEdge.top;
    double borderBottom = borderEdge.bottom;
    double borderLeft = borderEdge.left;
    double borderRight = borderEdge.right;

    double paddingTop = 0;
    double paddingBottom = 0;
    double paddingLeft = 0;
    double paddingRight = 0;
    if (padding != null) {
      paddingTop = padding!.top;
      paddingBottom = padding!.bottom;
      paddingLeft = padding!.left;
      paddingRight = padding!.right;
    }
    Rect backgroundClipRect;
    CSSBackgroundBoundary? backgroundClip = renderStyle.backgroundClip;
    switch (backgroundClip) {
      case CSSBackgroundBoundary.paddingBox:
        backgroundClipRect = offset.translate(borderLeft, borderTop) &
            Size(
              size!.width - borderRight - borderLeft,
              size.height - borderBottom - borderTop,
            );
        break;
      case CSSBackgroundBoundary.contentBox:
        backgroundClipRect = offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) &
            Size(
              size!.width - borderRight - borderLeft - paddingRight - paddingLeft,
              size.height - borderBottom - borderTop - paddingBottom - paddingTop,
            );
        break;
      default:
        backgroundClipRect = offset & size!;
        break;
    }
    return backgroundClipRect;
  }

  /// Paint the box decoration into the given location on the given canvas
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = offset & configuration.size!;
    final TextDirection? textDirection = configuration.textDirection;

    // When this element participates in an inline formatting context, backgrounds and borders
    // for inline-level boxes are painted by the paragraph path (InlineFormattingContext).
    // Skip BoxDecoration painting here to avoid double painting and mismatched joins.
    bool _skipForInlineIFC() {
      // Only inline-level boxes are painted via paragraph IFC.
      if (renderStyle.effectiveDisplay != CSSDisplay.inline) return false;
      final RenderBoxModel? self = renderStyle.attachedRenderBoxModel;
      if (self == null) return false;
      RenderObject? p = self.parent;
      while (p != null) {
        if (p is RenderFlowLayout) {
          return p.establishIFC;
        }
        p = (p as RenderObject).parent;
      }
      return false;
    }

    if (_skipForInlineIFC()) {
      return;
    }

    bool hasLocalAttachment = _hasLocalBackgroundImage();
    if (!hasLocalAttachment) {
      if (renderStyle.backgroundClip != CSSBackgroundBoundary.text) {
        final bool hasGradients = _hasGradientLayers();
        final bool hasImages = _hasImageLayers();
        Rect backgroundClipRect = _getBackgroundClipRect(offset, configuration);
        Rect backgroundOriginRect = _getBackgroundOriginRect(offset, configuration);

        if (hasImages) {
          // Paint layered images (and gradients if present) in proper order.
          _paintLayeredMixedBackgrounds(canvas, backgroundClipRect, backgroundOriginRect, configuration, textDirection);
        } else if (hasGradients) {
          _paintBackgroundColor(canvas, backgroundClipRect, textDirection);
        } else {
          _paintBackgroundColor(canvas, backgroundClipRect, textDirection);
        }
      }
    }

    // Check for custom border styles (dashed/double)
    bool hasDashedBorder = false;
    bool hasDoubleBorder = false;

    if (_decoration.border != null) {
      final Border border = _decoration.border as Border;

      bool topDashed = border.top is ExtendedBorderSide &&
          (border.top as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed;
      bool rightDashed = border.right is ExtendedBorderSide &&
          (border.right as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed;
      bool bottomDashed = border.bottom is ExtendedBorderSide &&
          (border.bottom as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed;
      bool leftDashed = border.left is ExtendedBorderSide &&
          (border.left as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.dashed;

      hasDashedBorder = topDashed || rightDashed || bottomDashed || leftDashed;

      bool topDouble = border.top is ExtendedBorderSide &&
          (border.top as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double;
      bool rightDouble = border.right is ExtendedBorderSide &&
          (border.right as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double;
      bool bottomDouble = border.bottom is ExtendedBorderSide &&
          (border.bottom as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double;
      bool leftDouble = border.left is ExtendedBorderSide &&
          (border.left as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double;

      hasDoubleBorder = topDouble || rightDouble || bottomDouble || leftDouble;
    }

    // Prefer dashed painter, then double painter, else fallback to Flutter
    if (hasDashedBorder) {
      _paintDashedBorder(canvas, rect, textDirection);
      renderStyle.target.ownerDocument.controller.reportFP();
    } else if (hasDoubleBorder) {
      _paintDoubleBorder(canvas, rect, textDirection);
      renderStyle.target.ownerDocument.controller.reportFP();
    } else if (_decoration.border != null) {
      _decoration.border?.paint(
        canvas,
        rect,
        shape: _decoration.shape,
        borderRadius: _decoration.borderRadius,
        textDirection: configuration.textDirection,
      );
      renderStyle.target.ownerDocument.controller.reportFP();
    }

    _paintShadows(canvas, rect, textDirection);
  }

  // Paint CSS double borders. Two parallel bands per side inside the border area.
  // For small widths (< 3), fall back to a single solid band for readability.
  void _paintDoubleBorder(Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.border == null) return;
    final Border border = _decoration.border as Border;

    // Helper: draw horizontal double bands within [top, bottom] region of the rect.
    void _drawHorizontalDoubleBands(double top, double bottom, Color color) {
      final double w = (bottom - top).abs();
      if (w <= 0) return;
      final Paint p = Paint()..style = PaintingStyle.fill..color = color;
      if (w < 3.0) {
        // Fallback solid band
        canvas.drawRect(Rect.fromLTWH(rect.left, top, rect.width, w), p);
        return;
      }
      final double band = (w / 3.0).floorToDouble().clamp(1.0, w);
      final double gap = (w - 2 * band).clamp(0.0, w);
      // Upper band (closer to content for bottom side; for top side this sits at the top edge)
      canvas.drawRect(Rect.fromLTWH(rect.left, top, rect.width, band), p);
      // Lower band (outer edge)
      canvas.drawRect(Rect.fromLTWH(rect.left, top + band + gap, rect.width, band), p);
    }

    // Helper: draw vertical double bands within [left, right] region of the rect.
    void _drawVerticalDoubleBands(double left, double right, Color color) {
      final double w = (right - left).abs();
      if (w <= 0) return;
      final Paint p = Paint()..style = PaintingStyle.fill..color = color;
      if (w < 3.0) {
        canvas.drawRect(Rect.fromLTWH(left, rect.top, w, rect.height), p);
        return;
      }
      final double band = (w / 3.0).floorToDouble().clamp(1.0, w);
      final double gap = (w - 2 * band).clamp(0.0, w);
      // Left inner band
      canvas.drawRect(Rect.fromLTWH(left, rect.top, band, rect.height), p);
      // Right outer band
      canvas.drawRect(Rect.fromLTWH(left + band + gap, rect.top, band, rect.height), p);
    }

    // Detect uniform double border to support border-radius by stroking rrect twice.
    bool _isUniformDouble(Border b) {
      if (b.top is! ExtendedBorderSide || b.right is! ExtendedBorderSide || b.bottom is! ExtendedBorderSide || b.left is! ExtendedBorderSide) {
        return false;
      }
      final t = b.top as ExtendedBorderSide;
      final r = b.right as ExtendedBorderSide;
      final btm = b.bottom as ExtendedBorderSide;
      final l = b.left as ExtendedBorderSide;
      final sameStyle = t.extendBorderStyle == CSSBorderStyleType.double &&
          t.extendBorderStyle == r.extendBorderStyle &&
          t.extendBorderStyle == btm.extendBorderStyle &&
          t.extendBorderStyle == l.extendBorderStyle;
      final sameWidth = t.width == r.width && t.width == btm.width && t.width == l.width;
      final sameColor = t.color == r.color && t.color == btm.color && t.color == l.color;
      return sameStyle && sameWidth && sameColor;
    }

    // Uniform double with border radius: draw two RRect strokes
    if (_isUniformDouble(border) && _decoration.hasBorderRadius && _decoration.borderRadius != null) {
      final side = border.top as ExtendedBorderSide; // all equal
      final double w = side.width;
      final Color color = side.color;
      final RRect rr = _decoration.borderRadius!.toRRect(rect);
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter
        ..color = color;
      if (w < 3.0) {
        p.strokeWidth = w;
        canvas.drawRRect(rr.deflate(w / 2.0), p);
        return;
      }
      final double band = (w / 3.0).floorToDouble().clamp(1.0, w);
      final double gap = (w - 2 * band).clamp(0.0, w);
      // Outer band (near border edge)
      p.strokeWidth = band;
      canvas.drawRRect(rr.deflate(band / 2.0), p);
      // Inner band (near content)
      canvas.drawRRect(rr.deflate(band + gap + band / 2.0), p);
      return;
    }

    // Non-uniform or no radius: paint per-side rectangles. This covers common cases like border-bottom.
    // Note: When border-radius is present and styles are non-uniform, this approximation won't curve bands;
    // however it ensures visibility rather than painting nothing.
    // Extract sides as ExtendedBorderSide when double
    if (border.top is ExtendedBorderSide &&
        (border.top as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double &&
        border.top.width > 0) {
      final s = border.top as ExtendedBorderSide;
      final double w = s.width;
      _drawHorizontalDoubleBands(rect.top, rect.top + w, s.color);
    }

    if (border.right is ExtendedBorderSide &&
        (border.right as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double &&
        border.right.width > 0) {
      final s = border.right as ExtendedBorderSide;
      final double w = s.width;
      _drawVerticalDoubleBands(rect.right - w, rect.right, s.color);
    }

    if (border.bottom is ExtendedBorderSide &&
        (border.bottom as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double &&
        border.bottom.width > 0) {
      final s = border.bottom as ExtendedBorderSide;
      final double w = s.width;
      _drawHorizontalDoubleBands(rect.bottom - w, rect.bottom, s.color);
    }

    if (border.left is ExtendedBorderSide &&
        (border.left as ExtendedBorderSide).extendBorderStyle == CSSBorderStyleType.double &&
        border.left.width > 0) {
      final s = border.left as ExtendedBorderSide;
      final double w = s.width;
      _drawVerticalDoubleBands(rect.left, rect.left + w, s.color);
    }
  }

  @override
  String toString() => 'BoxPainter for $_decoration';
}

/// Forked from flutter of [DecorationImagePainter] Class.
/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L208
class BoxDecorationImagePainter {
  BoxDecorationImagePainter._(this._details, this._renderStyle, this._onChanged);

  final CSSRenderStyle _renderStyle;
  DecorationImage _details;

  set image(DecorationImage detail) {
    _details = detail;
  }

  CSSBackgroundPosition get _backgroundPositionX {
    return _renderStyle.backgroundPositionX;
  }

  CSSBackgroundPosition get _backgroundPositionY {
    return _renderStyle.backgroundPositionY;
  }

  CSSBackgroundSize get _backgroundSize {
    return _renderStyle.backgroundSize;
  }

  final VoidCallback _onChanged;

  ImageStream? _imageStream;
  ImageInfo? _image;

  /// Forked from flutter with parameter customization of _paintImage method:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L231
  void paint(Canvas canvas, Rect rect, Path? clipPath, ImageConfiguration configuration) {
    bool flipHorizontally = false;
    if (_details.matchTextDirection) {
      assert(() {
        // We check this first so that the assert will fire immediately, not just
        // when the image is ready.
        if (configuration.textDirection == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('DecorationImage.matchTextDirection can only be used when a TextDirection is available.'),
            ErrorDescription(
              'When BoxDecorationImagePainter.paint() was called, there was no text direction provided '
              'in the ImageConfiguration object to match.',
            ),
            DiagnosticsProperty<DecorationImage>('The DecorationImage was', _details,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<ImageConfiguration>('The ImageConfiguration was', configuration,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (configuration.textDirection == TextDirection.rtl) flipHorizontally = true;
    }

    final ImageStream newImageStream = _details.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
        onError: _details.onError,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream!.addListener(listener);
    }
    if (_image == null) {
      if (DebugFlags.enableBackgroundLogs) {
        renderingLogger.finer('[Background] awaiting image load stream=${newImageStream.key} rect=$rect');
      }
      return;
    }

    if (clipPath != null) {
      canvas.save();
      canvas.clipPath(clipPath);
    }
    // Prefer computed longhands. If they appear to be default (e.g., 0%/left)
    // but the author-specified shorthand exists, resolve from the raw shorthand
    // as a defensive fallback to avoid stale/default axes.
    CSSBackgroundPosition px = _backgroundPositionX;
    CSSBackgroundPosition py = _backgroundPositionY;
    bool _isDefault(CSSBackgroundPosition p) =>
        p.length == null && p.calcValue == null && (p.percentage ?? -1) == -1;
    final String rawPos = _renderStyle.target.style.getPropertyValue(BACKGROUND_POSITION);
    if (rawPos.isNotEmpty && (_isDefault(px) || _isDefault(py))) {
      try {
        final List<String> pair = CSSPosition.parsePositionShorthand(rawPos);
        final CSSBackgroundPosition ax = CSSPosition.resolveBackgroundPosition(
            pair[0], _renderStyle, BACKGROUND_POSITION_X, true);
        final CSSBackgroundPosition ay = CSSPosition.resolveBackgroundPosition(
            pair[1], _renderStyle, BACKGROUND_POSITION_Y, false);
        if (_isDefault(px)) px = ax;
        if (_isDefault(py)) py = ay;
        if (DebugFlags.enableBackgroundLogs) {
          renderingLogger.finer('[Background] fallback axes from shorthand: raw="$rawPos" -> '
              'x=${ax.cssText()} y=${ay.cssText()}');
        }
      } catch (_) {}
    }

    _paintImage(
      painterRef: null,
      canvas: canvas,
      rect: rect,
      image: _image!.image,
      debugImageLabel: _image!.debugLabel,
      scale: _details.scale * _image!.scale,
      colorFilter: _details.colorFilter,
      positionX: px,
      positionY: py,
      backgroundSize: _backgroundSize,
      centerSlice: _details.centerSlice,
      repeat: _details.repeat,
      flipHorizontally: flipHorizontally,
      filterQuality: FilterQuality.low,
    );

    if (clipPath != null) canvas.restore();
  }

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value) return;
    if (_image != null && _image!.isCloneOf(value)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    if (DebugFlags.enableBackgroundLogs) {
      renderingLogger.finer('[Background] image stream delivered (sync=$synchronousCall) size=${value.image.width}x${value.image.height}');
    }
    if (!synchronousCall) _onChanged();
  }

  /// Releases the resources used by this painter.
  ///
  /// This should be called whenever the painter is no longer needed.
  ///
  /// After this method has been called, the object is no longer usable.
  @mustCallSuper
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(
      _handleImage,
      onError: _details.onError,
    ));
    _image?.dispose();
    _image = null;
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'BoxDecorationImagePainter')}(stream: $_imageStream, image: $_image) for $_details';
  }
}

// Used by [paintImage] to report image sizes drawn at the end of the frame.
Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

// [ImageSizeInfo]s that were reported on the last frame.
//
// Used to prevent duplicative reports from frame to frame.
Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

// Paints an image into the given rectangle on the canvas.
// Forked from flutter with parameter customization of _paintImage method:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L419
// Add positionX and positionY parameter to add the ability to specify absolute position of background image.
void _paintImage({
  BoxDecorationPainter? painterRef,
  required Canvas canvas,
  required Rect rect,
  required ui.Image image,
  String? debugImageLabel,
  double scale = 1.0,
  ColorFilter? colorFilter,
  required CSSBackgroundPosition positionX,
  required CSSBackgroundPosition positionY,
  required CSSBackgroundSize backgroundSize,
  Rect? centerSlice,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  bool flipHorizontally = false,
  bool invertColors = false,
  FilterQuality filterQuality = FilterQuality.low,
  bool isAntiAlias = false,
}) {
  assert(
    image.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
    'Cannot paint an image that is disposed.\n'
    'The caller of paintImage is expected to wait to dispose the image until '
    'after painting has completed.',
  );
  if (rect.isEmpty) return;
  Size outputSize = rect.size;
  double imageWidth = image.width.toDouble();
  double imageHeight = image.height.toDouble();
  Size inputSize = Size(imageWidth, imageHeight);
  double aspectRatio = imageWidth / imageHeight;
  Offset? sliceBorder;
  if (centerSlice != null) {
    sliceBorder = inputSize / scale - centerSlice.size as Offset;
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder * scale as Size;
  }
  BoxFit? fit = backgroundSize.fit;

  Size sourceSize = inputSize;
  Size destinationSize = outputSize;

  CSSLengthValue? backgroundWidth = backgroundSize.width;
  CSSLengthValue? backgroundHeight = backgroundSize.height;

  // Only background width is set, eg `100px`, `100px auto`.
  if (backgroundWidth != null &&
      !backgroundWidth.isAuto &&
      backgroundWidth.computedValue > 0 &&
      (backgroundHeight == null || backgroundHeight.isAuto)) {
    double width = backgroundWidth.computedValue;
    double height = width / aspectRatio;
    destinationSize = Size(width, height);

    // Only background height is set, eg `auto 100px`.
  } else if (backgroundWidth != null &&
      backgroundWidth.isAuto &&
      backgroundHeight != null &&
      !backgroundHeight.isAuto &&
      backgroundHeight.computedValue > 0) {
    double height = backgroundHeight.computedValue;
    double width = height * aspectRatio;
    destinationSize = Size(width, height);

    // Both background width and height are set, eg `100px 100px`.
  } else if (backgroundWidth != null &&
      !backgroundWidth.isAuto &&
      backgroundWidth.computedValue > 0 &&
      backgroundHeight != null &&
      !backgroundHeight.isAuto &&
      backgroundHeight.computedValue > 0) {
    double width = backgroundWidth.computedValue;
    double height = backgroundHeight.computedValue;
    destinationSize = Size(width, height);

    // Keyword values are set(contain|cover|auto), eg `contain`, `auto auto`.
  } else {
    // Default background-size: auto (no scaling). When fit is BoxFit.none and
    // both width/height are null, use the intrinsic image size as destination.
    if (fit == BoxFit.none && backgroundWidth == null && backgroundHeight == null) {
      destinationSize = inputSize; // draw at intrinsic size; clipping handled by clip rect
    } else {
      final FittedSizes fittedSizes = applyBoxFit(fit, inputSize / scale, outputSize);
      sourceSize = fittedSizes.source * scale;
      destinationSize = fittedSizes.destination;
    }
  }

  if (centerSlice != null) {
    outputSize += sliceBorder!;
    destinationSize += sliceBorder;
    // We don't have the ability to draw a subset of the image at the same time
    // as we apply a nine-patch stretch.
    assert(sourceSize == inputSize,
        'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.');
  }

  if (repeat != ImageRepeat.noRepeat && destinationSize == outputSize) {
    // There's no need to repeat the image because we're exactly filling the
    // output rect with the image.
    repeat = ImageRepeat.noRepeat;
  }
  final Paint paint = Paint()..isAntiAlias = isAntiAlias;
  if (colorFilter != null) paint.colorFilter = colorFilter;
  paint.filterQuality = filterQuality;
  paint.invertColors = invertColors;
  final double halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
  final double halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;

  // Provide layer destination size for percentage resolution inside calc().
  if (painterRef != null) {
    painterRef._currentLayerDestSizeForPercent = destinationSize;
  }

  // Use position as length type if specified in positionX/ positionY, otherwise use as percentage type.
  final double dx = positionX.calcValue != null
      ? positionX.calcValue!.computedValue(BACKGROUND_POSITION_X) ?? 0
      : positionX.length != null
          ? positionX.length!.computedValue
          : halfWidthDelta + (flipHorizontally ? -positionX.percentage! : positionX.percentage!) * halfWidthDelta;
  final double dy = positionY.calcValue != null
      ? positionY.calcValue!.computedValue(BACKGROUND_POSITION_Y) ?? 0
      : positionY.length != null
          ? positionY.length!.computedValue
          : halfHeightDelta + positionY.percentage! * halfHeightDelta;

  final Offset destinationPosition = rect.topLeft.translate(dx, dy);
  final Rect destinationRect = destinationPosition & destinationSize;
  if (DebugFlags.enableBackgroundLogs) {
    renderingLogger.finer('[Background] paintImage rect=$rect srcSize=$inputSize dstSize=$destinationSize '
        'dx=${dx.toStringAsFixed(2)} dy=${dy.toStringAsFixed(2)} destRect=$destinationRect '
        'posX=${positionX.cssText()} posY=${positionY.cssText()} fit=$backgroundSize');
  }
  // Clear override after computing offsets to avoid affecting unrelated callers.
  if (painterRef != null) {
    painterRef._currentLayerDestSizeForPercent = null;
  }

  // Set to true if we added a saveLayer to the canvas to invert/flip the image.
  bool invertedCanvas = false;
  // Output size and destination rect are fully calculated.
  if (!kReleaseMode) {
    final ImageSizeInfo sizeInfo = ImageSizeInfo(
      // Some ImageProvider implementations may not have given this.
      source: debugImageLabel ?? '<Unknown Image(${image.width}×${image.height})>',
      imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      displaySize: outputSize,
    );
    assert(() {
      if (debugInvertOversizedImages &&
          sizeInfo.decodedSizeInBytes > sizeInfo.displaySizeInBytes + debugImageOverheadAllowance) {
        final int overheadInKilobytes = (sizeInfo.decodedSizeInBytes - sizeInfo.displaySizeInBytes) ~/ 1024;
        final int outputWidth = outputSize.width.toInt();
        final int outputHeight = outputSize.height.toInt();
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'Image $debugImageLabel has a display size of '
              '$outputWidth×$outputHeight but a decode size of '
              '${image.width}×${image.height}, which uses an additional '
              '${overheadInKilobytes}KB.\n\n'
              'Consider resizing the asset ahead of time, supplying a cacheWidth '
              'parameter of $outputWidth, a cacheHeight parameter of '
              '$outputHeight, or using a ResizeImage.',
          library: 'painting library',
          context: ErrorDescription('while painting an image'),
        ));
        // Invert the colors of the canvas.
        canvas.saveLayer(
          destinationRect,
          Paint()
            ..colorFilter = const ColorFilter.matrix(<double>[
              -1,
              0,
              0,
              0,
              255,
              0,
              -1,
              0,
              0,
              255,
              0,
              0,
              -1,
              0,
              255,
              0,
              0,
              0,
              1,
              0,
            ]),
        );
        // Flip the canvas vertically.
        final double dy = -(rect.top + rect.height / 2.0);
        canvas.translate(0.0, -dy);
        canvas.scale(1.0, -1.0);
        canvas.translate(0.0, dy);
        invertedCanvas = true;
      }
      return true;
    }());
    // Avoid emitting events that are the same as those emitted in the last frame.
    if (!_lastFrameImageSizeInfo.contains(sizeInfo)) {
      final ImageSizeInfo? existingSizeInfo = _pendingImageSizeInfo[sizeInfo.source];
      if (existingSizeInfo == null || existingSizeInfo.displaySizeInBytes < sizeInfo.displaySizeInBytes) {
        _pendingImageSizeInfo[sizeInfo.source!] = sizeInfo;
      }
      debugOnPaintImage?.call(sizeInfo);
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        _lastFrameImageSizeInfo = _pendingImageSizeInfo.values.toSet();
        if (_pendingImageSizeInfo.isEmpty) {
          return;
        }
        _pendingImageSizeInfo = <String, ImageSizeInfo>{};
      });
    }
  }

  canvas.save();

  // Background image should never exceeds the boundary of its container.
  canvas.clipRect(rect);

  if (flipHorizontally) {
    final double dx = -(rect.left + rect.width / 2.0);
    canvas.translate(-dx, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.translate(dx, 0.0);
  }

  if (centerSlice == null) {
    final double halfWidthDelta = (inputSize.width - sourceSize.width) / 2.0;
    final double halfHeightDelta = (inputSize.height - sourceSize.height) / 2.0;
    // Always to draw image on 0 when position length type is specified.
    final Rect sourceRect = Rect.fromLTWH(
      positionX.calcValue != null
          ? 0
          : positionX.length != null
              ? 0
              : halfWidthDelta + positionX.percentage! * halfWidthDelta,
      positionY.calcValue != null
          ? 0
          : positionY.length != null
              ? 0
              : halfHeightDelta + positionY.percentage! * halfHeightDelta,
      sourceSize.width,
      sourceSize.height,
    );

    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageRect(image, sourceRect, destinationRect, paint);
    } else {
      for (final Rect tileRect in _generateImageTileRects(rect, destinationRect, repeat))
        canvas.drawImageRect(image, sourceRect, tileRect, paint);
    }
  } else {
    canvas.scale(1 / scale);
    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageNine(image, _scaleRect(centerSlice, scale), _scaleRect(destinationRect, scale), paint);
    } else {
      for (final Rect tileRect in _generateImageTileRects(rect, destinationRect, repeat))
        canvas.drawImageNine(image, _scaleRect(centerSlice, scale), _scaleRect(tileRect, scale), paint);
    }
  }

  canvas.restore();

  if (invertedCanvas) {
    canvas.restore();
  }
}

// Forked from flutter with no modification:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L597
Iterable<Rect> _generateImageTileRects(Rect outputRect, Rect fundamentalRect, ImageRepeat repeat) sync* {
  int startX = 0;
  int startY = 0;
  int stopX = 0;
  int stopY = 0;
  final double strideX = fundamentalRect.width;
  final double strideY = fundamentalRect.height;

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatX) {
    startX = ((outputRect.left - fundamentalRect.left) / strideX).floor();
    stopX = ((outputRect.right - fundamentalRect.right) / strideX).ceil();
  }

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatY) {
    startY = ((outputRect.top - fundamentalRect.top) / strideY).floor();
    stopY = ((outputRect.bottom - fundamentalRect.bottom) / strideY).ceil();
  }

  for (int i = startX; i <= stopX; ++i) {
    for (int j = startY; j <= stopY; ++j) yield fundamentalRect.shift(Offset(i * strideX, j * strideY));
  }
}

// Forked from flutter with no modification:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L621
Rect _scaleRect(Rect rect, double scale) =>
    Rect.fromLTRB(rect.left * scale, rect.top * scale, rect.right * scale, rect.bottom * scale);
