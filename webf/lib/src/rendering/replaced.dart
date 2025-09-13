/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';

/// RenderBox of a replaced element whose content is outside the scope of the CSS formatting model,
/// such as an image or embedded document.
/// https://drafts.csswg.org/css-display/#replaced-element
class RenderReplaced extends RenderBoxModel with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderReplaced(CSSRenderStyle renderStyle) : super(renderStyle: renderStyle);

  @override
  BoxSizeType get widthSizeType {
    bool widthDefined = renderStyle.width.isNotAuto || renderStyle.minWidth.isNotAuto;
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  BoxSizeType get heightSizeType {
    bool heightDefined = renderStyle.height.isNotAuto || renderStyle.minHeight.isNotAuto;
    return heightDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  // Whether the renderObject of replaced element is in lazy rendering.
  // Set true when the renderObject is not rendered yet and set false after
  // the renderObject is rendered.
  bool _isInLazyRendering = false;
  bool get isInLazyRendering => _isInLazyRendering;
  set isInLazyRendering(bool value) {
    if (value != _isInLazyRendering) {
      _isInLazyRendering = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
  }

  @override
  void performLayout() {
    beforeLayout();

    if (child != null) {
      BoxConstraints childConstraints = contentConstraints!;

      double? width;
      double? height;
      bool hasFiniteWidth = false;
      bool hasFiniteHeight = false;

      // Only use computed values if they are finite; unresolved percentages compute to infinity.
      if (renderStyle.width.isNotAuto) {
        final double w = renderStyle.width.computedValue;
        if (w.isFinite) {
          width = w;
          hasFiniteWidth = true;
        }
      }
      if (renderStyle.height.isNotAuto) {
        final double h = renderStyle.height.computedValue;
        if (h.isFinite) {
          height = h;
          hasFiniteHeight = true;
        }
      }

      if (hasFiniteWidth && hasFiniteHeight) {
        childConstraints = childConstraints.tighten(width: width, height: height);
      } else if (hasFiniteWidth) {
        childConstraints = childConstraints.tighten(
          width: width,
          height: renderStyle.aspectRatio != null ? width! * renderStyle.aspectRatio! : null,
        );
      } else if (hasFiniteHeight) {
        childConstraints = childConstraints.tighten(
          width: renderStyle.aspectRatio != null ? height! * renderStyle.aspectRatio! : null,
          height: height,
        );
      }

      // Avoid passing unconstrained infinity to child render box. Clamp to viewport when unbounded.
      if (childConstraints.maxWidth == double.infinity || childConstraints.maxHeight == double.infinity) {
        final viewport = renderStyle.target.ownerDocument.viewport!.viewportSize;
        final double newMaxW = childConstraints.maxWidth.isFinite ? childConstraints.maxWidth : viewport.width;
        final double newMaxH = childConstraints.maxHeight.isFinite ? childConstraints.maxHeight : viewport.height;
        double newMinW = childConstraints.minWidth;
        double newMinH = childConstraints.minHeight;
        if (!newMinW.isFinite || newMinW > newMaxW) newMinW = 0;
        if (!newMinH.isFinite || newMinH > newMaxH) newMinH = 0;
        childConstraints = BoxConstraints(
          minWidth: newMinW,
          maxWidth: newMaxW,
          minHeight: newMinH,
          maxHeight: newMaxH,
        );
      }

      child!.layout(childConstraints, parentUsesSize: true);

      Size childSize = child!.size;

      setMaxScrollableSize(childSize);
      size = getBoxSize(childSize);

      minContentWidth = renderStyle.intrinsicWidth;
      minContentHeight = renderStyle.intrinsicHeight;

      // Cache CSS baselines for replaced elements (inline-level):
      // CSS baseline for replaced inline elements is the bottom border edge
      // (i.e., the border-box bottom). Margins are handled by the formatting
      // context and must NOT be included here.
      try {
        final double baseline = (boxSize?.height ?? size.height);
        setCssBaselines(first: baseline, last: baseline);
      } catch (_) {
        // Safeguard: never let baseline caching break layout.
      }

      didLayout();
    } else {
      performResize();
      dispatchResize(contentSize, boxSize ?? Size.zero);
    }
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
  }

  @override
  void performResize() {
    double width = 0, height = 0;
    final Size attempingSize = contentConstraints!.biggest;
    if (attempingSize.width.isFinite) {
      width = attempingSize.width;
    }
    if (attempingSize.height.isFinite) {
      height = attempingSize.height;
    }

    size = constraints!.constrain(Size(width, height));
    assert(size.isFinite);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    final cached = computeCssLastBaselineOf(baseline);
    if (cached != null) return cached;
    // Fallback to bottom border edge (border-box height) without margins.
    return (boxSize?.height ?? size.height);
  }

  // Removed legacy computeDistanceToBaseline(); use computeDistanceToActualBaseline instead.

  // Should not paint when renderObject is in lazy loading and not rendered yet.
  @override
  bool get shouldPaint => !_isInLazyRendering && super.shouldPaint;

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    // In lazy rendering, only paint intersection observer for triggering intersection change callback.
    if (_isInLazyRendering) {
      paintIntersectionObserver(context, offset, paintNothing);
    } else if (shouldPaint) {
      paintBoxModel(context, offset);
    }
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    offset += Offset(renderStyle.paddingLeft.computedValue, renderStyle.paddingTop.computedValue);

    offset +=
        Offset(renderStyle.effectiveBorderLeftWidth.computedValue, renderStyle.effectiveBorderTopWidth.computedValue);

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    if (!hasSize || child?.hasSize == false) return false;
    if (renderStyle.transformMatrix != null) {
      return hitTestIntrinsicChild(result, child, position!);
    }
    return super.hitTestChildren(result, position: position!);
  }

  @override
  void calculateBaseline() {
    double? baseline = child?.getDistanceToBaseline(TextBaseline.alphabetic);
    setCssBaselines(first: baseline, last: baseline);
  }
}

class RenderRepaintBoundaryReplaced extends RenderReplaced {
  RenderRepaintBoundaryReplaced(super.renderStyle);

  @override
  bool get isRepaintBoundary => true;
}
