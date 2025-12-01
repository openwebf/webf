/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderPortalsParentData extends RenderLayoutParentData {}

class RenderEventListener extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderEventListener({required CSSRenderStyle renderStyle, required this.controller, required bool hasEvent})
      : _enableEvent = hasEvent,
        super(renderStyle: renderStyle) {
    if (hasEvent) {
      _gestureDispatcher = GestureDispatcher(renderStyle.target);
    }
  }

  bool _enableEvent = false;

  bool get enableEvent => _enableEvent;

  void disabledEventCapture() {
    _enableEvent = false;
    _gestureDispatcher = null;
  }

  void enableEventCapture() {
    _enableEvent = true;
    _gestureDispatcher = GestureDispatcher(renderStyle.target);
  }

  WebFController controller;

  GestureDispatcher? _gestureDispatcher;

  GestureDispatcher? get gestureDispatcher => _gestureDispatcher;

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final BoxParentData childParentData = child.parentData as BoxParentData;
    transform.translate(childParentData.offset.dx, childParentData.offset.dy);
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    parent?.markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeCssFirstBaseline();
  }

  @override
  bool get hasOverrideContentLogicalWidth => (child as RenderBoxModel).hasOverrideContentLogicalWidth;
  @override
  set hasOverrideContentLogicalWidth(value) {
    (child as RenderBoxModel).hasOverrideContentLogicalWidth = value;
  }

  @override
  bool get hasOverrideContentLogicalHeight => (child as RenderBoxModel).hasOverrideContentLogicalHeight;
  @override
  set hasOverrideContentLogicalHeight(value) {
    (child as RenderBoxModel).hasOverrideContentLogicalHeight = value;
  }

  @override
  double get minContentWidth => (child as RenderBoxModel).minContentWidth;
  @override
  double get minContentHeight => (child as RenderBoxModel).minContentHeight;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderPortalsParentData) {
      child.parentData = RenderPortalsParentData();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('hasEvent', _enableEvent));
  }


  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) {
      return false;
    }

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    bool isHit = result.addWithPaintOffset(offset: childParentData.offset, position: position, hitTest: (result, position) {
      // addWithPaintOffset is to add an offset to the child node, the calculation itself does not need to bring an offset.
      if (child!.hitTest(result, position: position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    });
    return isHit;
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
  void performLayout() {
    size = (child?..layout(constraints, parentUsesSize: true))?.size
        ?? computeSizeForNoChild(constraints);

    calculateBaseline();
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // Set the size of scrollable overflow area for Portal.
    if (child is RenderBoxModel) {
      scrollableSize = (child as RenderBoxModel).scrollableSize;
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    _gestureDispatcher?.handlePointerEvent(event);
  }

  @override
  void calculateBaseline() {
    double? childBase = child?.getDistanceToBaseline(TextBaseline.alphabetic);
    // Convert child's local baseline to this wrapper's coordinate system
    if (childBase != null && child is RenderBox) {
      final BoxParentData pd = (child as RenderBox).parentData as BoxParentData;
      childBase += pd.offset.dy;
    }
    setCssBaselines(first: childBase, last: childBase);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    // Intentionally do NOT call super (RenderBoxModel) here.
    // Applying WebFAccessibility semantics at both this wrapper and the inner
    // layout box causes duplicate announcements (e.g., label text read twice).
    // Delegate semantics to the child render box and keep this wrapper
    // transparent to the semantics tree.
    config.isSemanticBoundary = false;
  }
}

class RenderTouchEventListener extends RenderEventListener {
  RenderTouchEventListener({required super.renderStyle, required super.controller, required super.hasEvent});

  final RawPointerListener rawPointerListener = RawPointerListener();

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    rawPointerListener.handleEvent(renderStyle.target, event);
  }
}
