/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'package:flutter/foundation.dart';
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

  bool get paintsSelf {
    // Defer painting when this text participates in an ancestor inline
    // formatting context (IFC). But if we are inside an out-of-flow positioned
    // ancestor (absolute/fixed), that subtree does not participate in the
    // ancestor's IFC and we should paint ourselves.
    RenderObject? p = parent;
    while (p != null) {
      if (p is RenderBoxModel) {
        final pos = p.renderStyle.position;
        if (pos == CSSPositionType.absolute || pos == CSSPositionType.fixed) {
          // Out-of-flow positioned subtree: text paints itself.
          return true;
        }
      }
      if (p is RenderFlowLayout) {
        if (p.establishIFC) {
          // Ancestor IFC paints inline text; avoid self painting.
          return false;
        }
        // Otherwise, continue searching upward for an establishing IFC.
      }
      p = p.parent;
    }
    // No ancestor IFC found; paint ourselves.
    return true;
  }
  
  bool get _paintsSelf => paintsSelf;

  // Measure the full text size for a given available width without being clipped by
  // the parent's height constraints. This is used by scroll container sizing to
  // determine scrollable overflow, especially when the parent does not establish IFC.
  Size computeFullTextSizeForWidth(double maxWidth) {
    // Reuse span building to keep style consistent with actual painting.
    final span = _buildTextSpan();
    final tp = TextPainter(
      text: span,
      textAlign: renderStyle.textAlign,
      textDirection: renderStyle.direction,
      ellipsis: (renderStyle.effectiveTextOverflow == TextOverflow.ellipsis) ? '…' : null,
      maxLines: renderStyle.lineClamp, // honor line-clamp if any
    );
    tp.layout(minWidth: 0, maxWidth: maxWidth.isFinite ? maxWidth : double.infinity);
    return Size(tp.width, tp.height);
  }

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
    // Determine effective maxLines based on CSS semantics:
    // - If line-clamp is set, use it directly.
    // - If white-space is nowrap and text-overflow resolves to ellipsis,
    //   enforce a single line to enable truncation with ellipsis.
    final bool nowrap = renderStyle.whiteSpace == WhiteSpace.nowrap;
    final bool wantsEllipsis = renderStyle.effectiveTextOverflow == TextOverflow.ellipsis;
    final int? effectiveMaxLines = renderStyle.lineClamp ?? (nowrap && wantsEllipsis ? 1 : null);

    _textPainter!
      ..text = span
      ..textAlign = renderStyle.textAlign
      ..textDirection = renderStyle.direction
      ..ellipsis = (renderStyle.effectiveTextOverflow == TextOverflow.ellipsis) ? '…' : null
      ..maxLines = effectiveMaxLines
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
