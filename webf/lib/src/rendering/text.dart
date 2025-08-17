/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';

class RenderTextBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(
    data, {
    required this.renderStyle,
  }) : _data = data;

  String _data;

  set data(String value) {
    _data = value;
  }

  String get data => _data;

  CSSRenderStyle renderStyle;

  @override
  void performResize() {
    // RenderTextNode participate parent IFC layout
    // Text nodes don't have their own size - they are measured and laid out by the parent's IFC
    size = constraints.constrain(Size.zero);
  }

  @override
  void performLayout() {
    // Layout any child if present (though text nodes typically don't have children)
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(Size.zero);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(false);
  }

  // Text node need hittest self to trigger scroll
  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return false;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    // Text nodes don't have their own baseline - it's managed by the parent's IFC
    return null;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    // Text nodes don't contribute to semantics directly - their content is handled by the parent's IFC
    config.isSemanticBoundary = false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // Don't visit children for semantics - text content is handled by parent's IFC
    // This prevents the semantics visitor from trying to access our layout when it's not ready
  }

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => false;
}
