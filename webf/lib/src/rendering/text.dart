/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/box_model.dart';
import 'package:webf/src/css/whitespace_processor.dart';

class RenderTextBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(
    data, {
    required this.renderStyle,
  }) : _data = data;

  String _data;
  TextPainter? _textPainter;
  TextSpan? _cachedSpan;

  set data(String value) {
    if (_data == value) return;
    _data = value;
    // Text content changed. Since text boxes are measured and painted by the
    // parent's inline formatting context, notify the parent to relayout so the
    // paragraph gets rebuilt with the new text content.
    parent?.markNeedsLayout();
    // When not in IFC (no RenderBoxModel parent), we layout/paint ourselves.
    // Ensure we relayout to rebuild TextPainter metrics.
    markNeedsLayout();
    _cachedSpan = null;
    _textPainter = null;
  }

  String get data => _data;

  CSSRenderStyle renderStyle;

  bool get _paintsSelf => parent is! RenderFlowLayout;

  TextSpan _buildTextSpan() {
    // Phase I whitespace processing to approximate CSS behavior outside IFC
    final processed = WhitespaceProcessor.processPhaseOne(_data, renderStyle.whiteSpace);

    // Map CSS line-height to TextStyle.height multiplier
    final lh = renderStyle.lineHeight;
    final double? heightMultiple = lh.type == CSSLengthType.NORMAL
        ? null
        : (lh.type == CSSLengthType.EM
            ? lh.value
            : lh.computedValue / renderStyle.fontSize.computedValue);

    // Delegate span building to CSSTextMixin to keep styling consistent.
    _cachedSpan = CSSTextMixin.createTextSpan(
      processed,
      renderStyle,
      height: heightMultiple,
      oldTextSpan: _cachedSpan,
    );
    return _cachedSpan!;
  }

  void _layoutText(BoxConstraints constraints) {
    final span = _buildTextSpan();
    _textPainter ??= TextPainter(text: span, textDirection: renderStyle.direction);
    _textPainter!
      ..text = span
      ..textAlign = renderStyle.textAlign
      ..textDirection = renderStyle.direction
      ..ellipsis = (renderStyle.effectiveTextOverflow == TextOverflow.ellipsis) ? '…' : null
      ..maxLines = renderStyle.lineClamp
      ..layout(
        minWidth: constraints.minWidth.clamp(0.0, double.infinity),
        maxWidth: constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity,
      );
  }

  @override
  void performResize() {
    if (_paintsSelf) return; // sized by performLayout when self-painting
    // IFC: text nodes are measured/painted by parent IFC
    size = constraints.constrain(Size.zero);
  }

  @override
  void performLayout() {
    if (_paintsSelf) {
      _layoutText(constraints);
      final w = _textPainter?.width ?? 0.0;
      final h = _textPainter?.height ?? 0.0;
      size = constraints.constrain(Size(w, h));
    } else {
      // Layout any child if present (though text nodes typically don't have children)
      if (child != null) {
        child!.layout(constraints, parentUsesSize: true);
      }
    }
  }

  @override
  bool get sizedByParent => !_paintsSelf;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (_paintsSelf) {
      _layoutText(constraints);
      return constraints.constrain(Size(_textPainter?.width ?? 0.0, _textPainter?.height ?? 0.0));
    }
    return constraints.constrain(Size.zero);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_paintsSelf) return; // Participates in IFC; painted by parent
    if ((_textPainter == null) || (_textPainter!.text == null)) {
      _layoutText(constraints);
    }
    if (_textPainter == null) return;
    _textPainter!.paint(context.canvas, offset);
  }

  // Text node need hittest self to trigger scroll
  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    if (!_paintsSelf) {
      // Let parent IFC handle hit testing. Text nodes don't have their own boxes.
      return false;
    }
    if (position == null) return false;
    if (size.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
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
