import 'dart:math' as math;
import 'dart:ui' as ui
    show
        Paragraph,
        ParagraphBuilder,
        ParagraphStyle,
        ParagraphConstraints,
        PlaceholderAlignment,
        TextBox,
        TextPosition,
        LineMetrics,
        TextStyle,
        TextHeightBehavior,
        TextLeadingDistribution;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

import 'inline_item.dart';
import 'line_box.dart';
import 'inline_items_builder.dart';
import 'inline_layout_debugger.dart';

/// Debug flag to enable inline layout visualization.
/// When true, paints debug information for line boxes, margins, padding, etc.
///
/// To enable debug painting:
/// ```dart
/// import 'package:webf/rendering.dart';
///
/// // Enable debug paint
/// debugPaintInlineLayoutEnabled = true;
///
/// // Your WebF widget will now show debug visualizations
/// ```
///
/// Debug visualizations include:
/// - Green outline: Line box bounds
/// - Red line: Text baseline
/// - Blue outline: Text item bounds
/// - Magenta outline: Inline box bounds (span, etc.)
/// - Red semi-transparent fill: Left margin area
/// - Green semi-transparent fill: Right margin area
/// - Blue semi-transparent fill: Padding area
///
/// This is useful for debugging inline layout issues such as:
/// - Margin gaps not appearing correctly
/// - Text alignment problems
/// - Line box height calculations
/// - Padding and border rendering
bool debugPaintInlineLayoutEnabled = false;
bool debugLogInlineLayoutEnabled = false; // Enable verbose logging for paragraph-based IFC

/// Manages the inline formatting context for a block container.
/// Based on Blink's InlineNode.
class InlineFormattingContext {
  InlineFormattingContext({
    required this.container,
  });

  /// The block container that establishes this inline formatting context.
  final RenderLayoutBox container;

  /// The inline items in this formatting context.
  List<InlineItem> _items = [];

  List<InlineItem> get items => _items;

  /// The text content string.
  String _textContent = '';

  String get textContent => _textContent;

  /// Whether this context needs preparation.
  bool _needsCollectInlines = true;

  /// The line boxes created by layout.
  final List<LineBox> _lineBoxes = [];

  List<LineBox> get lineBoxes => _lineBoxes;

  // New: Paragraph-based layout artifacts
  ui.Paragraph? _paragraph;
  List<ui.LineMetrics> _paraLines = const [];
  // Track how many code units were added to the paragraph (text + placeholders)
  int _paraCharCount = 0;

  // Expose paragraph line metrics for baseline consumers
  List<ui.LineMetrics> get paragraphLineMetrics => _paraLines;

  // Placeholder boxes as reported by Paragraph, in the order placeholders were added.
  List<ui.TextBox> _placeholderBoxes = const [];

  // For mapping placeholder index -> RenderBox (atomic inline items only)
  final List<RenderBox?> _placeholderOrder = [];

  // Track all placeholders (atomic and extras) to synthesize boxes for empty spans
  final List<_InlinePlaceholder> _allPlaceholders = [];

  // For mapping inline element RenderBox -> range in paragraph text
  final Map<RenderBoxModel, (int start, int end)> _elementRanges = {};
  // Measured visual sizes (border-box) for inline render boxes (including wrappers)
  final Map<RenderBox, Size> _measuredVisualSizes = {};

  Size? measuredVisualSizeOf(RenderBox box) => _measuredVisualSizes[box];

  // Find the TextBox for a left-extras placeholder of a given inline element, if any.
  ui.TextBox? _leftExtraTextBoxFor(RenderBoxModel box) {
    for (int i = 0; i < _allPlaceholders.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind == _PHKind.leftExtra && ph.owner == box) {
        if (i < _placeholderBoxes.length) return _placeholderBoxes[i];
        break;
      }
    }
    return null;
  }

  bool _sameRect(ui.TextBox a, ui.TextBox b, [double eps = 0.5]) {
    return (a.left - b.left).abs() < eps && (a.top - b.top).abs() < eps &&
        (a.right - b.right).abs() < eps && (a.bottom - b.bottom).abs() < eps;
  }

  // Measure text metrics (height and baseline offset) for a given CSS text style
  // using the same text height behavior as the paragraph path.
  (double height, double baselineOffset) _measureTextMetricsForStyle(CSSRenderStyle rs) {
    final dir = (container as RenderBoxModel).renderStyle.direction;
    final mpb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textDirection: dir,
      textHeightBehavior: const ui.TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
        leadingDistribution: ui.TextLeadingDistribution.even,
      ),
      maxLines: 1,
    ));
    mpb.pushStyle(_uiTextStyleFromCssNoLineHeight(rs));
    mpb.addText('M');
    final mp = mpb.build();
    mp.layout(const ui.ParagraphConstraints(width: 1000000.0));
    final lines = mp.computeLineMetrics();
    if (lines.isNotEmpty) {
      final lm = lines.first;
      final double ascent = lm.ascent;
      final double descent = lm.descent;
      return (ascent + descent, ascent);
    }
    final double baseline = mp.alphabeticBaseline;
    final double ph = mp.height;
    if (ph.isFinite && ph > 0 && baseline.isFinite && baseline > 0) {
      return (ph, baseline);
    }
    final fs = rs.fontSize.computedValue;
    return (fs, fs * 0.8);
  }

  // Variant of _uiTextStyleFromCss that ignores CSS line-height (height multiple)
  // so we can measure pure font metrics (ascent+descent) for decoration bands.
  ui.TextStyle _uiTextStyleFromCssNoLineHeight(CSSRenderStyle rs) {
    final families = rs.fontFamily;
    if (families != null && families.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(families[0], rs.fontWeight, rs);
    }
    return ui.TextStyle(
      color: rs.backgroundClip != CSSBackgroundBoundary.text ? rs.color.value : null,
      decoration: rs.textDecorationLine,
      decorationColor: rs.textDecorationColor?.value,
      decorationStyle: rs.textDecorationStyle,
      fontWeight: rs.fontWeight,
      fontStyle: rs.fontStyle,
      textBaseline: CSSText.getTextBaseLine(),
      fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
      fontFamilyFallback: families,
      fontSize: rs.fontSize.computedValue,
      letterSpacing: rs.letterSpacing?.computedValue,
      wordSpacing: rs.wordSpacing?.computedValue,
      // height intentionally null to ignore CSS line-height
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
      shadows: rs.textShadow,
    );
  }

  // Map a paragraph TextBox to its line index (best overlap), or -1 if none.
  int _lineIndexForRect(ui.TextBox tb) {
    if (_paraLines.isEmpty) return -1;
    int best = -1;
    double bestOverlap = 0;
    for (int i = 0; i < _paraLines.length; i++) {
      final lm = _paraLines[i];
      final double lt = lm.baseline - lm.ascent;
      final double lb = lm.baseline + lm.descent;
      final double overlap = math.max(0, math.min(tb.bottom, lb) - math.max(tb.top, lt));
      if (overlap > bestOverlap) {
        bestOverlap = overlap;
        best = i;
      }
    }
    return best;
  }

  // Compute a visual longest line that accounts for trailing extras (padding/border/margin)
  // on the last fragment of inline elements. This adjusts for our choice to not insert
  // right-extras placeholders for non-empty spans.
  double _computeVisualLongestLine() {
    if (_paragraph == null || _paraLines.isEmpty) return _paragraph?.longestLine ?? 0;
    // Base rights from paragraph line metrics
    final rights = List<double>.generate(
      _paraLines.length,
      (i) => _paraLines[i].left + _paraLines[i].width,
      growable: false,
    );
    // Extend rights by trailing extras of inline elements that end on a line
    _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
      final int sIdx = range.$1;
      final int eIdx = range.$2;
      if (eIdx <= sIdx) return;
      List<ui.TextBox> rects = _paragraph!.getBoxesForRange(sIdx, eIdx);
      if (rects.isEmpty) return;
      final last = rects.last;
      final li = _lineIndexForRect(last);
      if (li < 0) return;
      final s = box.renderStyle;
      final double padR = s.paddingRight.computedValue;
      final double bR = s.borderRightWidth?.computedValue ?? 0.0;
      final double mR = s.marginRight.computedValue;
      final double extended = last.right + padR + bR + mR;
      if (extended > rights[li]) rights[li] = extended;
    });
    double baseLongest = _paragraph!.longestLine;
    double visualLongest = rights.fold<double>(0, (p, v) => v > p ? v : p);
    final double result = visualLongest > baseLongest ? visualLongest : baseLongest;
    if (debugLogInlineLayoutEnabled) {
      renderingLogger.fine('[IFC] visualLongestLine=${result.toStringAsFixed(2)} (base=${baseLongest.toStringAsFixed(2)})');
    }
    return result;
  }

  // Whether this inline element had a left-extras placeholder inserted.
  bool _elementHasLeftExtrasPlaceholder(RenderBoxModel box) {
    for (final ph in _allPlaceholders) {
      if (ph.kind == _PHKind.leftExtra && ph.owner == box) return true;
    }
    return false;
  }

  // Return the line band's top, bottom and baseline for a given line index.
  (double top, double bottom, double baseline) _bandForLine(int lineIndex) {
    final lm = _paraLines[lineIndex];
    final double lt = lm.baseline - lm.ascent;
    final double lb = lm.baseline + lm.descent;
    return (lt, lb, lm.baseline);
  }

  // Find paragraph line index with maximum vertical overlap for a TextBox.
  int _bestOverlapLineIndexForBox(ui.TextBox tb, List<ui.LineMetrics> lines) {
    int best = -1;
    double bestOverlap = -1;
    for (int i = 0; i < lines.length; i++) {
      final lm = lines[i];
      final double lt = lm.baseline - lm.ascent;
      final double lb = lm.baseline + lm.descent;
      final double overlap = math.max(0, math.min(tb.bottom, lb) - math.max(tb.top, lt));
      if (overlap > bestOverlap) {
        bestOverlap = overlap;
        best = i;
      }
    }
    return best;
  }

  // Note: paragraph-based IFC no longer assigns per-child parentData offsets.
  // Inline content is painted via paragraph; positioned descendants are painted
  // separately. Atomic inlines can be painted directly at placeholder rects if
  // needed, without mutating parentData here.

  // Build decoration entries (span fragments to paint) with rects filtered
  // for extras placeholders; includes only elements that actually paint.
  List<_SpanPaintEntry> _buildDecorationEntriesForPainting() {
    final entries = <_SpanPaintEntry>[];
    _elementRanges.forEach((box, range) {
      final style = box.renderStyle;
      final hasBg = style.backgroundColor?.value != null;
      final hasBorder = ((style.borderLeftWidth?.value ?? 0) > 0) ||
          ((style.borderTopWidth?.value ?? 0) > 0) ||
          ((style.borderRightWidth?.value ?? 0) > 0) ||
          ((style.borderBottomWidth?.value ?? 0) > 0);
      final hasPadding = ((style.paddingLeft?.value ?? 0) > 0) ||
          ((style.paddingTop?.value ?? 0) > 0) ||
          ((style.paddingRight?.value ?? 0) > 0) ||
          ((style.paddingBottom?.value ?? 0) > 0);
      if (!hasBg && !hasBorder && !hasPadding) return;

      List<ui.TextBox> rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
      bool synthesized = false;
      if (rects.isEmpty) {
        rects = _synthesizeRectsForEmptySpan(box);
        if (rects.isEmpty) return;
        synthesized = true;
      } else {
        // Filter leading placeholder box when present
        final tbPH = _leftExtraTextBoxFor(box);
        if (tbPH != null && _sameRect(rects.first, tbPH)) {
          rects = rects.sublist(1);
        }
      }
      entries.add(_SpanPaintEntry(box, style, rects, _depthFromContainer(box), synthesized));
    });
    entries.sort((a, b) => a.depth.compareTo(b.depth));
    return entries;
  }

  // Shrink paragraph width only as needed so the last line can accommodate
  // trailing extras (padding/border/margin) without overflow.
  void _shrinkWidthForLastLineTrailingExtras(ui.Paragraph paragraph, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.maxWidth.isFinite || constraints.maxWidth <= 0) return;
    final lines = paragraph.computeLineMetrics();
    if (lines.isEmpty) return;
    final int lastIndex = lines.length - 1;
    double trailingReserve = 0;
    _elementRanges.forEach((box, range) {
      final int sIdx = range.$1;
      final int eIdx = range.$2;
      if (eIdx <= sIdx) return;
      final rects = paragraph.getBoxesForRange(sIdx, eIdx);
      if (rects.isEmpty) return;
      final last = rects.last;
      final li = _bestOverlapLineIndexForBox(last, lines);
      if (li != lastIndex) return;
      final s = box.renderStyle;
      trailingReserve += s.paddingRight.computedValue + (s.borderRightWidth?.computedValue ?? 0.0) + s.marginRight.computedValue;
    });
    if (trailingReserve <= 0) return;
    final double maxW = constraints.maxWidth;
    final double need = lines.last.width + trailingReserve - maxW;
    if (need <= 0.5) return;
    double hi = maxW;
    double lo = math.max(0.0, maxW - trailingReserve);
    double chosen = hi;
    for (int it = 0; it < 6; it++) {
      final double mid = (hi + lo) / 2.0;
      paragraph.layout(ui.ParagraphConstraints(width: mid));
      final lw = paragraph.computeLineMetrics().last.width;
      if (lw + trailingReserve <= maxW + 0.1) {
        chosen = mid;
        lo = mid;
      } else {
        hi = mid;
      }
    }
    if (debugLogInlineLayoutEnabled) {
      renderingLogger.fine('[IFC] reserve trailing extras (last-line only): width '
          '${maxW.toStringAsFixed(2)} → ${chosen.toStringAsFixed(2)} (reserve=${trailingReserve.toStringAsFixed(2)})');
    }
    paragraph.layout(ui.ParagraphConstraints(width: chosen));
  }
  /// Mark that inline collection is needed.
  void setNeedsCollectInlines() {
    _needsCollectInlines = true;
    // Debug: Log when recollection is triggered
    // print('InlineFormattingContext: setNeedsCollectInlines called');
  }

  /// Prepare for layout by collecting inlines and shaping text.
  void prepareLayout() {
    if (_needsCollectInlines) {
      // Debug: Log preparation
      // print('InlineFormattingContext: prepareLayout - collecting inlines');
      _collectInlines();
      _needsCollectInlines = false;
    }
  }

  // Expose paragraph intrinsic widths when available.
  // minIntrinsicWidth approximates CSS min-content width for the inline content
  // and is used by flex auto-min-size computation to avoid clamping to the
  // max-content width (longestLine).
  double get paragraphMinIntrinsicWidth {
    if (_paragraph != null) {
      // ui.Paragraph provides minIntrinsicWidth when text is laid out.
      // If unavailable for any reason, fall back to longestLine to remain
      // conservative.
      try {
        final double w = (_paragraph as dynamic).minIntrinsicWidth as double? ?? _paragraph!.longestLine;
        return w.isFinite ? w : _paragraph!.longestLine;
      } catch (_) {
        return _paragraph!.longestLine;
      }
    }
    return 0;
  }

  // Expose visual longest line width (accounts for trailing extras) for
  // consumers that need a scrollable content width when using paragraph path.
  double get paragraphVisualMaxLineWidth => _computeVisualLongestLine();

  // Expose paragraph object for consumers (Flow) that need paragraph height fallback.
  ui.Paragraph? get paragraph => _paragraph;

  /// Collect inline items from the render tree.
  void _collectInlines() {
    final builder = InlineItemsBuilder(
      direction: container.renderStyle.direction,
    );

    builder.build(container);

    _items = builder.items;
    _textContent = builder.textContent;

    // Text content and items collected
  }

  /// Perform layout with given constraints.
  Size layout(BoxConstraints constraints) {
    // Prepare items if needed
    prepareLayout();
    // New path: build a single Paragraph using dart:ui APIs
    _buildAndLayoutParagraph(constraints);

    // Compute size from paragraph
    final para = _paragraph!;
    // Use visual longest line that includes trailing extras for shrink-to-fit behavior
    final double width = _computeVisualLongestLine();
    double height = para.height;
    // If there is no text and no placeholders, an IFC with purely out-of-flow content
    // contributes 0 to the in-flow content height per CSS.
    if (_paraCharCount == 0 && _placeholderBoxes.isEmpty) {
      height = 0;
    }
    // After paragraph is ready, update parentData.offset for atomic inline children so that
    // paint and hit testing can rely on the standard Flutter offset mechanism.
    _applyAtomicInlineParentDataOffsets();
    return Size(width, height);
  }

  /// Paint the inline content.
  void paint(PaintingContext context, Offset offset) {
    if (_paragraph == null) return;

    // Interleave line background and text painting so that later lines can
    // visually overlay earlier lines when they cross vertically.
    // For each paragraph line: paint decorations for that line, then clip and paint text for that line.
    final para = _paragraph!;
    if (_paraLines.isEmpty) {
      // Fallback: paint decorations then text if no line metrics
      _paintInlineSpanDecorations(context, offset);
      context.canvas.drawParagraph(para, offset);
    } else {
      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        final double lineTop = lm.baseline - lm.ascent;
        final double lineBottom = lm.baseline + lm.descent;

        // Paint only the decorations belonging to this line
        _paintInlineSpanDecorations(context, offset, lineTop: lineTop, lineBottom: lineBottom);

        // Clip to the current line and paint the paragraph text for this band
        // Use the per-line visual width when available to avoid over-clipping
        // in cases where paragraph.width is smaller than actual glyph extents
        // (e.g., shaped with width 0 to enforce breaks). This keeps text visible
        // even when content width is zero due to padding/border.
        final double lineRight = lm.left + lm.width;
        final double clipRight = math.max(para.width, lineRight);
        final Rect clip = Rect.fromLTRB(
          offset.dx,
          offset.dy + lineTop,
          offset.dx + clipRight,
          offset.dy + lineBottom,
        );
        context.canvas.save();
        context.canvas.clipRect(clip);
        context.canvas.drawParagraph(para, offset);
        context.canvas.restore();
      }
    }

    // Paint atomic inline children using parentData.offset for consistency.
    // Convert container-origin offsets to content-local by subtracting the content origin.
    final double contentOriginX =
        container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue;
    final double contentOriginY =
        container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue;

    for (int i = 0; i < _placeholderOrder.length && i < _placeholderBoxes.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;
      // Choose the direct child (wrapper) to paint
      RenderBox paintBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) paintBox = p;
        p = p.parent;
      }
      if (!paintBox.hasSize) continue;
      final RenderLayoutParentData pd = paintBox.parentData as RenderLayoutParentData;
      final Offset contentLocalOffset = Offset(pd.offset.dx - contentOriginX, pd.offset.dy - contentOriginY);
      context.paintChild(paintBox, offset + contentLocalOffset);
    }

    if (debugPaintInlineLayoutEnabled) {
      _debugPaintParagraph(context, offset);
    }
  }

  /// Debug paint for paragraph-based layout path: visualizes lines, baselines,
  /// placeholder boxes, and inline element ranges.
  void _debugPaintParagraph(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // 1) Line bounds and baselines using ui.LineMetrics when available
    if (_paraLines.isNotEmpty && _paragraph != null) {
      final lineRectPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFF00FF00); // Green for line box bounds
      final baselinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFFF0000); // Red for baseline

      for (final lm in _paraLines) {
        final double lineTop = lm.baseline - lm.ascent;
        final rect = Rect.fromLTWH(
          offset.dx + lm.left,
          offset.dy + lineTop,
          lm.width,
          lm.height,
        );
        canvas.drawRect(rect, lineRectPaint);
        // Baseline line across the visual line width
        final double by = offset.dy + lm.baseline;
        canvas.drawLine(Offset(offset.dx + lm.left, by), Offset(offset.dx + lm.left + lm.width, by), baselinePaint);
      }
    }

    // 2) Placeholder rectangles (atomic inline boxes) in blue
    if (_placeholderBoxes.isNotEmpty) {
      final phPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFF00AAFF); // Blue for placeholders
      for (final tb in _placeholderBoxes) {
        final r = Rect.fromLTRB(tb.left, tb.top, tb.right, tb.bottom).shift(offset);
        canvas.drawRect(r, phPaint);
      }
    }

    // 3) Inline element ranges (spans) in magenta outline, extended by padding/border
    if (_elementRanges.isNotEmpty && _paragraph != null) {
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFFF00FF); // Magenta for inline spans

      // Build entries similar to decoration painter to include padding/border per fragment
      final entries = <_SpanPaintEntry>[];
      _elementRanges.forEach((box, range) {
        final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
        if (rects.isEmpty) return;
      entries.add(_SpanPaintEntry(box, box.renderStyle, rects, _depthFromContainer(box), false));
      });
      entries.sort((a, b) => a.depth.compareTo(b.depth));

      for (final e in entries) {
        final s = e.style;
        final padL = s.paddingLeft.computedValue;
        final padR = s.paddingRight.computedValue;
        final padT = s.paddingTop.computedValue;
        final padB = s.paddingBottom.computedValue;
        final bL = s.borderLeftWidth?.computedValue ?? 0.0;
        final bR = s.borderRightWidth?.computedValue ?? 0.0;
        final bT = s.borderTopWidth?.computedValue ?? 0.0;
        final bB = s.borderBottomWidth?.computedValue ?? 0.0;

        for (int i = 0; i < e.rects.length; i++) {
          final tb = e.rects[i];
          bool isFirst = (i == 0);
          bool isLast = (i == e.rects.length - 1);
          double left = tb.left;
          double right = tb.right;
          double top = tb.top;
          double bottom = tb.bottom;
          // Avoid double-counting when a left-extras placeholder exists
          final bool hasLeftPH = _elementHasLeftExtrasPlaceholder(e.box);
          if (isFirst && !hasLeftPH) left -= (padL + bL);
          if (isLast) right += (padR + bR);
          top -= (padT + bT);
          bottom += (padB + bB);
          final r = Rect.fromLTRB(left, top, right, bottom).shift(offset);
          canvas.drawRect(r, outline);
        }
      }
    }
  }

  /// Hit test the inline content.
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Paragraph path: hit test atomic inlines at parentData offsets (content-relative)
    final double contentOriginX =
        container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue;
    final double contentOriginY =
        container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue;

    for (int i = 0; i < _placeholderOrder.length && i < _placeholderBoxes.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;
      // Use the direct child (wrapper) that carries the parentData offset
      RenderBox hitBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) hitBox = p;
        p = p.parent;
      }
      final RenderLayoutParentData pd = hitBox.parentData as RenderLayoutParentData;
      final Offset contentLocalOffset = Offset(pd.offset.dx - contentOriginX, pd.offset.dy - contentOriginY);
      final bool isHit = result.addWithPaintOffset(
        offset: contentLocalOffset,
        position: position,
        hitTest: (BoxHitTestResult res, Offset transformed) {
          return hitBox.hitTest(res, position: transformed);
        },
      );
      if (isHit) return true;
    }

    // Paragraph path: hit test non-atomic inline elements (e.g., <span>) using text ranges
    if (_paragraph != null && _elementRanges.isNotEmpty) {
      // Search from deepest descendants first to better match nested inline targets
      final entries = _elementRanges.entries.toList()
        ..sort((a, b) => _depthFromContainer(b.key).compareTo(_depthFromContainer(a.key)));

      for (final entry in entries) {
        final RenderBoxModel box = entry.key;
        final (int start, int end) = entry.value;

        List<ui.TextBox> rects = const [];
        bool synthesized = false;
        if (end <= start) {
          // Empty range: synthesize rects from extras for empty inline spans
          rects = _synthesizeRectsForEmptySpan(box);
          if (rects.isEmpty) continue;
          synthesized = true;
        } else {
          rects = _paragraph!.getBoxesForRange(start, end);
          if (rects.isEmpty) {
            rects = _synthesizeRectsForEmptySpan(box);
            if (rects.isEmpty) continue;
            synthesized = true;
          }
        }

        // Inflate rects to include padding and borders
        final style = box.renderStyle;
        final padL = style.paddingLeft.computedValue;
        final padR = style.paddingRight.computedValue;
        final padT = style.paddingTop.computedValue;
        final padB = style.paddingBottom.computedValue;
        final bL = style.borderLeftWidth?.computedValue ?? 0.0;
        final bR = style.borderRightWidth?.computedValue ?? 0.0;
        final bT = style.borderTopWidth?.computedValue ?? 0.0;
        final bB = style.borderBottomWidth?.computedValue ?? 0.0;

        for (int i = 0; i < rects.length; i++) {
          final tb = rects[i];
          double left = tb.left;
          double right = tb.right;
          double top = tb.top;
          double bottom = tb.bottom;

          final bool isFirst = (i == 0);
          final bool isLast = (i == rects.length - 1);

          // Horizontal expansion only on first/last fragments for real text fragments.
          // For synthesized rects (built from extras), placeholders already include padding/border,
          // so do not expand horizontally again to avoid oversizing the hit area.
          if (!synthesized) {
            if (isFirst) left -= (padL + bL);
            if (isLast) right += (padR + bR);
          }
          // Vertical extent: include full content on every fragment. For synthesized spans,
          // use effective line-height to match painted area; otherwise expand by padding/border.
          if (synthesized) {
            final double lineHeight = _effectiveLineHeightPx(style);
            top = tb.top - (lineHeight + padT + bT);
            bottom = tb.top + (padB + bB);
          } else {
            top -= (padT + bT);
            bottom += (padB + bB);
          }

          if (position.dx >= left &&
              position.dx <= right &&
              position.dy >= top &&
              position.dy <= bottom) {
            // Prefer hitting the RenderEventListener wrapper if present, so events dispatch correctly
            RenderEventListener? listener;
            RenderObject? p = box;
            while (p != null && p != container) {
              if (p is RenderEventListener && p.enableEvent) {
                listener = p;
                break;
              }
              p = p.parent;
            }

            if (listener != null) {
              // Convert container-local position to listener-local position
              final Offset offsetToContainer = getLayoutTransformTo(listener, container);
              final Offset local = position - offsetToContainer;
              result.add(BoxHitTestEntry(listener, local));
              return true;
            } else {
              // Fallback: add entry for the box itself
              final Offset offsetToContainer = getLayoutTransformTo(box, container);
              final Offset local = position - offsetToContainer;
              result.add(BoxHitTestEntry(box, local));
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  /// Update parentData.offset for atomic inline children so that paint and hit testing
  /// can rely on Flutter's standard offset mechanism. Offsets are set in container-origin
  /// coordinates (i.e., include padding and border).
  void _applyAtomicInlineParentDataOffsets() {
    if (_placeholderBoxes.isEmpty || _placeholderOrder.isEmpty) return;

    final double contentOriginX =
        container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue;
    final double contentOriginY =
        container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue;

    for (int i = 0; i < _placeholderOrder.length && i < _placeholderBoxes.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;

      // Find the direct RenderBox child under the container; it carries RenderLayoutParentData
      RenderBox paintBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) paintBox = p;
        p = p.parent;
      }

      final tb = _placeholderBoxes[i];
      double left = tb.left;
      double top = tb.top;
      // Add box margins and conditionally add CSS relative offset.
      // If the direct child under the container is a RenderBoxModel, let
      // CSSPositionedLayout.applyRelativeOffset add the style offset.
      // Otherwise (wrappers), pre-add the relative offset from the atomic inline (rb).
      if (rb is RenderBoxModel) {
        left += rb.renderStyle.marginLeft.computedValue;
        top += rb.renderStyle.marginTop.computedValue;
        if (paintBox is! RenderBoxModel) {
          final Offset? rel = CSSPositionedLayout.getRelativeOffset(rb.renderStyle);
          if (rel != null) {
            left += rel.dx;
            top += rel.dy;
          }
        }
      }

      final Offset relativeOffset = Offset(contentOriginX + left, contentOriginY + top);
      CSSPositionedLayout.applyRelativeOffset(relativeOffset, paintBox);
    }
  }

  /// Get the bounding rectangle for a specific inline element across all line fragments.
  Rect? getBoundsForRenderBox(RenderBox targetBox) {
    // Paragraph path: bounds for atomic inline placeholders
    final idx = _placeholderOrder.indexOf(targetBox);
    if (idx >= 0 && idx < _placeholderBoxes.length) {
      final r = _placeholderBoxes[idx];
      return Rect.fromLTWH(r.left, r.top, r.right - r.left, r.bottom - r.top);
    }
    // For inline element ranges (non-atomic), approximate using getBoxesForRange if recorded
    if (targetBox is RenderBoxModel) {
      final range = _elementRanges[targetBox];
      if (range != null && _paragraph != null) {
        List<ui.TextBox> rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
        bool synthesized = false;
        if (rects.isEmpty) {
          rects = _synthesizeRectsForEmptySpan(targetBox);
          synthesized = rects.isNotEmpty;
        }
        if (rects.isNotEmpty) {
          if (!synthesized) {
            double? minX, minY, maxX, maxY;
            for (final tb in rects) {
              minX = (minX == null) ? tb.left : math.min(minX, tb.left);
              minY = (minY == null) ? tb.top : math.min(minY, tb.top);
              maxX = (maxX == null) ? tb.right : math.max(maxX, tb.right);
              maxY = (maxY == null) ? tb.bottom : math.max(maxY, tb.bottom);
            }
            return Rect.fromLTRB(minX!, minY!, maxX!, maxY!);
          } else {
            // For synthesized empty spans, include effective line-height vertically to match visual area
            final style = targetBox.renderStyle;
            final padT = style.paddingTop.computedValue;
            final bT = style.borderTopWidth?.computedValue ?? 0.0;
            final padB = style.paddingBottom.computedValue;
            final bB = style.borderBottomWidth?.computedValue ?? 0.0;
            final lh = _effectiveLineHeightPx(style);
            final tb = rects.first;
            final double left = tb.left;
            final double right = tb.right;
            final double top = tb.top - (lh + padT + bT);
            final double bottom = tb.top + (padB + bB);
            return Rect.fromLTRB(left, top, right, bottom);
          }
        }
      }
    }
    return null;
  }

  // Build and layout a Paragraph from collected inline items
  void _buildAndLayoutParagraph(BoxConstraints constraints) {
    final style = (container as RenderBoxModel).renderStyle;
    // Lay out atomic inlines first to obtain sizes for placeholders
    _layoutAtomicInlineItemsForParagraph();

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: style.textAlign,
      textDirection: style.direction,
      maxLines: style.lineClamp,
      ellipsis: style.effectiveTextOverflow == TextOverflow.ellipsis ? '\u2026' : null,
      // Distribute extra line-height evenly above/below the glyphs so a single
      // line with large line-height (e.g., equal to box height) is vertically
      // centered as in CSS.
      textHeightBehavior: const ui.TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
        leadingDistribution: ui.TextLeadingDistribution.even,
      ),
    ));

    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _elementRanges.clear();
    _measuredVisualSizes.clear();
    // Track open inline element frames for deferred extras handling
    final List<_OpenInlineFrame> openFrames = [];

    // Track current paragraph code-unit position as we add text/placeholders
    int paraPos = 0;
    // Track an inline element stack to record ranges
    final List<RenderBoxModel> elementStack = [];

    if (debugLogInlineLayoutEnabled) {
      // Log high-level container info
      renderingLogger.fine('[IFC] Build paragraph: maxWidth=${constraints.maxWidth.toStringAsFixed(2)} '
          'dir=${style.direction} textAlign=${style.textAlign} lineClamp=${style.lineClamp}');
    }

    // Record overflow flags for debugging
    final CSSOverflowType containerOverflowX = style.effectiveOverflowX;
    final CSSOverflowType containerOverflowY = style.effectiveOverflowY;
    if (debugLogInlineLayoutEnabled) {
      renderingLogger.fine('[IFC] overflow flags: overflowX=$containerOverflowX overflowY=$containerOverflowY');
    }

    // Measure text metrics (height and baseline offset) for a given CSS text style.
    // Returns (height, baselineOffset) where baselineOffset is distance from top to alphabetic baseline.
    (double, double) _measureTextMetricsFor(CSSRenderStyle rs) {
      // Use same text height behavior as the main paragraph to match leading distribution.
      final mpb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: style.direction,
        textHeightBehavior: const ui.TextHeightBehavior(
          applyHeightToFirstAscent: true,
          applyHeightToLastDescent: true,
          leadingDistribution: ui.TextLeadingDistribution.even,
        ),
        maxLines: 1,
      ));
      mpb.pushStyle(_uiTextStyleFromCss(rs));
      // Use a representative glyph to materialize font metrics.
      mpb.addText('M');
      final mp = mpb.build();
      mp.layout(const ui.ParagraphConstraints(width: 1000000.0));
      // Prefer Paragraph.computeLineMetrics when available (Flutter stable API).
      final lines = mp.computeLineMetrics();
      if (lines.isNotEmpty) {
        final lm = lines.first;
        final double ascent = lm.ascent;
        final double descent = lm.descent;
        return (ascent + descent, ascent);
      }
      // Fallback for odd cases: derive from paragraph metrics.
      final double baseline = mp.alphabeticBaseline;
      final double ph = mp.height; // single-line paragraph height
      if (ph.isFinite && ph > 0 && baseline.isFinite && baseline > 0) {
        return (ph, baseline);
      }
      // Last resort: approximate using font size when metrics are unavailable.
      final fs = rs.fontSize.computedValue;
      return (fs, fs * 0.8);
    }

    // Helper to flush pending left extras for all open frames (from outermost to innermost)
    void _flushPendingLeftExtras() {
      for (final frame in openFrames) {
        if (!frame.leftFlushed && frame.leftExtras > 0) {
          final rs = frame.box.renderStyle;
          final (ph, bo) = _measureTextMetricsFor(rs);
          // Use measured text metrics for placeholder height and baseline to
          // align with the paragraph's line box for this style.
          pb.addPlaceholder(frame.leftExtras, ph, ui.PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic, baselineOffset: bo);
          paraPos += 1; // account for placeholder char
          _allPlaceholders.add(_InlinePlaceholder.leftExtra(frame.box));
          frame.leftFlushed = true;
          if (debugLogInlineLayoutEnabled) {
            final effLH = _effectiveLineHeightPx(rs);
            renderingLogger.finer('[IFC] open extras <${_getElementDescription(frame.box)}> '
                'leftExtras=${frame.leftExtras.toStringAsFixed(2)} '
                'metrics(height=${ph.toStringAsFixed(2)}, baselineOffset=${bo.toStringAsFixed(2)}, '
                'effectiveLineHeight=${effLH.toStringAsFixed(2)}, fontSize=${rs.fontSize.computedValue.toStringAsFixed(2)})');
          }
        }
      }
    }

    // Determine whether we should avoid breaking within ASCII words.
    // This helps match CSS behavior where long unbreakable words in a
    // horizontally scrollable container should overflow and allow scroll
    // instead of wrapping arbitrarily.
    bool _ancestorHasHorizontalScroll() {
      RenderObject? p = container.parent;
      while (p != null) {
        if (p is RenderBoxModel) {
          // Ignore the document root and body (page scroller); they should not
          // trigger wide shaping for general layout like flex items.
          final tag = p.renderStyle.target.tagName;
          if (tag == 'HTML' || tag == 'BODY') {
            p = (p as RenderObject).parent;
            continue;
          }
          final o = p.renderStyle.effectiveOverflowX;
          if (o == CSSOverflowType.scroll || o == CSSOverflowType.auto) {
            if (debugLogInlineLayoutEnabled) {
              final t = p.renderStyle.target.tagName.toLowerCase();
              renderingLogger.fine('[IFC] ancestor scroll-x detected at <$t> overflowX=$o');
            }
            return true;
          }
        }
        // Stop at widget boundary to avoid leaking outside this subtree
        if (p is RenderWidget) break;
        p = (p is RenderObject) ? (p as RenderObject).parent : null;
      }
      return false;
    }

    bool _whiteSpaceEligibleForNoWordBreak(WhiteSpace ws) =>
        ws == WhiteSpace.normal || ws == WhiteSpace.preLine || ws == WhiteSpace.nowrap;

    String _insertWordJoinersForAsciiWords(String input) {
      if (input.isEmpty) return input;
      const int A = 0x41, Z = 0x5A; // A-Z
      const int a = 0x61, z = 0x7A; // a-z
      const int zero = 0x30, nine = 0x39; // 0-9
      bool isAsciiAlphaNum(int cu) =>
          (cu >= A && cu <= Z) || (cu >= a && cu <= z) || (cu >= zero && cu <= nine);

      final sb = StringBuffer();
      int i = 0;
      final int n = input.length;
      while (i < n) {
        final int cu = input.codeUnitAt(i);
        if (isAsciiAlphaNum(cu)) {
          // start of a run
          int start = i;
          // write first char
          sb.writeCharCode(cu);
          i++;
          while (i < n) {
            final int c = input.codeUnitAt(i);
            if (!isAsciiAlphaNum(c)) break;
            // Insert a WORD JOINER (U+2060) between ascii alphanumerics
            sb.write('\u2060');
            sb.writeCharCode(c);
            i++;
          }
          // Done with this run
        } else {
          sb.writeCharCode(cu);
          i++;
        }
      }
      return sb.toString();
    }

    final bool _avoidWordBreakInScrollableX = _ancestorHasHorizontalScroll();

    for (final item in _items) {
      if (item.isOpenTag && item.renderBox != null) {
        final rb = item.renderBox!;
        elementStack.add(rb);
        if (item.style != null) {
          final st = item.style!;
          // Defer left extras until we know this span has content; for empty spans we will merge.
          final leftExtras = (st.marginLeft.computedValue) +
              (st.borderLeftWidth?.computedValue ?? 0.0) +
              (st.paddingLeft.computedValue);
          final rightExtras = (st.paddingRight.computedValue) +
              (st.borderRightWidth?.computedValue ?? 0.0) +
              (st.marginRight.computedValue);
          if (rb is RenderBoxModel) {
            openFrames.add(_OpenInlineFrame(rb, leftExtras: leftExtras, rightExtras: rightExtras));
          }
          pb.pushStyle(_uiTextStyleFromCss(st));
          if (debugLogInlineLayoutEnabled) {
            final fam = st.fontFamily;
            final fs = st.fontSize.computedValue;
            renderingLogger.finer('[IFC] pushStyle <${_getElementDescription(rb)}> fontSize=${fs.toStringAsFixed(2)} family=${fam?.join(',') ?? 'default'}');
          }
        }
        // Record content range start after left extras
        _elementRanges[rb] = (paraPos, paraPos);
      } else if (item.isCloseTag && item.renderBox != null) {
        // Pop style and seal range end
        if (elementStack.isNotEmpty && elementStack.last == item.renderBox) {
          final start = _elementRanges[item.renderBox!]!.$1;
          _elementRanges[item.renderBox!] = (start, paraPos);
          elementStack.removeLast();
        }
        if (item.style != null) {
          pb.pop();
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.finer('[IFC] popStyle </${_getElementDescription(item.renderBox!)}>');
          }
          // Handle right extras or merged extras for empty spans
          if (item.renderBox is RenderBoxModel) {
            // Find and remove the corresponding open frame
            int idx = openFrames.lastIndexWhere((f) => f.box == item.renderBox);
            if (idx != -1) {
              final frame = openFrames.removeAt(idx);
            if (frame.hadContent) {
                // Non-empty inline span: ensure left extras flushed, and DO NOT
                // add a trailing right-extras placeholder. Let painting extend
                // the last fragment's right edge by padding/border instead.
                // This avoids creating an extra paragraph line that contains
                // only the right extras, which looks like an odd gap after text.
                _flushPendingLeftExtras();
                if (debugLogInlineLayoutEnabled && frame.rightExtras > 0) {
                  renderingLogger.finer('[IFC] suppress right extras placeholder for </${_getElementDescription(frame.box)}> '
                      'rightExtras=${frame.rightExtras.toStringAsFixed(2)} (painted via fragment extension)');
                }
              } else {
                // Empty span: merge left+right extras into a single placeholder only if non-zero.
                // When merged == 0, do NOT add any placeholder; an empty inline with no extras
                // must not create a line box contribution (content height should remain 0).
                final double merged = frame.leftExtras + frame.rightExtras;
                if (merged > 0) {
                  final rs = frame.box.renderStyle;
                  final (ph, bo) = _measureTextMetricsFor(rs);
                  pb.addPlaceholder(merged, ph, ui.PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic, baselineOffset: bo);
                  paraPos += 1;
                  _allPlaceholders.add(_InlinePlaceholder.emptySpan(frame.box, merged));
                  if (debugLogInlineLayoutEnabled) {
                    renderingLogger.finer('[IFC] empty span extras <${_getElementDescription(frame.box)}>'
                        ' merged=${merged.toStringAsFixed(2)}');
                  }
                } else {
                  if (debugLogInlineLayoutEnabled) {
                    renderingLogger.finer('[IFC] suppress empty span placeholder for '
                        '<${_getElementDescription(frame.box)}> (no padding/border/margins)');
                  }
                }
              }
            }
          }
        }
      } else if (item.isAtomicInline && item.renderBox != null) {
        // First content inside any open frames
        if (openFrames.isNotEmpty) {
          for (final f in openFrames) {
            f.hadContent = true;
          }
          _flushPendingLeftExtras();
        }
        // Add placeholder for atomic inline
        final rb = item.renderBox!;
        final rbStyle = rb.renderStyle;
        // Width impacts line-breaking: include horizontal margins.
        final mL = rbStyle.marginLeft.computedValue;
        final mR = rbStyle.marginRight.computedValue;
        final mT = rbStyle.marginTop.computedValue;
        final mB = rbStyle.marginBottom.computedValue;
        final width = (rb is RenderBoxModel)
            ? ((rb.boxSize?.width ?? (rb.hasSize ? rb.size.width : 0.0)) + mL + mR)
            : (rb.hasSize ? rb.size.width : 0.0) + mL + mR;
        // Include vertical margins in placeholder height
        final borderBoxHeight = (rb is RenderBoxModel)
            ? (rb.boxSize?.height ?? (rb.hasSize ? rb.size.height : 0.0))
            : (rb.hasSize ? rb.size.height : 0.0);
        final height = borderBoxHeight + mT + mB;

        // Baseline offset for inline-block: prefer child last-line baseline if available.
        final resolvedChild = _resolveAtomicChildForBaseline(rb);
        double? innerBaseline = _computeInlineBlockBaseline(resolvedChild) ?? _computeInlineBlockBaseline(rb);
        // Shift baseline by top margin so it's measured from placeholder top
        double? baselineOffset = innerBaseline != null ? (mT + innerBaseline) : null;
        baselineOffset ??= height; // fallback to bottom edge including margins

        // Map CSS vertical-align to dart:ui PlaceholderAlignment for atomic inline items.
        // For textTop/textBottom we approximate using top/bottom as Flutter does not
        // distinguish font-box vs line-box alignment at this level.
        pb.addPlaceholder(width, height,
            _placeholderAlignmentFromCss(rbStyle.verticalAlign),
            baseline: TextBaseline.alphabetic, baselineOffset: baselineOffset);
        _placeholderOrder.add(rb);
        _allPlaceholders.add(_InlinePlaceholder.atomic(rb));
        paraPos += 1; // placeholder adds a single object replacement char

        if (debugLogInlineLayoutEnabled) {
          final bw = rb.boxSize?.width ?? (rb.hasSize ? rb.size.width : 0.0);
          final bh = rb.boxSize?.height ?? (rb.hasSize ? rb.size.height : 0.0);
          renderingLogger.finer('[IFC] placeholder <${_getElementDescription(rb)}> borderBox=(${bw.toStringAsFixed(2)}x${bh.toStringAsFixed(2)}) '
              'margins=(L:${mL.toStringAsFixed(2)},T:${mT.toStringAsFixed(2)},R:${mR.toStringAsFixed(2)},B:${mB.toStringAsFixed(2)}) '
              'placeholder=(w:${width.toStringAsFixed(2)}, h:${height.toStringAsFixed(2)}, baselineOffset:${baselineOffset.toStringAsFixed(2)})');
        }
      } else if (item.isText) {
        String text = item.getText(_textContent);
        if (text.isEmpty || item.style == null) continue;
        // First content inside any open frames
        if (openFrames.isNotEmpty) {
          for (final f in openFrames) {
            f.hadContent = true;
          }
          _flushPendingLeftExtras();
        }
        // If any ancestor establishes horizontal scroll/auto overflow,
        // prevent breaking within ASCII words so long sequences (e.g., digits)
        // overflow horizontally and can be scrolled instead of wrapping.
        if (_avoidWordBreakInScrollableX && _whiteSpaceEligibleForNoWordBreak(item.style!.whiteSpace)) {
          text = _insertWordJoinersForAsciiWords(text);
        }
        pb.pushStyle(_uiTextStyleFromCss(item.style!));
        pb.addText(text);
        pb.pop();
        paraPos += text.length;
        if (debugLogInlineLayoutEnabled) {
          final t = text.replaceAll('\n', '\\n');
          renderingLogger.finer('[IFC] addText len=${text.length} at=$paraPos "$t"');
        }
      } else if (item.type == InlineItemType.control) {
        // Control characters (e.g., from <br>) act as hard line breaks.
        final text = item.getText(_textContent);
        if (text.isEmpty) continue;
        if (openFrames.isNotEmpty) {
          for (final f in openFrames) {
            f.hadContent = true;
          }
          _flushPendingLeftExtras();
        }
        // Use container style to ensure a style is on the stack for ParagraphBuilder
        pb.pushStyle(_uiTextStyleFromCss(style));
        pb.addText(text);
        pb.pop();
        paraPos += text.length;
        if (debugLogInlineLayoutEnabled) {
          final t = text.replaceAll('\n', '\\n');
          renderingLogger.finer('[IFC] addCtrl len=${text.length} at=$paraPos "$t"');
        }
      }
    }

    final paragraph = pb.build();
    // First layout: choose a sensible width for shaping.
    // If constraints are unbounded, use a large width. If bounded but zero/negative,
    // treat it like unbounded to let content determine natural width instead of 0.
    // Try to get a fallback content max width from the container's render style.
    // This approximates the parent's content box width and helps when our own
    // constraints report maxWidth <= 0 during intrinsic measurements.
    double? fallbackContentMaxWidth;
    // In a flex item intrinsic measurement, avoid falling back to ancestor
    // content widths. Let content determine its natural width instead of
    // adopting the flex container's max width.
    bool parentIsFlex = false;
    bool parentIsInlineBlockAutoWidth = false;
    // Walk up the ancestor chain to detect if we are inside a flex item.
    // Do not stop at intermediate wrappers (e.g., RenderEventListener/Wrapper).
    // Stop early if we hit a RenderWidget boundary.
    RenderObject? p = container.parent;
    while (p != null) {
      if (p is RenderFlexLayout) {
        parentIsFlex = true;
        break;
      }
      if (p is RenderEventListener) {
        p = p.parent;
        continue;
      }
      if (p is RenderBoxModel) {
        final rs = p.renderStyle;
        if (rs.effectiveDisplay == CSSDisplay.inlineBlock && rs.width.isAuto) {
          parentIsInlineBlockAutoWidth = true;
          // Keep walking up to avoid treating this as a hard boundary
        }
        if (p is RenderWidget) {
          // Stop at widget boundary to avoid leaking app viewport widths
          break;
        }
      }
      p = (p is RenderObject) ? (p as RenderObject).parent : null;
    }
    // Prefer this container's own computed content max width
    final double cmw = style.contentMaxConstraintsWidth;
    if (!parentIsFlex && !parentIsInlineBlockAutoWidth && cmw.isFinite && cmw > 0) {
      fallbackContentMaxWidth = cmw;
    }
    // If not available, walk up ancestors to find a reasonable content width
    if (!parentIsFlex && !parentIsInlineBlockAutoWidth && fallbackContentMaxWidth == null) {
      RenderObject? p = container.parent;
      while (p != null) {
        if (p is RenderBoxModel) {
          final double acmw = p.renderStyle.contentMaxConstraintsWidth;
          if (acmw.isFinite && acmw > 0) {
            fallbackContentMaxWidth = acmw;
            break;
          }
          final BoxConstraints? cc = p.contentConstraints;
          if (cc != null && cc.hasBoundedWidth && cc.maxWidth.isFinite && cc.maxWidth > 0) {
            fallbackContentMaxWidth = cc.maxWidth;
            break;
          }
        }
        p = (p is RenderObject) ? p.parent : null;
      }
    }

    double initialWidth;
    bool _shapedWithZeroWidth = false; // Track when we intentionally shape with 0 width

    // Decide whether shaping with zero width is appropriate. We only do this
    // when there are natural break opportunities between items (e.g., between
    // atomic inline boxes, explicit breaks) or whitespace within text. For a
    // single unbreakable text run (e.g., "11111"), we avoid zero-width shaping
    // to prevent per-character wrapping and instead let it overflow.
    bool _containsSoftWrapWhitespace(String s) {
      // Matches common whitespace that creates soft wrap opportunities
      return s.contains(RegExp(r"[\s\u200B\u2060]")); // include ZWSP/WORD JOINER
    }
    bool _hasAtomicInlines = _items.any((it) => it.isAtomicInline);
    bool _hasExplicitBreaks = _items.any((it) => it.type == InlineItemType.control || it.type == InlineItemType.lineBreakOpportunity);
    bool _hasWhitespaceInText = false;
    for (final it in _items) {
      if (it.isText) {
        final t = it.getText(_textContent);
        if (_containsSoftWrapWhitespace(t)) { _hasWhitespaceInText = true; break; }
      }
    }
    final bool _preferZeroWidthShaping = _hasAtomicInlines || _hasExplicitBreaks || _hasWhitespaceInText;
    if (!constraints.hasBoundedWidth) {
      // Unbounded: prefer a reasonable fallback if available, otherwise use a very large width
      initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
          ? fallbackContentMaxWidth
          : 1000000.0;
    } else {
      if (constraints.maxWidth > 0) {
        initialWidth = constraints.maxWidth;
      } else {
        // Bounded but maxWidth <= 0: respect zero available inline-size only when
        // there are natural break opportunities (atomic inlines, whitespace, explicit breaks).
        // Otherwise, avoid forcing per-character wrapping for an unbreakable run
        // and shape with a reasonable fallback width so content overflows instead.
        if (_preferZeroWidthShaping) {
          initialWidth = 0.0;
          _shapedWithZeroWidth = true;
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.fine('[IFC] respect zero maxWidth for shaping (has breaks)');
          }
        } else {
          initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
              ? fallbackContentMaxWidth
              : 1000000.0;
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.fine('[IFC] avoid zero-width shaping for unbreakable text; '
                'use fallback=${initialWidth.toStringAsFixed(2)}');
          }
        }
      }
    }

    // If an ancestor has horizontal scrolling, shape with a very large width
    // to avoid forced wrapping. The container itself will still size to its
    // own constraints (e.g., 100px), and overflow/scroll metrics will use the
    // paragraph's visual longest line.
    if (_avoidWordBreakInScrollableX) {
      initialWidth = 1000000.0;
      if (debugLogInlineLayoutEnabled) {
        renderingLogger.fine('[IFC] ancestor horizontal scroll → shape wide initialWidth=${initialWidth.toStringAsFixed(2)}');
      }
    }
    if (debugLogInlineLayoutEnabled) {
      renderingLogger.fine('[IFC] initialWidth=${initialWidth.toStringAsFixed(2)} '
          '(bounded=${constraints.hasBoundedWidth}, maxW=${constraints.maxWidth.toStringAsFixed(2)}, '
          'fallback=${(fallbackContentMaxWidth ?? 0).toStringAsFixed(2)})');
    }
    paragraph.layout(ui.ParagraphConstraints(width: initialWidth));

    // Use container's available content width to preserve text-align behavior
    // for both block and inline-block containers when width is definite.
    // Only shrink-to-fit when the width is effectively unbounded.
    final CSSDisplay display = (container as RenderBoxModel).renderStyle.effectiveDisplay;
    final bool isBlockLike = display == CSSDisplay.block || display == CSSDisplay.inlineBlock;

    if (isBlockLike) {
      // Keep the laid-out width (initialWidth) when we have a definite width.
      // Handle unbounded or non-positive widths by shrinking to content or
      // using a reasonable fallback.
      if (!constraints.hasBoundedWidth) {
        final double targetWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
            ? fallbackContentMaxWidth
            : paragraph.longestLine;
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      } else if (constraints.maxWidth <= 0) {
        // When we intentionally shaped with zero width to enforce line breaks (due to zero
        // available content width), do not reflow with a fallback width. Keep the 0-width
        // shaping so each atomic/text fragment occupies its own line as expected.
        if (!_shapedWithZeroWidth) {
          final double targetWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
              ? fallbackContentMaxWidth
              : paragraph.longestLine;
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.fine('[IFC] block-like reflow with fallback width '
                '${targetWidth.toStringAsFixed(2)} (had maxWidth=${constraints.maxWidth})');
          }
          paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
        } else if (debugLogInlineLayoutEnabled) {
          renderingLogger.fine('[IFC] keep zero-width shaping for block-like container');
        }
      }
    } else {
      // Non block-like (theoretically unused here) — retain previous behavior.
      final double targetWidth = math.min(
          paragraph.longestLine, constraints.maxWidth.isFinite ? constraints.maxWidth : paragraph.longestLine);
      if (targetWidth != initialWidth) {
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    }
    _shrinkWidthForLastLineTrailingExtras(paragraph, constraints);

    _paragraph = paragraph;
    _paraLines = paragraph.computeLineMetrics();
    _placeholderBoxes = paragraph.getBoxesForPlaceholders();
    _paraCharCount = paraPos; // record final character count

    if (debugLogInlineLayoutEnabled) {
      // Try to extract intrinsic widths when available on this engine.
      double? minIntrinsic;
      double? maxIntrinsic;
      try { minIntrinsic = (paragraph as dynamic).minIntrinsicWidth as double?; } catch (_) {}
      try { maxIntrinsic = (paragraph as dynamic).maxIntrinsicWidth as double?; } catch (_) {}

      renderingLogger.fine('[IFC] paragraph: width=${paragraph.width.toStringAsFixed(2)} height=${paragraph.height.toStringAsFixed(2)} '
          'longestLine=${paragraph.longestLine.toStringAsFixed(2)} maxLines=${style.lineClamp} exceeded=${paragraph.didExceedMaxLines}');
      if (minIntrinsic != null || maxIntrinsic != null) {
        renderingLogger.fine('[IFC] intrinsic: min=${(minIntrinsic ?? double.nan).toStringAsFixed(2)} '
            'max=${(maxIntrinsic ?? double.nan).toStringAsFixed(2)}');
      }
      // Log flags related to break avoidance in scrollable containers.
      renderingLogger.fine('[IFC] flags: avoidWordBreakInScrollableX=${_avoidWordBreakInScrollableX} whiteSpace=${style.whiteSpace}');
      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        renderingLogger.finer('  [line $i] baseline=${lm.baseline.toStringAsFixed(2)} height=${lm.height.toStringAsFixed(2)} '
            'ascent=${lm.ascent.toStringAsFixed(2)} descent=${lm.descent.toStringAsFixed(2)} left=${lm.left.toStringAsFixed(2)} width=${lm.width.toStringAsFixed(2)}');
      }
      // Log all placeholders including extras (left/right/empty) and atomics
      for (int i = 0; i < _placeholderBoxes.length && i < _allPlaceholders.length; i++) {
        final tb = _placeholderBoxes[i];
        final ph = _allPlaceholders[i];
        final kind = ph.kind.toString().split('.').last;
        String ownerDesc = 'n/a';
        if (ph.owner != null) ownerDesc = _getElementDescription(ph.owner!);
        double height = tb.bottom - tb.top;
        final li = _lineIndexForRect(tb);
        String lineStr = '';
        if (li >= 0) {
          final lm = _paraLines[li];
          final lt = lm.baseline - lm.ascent;
          final lb = lm.baseline + lm.descent;
          final dt = tb.top - lt;
          final db = lb - tb.bottom;
          lineStr = ' line=$li lineTop=${lt.toStringAsFixed(2)} lineBottom=${lb.toStringAsFixed(2)} '
              'topDelta=${dt.toStringAsFixed(2)} bottomDelta=${db.toStringAsFixed(2)}';
        }
        if (ph.kind == _PHKind.leftExtra && ph.owner != null) {
          final (h, b) = _measureTextMetricsFor(ph.owner!.renderStyle);
          final effLH = _effectiveLineHeightPx(ph.owner!.renderStyle);
          renderingLogger.finer('  [ph $i] kind=$kind owner=<$ownerDesc> rect=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
              'h=${height.toStringAsFixed(2)} metrics(height=${h.toStringAsFixed(2)}, baselineOffset=${b.toStringAsFixed(2)}, effLineHeight=${effLH.toStringAsFixed(2)})$lineStr');
        } else {
          String childDesc = '';
          if (ph.kind == _PHKind.atomic && i < _placeholderOrder.length) {
            final rb = _placeholderOrder[i];
            childDesc = ' child=<${_getElementDescription(rb is RenderBoxModel ? rb : null)}>';
          }
          renderingLogger.finer('  [ph $i] kind=$kind owner=<$ownerDesc> rect=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
              'h=${height.toStringAsFixed(2)}$childDesc$lineStr');
        }
      }
      // Log element ranges
      _elementRanges.forEach((rb, range) {
        renderingLogger.finer('  [range] <${_getElementDescription(rb)}> ${range.$1}..${range.$2}');
        final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
        for (int i = 0; i < rects.length && i < 4; i++) {
          final tb = rects[i];
          final li = _lineIndexForRect(tb);
          if (li >= 0) {
            final lm = _paraLines[li];
            final lt = lm.baseline - lm.ascent;
            final lb = lm.baseline + lm.descent;
            final dt = tb.top - lt;
            final db = lb - tb.bottom;
            renderingLogger.finer('    [frag $i] tb=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
                '→ line=$li topDelta=${dt.toStringAsFixed(2)} bottomDelta=${db.toStringAsFixed(2)}');
          }
        }
      });
    }
  }

  void _layoutAtomicInlineItemsForParagraph() {
    final Set<RenderBox> laidOut = {};
    for (final item in _items) {
      if (item.isAtomicInline && item.renderBox != null) {
        final child = item.renderBox!;
        if (laidOut.contains(child)) continue;
        final constraints = child.getConstraints();
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.finer('[IFC] layout atomic <${_getElementDescription(child is RenderBoxModel ? child : null)}>'
              ' constraints=${constraints.toString()}');
        }
        child.layout(constraints, parentUsesSize: true);
        laidOut.add(child);
      }
    }
  }

  // If an atomic inline is wrapped (e.g., event listener), unwrap to the content box for baseline
  RenderBox _resolveAtomicChildForBaseline(RenderBox box) {
    RenderBox current = box;
    for (int i = 0; i < 3; i++) {
      if (current is RenderObjectWithChildMixin) {
        final child = (current as dynamic).child as RenderBox?;
        if (child != null) {
          current = child;
          continue;
        }
      }
      break;
    }
    return current;
  }

  // Compute inline-block baseline using WebF CSS baseline API to avoid Flutter's restrictions.
  // Returns null if the child has no CSS baseline.
  double? _computeInlineBlockBaseline(RenderBox box) {
    // Use cached CSS baseline saved during child's layout
    if (box is RenderBoxModel) {
      return box.computeCssLastBaselineOf(TextBaseline.alphabetic);
    }
    return null;
  }

  // Paint backgrounds and borders for non-atomic inline elements using paragraph range boxes
  void _paintInlineSpanDecorations(PaintingContext context, Offset offset, {double? lineTop, double? lineBottom}) {
    if (_elementRanges.isEmpty || _paragraph == null) return;

    // Build entries with depth for proper painting order (parents first)
    final entries = _buildDecorationEntriesForPainting();
    final canvas = context.canvas;

    // Identify current line index if painting per-line.
    int currentLineIndex = -1;
    if (lineTop != null && lineBottom != null && _paraLines.isNotEmpty) {
      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        final double lt = lm.baseline - lm.ascent;
        final double lb = lm.baseline + lm.descent;
        // Allow small epsilon for float differences
        if ((lt - lineTop).abs() < 0.02 && (lb - lineBottom).abs() < 0.02) {
          currentLineIndex = i;
          break;
        }
      }
    }

    for (final e in entries) {
      final s = e.style;
      final padL = s.paddingLeft.computedValue;
      final padR = s.paddingRight.computedValue;
      final padT = s.paddingTop.computedValue;
      final padB = s.paddingBottom.computedValue;
      final bL = s.borderLeftWidth?.computedValue ?? 0.0;
      final bR = s.borderRightWidth?.computedValue ?? 0.0;
      final bT = s.borderTopWidth?.computedValue ?? 0.0;
      final bB = s.borderBottomWidth?.computedValue ?? 0.0;
      // Cache metrics per style for all its fragments in this loop
      final (double mHeight, double mBaseline) = _measureTextMetricsForStyle(s);

      for (int i = 0; i < e.rects.length; i++) {
        final tb = e.rects[i];
        // If painting per-line, assign each fragment to exactly one line by
        // best overlap to avoid double-paint across bands due to overshoot.
        if (lineTop != null && lineBottom != null) {
          if (tb.bottom <= lineTop || tb.top >= lineBottom) continue; // early reject
          if (currentLineIndex >= 0) {
            final best = _lineIndexForRect(tb);
            if (best != currentLineIndex) continue;
          }
        }
        double left = tb.left;
        double right = tb.right;
        double top = tb.top;
        double bottom = tb.bottom;

        // Use font metrics band centered on the line baseline as base vertical extent
        // so decoration rectangles wrap the visible content height (font ascent+descent),
        // not the full CSS line-height. This matches browser behavior.
        if (lineTop != null && lineBottom != null && !e.synthetic && currentLineIndex >= 0) {
          final lm = _paraLines[currentLineIndex];
          final double baseTop = lm.baseline - mBaseline;
          final double baseBottom = baseTop + mHeight;
          if (debugLogInlineLayoutEnabled && ((top - baseTop).abs() > 0.5 || (bottom - baseBottom).abs() > 0.5)) {
            renderingLogger.finer('    [metrics] span frag to content band: '
                'top ${top.toStringAsFixed(2)}→${baseTop.toStringAsFixed(2)} '
                'bottom ${bottom.toStringAsFixed(2)}→${baseBottom.toStringAsFixed(2)}');
          }
          top = baseTop;
          bottom = baseBottom;
        }

        // For empty height rects we keep the clamped band; vertical padding/border
        // will be applied conditionally below to avoid exaggerated heights.

        final bool isFirst = (i == 0);
        final bool isLast = (i == e.rects.length - 1);

        // Extend horizontally on first/last fragments
        if (!e.synthetic) {
          // Expand horizontally: first fragment includes left padding/border;
          // last fragment includes right padding/border.
          if (isFirst) left -= (padL + bL);
          if (isLast) right += (padR + bR);
        }
        // Apply vertical padding on every fragment (matches browsers: inline
        // vertical padding is painted around each fragment but does not affect
        // line box height). Borders are still handled per-edge rules below.
        final double effPadTop = padT;
        final double effPadBottom = padB;
        top -= (effPadTop + bT);
        bottom += (effPadBottom + bB);

        // Expand horizontally to include descendant inline fragments on this line,
        // so parent backgrounds cover child padding/border and avoid gaps.
        for (final childEntry in entries) {
          if (childEntry.depth <= e.depth) continue; // only deeper entries
          if (!_isAncestor(e.box, childEntry.box)) continue;
          final cs = childEntry.style;
          final cPadL = cs.paddingLeft.computedValue;
          final cPadR = cs.paddingRight.computedValue;
          final cBL = cs.borderLeftWidth?.computedValue ?? 0.0;
          final cBR = cs.borderRightWidth?.computedValue ?? 0.0;
          for (int j = 0; j < childEntry.rects.length; j++) {
            final cr = childEntry.rects[j];
            if (lineTop != null && lineBottom != null) {
              if (cr.bottom <= lineTop || cr.top >= lineBottom) continue;
            }
            double cLeft = cr.left;
            double cRight = cr.right;
            final cIsFirst = (j == 0);
            final cIsLast = (j == childEntry.rects.length - 1);
            if (cIsFirst) cLeft -= (cPadL + cBL);
            if (cIsLast) cRight += (cPadR + cBR);
            if (cLeft < left) left = cLeft;
            if (cRight > right) right = cRight;
          }
        }

        final rect = Rect.fromLTRB(left, top, right, bottom).shift(offset);

        if (debugLogInlineLayoutEnabled) {
          final bool drawTop = (bT > 0);
          final bool drawBottom = (bB > 0);
          final bool drawLeft = (isFirst && bL > 0);
          final bool drawRight = (isLast && bR > 0);
          final String lineInfo = (currentLineIndex >= 0)
              ? ' line=$currentLineIndex'
              : '';
          renderingLogger.finer('[DECOR] <${_getElementDescription(e.box)}> frag=${i}'+
              lineInfo+
              ' rect=(${rect.left.toStringAsFixed(2)},${rect.top.toStringAsFixed(2)} - '+
              '${rect.right.toStringAsFixed(2)},${rect.bottom.toStringAsFixed(2)}) size=('+
              '${rect.width.toStringAsFixed(2)}x${rect.height.toStringAsFixed(2)}) '+
              'borders(T:${drawTop ? bT.toStringAsFixed(2) : '0'}, '+
              'R:${drawRight ? bR.toStringAsFixed(2) : '0'}, '+
              'B:${drawBottom ? bB.toStringAsFixed(2) : '0'}, '+
              'L:${drawLeft ? bL.toStringAsFixed(2) : '0'})');
        }

        // Background
        if (s.backgroundColor?.value != null) {
          final bg = Paint()..color = s.backgroundColor!.value;
          canvas.drawRect(rect, bg);
        }

        // Borders
        final p = Paint()..style = PaintingStyle.fill;
        // Paint top border on every fragment (spec behavior). With clamped bands
        // and conditional padding, the shared join sits at a single y.
        if (bT > 0) {
          p.color = s.borderTopColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, bT), p);
        }
        // Paint bottom border on every fragment.
        if (bB > 0) {
          p.color = s.borderBottomColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - bB, rect.width, bB), p);
        }
        if (isFirst && bL > 0) {
          p.color = s.borderLeftColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, bL, rect.height), p);
        }
        if (isLast && bR > 0) {
          p.color = s.borderRightColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.right - bR, rect.top, bR, rect.height), p);
        }
      }
    }

    if (debugLogInlineLayoutEnabled) {
      for (final e in entries) {
        for (int i = 0; i < e.rects.length; i++) {
          final tb = e.rects[i];
          renderingLogger.finer('  [span] <${_getElementDescription(e.box)}> frag=$i '
              'tb=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)})');
        }
      }
    }
  }

  // Create a synthetic TextBox from left/right extras placeholders for empty inline spans
  List<ui.TextBox> _synthesizeRectsForEmptySpan(RenderBoxModel box) {
    if (_paragraph == null || _allPlaceholders.isEmpty) return const [];
    int? leftIndex;
    int? rightIndex;
    int? mergedIndex;
    double? mergedWidth;
    for (int i = 0; i < _allPlaceholders.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.owner != box) continue;
      if (ph.kind == _PHKind.leftExtra) leftIndex ??= i;
      if (ph.kind == _PHKind.rightExtra) rightIndex = i;
      if (ph.kind == _PHKind.emptySpan) {
        mergedIndex = i;
        mergedWidth = ph.width;
      }
    }
    // Prefer merged placeholder when available to avoid line-break artifacts
    if (mergedIndex != null && mergedIndex! < _placeholderBoxes.length) {
      final anchor = _placeholderBoxes[mergedIndex!];
      final double leftEdge = anchor.left;
      final double rightEdge = anchor.left + (mergedWidth ?? (anchor.right - anchor.left));
      final double top = anchor.top;
      final double bottom = anchor.bottom;
      return [ui.TextBox.fromLTRBD(leftEdge, top, rightEdge, bottom, TextDirection.ltr)];
    }
    // Fallback to separate left/right extras if present
    if (leftIndex == null || rightIndex == null) return const [];
    if (leftIndex! >= _placeholderBoxes.length || rightIndex! >= _placeholderBoxes.length) return const [];
    final left = _placeholderBoxes[leftIndex!];
    final right = _placeholderBoxes[rightIndex!];
    final l = left.left;
    final r = right.right;
    final t = math.min(left.top, right.top);
    final b = math.max(left.bottom, right.bottom);
    return [ui.TextBox.fromLTRBD(l, t, r, b, TextDirection.ltr)];
  }

  int _depthFromContainer(RenderObject obj) {
    int d = 0;
    RenderObject? p = obj.parent;
    while (p != null && p != container) {
      d++;
      p = p.parent;
    }
    return d;
  }

  bool _isAncestor(RenderObject ancestor, RenderObject node) {
    RenderObject? p = node.parent;
    while (p != null) {
      if (p == ancestor) return true;
      if (p == container) return false;
      p = p.parent;
    }
    return false;
  }

  // Map CSS VerticalAlign to ui.PlaceholderAlignment used by ParagraphBuilder.addPlaceholder.
  // Notes:
  // - Flutter does not provide distinct alignments for CSS text-top/text-bottom vs line-box
  //   top/bottom; we approximate by using top/bottom.
  // - Baseline alignment uses the computed baselineOffset above (measured from placeholder top).
  ui.PlaceholderAlignment _placeholderAlignmentFromCss(VerticalAlign va) {
    switch (va) {
      case VerticalAlign.baseline:
        return ui.PlaceholderAlignment.baseline;
      case VerticalAlign.top:
        return ui.PlaceholderAlignment.top;
      case VerticalAlign.bottom:
        return ui.PlaceholderAlignment.bottom;
      case VerticalAlign.middle:
        return ui.PlaceholderAlignment.middle;
      // For unsupported values (textTop/textBottom), fall back to baseline.
      default:
        return ui.PlaceholderAlignment.baseline;
    }
  }

  // Convert CSSRenderStyle to dart:ui TextStyle for ParagraphBuilder
  ui.TextStyle _uiTextStyleFromCss(CSSRenderStyle rs) {
    final families = rs.fontFamily;
    if (families != null && families.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(families[0], rs.fontWeight, rs);
    }
    // Map CSS line-height to a multiplier for dart:ui. For 'normal', align with CSS by
    // using 1.2× font-size instead of letting Flutter pick a font-driven band.
    final double? heightMultiple = ((){
      if (rs.lineHeight.type == CSSLengthType.NORMAL) {
        return kTextHeightNone; // CSS 'normal' approximation
      }
      if (rs.lineHeight.type == CSSLengthType.EM) {
        return rs.lineHeight.value;
      }
      return rs.lineHeight.computedValue / rs.fontSize.computedValue;
    })();

    return ui.TextStyle(
      color: rs.backgroundClip != CSSBackgroundBoundary.text ? rs.color.value : null,
      decoration: rs.textDecorationLine,
      decorationColor: rs.textDecorationColor?.value,
      decorationStyle: rs.textDecorationStyle,
      fontWeight: rs.fontWeight,
      fontStyle: rs.fontStyle,
      textBaseline: CSSText.getTextBaseLine(),
      fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
      fontFamilyFallback: families,
      fontSize: rs.fontSize.computedValue,
      letterSpacing: rs.letterSpacing?.computedValue,
      wordSpacing: rs.wordSpacing?.computedValue,
      height: heightMultiple,
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
      shadows: rs.textShadow,
      // fontFeatures/fontVariations could be mapped from CSS if available
    );
  }

  void dispose() {
    _items.clear();
    _lineBoxes.clear();
    _placeholderBoxes = const [];
    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _elementRanges.clear();
    _measuredVisualSizes.clear();
    _paraLines = const [];
    _paragraph = null;
  }

  // Compute an effective line-height in px for cases where we need a concrete
  // value (e.g., synthesizing empty inline span height). If CSS line-height is
  // 'normal', fall back to a reasonable multiple of font-size (1.2x), which
  // approximates typical font metrics used by the paragraph shaper.
  double _effectiveLineHeightPx(CSSRenderStyle rs) {
    final lh = rs.lineHeight;
    if (lh.type == CSSLengthType.NORMAL) {
      // Approximate 'normal' as 1.2 × font-size
      return rs.fontSize.computedValue * 1.2;
    }
    final v = lh.computedValue;
    // Guard against zero or infinity
    if (v.isInfinite || v <= 0) {
      return rs.fontSize.computedValue * 1.2;
    }
    return v;
  }

  /// Get a description of the element from a RenderBoxModel.
  String _getElementDescription(RenderBoxModel? renderBox) {
    if (renderBox == null) return 'unknown';

    // Try to get element tag from the RenderBoxModel
    final element = renderBox.renderStyle.target;
    if (element != null) {
      // For HTML elements, return the tag name
      final tagName = element.tagName;
      if (tagName.isNotEmpty && tagName != 'DIV') {
        return tagName.toLowerCase();
      }

      // For elements with specific classes or IDs, include them
      final id = element.id;
      final className = element.className;

      if (id != null && id.isNotEmpty) {
        return '${tagName.toLowerCase()}#$id';
      } else if (className.isNotEmpty) {
        return '${tagName.toLowerCase()}.$className';
      }

      return tagName.toLowerCase();
    }

    // Fallback to a short description
    final typeStr = renderBox.runtimeType.toString();
    if (typeStr.startsWith('Render')) {
      return typeStr.substring(6); // Remove 'Render' prefix
    }
    return typeStr;
  }

  /// Add debugging information for the inline formatting context.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<RenderLayoutBox>('container', container));
    properties.add(IntProperty('items', _items.length));
    properties.add(IntProperty('lineBoxes', _lineBoxes.length));
    properties.add(StringProperty('textContent', _textContent, showName: true, quoted: true, ifEmpty: '<empty>'));
    properties.add(
        FlagProperty('needsCollectInlines', value: _needsCollectInlines, ifTrue: 'needs collect', ifFalse: 'ready'));

    // Add inline item details with visual formatting
    if (_items.isNotEmpty) {
      // Create a visual representation of inline items
      final itemsDescription = <String>[];
      final itemTypeCounts = <String, int>{};

      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        final typeStr = item.type.toString().split('.').last;
        itemTypeCounts[typeStr] = (itemTypeCounts[typeStr] ?? 0) + 1;

        // Build visual representation
        String itemStr = '';
        switch (item.type) {
          case InlineItemType.text:
            final text = item.getText(_textContent);
            final truncatedText = text.length > 20 ? '${text.substring(0, 20)}...' : text;
            itemStr = '[TEXT: "$truncatedText" (${item.length} chars)]';
            break;
          case InlineItemType.openTag:
            itemStr = '[OPEN: <${_getElementDescription(item.renderBox)}>]';
            break;
          case InlineItemType.closeTag:
            itemStr = '[CLOSE: </${_getElementDescription(item.renderBox)}>]';
            break;
          case InlineItemType.atomicInline:
            itemStr = '[ATOMIC: ${_getElementDescription(item.renderBox)}]';
            break;
          case InlineItemType.lineBreakOpportunity:
            itemStr = '[BREAK]';
            break;
          case InlineItemType.bidiControl:
            itemStr = '[BIDI: level=${item.bidiLevel}]';
            break;
          default:
            itemStr = '[${typeStr.toUpperCase()}]';
        }

        if (i < 10) {
          // Show first 10 items
          itemsDescription.add(itemStr);
        } else if (i == 10) {
          itemsDescription.add('... ${_items.length - 10} more items');
          break;
        }
      }

      properties.add(DiagnosticsProperty<List<String>>(
        'inlineItems',
        itemsDescription,
        style: DiagnosticsTreeStyle.truncateChildren,
      ));

      properties.add(DiagnosticsProperty<Map<String, int>>(
        'itemSummary',
        itemTypeCounts,
        style: DiagnosticsTreeStyle.sparse,
      ));
    }

    // Add detailed line box information with visual layout
    if (_lineBoxes.isNotEmpty) {
      final lineBoxDescriptions = <String>[];
      double totalHeight = 0;

      for (int i = 0; i < _lineBoxes.length && i < 5; i++) {
        // Show first 5 lines
        final lineBox = _lineBoxes[i];
        totalHeight += lineBox.height;

        // Count item types in this line
        final lineItemTypes = <String, int>{};
        for (final item in lineBox.items) {
          final typeName = item.runtimeType.toString().replaceAll('LineBoxItem', '');
          lineItemTypes[typeName] = (lineItemTypes[typeName] ?? 0) + 1;
        }

        final lineStr = 'Line ${i + 1}: '
            'w=${lineBox.width.toStringAsFixed(1)}, '
            'h=${lineBox.height.toStringAsFixed(1)}, '
            'baseline=${lineBox.baseline.toStringAsFixed(1)}, '
            'align=${lineBox.alignmentOffset.toStringAsFixed(1)}, '
            'items=${lineBox.items.length} '
            '${lineItemTypes.entries.map((e) => '${e.key}:${e.value}').join(', ')}';

        lineBoxDescriptions.add(lineStr);
      }

      if (_lineBoxes.length > 5) {
        lineBoxDescriptions.add('... ${_lineBoxes.length - 5} more lines');
      }

      properties.add(DiagnosticsProperty<List<String>>(
        'lineBoxLayout',
        lineBoxDescriptions,
        style: DiagnosticsTreeStyle.truncateChildren,
      ));

      // Add layout metrics
      final layoutMetrics = <String, String>{
        'totalLines': _lineBoxes.length.toString(),
        'totalHeight': totalHeight.toStringAsFixed(1),
        'avgLineHeight': (_lineBoxes.isEmpty ? 0 : totalHeight / _lineBoxes.length).toStringAsFixed(1),
        'maxLineWidth': _lineBoxes.map((l) => l.width).reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      };

      properties.add(DiagnosticsProperty<Map<String, String>>(
        'layoutMetrics',
        layoutMetrics,
        style: DiagnosticsTreeStyle.sparse,
      ));
    }

    // Add bidi information if present
    final bidiLevels = <int>{};
    for (final item in _items) {
      if (item.bidiLevel > 0) {
        bidiLevels.add(item.bidiLevel);
      }
    }
    if (bidiLevels.isNotEmpty) {
      properties.add(DiagnosticsProperty<Set<int>>(
        'bidiLevels',
        bidiLevels,
        style: DiagnosticsTreeStyle.singleLine,
      ));
    }

    // Add detailed visual debugging if items and line boxes are available
    if (_items.isNotEmpty && _lineBoxes.isNotEmpty) {
      final debugger = InlineLayoutDebugger(this);
      debugger.debugFillProperties(properties);
    }
  }
}

// Tracks an open inline element while building the paragraph so we can
// defer inserting left extras until we know the span actually has content.
class _OpenInlineFrame {
  _OpenInlineFrame(this.box, {required this.leftExtras, required this.rightExtras});
  final RenderBoxModel box;
  final double leftExtras;
  final double rightExtras;
  bool leftFlushed = false;
  bool hadContent = false;
}

// Placeholder descriptor to map paragraph placeholders back to owners
// for both atomic inlines and extras (left/right).
enum _PHKind { atomic, leftExtra, rightExtra, emptySpan }

class _InlinePlaceholder {
  final _PHKind kind;
  final RenderBoxModel? owner;
  final RenderBox? atomic;
  final double? width; // used for merged empty span extras
  _InlinePlaceholder._(this.kind, {this.owner, this.atomic, this.width});
  factory _InlinePlaceholder.atomic(RenderBox rb) => _InlinePlaceholder._(_PHKind.atomic, atomic: rb);
  factory _InlinePlaceholder.leftExtra(RenderBoxModel owner) => _InlinePlaceholder._(_PHKind.leftExtra, owner: owner);
  factory _InlinePlaceholder.rightExtra(RenderBoxModel owner) => _InlinePlaceholder._(_PHKind.rightExtra, owner: owner);
  factory _InlinePlaceholder.emptySpan(RenderBoxModel owner, double width) =>
      _InlinePlaceholder._(_PHKind.emptySpan, owner: owner, width: width);
}

class _SpanPaintEntry {
  _SpanPaintEntry(this.box, this.style, this.rects, this.depth, [this.synthetic = false]);

  final RenderBoxModel box;
  final CSSRenderStyle style;
  final List<ui.TextBox> rects;
  final int depth;
  final bool synthetic;
}
