/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
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

  // Replaced elements provide atomic intrinsic sizes derived from
  // specified width/height, intrinsic sizes, and aspect-ratio.
  @override
  double computeMinIntrinsicWidth(double height) {
    double content = 0.0;
    // 1) Specified width wins if non-auto and finite.
    if (renderStyle.width.isNotAuto) {
      final double w = renderStyle.width.computedValue;
      if (w.isFinite && w > 0) content = w;
    } else {
      // 2) Use aspect-ratio with given height when available.
      final double? ratio = renderStyle.aspectRatio;
      if (ratio != null && height.isFinite && height > 0) {
        content = height * ratio;
      }
      // 3) Fall back to intrinsic width if known.
      if (content == 0.0 && renderStyle.intrinsicWidth.isFinite && renderStyle.intrinsicWidth > 0) {
        content = renderStyle.intrinsicWidth;
      }
      // 4) Respect min/max-width from style if present.
      if (renderStyle.minWidth.isNotAuto) {
        content = content < renderStyle.minWidth.computedValue ? renderStyle.minWidth.computedValue : content;
      }
      if (renderStyle.maxWidth.isNotNone) {
        content = content > renderStyle.maxWidth.computedValue ? renderStyle.maxWidth.computedValue : content;
      }
    }
    final double padding = (renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    return content + padding + border;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double content = 0.0;
    if (renderStyle.height.isNotAuto) {
      final double h = renderStyle.height.computedValue;
      if (h.isFinite && h > 0) content = h;
    } else {
      final double? ratio = renderStyle.aspectRatio;
      if (ratio != null && width.isFinite && width > 0) {
        content = width / ratio;
      }
      if (content == 0.0 && renderStyle.intrinsicHeight.isFinite && renderStyle.intrinsicHeight > 0) {
        content = renderStyle.intrinsicHeight;
      }
      if (renderStyle.minHeight.isNotAuto) {
        content = content < renderStyle.minHeight.computedValue ? renderStyle.minHeight.computedValue : content;
      }
      if (renderStyle.maxHeight.isNotNone) {
        content = content > renderStyle.maxHeight.computedValue ? renderStyle.maxHeight.computedValue : content;
      }
    }
    final double padding = (renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // For replaced elements, min/max intrinsic widths are the same preferred width
    // derived from specified size, aspect-ratio, or intrinsic width when available.
    return computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
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
      // Only use computed values if they are finite; unresolved percentages compute to infinity.
      if (renderStyle.width.isNotAuto) {
        final double w = renderStyle.width.computedValue;
        if (w.isFinite) width = w;
      }
      if (renderStyle.height.isNotAuto) {
        final double h = renderStyle.height.computedValue;
        if (h.isFinite) height = h;
      }

      // Clamp specified sizes to the available constraints first (includes max-width/min-width from style).
      if (width != null) {
        width = width.clamp(childConstraints.minWidth, childConstraints.maxWidth);
      }
      if (height != null) {
        height = height.clamp(childConstraints.minHeight, childConstraints.maxHeight);
      }

      // Apply aspect-ratio and constraint-driven sizing when only one or neither dimension is specified.
      final double? ratio = renderStyle.aspectRatio;
      if (width != null && height != null) {
        childConstraints = childConstraints.tighten(width: width, height: height);
      } else if (width != null) {
        final double? h = ratio != null ? (width / ratio) : null;
        final double? clampedH = h?.clamp(childConstraints.minHeight, childConstraints.maxHeight);
        childConstraints = childConstraints.tighten(width: width, height: clampedH);
      } else if (height != null) {
        final double? w = ratio != null ? (height * ratio) : null;
        final double? clampedW = w?.clamp(childConstraints.minWidth, childConstraints.maxWidth);
        childConstraints = childConstraints.tighten(width: clampedW, height: height);
      } else if (ratio != null) {
        // Both width and height are auto; resolve via aspect-ratio and constraints.
        final double loW = childConstraints.minWidth.isFinite ? childConstraints.minWidth : 0.0;
        final double hiW = childConstraints.maxWidth.isFinite ? childConstraints.maxWidth : double.infinity;
        final double loH = childConstraints.minHeight.isFinite ? childConstraints.minHeight : 0.0;
        final double hiH = childConstraints.maxHeight.isFinite ? childConstraints.maxHeight : double.infinity;

        final bool hasWidthDef = loW > 0 || hiW.isFinite;
        final bool hasHeightDef = loH > 0 || hiH.isFinite;

        double? usedW;
        double? usedH;

        if (hasWidthDef || !hasHeightDef) {
          // Prefer width-driven when width has a definite constraint (e.g., min-width) or height does not.
          double w0 = renderStyle.intrinsicWidth.isFinite && renderStyle.intrinsicWidth > 0
              ? renderStyle.intrinsicWidth
              : 0.0;
          // Satisfy min/max width constraints; if intrinsic is below min, take min.
          w0 = w0.clamp(loW, hiW);
          if (w0 <= 0 && loW > 0) w0 = loW;
          // Derive height from ratio and clamp.
          double hFromW = w0 / ratio;
          double h1 = hFromW.clamp(loH, hiH);
          // If clamping height changed the ratio, recompute width to preserve ratio within constraints.
          double w1 = (h1 * ratio).clamp(loW, hiW);
          usedW = w1;
          usedH = h1;
        } else {
          // Height-driven when only height has a definite constraint.
          double h0 = renderStyle.intrinsicHeight.isFinite && renderStyle.intrinsicHeight > 0
              ? renderStyle.intrinsicHeight
              : 0.0;
          h0 = h0.clamp(loH, hiH);
          if (h0 <= 0 && loH > 0) h0 = loH;
          double wFromH = h0 * ratio;
          double w1 = wFromH.clamp(loW, hiW);
          double h1 = (w1 / ratio).clamp(loH, hiH);
          usedW = w1;
          usedH = h1;
        }

        if (usedW > 0 && usedH > 0) {
          childConstraints = childConstraints.tighten(width: usedW, height: usedH);
        }
      }

      // Avoid passing totally unconstrained constraints to child render box.
      // Historically we clamped both axes to the viewport which caused <img> with unknown
      // intrinsic height to temporarily take the full viewport height (e.g., 640px) before
      // the image loaded, breaking baseline alignment in flex containers.
      //
      // Fix: Only clamp the max-width to the viewport when unbounded. Keep max-height
      // unbounded so replaced elements without a resolved height/aspect-ratio don't
      // inherit the viewport height during initial layout. This lets them size to 0
      // (or to their intrinsic defaults once available) instead of stretching cross-axis.
      if (childConstraints.maxWidth == double.infinity || childConstraints.maxHeight == double.infinity) {
        final viewport = renderStyle.target.ownerDocument.viewport!.viewportSize;

        final double resolvedMaxW = childConstraints.maxWidth.isFinite ? childConstraints.maxWidth : viewport.width;
        // Preserve unbounded maxHeight to avoid using viewport height as a fallback.
        final double resolvedMaxH = childConstraints.maxHeight.isFinite ? childConstraints.maxHeight : double.infinity;

        double resolvedMinW = childConstraints.minWidth;
        double resolvedMinH = childConstraints.minHeight;
        if (!resolvedMinW.isFinite || resolvedMinW > resolvedMaxW) resolvedMinW = 0;
        // When maxHeight is unbounded, ensure minHeight is not greater than it and remains finite.
        if (!resolvedMinH.isFinite || (!resolvedMaxH.isFinite && resolvedMinH > 0) || (resolvedMaxH.isFinite && resolvedMinH > resolvedMaxH)) {
          resolvedMinH = 0;
        }

        childConstraints = BoxConstraints(
          minWidth: resolvedMinW,
          maxWidth: resolvedMaxW,
          minHeight: resolvedMinH,
          maxHeight: resolvedMaxH,
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

    size = constraints.constrain(Size(width, height));
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
