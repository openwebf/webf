/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
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
    if (child.parentData is! RenderLayoutParentData) {
      if (child is RenderBoxModel) {
        RenderLayoutParentData parentData = RenderLayoutParentData();
        child.parentData = CSSPositionedLayout.getPositionParentData(child, parentData);
      } else {
        child.parentData = RenderLayoutParentData();
      }
    }
  }

  @override
  void performLayout() {
    beforeLayout();

    if (child != null) {
      // To maximum compact with Flutter, We needs to limit the maxWidth and maxHeight constraints to
      // the viewportSize, as same as the MaterialApp does.
      Size viewportSize = renderStyle.target.ownerDocument.viewport!.viewportSize;
      BoxConstraints childConstraints = contentConstraints!;
      if (renderStyle.target.renderObjectManagerType == RenderObjectManagerType.FLUTTER_ELEMENT) {
        childConstraints = BoxConstraints(
          minWidth: childConstraints.minWidth,
          maxWidth: math.min(viewportSize.width, childConstraints.maxWidth),
          minHeight: childConstraints.minHeight,
          maxHeight: math.min(viewportSize.height, childConstraints.maxHeight)
        );
      }

      child!.layout(childConstraints, parentUsesSize: true);

      Size childSize = child!.size;

      setMaxScrollableSize(childSize);
      size = getBoxSize(childSize);

      minContentWidth = renderStyle.intrinsicWidth;
      minContentHeight = renderStyle.intrinsicHeight;

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
    final Size attempingSize = constraints.biggest;
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
    return computeDistanceToBaseline();
  }

  /// Compute distance to baseline of replaced element
  @override
  double computeDistanceToBaseline() {
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;

    // Use margin-bottom as baseline if layout has no children
    return marginTop + boxSize!.height + marginBottom;
  }

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

  RenderRepaintBoundaryReplaced toRepaintBoundaryReplaced() {
    RenderObject? childRenderObject = child;
    child = null;
    RenderRepaintBoundaryReplaced newChild = RenderRepaintBoundaryReplaced(renderStyle);
    newChild.child = childRenderObject as RenderBox?;
    return copyWith(newChild);
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
  T copyWith<T extends RenderBoxModel>(T copiedRenderBoxModel) {
    final renderObject = super.copyWith(copiedRenderBoxModel) as RenderReplaced;
    renderObject._isInLazyRendering = _isInLazyRendering;
    return renderObject as T;
  }
}

class RenderRepaintBoundaryReplaced extends RenderReplaced {
  RenderRepaintBoundaryReplaced(CSSRenderStyle renderStyle) : super(renderStyle);

  @override
  bool get isRepaintBoundary => true;

  RenderReplaced toReplaced() {
    RenderObject? childRenderObject = child;
    child = null;
    RenderReplaced newChild = RenderReplaced(renderStyle);
    newChild.child = childRenderObject as RenderBox?;
    return copyWith(newChild);
  }
}
