/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

/// RenderBox of a widget element whose content is rendering by Flutter Widgets.
class RenderWidget extends RenderBoxModel
    with ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderWidget({required super.renderStyle});

  // Cache sticky children to calculate the base offset of sticky children
  final Set<RenderBoxModel> stickyChildren = {};

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

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
  }

  void _layoutChild(RenderBox child) {
    // Ensure logical content sizes are computed from CSS before deriving constraints
    // so that explicit width/height (e.g. h-8) can be honored.
    renderStyle.computeContentBoxLogicalWidth();
    renderStyle.computeContentBoxLogicalHeight();

    // Base child constraints come from our content box constraints.
    // For inline-block with auto width, avoid clamping to the viewport so
    // children can determine natural width and we shrink-wrap accordingly.
    final bool isInlineBlockAutoWidth =
        renderStyle.effectiveDisplay == CSSDisplay.inlineBlock && renderStyle.width.isAuto;

    Size viewportSize = renderStyle.target.ownerDocument.viewport!.viewportSize;
    BoxConstraints childConstraints;
    if (isInlineBlockAutoWidth) {
      childConstraints = BoxConstraints(
        minWidth: contentConstraints!.minWidth,
        maxWidth: contentConstraints!.maxWidth,
        minHeight: contentConstraints!.minHeight,
        maxHeight: contentConstraints!.maxHeight,
      );
    } else {
      childConstraints = BoxConstraints(
          minWidth: contentConstraints!.minWidth,
          maxWidth: (contentConstraints!.hasTightWidth || (renderStyle.target as WidgetElement).allowsInfiniteWidth)
              ? contentConstraints!.maxWidth
              : math.min(viewportSize.width, contentConstraints!.maxWidth),
          minHeight: contentConstraints!.minHeight,
          maxHeight: (contentConstraints!.hasTightHeight || (renderStyle.target as WidgetElement).allowsInfiniteHeight)
              ? contentConstraints!.maxHeight
              : math.min(viewportSize.height, contentConstraints!.maxHeight));
    }

    // If an explicit CSS height is specified (non-auto), tighten the child's
    // constraints on the cross axis to that used content height, clamped
    // within our content constraints. This makes classes like `h-8` take effect
    // for RenderWidget containers within flex/flow contexts.
    // Note: contentBoxLogicalHeight is the content-box height (excluding padding/border).
    if (renderStyle.height.isNotAuto) {
      final double? logicalContentHeight = renderStyle.contentBoxLogicalHeight;
      if (logicalContentHeight != null && logicalContentHeight.isFinite) {
        // Clamp to the available content constraints to avoid exceeding parent limits.
        final double clampedHeight = logicalContentHeight
            .clamp(contentConstraints!.minHeight, contentConstraints!.maxHeight);
        childConstraints = childConstraints.tighten(height: clampedHeight);
      }
    }

    child.layout(childConstraints, parentUsesSize: true);

    Size childSize = child.size;

    setMaxScrollableSize(childSize);
    size = getBoxSize(childSize);

    minContentWidth = renderStyle.intrinsicWidth;
    minContentHeight = renderStyle.intrinsicHeight;

    _setChildrenOffset(child);
  }

  void _setChildrenOffset(RenderBox child) {
    double borderLeftWidth = renderStyle.borderLeftWidth?.computedValue ?? 0.0;
    double borderTopWidth = renderStyle.borderTopWidth?.computedValue ?? 0.0;

    double paddingLeftWidth = renderStyle.paddingLeft.computedValue;
    double paddingTopWidth = renderStyle.paddingTop.computedValue;

    Offset offset = Offset(borderLeftWidth + paddingLeftWidth, borderTopWidth + paddingTopWidth);
    // Apply position relative offset change.
    CSSPositionedLayout.applyRelativeOffset(offset, child);
  }

  // Compute painting order using CSS stacking categories:
  // negatives → normal-flow → positioned(auto/0) → positives.
  List<RenderBox> _computePaintingOrder() {
    if (childCount == 0) return const [];
    if (childCount == 1) return <RenderBox>[firstChild as RenderBox];

    List<RenderBox> normal = [];
    List<RenderBoxModel> negatives = [];
    List<RenderBoxModel> positionedAutoOrZero = [];
    List<RenderBoxModel> positives = [];

    visitChildren((RenderObject c) {
      if (c is RenderBoxModel) {
        final rs = c.renderStyle;
        final int? zi = rs.zIndex;
        final bool positioned = rs.position != CSSPositionType.static;
        if (zi != null && zi < 0) {
          negatives.add(c);
        } else if (zi != null && zi > 0) {
          positives.add(c);
        } else if (zi == 0) {
          positionedAutoOrZero.add(c);
        } else if (positioned && zi == null) {
          positionedAutoOrZero.add(c);
        } else {
          normal.add(c);
        }
      } else {
        normal.add(c as RenderBox);
      }
    });

    // Precompute DOM order index per item to minimize comparator work and allocations.
    final Map<RenderBoxModel, int> _domIndexMap = {};
    void _ensureDomIndex(RenderBoxModel m) {
      if (_domIndexMap.containsKey(m)) return;
      final el = m.renderStyle.target;
      final parent = el.parentElement;
      if (parent == null) {
        _domIndexMap[m] = 0;
        return;
      }
      int i = 0;
      for (final childEl in parent.children) {
        if (identical(childEl, el)) break;
        i++;
      }
      _domIndexMap[m] = i;
    }
    int _domIndex(RenderBoxModel m) {
      _ensureDomIndex(m);
      return _domIndexMap[m] ?? 0;
    }

    // Negative z-index first (ascending)
    negatives.sort((a, b) {
      final int az = a.renderStyle.zIndex ?? 0;
      final int bz = b.renderStyle.zIndex ?? 0;
      if (az != bz) return az.compareTo(bz);
      return _domIndex(a).compareTo(_domIndex(b));
    });

    // Positioned auto/0 by DOM order
    positionedAutoOrZero.sort((a, b) => _domIndex(a).compareTo(_domIndex(b)));

    // Positive z-index ascending
    positives.sort((a, b) {
      final int az = a.renderStyle.zIndex ?? 0;
      final int bz = b.renderStyle.zIndex ?? 0;
      if (az != bz) return az.compareTo(bz);
      return _domIndex(a).compareTo(_domIndex(b));
    });

    final List<RenderBox> ordered = [];
    ordered.addAll(negatives.cast<RenderBox>());
    ordered.addAll(normal);
    ordered.addAll(positionedAutoOrZero.cast<RenderBox>());
    ordered.addAll(positives.cast<RenderBox>());
    return ordered;
  }

  List<RenderBox>? _cachedPaintingOrder;

  List<RenderBox> get paintingOrder {
    _cachedPaintingOrder ??= _computePaintingOrder();
    return _cachedPaintingOrder!;
  }

  void markChildrenNeedsSort() {
    _cachedPaintingOrder = null;
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    _cachedPaintingOrder = null;
  }

  @override
  void remove(RenderBox child) {
    super.remove(child);
    _cachedPaintingOrder = null;
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child, after: after);
    _cachedPaintingOrder = null;
  }

  @override
  void performLayout() {
    beforeLayout();

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderBox> _nonPositionedChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
        _positionedChildren.add(child);
      } else {
        _nonPositionedChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          _stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    if (_nonPositionedChildren.isNotEmpty) {
      _layoutChild(_nonPositionedChildren.first);
    } else {
      performResize();
    }

    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
    }

    // // Calculate the offset of its sticky children.
    // for (RenderBoxModel stickyChild in stickyChildren) {
    //   CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
    // }

    calculateBaseline();
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
    didLayout();
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
    final cached = computeCssLastBaselineOf(baseline);
    if (cached != null) return cached;
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;
    // Use margin-bottom as baseline if layout has no children
    return computeCssFirstBaseline() ?? marginTop + boxSize!.height + marginBottom;
  }

  @override
  void dispose() {
    super.dispose();
    stickyChildren.clear();
  }

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    // Check if the widget element has disabled box model painting
    if (renderStyle.target is WidgetElement) {
      final widgetElement = renderStyle.target as WidgetElement;
      if (widgetElement.disableBoxModelPaint) {
        // Call performPaint directly without box model painting
        performPaint(context, offset);
        return;
      }
    }

    // Default behavior: paint with box model
    paintBoxModel(context, offset);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    // Report FCP/LCP when RenderWidget with contentful Flutter widget is first painted
    if (renderStyle.target is WidgetElement && firstChild != null && hasSize && !size.isEmpty) {
      final widgetElement = renderStyle.target as WidgetElement;

      // Check if the widget contains contentful content and get the actual visible area
      double contentfulArea = _getContentfulPaintArea(widgetElement);
      if (contentfulArea > 0) {
        // Report FP first (if not already reported)
        widgetElement.ownerDocument.controller.reportFP();
        widgetElement.ownerDocument.controller.reportFCP();

        // Report LCP candidate with the actual contentful area
        widgetElement.ownerDocument.controller.reportLCPCandidate(widgetElement, contentfulArea);
      }
    }

    for (final RenderBox child in paintingOrder) {
      if (isPositionPlaceholder(child)) continue;
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      if (child.hasSize) context.paintChild(child, offset + pd.offset);
    }
  }

  /// Gets the total visible area of contentful paint children.
  /// Returns 0 if no contentful paint is found.
  double _getContentfulPaintArea(WidgetElement widgetElement) {
    // Only check render objects created directly by the WidgetElement's state build() method
    // This uses a special method that skips any RenderBoxModel or RenderWidget children
    return ContentfulWidgetDetector.getContentfulPaintAreaFromFlutterWidget(firstChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    if (renderStyle.transformMatrix != null) {
      return hitTestIntrinsicChild(result, firstChild, position!);
    }

    RenderBox? child = lastChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);

          if (child is RenderBoxModel) {
            CSSPositionType positionType = child.renderStyle.position;
            if (positionType == CSSPositionType.fixed) {
              Offset totalScrollOffset = (this as RenderBoxModel).getTotalScrollOffset();
              transformed -= totalScrollOffset;
            }
          }

          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }

      child = childParentData.previousSibling;
    }

    return false;
  }

  @override
  void calculateBaseline() {
    // Baselines returned by children are relative to the child's local
    // coordinate system. RenderWidget paints its child offset by its own
    // border+padding; include that offset so cached CSS baselines are
    // relative to the RenderWidget's border box top (CSS expectation).
    double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    double paddingTop = renderStyle.paddingTop.computedValue;
    double topInset = borderTop + paddingTop;

    double? firstBaseline = firstChild?.getDistanceToBaseline(TextBaseline.alphabetic);
    double? lastBaseline = lastChild?.getDistanceToBaseline(TextBaseline.alphabetic);

    if (firstBaseline != null) firstBaseline += topInset;
    if (lastBaseline != null) lastBaseline += topInset;
    setCssBaselines(first: firstBaseline, last: lastBaseline);
  }
}

class RenderRepaintBoundaryWidget extends RenderWidget {
  RenderRepaintBoundaryWidget({required super.renderStyle});

  @override
  bool get isRepaintBoundary => true;
}
