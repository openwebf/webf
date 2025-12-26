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
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
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
    // Configure strut and text height behavior to honor CSS line-height.
    StrutStyle? strut;
    final lh = renderStyle.lineHeight;
    if (lh.type != CSSLengthType.NORMAL) {
      final double fs = renderStyle.fontSize.computedValue;
      if (fs.isFinite && fs > 0) {
        final double scaledFs = renderStyle.textScaler.scale(fs);
        final double multiple = lh.computedValue / fs;
        if (multiple.isFinite && multiple > 0) {
          final FontWeight weight = (renderStyle.boldText && renderStyle.fontWeight.index < FontWeight.w700.index)
              ? FontWeight.w700
              : renderStyle.fontWeight;
          strut = StrutStyle(
            fontSize: scaledFs,
            height: multiple,
            fontFamilyFallback: renderStyle.fontFamily,
            fontStyle: renderStyle.fontStyle,
            fontWeight: weight,
            // Minimum line-box height like CSS; allow expansion if content larger.
            forceStrutHeight: false,
          );
        }
      }
    }
    const TextHeightBehavior thb = TextHeightBehavior(
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      leadingDistribution: TextLeadingDistribution.even,
    );

    // Compute effective maxLines consistent with layout.
    final bool nowrap = renderStyle.whiteSpace == WhiteSpace.nowrap;
    final bool ellipsis = renderStyle.effectiveTextOverflow == TextOverflow.ellipsis;
    final int? effectiveMaxLines = renderStyle.lineClamp ?? (nowrap && ellipsis ? 1 : null);

    final tp = TextPainter(
      text: span,
      textAlign: renderStyle.textAlign,
      textDirection: renderStyle.direction,
      textScaler: renderStyle.textScaler,
      ellipsis: ellipsis ? '…' : null,
      maxLines: effectiveMaxLines, // honor line-clamp or nowrap+ellipsis
      strutStyle: strut,
      textHeightBehavior: thb,
    );
    tp.layout(minWidth: 0, maxWidth: maxWidth.isFinite ? maxWidth : double.infinity);
    return Size(tp.width, tp.height);
  }

  TextSpan _buildTextSpan() {
    // Phase I whitespace processing to approximate CSS behavior outside IFC
    String processed = WhitespaceProcessor.processPhaseOne(_data, renderStyle.whiteSpace);
    // CSS `white-space: nowrap` (and `pre`) forbid soft wrapping opportunities at
    // regular spaces. Flutter's line breaking treats U+0020 as a break opportunity,
    // so replace it with U+00A0 to match CSS behavior (while still allowing
    // explicit breaks such as <br> / newlines in `pre`).
    if (renderStyle.whiteSpace == WhiteSpace.nowrap || renderStyle.whiteSpace == WhiteSpace.pre) {
      processed = processed.replaceAll(' ', '\u00A0');
    }

    // Map CSS line-height to TextStyle.height multiplier
    final lh = renderStyle.lineHeight;
    final double? heightMultiple = lh.type == CSSLengthType.NORMAL
        ? null
        : (lh.type == CSSLengthType.EM
            ? lh.value
            : (() {
                final double fs = renderStyle.fontSize.computedValue;
                if (!fs.isFinite || fs <= 0) return null;
                return lh.computedValue / fs;
              })());

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
    _textPainter ??= TextPainter(text: span, textDirection: renderStyle.direction, textScaler: renderStyle.textScaler);
    // Determine effective maxLines based on CSS semantics:
    // - If line-clamp is set, use it directly.
    // - If white-space is nowrap and text-overflow resolves to ellipsis,
    //   enforce a single line to enable truncation with ellipsis.
    final bool nowrap = renderStyle.whiteSpace == WhiteSpace.nowrap;
    final bool wantsEllipsis = renderStyle.effectiveTextOverflow == TextOverflow.ellipsis;
    final int? effectiveMaxLines = renderStyle.lineClamp ?? (nowrap && wantsEllipsis ? 1 : null);

    // Configure strut and text height behavior to honor CSS line-height.
    final lh = renderStyle.lineHeight;
    StrutStyle? strut;
    if (lh.type != CSSLengthType.NORMAL) {
      final double fs = renderStyle.fontSize.computedValue;
      if (fs.isFinite && fs > 0) {
        final double scaledFs = renderStyle.textScaler.scale(fs);
        final double multiple = lh.computedValue / fs;
        if (multiple.isFinite && multiple > 0) {
          final FontWeight weight = (renderStyle.boldText && renderStyle.fontWeight.index < FontWeight.w700.index)
              ? FontWeight.w700
              : renderStyle.fontWeight;
          strut = StrutStyle(
            fontSize: scaledFs,
            height: multiple,
            fontFamilyFallback: renderStyle.fontFamily,
            fontStyle: renderStyle.fontStyle,
            fontWeight: weight,
            // Minimum line-box height like CSS; allow expansion if content larger.
            forceStrutHeight: false,
          );
        }
      }
    }
    const TextHeightBehavior thb = TextHeightBehavior(
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      leadingDistribution: TextLeadingDistribution.even,
    );

    _textPainter!
      ..text = span
      ..textAlign = renderStyle.textAlign
      ..textDirection = renderStyle.direction
      ..textScaler = renderStyle.textScaler
      ..ellipsis = (renderStyle.effectiveTextOverflow == TextOverflow.ellipsis) ? '…' : null
      ..maxLines = effectiveMaxLines
      ..strutStyle = strut
      ..textHeightBehavior = thb
      ..layout(
        // Use loose width to keep intrinsic sizing (shrink-to-fit) for
        // absolutely/fixed positioned auto-width content. Horizontal centering
        // will be handled in paint by offsetting within the available width.
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
    if (_data.isEmpty) {
      size = Size.zero;
      return;
    }

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
    // Apply horizontal alignment manually when painting within a bounded box.
    double dx = 0.0;
    if (_textPainter != null) {
      // Use the actual laid-out box width for alignment decisions.
      // Using constraints.maxWidth here can cause painting outside the allocated box
      // when maxWidth >> size.width (e.g., under RenderPositionedBox/Align).
      final double availableWidth = size.width.isFinite ? size.width : (_textPainter!.width);
      final double lineWidth = _textPainter!.width;
      TextAlign align = renderStyle.textAlign;
      if (align == TextAlign.start) {
        align = (renderStyle.direction == TextDirection.rtl) ? TextAlign.right : TextAlign.left;
      }
      switch (align) {
        case TextAlign.center:
          dx = (availableWidth - lineWidth) / 2.0;
          break;
        case TextAlign.right:
        case TextAlign.end:
          dx = (availableWidth - lineWidth);
          break;
        case TextAlign.justify:
        case TextAlign.left:
        case TextAlign.start:
          dx = 0.0;
          break;
      }
      if (dx.isNaN || !dx.isFinite) dx = 0.0;
    }

    _textPainter!.paint(context.canvas, offset + Offset(dx, 0));

    // Optional debug painting for text bounds/baseline when enabled globally.
    if (DebugFlags.debugPaintInlineLayoutEnabled) {
      final Paint outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF00AAFF);
      final Rect r = offset & size;
      context.canvas.drawRect(r, outline);
    }
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

  // Provide meaningful intrinsic sizes so IntrinsicWidth/Height can query text nodes
  // when they paint themselves outside an IFC (e.g., absolute/fixed positioned contexts).
  TextPainter _prepareIntrinsicTextPainter({double? maxWidth}) {
    final span = _buildTextSpan();
    // Respect CSS white-space/line-clamp/ellipsis in intrinsic measurement.
    final bool nowrap = renderStyle.whiteSpace == WhiteSpace.nowrap;
    final bool ellipsis = renderStyle.effectiveTextOverflow == TextOverflow.ellipsis;
    final int? effectiveMaxLines = renderStyle.lineClamp ?? (nowrap && ellipsis ? 1 : null);

    // Map CSS line-height to StrutStyle when explicit.
    final lh = renderStyle.lineHeight;
    StrutStyle? strut;
    if (lh.type != CSSLengthType.NORMAL) {
      final double fs = renderStyle.fontSize.computedValue;
      if (fs.isFinite && fs > 0) {
        final double scaledFs = renderStyle.textScaler.scale(fs);
        final double multiple = lh.computedValue / fs;
        if (multiple.isFinite && multiple > 0) {
          final FontWeight weight = (renderStyle.boldText && renderStyle.fontWeight.index < FontWeight.w700.index)
              ? FontWeight.w700
              : renderStyle.fontWeight;
          strut = StrutStyle(
            fontSize: scaledFs,
            height: multiple,
            fontFamilyFallback: renderStyle.fontFamily,
            fontStyle: renderStyle.fontStyle,
            fontWeight: weight,
            forceStrutHeight: false,
          );
        }
      }
    }

    final tp = TextPainter(
      text: span,
      textAlign: renderStyle.textAlign,
      textDirection: renderStyle.direction,
      textScaler: renderStyle.textScaler,
      ellipsis: ellipsis ? '…' : null,
      maxLines: effectiveMaxLines,
      strutStyle: strut,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
    tp.layout(minWidth: 0, maxWidth: maxWidth ?? double.infinity);
    return tp;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    // Min intrinsic for text approximates the width of the longest unbreakable piece.
    final tp = _prepareIntrinsicTextPainter();
    // TextPainter exposes minIntrinsicWidth/maxIntrinsicWidth metrics.
    return tp.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final tp = _prepareIntrinsicTextPainter();
    return tp.maxIntrinsicWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final tp = _prepareIntrinsicTextPainter(maxWidth: width.isFinite ? width : double.infinity);
    return tp.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final tp = _prepareIntrinsicTextPainter(maxWidth: width.isFinite ? width : double.infinity);
    return tp.height;
  }

}
