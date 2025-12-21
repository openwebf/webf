/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

class RenderLayoutBoxWrapper extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderLayoutBoxWrapper({
    required super.renderStyle,
  });

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    // Intentionally do NOT call super (RenderBoxModel) here.
    // This wrapper exists only to adapt layout constraints (e.g. for Scrollable
    // and ListView contexts). Applying WebFAccessibility semantics here would
    // duplicate the semantics produced by the real element render box inside.
    config.isSemanticBoundary = false;
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeCssFirstBaseline();
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final BoxParentData childParentData = child.parentData as BoxParentData;
    transform.translate(childParentData.offset.dx, childParentData.offset.dy);
  }

  @override
  void performLayout() {
    renderStyle.computeContentBoxLogicalWidth();
    renderStyle.computeContentBoxLogicalHeight();

    // Do NOT call super.performLayout() (RenderProxyBoxMixin) because it would
    // pass our tight ListView constraints to the child, forcing it to expand.
    // Instead, lay out the child with its own CSS-derived constraints.
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.constrain(Size.zero);
      initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
      return;
    }

    BoxConstraints childConstraints;
    if (c is RenderBoxModel) {
      // Compute constraints from the child's CSS, isolating it from wrapper tightness.
      childConstraints = c.getConstraints();
      // Deflate wrapper padding/border aren’t relevant here; the child’s own
      // CSS logic already accounts for its padding/border.
    } else if (c is RenderTextBox) {
      // Text nodes inside wrappers should measure themselves with a sensible bound.
      final double maxW = constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity;
      final double maxH = constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity;
      childConstraints = BoxConstraints(minWidth: 0, maxWidth: maxW, minHeight: 0, maxHeight: maxH);
    } else {
      // Fallback: provide loose, unbounded constraints so inner WebF render boxes
      // can compute their own CSS-based constraints without being forced to expand.
      childConstraints = const BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
      );
    }

    // Intersect child's CSS-derived constraints with the wrapper's incoming constraints.
    // This allows outer layout (e.g., flex) to enforce a definite inline/cross size.
    // Without this, the wrapper would ignore tight sizes from its parent and the
    // inner WebF render boxes would keep unbounded widths.
    BoxConstraints intersect(BoxConstraints a, BoxConstraints b) {
      double minW = math.max(a.minWidth, b.minWidth);
      double minH = math.max(a.minHeight, b.minHeight);
      double maxW = a.maxWidth;
      double maxH = a.maxHeight;
      if (b.hasBoundedWidth) {
        maxW = math.min(a.maxWidth, b.maxWidth);
      }
      if (b.hasBoundedHeight) {
        maxH = math.min(a.maxHeight, b.maxHeight);
      }
      if (minW > maxW) minW = maxW;
      if (minH > maxH) minH = maxH;
      return BoxConstraints(minWidth: minW, maxWidth: maxW, minHeight: minH, maxHeight: maxH);
    }

    childConstraints = intersect(childConstraints, constraints);

    c.layout(childConstraints, parentUsesSize: true);

    if (c is RenderBoxModel) {
      // For list-like widget containers (ListView children), sibling margin
      // collapsing must be handled within each wrapped item since the parent
      // is a Flutter RenderObject that doesn't implement CSS collapsing.
      // Use sibling-oriented collapsed margins so the inter-item spacing equals
      // the CSS collapsed result between previous bottom and current top.
      final double childMarginTop = renderStyle.collapsedMarginTopForSibling;
      final double childMarginBottom = renderStyle.collapsedMarginBottomForSibling;
      final double childMarginLeft = renderStyle.marginLeft.computedValue;
      final double childMarginRight = renderStyle.marginRight.computedValue;

      // Scrollable size of the child’s content box
      final Size contentScrollable = c.renderStyle.isSelfScrollingContainer() ? c.size : c.scrollableSize;

      // Decide sizing based on list axis. In a horizontal list (unbounded width),
      // widen by left+right margins so gaps appear between items. In a vertical
      // list (unbounded height), increase height by top+bottom margins.
      final bool isHorizontalList = constraints.hasBoundedHeight && !constraints.hasBoundedWidth;
      final bool isVerticalList = constraints.hasBoundedWidth && !constraints.hasBoundedHeight;

      double wrapperWidth;
      double wrapperHeight;
      if (isHorizontalList) {
        wrapperWidth = contentScrollable.width + childMarginLeft + childMarginRight;
        // Height is tight from the viewport; still offset child by vertical margins below.
        wrapperHeight = constraints.hasBoundedHeight ? constraints.maxHeight : (contentScrollable.height + childMarginTop + childMarginBottom);
      } else if (isVerticalList) {
        wrapperWidth = constraints.hasBoundedWidth ? constraints.maxWidth : (contentScrollable.width + childMarginLeft + childMarginRight);
        wrapperHeight = contentScrollable.height + childMarginTop + childMarginBottom;
      } else {
        // Fallback (no tightness info): include both margins conservatively.
        wrapperWidth = contentScrollable.width + childMarginLeft + childMarginRight;
        wrapperHeight = contentScrollable.height + childMarginTop + childMarginBottom;
      }

      size = constraints.constrain(Size(wrapperWidth, wrapperHeight));

      if (renderStyle.isSelfPositioned() || renderStyle.isSelfStickyPosition()) {
        CSSPositionedLayout.applyPositionedChildOffset(this, c);
      } else {
        // Offset the child within the wrapper by its margins
        final Offset relativeOffset = Offset(childMarginLeft, childMarginTop);
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, c);
      }
    } else {
      // Non-RenderBoxModel child: just adopt its size vertically with margins=0.
      size = constraints.constrain(c.size);
    }

    calculateBaseline();
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }
    final BoxParentData childParentData = child.parentData as BoxParentData;
    context.paintChild(child, offset + childParentData.offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize || !contentVisibilityHitTest(result, position: position) || renderStyle.isVisibilityHidden) {
      return false;
    }

    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription("Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'),
            ErrorHint('If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription('Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());

    // Determine whether the hittest position is within the visible area of the node in scroll.
    if ((clipX || clipY) && !size.contains(position)) {
      return false;
    }

    if (child == null) {
      return false;
    }

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    bool isHit = result.addWithPaintOffset(offset: childParentData.offset, position: position, hitTest: (result, position) {
      // addWithPaintOffset is to add an offset to the child node, the calculation itself does not need to bring an offset.
      if (hasSize && hitTestChildren(result, position: position) || hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    });
    return isHit;
  }

  @override
  void calculateBaseline() {
    double? baseline = child?.getDistanceToBaseline(TextBaseline.alphabetic);
    setCssBaselines(first: baseline, last: baseline);
  }
}

class LayoutBoxWrapper extends SingleChildRenderObjectWidget {
  final dom.Element ownerElement;

  const LayoutBoxWrapper({super.key, required Widget child, required this.ownerElement}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBoxWrapper(renderStyle: ownerElement.renderStyle);
  }
}
