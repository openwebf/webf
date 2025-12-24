/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

// Render object for <br>. When not inside an IFC (e.g., as a flex item),
// it contributes one line of vertical space equal to the computed line height.
class RenderBr extends RenderLayoutBox {
  RenderBr({required super.renderStyle});

  double _computeLineHeightPx() {
    // If an explicit line-height is provided and resolves to a pixel value, use it.
    final lh = renderStyle.lineHeight;
    if (lh.type != CSSLengthType.NORMAL) {
      final v = lh.computedValue;
      if (v.isFinite && v > 0) return v;
    }
    // Fallback: use font metrics via TextPainter for a realistic single line height.
    // Construct a TextSpan using CSS text mapping.
    final span = CSSTextMixin.createTextSpan(' ', renderStyle);
    final tp = TextPainter(text: span, textDirection: renderStyle.direction, textScaler: renderStyle.textScaler);
    tp.layout();
    return tp.height;
  }

  @override
  void performLayout() {
    beforeLayout();
    double lineHeight = _computeLineHeightPx();

    // In a row-direction flex container, <br> should not add horizontal space
    // nor increase cross size. Keep it zero-height in that scenario.
    final parentStyle = renderStyle.getAttachedRenderParentRenderStyle();
    if (parentStyle != null && parentStyle.isSelfRenderFlexLayout()) {
      if (CSSFlex.isHorizontalFlexDirection(parentStyle.flexDirection)) {
        lineHeight = 0;
      }
    }

    // BR contributes no intrinsic width; only vertical space of one line.
    // Compute final border-box size from a content box of (0, lineHeight)
    size = getBoxSize(Size(0, lineHeight));

    // No overflow beyond its own box.
    setMaxScrollableSize(Size(0, lineHeight));

    // BR has no text baseline of its own.
    setCssBaselines(first: null, last: null);
  }

  @override
  void calculateBaseline() {
  }
}
