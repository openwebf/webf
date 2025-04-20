/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
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
  void markNeedsLayout() {
    super.markNeedsLayout();
    parent?.markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  @override
  double? computeDistanceToBaseline() {
    return renderStyle.attachedRenderBoxModel!.computeDistanceToBaseline();
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
  void performLayout() {
    super.performLayout();

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

    if (event is PointerDownEvent) {
      rawPointerListener.recordEventTarget(renderStyle.target);
    }
  }
}
