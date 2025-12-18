/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: overridden_fields

import 'dart:core';

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';

// CSS Box Model: https://drafts.csswg.org/css-box-4/
mixin CSSBoxMixin on RenderStyle {
  final DecorationPosition decorationPosition = DecorationPosition.background;
  final ImageConfiguration imageConfiguration = ImageConfiguration.empty;

  CSSBoxDecoration? _cachedDecoration;

  @override
  void resetBoxDecoration() {
    _cachedDecoration = null;
  }

  /// What decoration to paint, should get value after layout.
  CSSBoxDecoration? get decoration {
    if (_cachedDecoration != null) return _cachedDecoration;

    List<Radius>? radius = this.borderRadius;
    List<BorderSide>? borderSides = this.borderSides;

    if (backgroundColor == null &&
        backgroundImage == null &&
        borderSides == null &&
        radius == null &&
        shadows == null) {
      return null;
    }

    Border? border;
    if (borderSides != null) {
      // Side read inorder left top right bottom.
      border = Border(left: borderSides[0], top: borderSides[1], right: borderSides[2], bottom: borderSides[3]);
    }

    BorderRadius? borderRadius;
    // Always compute a BorderRadius when radii exist. We will still avoid
    // passing it to Flutter's Border.paint when the border is non-uniform,
    // but backgrounds, shadows and overflow clipping can still use it.
    if (radius != null) {
      borderRadius = BorderRadius.only(
        topLeft: radius[0],
        topRight: radius[1],
        bottomRight: radius[2],
        bottomLeft: radius[3],
      );
      if (DebugFlags.enableBorderRadiusLogs) {
        try {
          final el = target;
          final nonUniform = border != null && !border.isUniform;
          final scope = nonUniform ? ' (bg/clip only; border non-uniform)' : '';
          renderingLogger.finer('[BorderRadius] apply in decoration for <${el.tagName.toLowerCase()}>$scope '
              'tl=(${radius[0].x.toStringAsFixed(2)},${radius[0].y.toStringAsFixed(2)}) '
              'tr=(${radius[1].x.toStringAsFixed(2)},${radius[1].y.toStringAsFixed(2)}) '
              'br=(${radius[2].x.toStringAsFixed(2)},${radius[2].y.toStringAsFixed(2)}) '
              'bl=(${radius[3].x.toStringAsFixed(2)},${radius[3].y.toStringAsFixed(2)})');
        } catch (_) {}
      }
    }

    Gradient? gradient = backgroundClip != CSSBackgroundBoundary.text ? backgroundImage?.gradient : null;
    if (gradient is BorderGradientMixin && border != null) {
      gradient.borderEdge = border.dimensions as EdgeInsets;
    }

    DecorationImage? decorationImage;
    ImageProvider? image = backgroundImage?.image;
    if (image != null) {
      decorationImage = DecorationImage(
        image: image,
        repeat: backgroundRepeat.imageRepeat(),
      );
    }

    final CSSBoxDecoration built = CSSBoxDecoration(
      boxShadow: shadows,
      color: gradient != null ? null : backgroundColor?.value, // FIXME: chrome will work with gradient and color.
      image: decorationImage,
      border: border,
      borderRadius: borderRadius,
      gradient: gradient,
    );



    return _cachedDecoration = built;
  }
}

class CSSBoxDecoration extends BoxDecoration {
  const CSSBoxDecoration({
    this.color,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
  }) : super(
            color: color,
            image: image,
            border: border,
            borderRadius: borderRadius,
            gradient: gradient,
            backgroundBlendMode: backgroundBlendMode,
            shape: shape);

  @override
  final Color? color;

  @override
  final DecorationImage? image;

  @override
  final BoxBorder? border;

  @override
  final BorderRadius? borderRadius;

  @override
  final List<WebFBoxShadow>? boxShadow;

  @override
  final Gradient? gradient;

  @override
  final BlendMode? backgroundBlendMode;

  @override
  final BoxShape shape;

  bool get hasBorderRadius => borderRadius != null && borderRadius != BorderRadius.zero;

  CSSBoxDecoration clone({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadius? borderRadius,
    List<WebFBoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
  }) {
    return CSSBoxDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      shape: shape ?? this.shape,
    );
  }
}
