/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:core';

import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
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
    // Flutter border radius only works when border is uniform.
    if (radius != null && (border == null || border.isUniform)) {
      borderRadius = BorderRadius.only(
        topLeft: radius[0],
        topRight: radius[1],
        bottomRight: radius[2],
        bottomLeft: radius[3],
      );
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

    if (kDebugMode && DebugFlags.enableCssLogs) {
      // Log the final decoration that will be used by box painters. When background-clip:text is set,
      // gradients are intentionally omitted from BoxDecoration (painted later by IFC), so this log helps
      // explain why no gradient/image is present here.
      cssLogger.fine('[background] build decoration: '
          'color=' + (built.color?.toString() ?? 'null') + ', '
          'image=' + (image != null ? backgroundImage?.cssText() ?? 'none' : 'none') + ', '
          'repeat=' + backgroundRepeat.cssText() + ', '
          'position=' + backgroundPositionX.cssText() + ' ' + backgroundPositionY.cssText() + ', '
          'size=' + backgroundSize.cssText() + ', '
          'clip=' + (backgroundClip?.cssText() ?? 'border-box'));
    }

    return _cachedDecoration = built;
  }
}

class CSSBoxDecoration extends BoxDecoration {
  CSSBoxDecoration({
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
