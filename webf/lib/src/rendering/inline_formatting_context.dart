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
    // Use actual content width (longestLine) for shrink-to-fit behavior
    final double width = para.longestLine;
    final double height = para.height;

    // Update children offsets from placeholder boxes (atomic inlines)
    _updateChildOffsetsFromParagraph();

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
        final Rect clip = Rect.fromLTRB(
          offset.dx,
          offset.dy + lineTop,
          offset.dx + para.width,
          offset.dy + lineBottom,
        );
        context.canvas.save();
        context.canvas.clipRect(clip);
        context.canvas.drawParagraph(para, offset);
        context.canvas.restore();
      }
    }

    // Paint atomic inline children at their parentData offsets (container-relative)
    for (int i = 0; i < _placeholderOrder.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;
      // Find the direct child of container that owns the parentData.offset we set in layout
      RenderBox paintBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) paintBox = p;
        p = p.parent;
      }
      if (!paintBox.hasSize) continue;
      final pd = paintBox.parentData as ContainerBoxParentData<RenderBox>;
      context.paintChild(paintBox, offset + pd.offset);
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
          if (isFirst) left -= (padL + bL);
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
    // Paragraph path: hit test atomic inlines using their parentData offsets
    // Convert content-relative position to container-relative to match parentData.offset space
    final contentOffset = Offset(
      container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue,
      container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue,
    );
    for (int i = 0; i < _placeholderOrder.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;
      // Use the direct child (wrapper) that carries the parentData offset
      RenderBox hitBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) hitBox = p;
        p = p.parent;
      }
      final parentData = hitBox.parentData as ContainerBoxParentData<RenderBox>;
      final local = (position + contentOffset) - (parentData.offset);
      if (hitBox.hitTest(result, position: local)) {
        return true;
      }
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
          pb.addPlaceholder(frame.leftExtras, ph, ui.PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic, baselineOffset: bo);
          paraPos += 1; // account for placeholder char
          _allPlaceholders.add(_InlinePlaceholder.leftExtra(frame.box));
          frame.leftFlushed = true;
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.finer('[IFC] open extras <${_getElementDescription(frame.box)}> leftExtras='
                '${frame.leftExtras.toStringAsFixed(2)}');
          }
        }
      }
    }

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
                // Non-empty: ensure left extras flushed, then add right extras
                _flushPendingLeftExtras();
                if (frame.rightExtras > 0) {
                  final rs = frame.box.renderStyle;
                  final (ph, bo) = _measureTextMetricsFor(rs);
                  pb.addPlaceholder(frame.rightExtras, ph, ui.PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic, baselineOffset: bo);
                  paraPos += 1;
                  _allPlaceholders.add(_InlinePlaceholder.rightExtra(frame.box));
                  if (debugLogInlineLayoutEnabled) {
                    renderingLogger.finer('[IFC] close extras </${_getElementDescription(frame.box)}> rightExtras='
                        '${frame.rightExtras.toStringAsFixed(2)}');
                  }
                }
              } else {
                // Empty span: merge left+right extras into a single placeholder to avoid wrapping
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
        final text = item.getText(_textContent);
        if (text.isEmpty || item.style == null) continue;
        // First content inside any open frames
        if (openFrames.isNotEmpty) {
          for (final f in openFrames) {
            f.hadContent = true;
          }
          _flushPendingLeftExtras();
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
    if (!constraints.hasBoundedWidth) {
      // Unbounded: prefer a reasonable fallback if available, otherwise use a very large width
      initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
          ? fallbackContentMaxWidth
          : 1000000.0;
    } else {
      if (constraints.maxWidth > 0) {
        initialWidth = constraints.maxWidth;
      } else {
        // Bounded but maxWidth <= 0: use fallback content width when available (even in flex),
        // otherwise fall back to a large width to allow natural shaping.
        initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
            ? fallbackContentMaxWidth
            : 1000000.0;
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.fine('[IFC] adjust initialWidth due to maxWidth=${constraints.maxWidth} '
              '→ ${initialWidth.toStringAsFixed(2)} (fallback=${(fallbackContentMaxWidth ?? 0).toStringAsFixed(2)})');
        }
      }
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
        final double targetWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
            ? fallbackContentMaxWidth
            : paragraph.longestLine;
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.fine('[IFC] block-like reflow with fallback width '
              '${targetWidth.toStringAsFixed(2)} (had maxWidth=${constraints.maxWidth})');
        }
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    } else {
      // Non block-like (theoretically unused here) — retain previous behavior.
      final double targetWidth = math.min(
          paragraph.longestLine, constraints.maxWidth.isFinite ? constraints.maxWidth : paragraph.longestLine);
      if (targetWidth != initialWidth) {
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    }
    _paragraph = paragraph;
    _paraLines = paragraph.computeLineMetrics();
    _placeholderBoxes = paragraph.getBoxesForPlaceholders();

    if (debugLogInlineLayoutEnabled) {
      renderingLogger.fine('[IFC] paragraph: width=${paragraph.width.toStringAsFixed(2)} height=${paragraph.height.toStringAsFixed(2)} '
          'longestLine=${paragraph.longestLine.toStringAsFixed(2)} maxLines=${style.lineClamp} exceeded=${paragraph.didExceedMaxLines}');
      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        renderingLogger.finer('  [line $i] baseline=${lm.baseline.toStringAsFixed(2)} height=${lm.height.toStringAsFixed(2)} '
            'ascent=${lm.ascent.toStringAsFixed(2)} descent=${lm.descent.toStringAsFixed(2)} left=${lm.left.toStringAsFixed(2)} width=${lm.width.toStringAsFixed(2)}');
      }
      for (int i = 0; i < _placeholderBoxes.length && i < _placeholderOrder.length; i++) {
        final tb = _placeholderBoxes[i];
        final rb = _placeholderOrder[i];
        renderingLogger.finer('  [ph $i] rect=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
            'child=<${_getElementDescription(rb is RenderBoxModel ? rb : null)}>');
      }
      // Log element ranges
      _elementRanges.forEach((rb, range) {
        renderingLogger.finer('  [range] <${_getElementDescription(rb)}> ${range.$1}..${range.$2}');
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

  void _updateChildOffsetsFromParagraph() {
    if (debugLogInlineLayoutEnabled) {
      renderingLogger.finer('[IFC] updateChildOffsetsFromParagraph placeholders=${_placeholderBoxes.length} order=${_placeholderOrder.length}');
    }
    // Base content offset (padding + border) to convert content-relative positions
    // to the container's coordinate space, matching actual paint offset usage.
    final contentOffset = Offset(
      container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue,
      container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue,
    );
    // Apply offsets to actual children housed in this container
    // We need to map RenderEventListener wrappers to their real children when present.
    for (int i = 0; i < _placeholderBoxes.length && i < _placeholderOrder.length; i++) {
      final rb = _placeholderOrder[i];
      if (rb == null) continue;
      final rect = _placeholderBoxes[i];
      // Place child at placeholder's top + margin-top; baseline alignment already encoded by rect
      double left = rect.left;
      double top = rect.top;
      if (rb is RenderBoxModel) {
        left += rb.renderStyle.marginLeft.computedValue;
        top += rb.renderStyle.marginTop.computedValue;
      }
      // ParentData offsets are container-relative
      Offset childOffset = contentOffset + Offset(left, top);
      if (rb is RenderBoxModel) {
        // already included margins
      }

      // Walk up to find the direct child of the container to assign offset
      RenderBox target = rb;
      RenderObject? p = rb.parent;
      bool hasWrapper = false;
      while (p != null && p != container) {
        if (p is RenderBox) {
          target = p;
          hasWrapper = true;
        }
        p = p.parent;
      }
      if (p == container && target is RenderBox) {
        final pd = target.parentData as ContainerBoxParentData<RenderBox>;
        pd.offset = childOffset;
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.finer('[IFC] set parentData for <${_getElementDescription(rb is RenderBoxModel ? rb : null)}> target=${target.runtimeType} offset=(${childOffset.dx.toStringAsFixed(2)},${childOffset.dy.toStringAsFixed(2)})');
        }
        // Ensure the atomic render box itself has zero local offset inside wrapper
        // so wrapper's parentData carries the full translation.
        if (hasWrapper && rb.parentData is BoxParentData) {
          (rb.parentData as BoxParentData).offset = Offset.zero;
        }
        // Compute and record a visual border-box size for atomic inline to be applied via tight constraints later.
        if (rb is RenderBoxModel) {
          final CSSRenderStyle s = rb.renderStyle;
          final double padL = s.paddingLeft.computedValue;
          final double padR = s.paddingRight.computedValue;
          final double padT = s.paddingTop.computedValue;
          final double padB = s.paddingBottom.computedValue;
          final double bL = s.borderLeftWidth?.computedValue ?? 0.0;
          final double bR = s.borderRightWidth?.computedValue ?? 0.0;
          final double bT = s.borderTopWidth?.computedValue ?? 0.0;
          final double bB = s.borderBottomWidth?.computedValue ?? 0.0;
          final double bw = (rb.boxSize?.width ?? (rb.hasSize ? rb.size.width : 0.0));
          final double bh = (rb.boxSize?.height ?? (rb.hasSize ? rb.size.height : 0.0));
          final double visualW = bw + padL + padR + bL + bR;
          final double visualH = bh + padT + padB + bT + bB;
          _measuredVisualSizes[target] = Size(visualW, visualH);
        }
      }
    }

    // Also set offsets for non-atomic inline boxes using paragraph ranges.
    if (_paragraph != null && _elementRanges.isNotEmpty) {
      _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
        List<ui.TextBox> rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
        bool synthesized = false;
        if (rects.isEmpty) {
          rects = _synthesizeRectsForEmptySpan(box);
          if (rects.isEmpty) return;
          synthesized = true;
        }

        // Use the first fragment as the anchor
        final style = box.renderStyle;
        final padL = style.paddingLeft.computedValue;
        final padT = style.paddingTop.computedValue;
        final bL = style.borderLeftWidth?.computedValue ?? 0.0;
        final bT = style.borderTopWidth?.computedValue ?? 0.0;
        final mL = style.marginLeft.computedValue;

        final tb = rects.first;
        double left;
        double top;
        if (synthesized) {
          // Synthetic rect spans left/right extras. Anchor to the paragraph line band
          // like real text fragments: use line top minus padding+border, not CSS line-height.
          left = tb.left + mL;
          top = tb.top - (padT + bT);
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.finer('[IFC] synthesize offset for <${_getElementDescription(box)}>: '
                'tb.top=${tb.top.toStringAsFixed(2)} padT=${padT.toStringAsFixed(2)} bT=${bT.toStringAsFixed(2)} '
                '-> top=${top.toStringAsFixed(2)}');
          }
        } else {
          // Real text fragment: move outward by padding+border to reach border-box top-left
          left = tb.left - (padL + bL);
          top = tb.top - (padT + bT);
        }

        final Offset childOffset = contentOffset + Offset(left, top);

        // Assign offset to the direct child (wrapper if present)
        RenderBox target = box;
        RenderObject? p = box.parent;
        bool hasWrapper = false;
        while (p != null && p != container) {
          if (p is RenderBox) {
            target = p;
            hasWrapper = true;
          }
          p = p.parent;
        }
        if (p == container && target is RenderBox) {
          final pd = target.parentData as ContainerBoxParentData<RenderBox>;
          pd.offset = childOffset;
          if (debugLogInlineLayoutEnabled) {
            renderingLogger.finer('[IFC] set inline parentData for <${_getElementDescription(box)}> target=${target.runtimeType} offset=(${childOffset.dx.toStringAsFixed(2)},${childOffset.dy.toStringAsFixed(2)})');
          }
          if (hasWrapper && box.parentData is BoxParentData) {
            (box.parentData as BoxParentData).offset = Offset.zero;
          }

          // Compute and store a debug visual size/rect for the inline element for Inspector.
          double lEdge, rEdge, tEdge, bEdge;
          if (synthesized) {
            // Synthesized rect from extras: include content height using effective line-height
            // to better match painted area of empty inline spans.
            final double lineHeight = _effectiveLineHeightPx(style);
            lEdge = tb.left;
            rEdge = tb.right;
            tEdge = tb.top - (lineHeight + padT + bT);
            bEdge = tb.top + (style.paddingBottom.computedValue + (style.borderBottomWidth?.computedValue ?? 0.0));
          } else {
            // Union across fragments: first/last horizontally; min/max vertically
            lEdge = rects.first.left - (padL + bL);
            rEdge = rects.last.right + (style.paddingRight.computedValue + (style.borderRightWidth?.computedValue ?? 0.0));
            double minTop = rects.map((e) => e.top).reduce(math.min) - (padT + bT);
            double maxBottom = rects.map((e) => e.bottom).reduce(math.max) +
                (style.paddingBottom.computedValue + (style.borderBottomWidth?.computedValue ?? 0.0));
            tEdge = minTop;
            bEdge = maxBottom;
          }
          final Rect contentRect = Rect.fromLTRB(lEdge, tEdge, rEdge, bEdge);
          final Size visualSize = Size(contentRect.width, contentRect.height);
          // Record measured size for the direct child to be laid out tightly later.
          _measuredVisualSizes[target] = visualSize;
        }
      });
    }
  }

  // Paint backgrounds and borders for non-atomic inline elements using paragraph range boxes
  void _paintInlineSpanDecorations(PaintingContext context, Offset offset, {double? lineTop, double? lineBottom}) {
    if (_elementRanges.isEmpty || _paragraph == null) return;

    // Build entries with depth for proper painting order (parents first)
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
        // Synthesize rect for empty spans using extras placeholders
        rects = _synthesizeRectsForEmptySpan(box);
        if (rects.isEmpty) return;
        synthesized = true;
      }
      entries.add(_SpanPaintEntry(box, style, rects, _depthFromContainer(box), synthesized));
    });

    entries.sort((a, b) => a.depth.compareTo(b.depth));
    final canvas = context.canvas;

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
        // If painting per-line, skip fragments not intersecting the current line band
        if (lineTop != null && lineBottom != null) {
          if (tb.bottom <= lineTop || tb.top >= lineBottom) continue;
        }
        double left = tb.left;
        double right = tb.right;
        double top = tb.top;
        double bottom = tb.bottom;

        // If the text box has zero height (empty span), synthesize a content height
        // based on CSS line-height semantics so padding/border wrap visible content.
        if ((bottom - top).abs() < 0.5) {
          // Prefer paragraph height, otherwise approximate NORMAL as ~1.125×font-size
          final double fs = s.fontSize.computedValue;
          final double paraH = _paragraph?.height ?? 0;
          final double approxNormal = fs * 1.125; // heuristic tuned to typical UA default
          final double contentH = math.max(paraH, approxNormal);
          final double center = (top + bottom) / 2.0;
          top = center - contentH / 2.0;
          bottom = center + contentH / 2.0;
        }

        final bool isFirst = (i == 0);
        final bool isLast = (i == e.rects.length - 1);

        // Extend horizontally on first/last fragments
        if (!e.synthetic) {
          if (isFirst) left -= (padL + bL);
          if (isLast) right += (padR + bR);
        }
        // Each line fragment paints its full vertical content (padding + border)
        top -= (padT + bT);
        bottom += (padB + bB);

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

        // Background
        if (s.backgroundColor?.value != null) {
          final bg = Paint()..color = s.backgroundColor!.value;
          canvas.drawRect(rect, bg);
        }

        // Borders
        final p = Paint()..style = PaintingStyle.fill;
        // Top/bottom borders on every fragment to match full per-line painting
        if (bT > 0) {
          p.color = s.borderTopColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, bT), p);
        }
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
        return 1.2; // CSS 'normal' approximation
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
