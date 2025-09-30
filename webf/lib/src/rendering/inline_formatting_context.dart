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
    TextLeadingDistribution,
    StrutStyle,
    Path,
    PathOperation;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:logging/logging.dart' show Level;
import 'package:webf/src/foundation/inline_layout_logging.dart';

import 'inline_item.dart';
import 'line_box.dart';
import 'inline_items_builder.dart';
import 'inline_layout_debugger.dart';

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
  double _paragraphMinLeft = 0.0; // Painting translation applied to paragraph output.
  bool _paragraphShapedWithHugeWidth = false; // Track when layout used extremely wide shaping.

  // Track how many code units were added to the paragraph (text + placeholders)
  int _paraCharCount = 0;

  // Expose paragraph line metrics for baseline consumers
  List<ui.LineMetrics> get paragraphLineMetrics => _paraLines;

  // Placeholder boxes as reported by Paragraph, in the order placeholders were added.
  List<ui.TextBox> _placeholderBoxes = const [];

  // For text-run placeholders (vertical-align on non-atomic text), store sub-paragraphs
  // aligned by index with _allPlaceholders; null for non text-run placeholders.
  List<ui.Paragraph?> _textRunParas = const [];

  // Baseline offsets computed from a prior layout pass for text-run placeholders.
  // Indexed by occurrence order of textRun placeholders only.
  List<double>? _textRunBaselineOffsets;
  int _textRunBuildIndex = 0;

  // Baseline offsets computed for atomic (inline-block/replaced) placeholders with
  // CSS vertical-align != baseline. Indexed by encounter order of atomic placeholders.
  List<double>? _atomicBaselineOffsets;
  int _atomicBuildIndex = 0;

  // For mapping placeholder index -> RenderBox (atomic inline items only)
  final List<RenderBox?> _placeholderOrder = [];

  // Track all placeholders (atomic and extras) to synthesize boxes for empty spans
  final List<_InlinePlaceholder> _allPlaceholders = [];

  // Debug variables removed after stabilization.

  // Two-pass control: suppress right-extras placeholders in the first pass so
  // we can observe natural line breaks, then selectively re-enable them for
  // inline elements that don't fragment across lines.
  bool _suppressAllRightExtras = false;
  final Set<RenderBoxModel> _forceRightExtrasOwners = <RenderBoxModel>{};

  // When any ancestor establishes horizontal scrolling on X (overflow-x: scroll/auto),
  // avoid breaking within ASCII words and shape with a very wide width to keep
  // long sequences unwrapped. Also, do not shrink paragraph width for trailing
  // extras in this mode to preserve single-line content for scrollers.
  bool _avoidWordBreakInScrollableX = false;

  // Pass-1 bookkeeping was previously used for leading spacers; removed.

  // For mapping inline element RenderBox -> range in paragraph text
  final Map<RenderBoxModel, (int start, int end)> _elementRanges = {};

  // Measured visual sizes (border-box) for inline render boxes (including wrappers)
  final Map<RenderBox, Size> _measuredVisualSizes = {};

  Size? measuredVisualSizeOf(RenderBox box) => _measuredVisualSizes[box];

  // Resolve the RenderBoxModel that carries CSS styles for a placeholder's
  // render box (which may be a wrapper). Walk down a few levels if necessary.
  RenderBoxModel? _resolveStyleBoxForPlaceholder(RenderBox? rb) {
    if (rb is RenderBoxModel) return rb;
    RenderBox? cur = rb;
    for (int i = 0; i < 3; i++) {
      if (cur is RenderObjectWithChildMixin<RenderBox>) {
        final RenderBox? child = (cur as dynamic).child as RenderBox?;
        if (child == null) break;
        if (child is RenderBoxModel) return child;
        cur = child;
        continue;
      }
      break;
    }
    return null;
  }

  // Extra positive Y overflow beyond the paragraph's baseline-bottom caused by
  // CSS relative offsets or transforms on atomic inline boxes. This is used by
  // the container to extend its scrollable height when using the paragraph path.
  double additionalPositiveYOffsetFromAtomicPlaceholders() {
    if (_paragraph == null || _placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return 0.0;

    // Base paragraph height measured as sum of line heights when available.
    final double baseHeight = _paraLines.isEmpty
        ? (_paragraph?.height ?? 0.0)
        : _paraLines.fold<double>(0.0, (sum, lm) => sum + lm.height);

    double maxBottom = baseHeight;
    final int n = math.min(_placeholderBoxes.length, _allPlaceholders.length);
    for (int i = 0; i < n; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      final tb = _placeholderBoxes[i];
      // Map placeholder index to the corresponding render box (may be a wrapper).
      RenderBox? rb = ph.atomic;
      if (rb == null) continue;
      final RenderBoxModel? styleBox = _resolveStyleBoxForPlaceholder(rb);
      if (styleBox == null) continue;
      double extraDy = 0.0;
      final Offset? rel = CSSPositionedLayout.getRelativeOffset(styleBox.renderStyle);
      if (rel != null && rel.dy > 0) extraDy += rel.dy;
      final Offset? tr = styleBox.renderStyle.effectiveTransformOffset;
      if (tr != null && tr.dy > 0) extraDy += tr.dy;
      final double bottom = tb.bottom + extraDy;
      if (bottom > maxBottom) maxBottom = bottom;
    }
    final double extra = maxBottom - baseHeight;
    return extra > 0 ? extra : 0.0;
  }

  // Additional vertical overflow beyond the paragraph's total line-height
  // introduced by atomic inline boxes (e.g., inline-block, replaced). If an
  // atomic box's own scrollable height exceeds the line box height it occupies,
  // the container's scrollable overflow should extend to include that bottom.
  // This mirrors CSS Overflow propagation for inline formatting contexts where
  // overflow is visible.
  double additionalOverflowHeightFromAtomicPlaceholders() {
    if (_paragraph == null || _placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return 0.0;

    // Base paragraph height measured as sum of line heights when available.
    final double baseHeight = _paraLines.isEmpty
        ? (_paragraph?.height ?? 0.0)
        : _paraLines.fold<double>(0.0, (sum, lm) => sum + lm.height);

    double maxBottom = baseHeight;
    final int n = math.min(_placeholderBoxes.length, _allPlaceholders.length);
    for (int i = 0; i < n; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      // Paragraph-reported box for the placeholder position in paragraph space.
      final tb = _placeholderBoxes[i];
      // Map placeholder index to the corresponding render box (may be a wrapper).
      final RenderBox? rb = ph.atomic;
      if (rb == null) continue;

      // Resolve to a RenderBoxModel that carries CSS styles/scrollable sizes.
      final RenderBoxModel? styleBox = _resolveStyleBoxForPlaceholder(rb);
      if (styleBox == null || !styleBox.hasSize) continue;

      // Determine child's effective scrollable height: use scrollableSize when the
      // child is not itself a scroll container (overflow visible); otherwise the
      // element's own box size defines its scroll range contribution.
      final rs = styleBox.renderStyle;
      final bool childScrolls = rs.effectiveOverflowX != CSSOverflowType.visible ||
          rs.effectiveOverflowY != CSSOverflowType.visible;
      final Size childExtent = childScrolls
          ? (styleBox.boxSize ?? styleBox.size)
          : styleBox.scrollableSize;

      double candidateBottom = tb.top + (childExtent.height.isFinite ? childExtent.height : 0.0);

      // Account for positive downward relative/transform offsets on the atomic box.
      final Offset? rel = CSSPositionedLayout.getRelativeOffset(rs);
      if (rel != null && rel.dy > 0) candidateBottom += rel.dy;
      final Offset? tr = rs.effectiveTransformOffset;
      if (tr != null && tr.dy > 0) candidateBottom += tr.dy;

      if (candidateBottom > maxBottom) {
        maxBottom = candidateBottom;
      }
    }

    final double extra = maxBottom - baseHeight;
    return extra > 0 ? extra : 0.0;
  }

  // Additional horizontal overflow to the right beyond the paragraph's
  // visual max line width introduced by atomic inline boxes whose own
  // scrollable width exceeds the inline box width used for line layout.
  // Returns the extra width in px to add to paragraph width.
  double additionalPositiveXOverflowFromAtomicPlaceholders() {
    if (_paragraph == null || _placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return 0.0;

    // Base paragraph right edge is the visual max line width.
    final double baseRight = (_paraLines.isEmpty)
        ? (_paragraph?.maxIntrinsicWidth ?? _paragraph?.width ?? 0.0)
        : _paraLines.fold<double>(0.0, (maxR, lm) => math.max(maxR, lm.left + lm.width));

    double maxRight = baseRight;
    final int n = math.min(_placeholderBoxes.length, _allPlaceholders.length);
    for (int i = 0; i < n; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      final tb = _placeholderBoxes[i];
      final RenderBox? rb = ph.atomic;
      if (rb == null) continue;
      final RenderBoxModel? styleBox = _resolveStyleBoxForPlaceholder(rb);
      if (styleBox == null || !styleBox.hasSize) continue;

      final rs = styleBox.renderStyle;
      final bool childScrolls = rs.effectiveOverflowX != CSSOverflowType.visible ||
          rs.effectiveOverflowY != CSSOverflowType.visible;
      final Size childExtent = childScrolls
          ? (styleBox.boxSize ?? styleBox.size)
          : styleBox.scrollableSize;

      double candidateRight = tb.left + (childExtent.width.isFinite ? childExtent.width : 0.0);
      final Offset? rel = CSSPositionedLayout.getRelativeOffset(rs);
      if (rel != null && rel.dx > 0) candidateRight += rel.dx;
      final Offset? tr = rs.effectiveTransformOffset;
      if (tr != null && tr.dx > 0) candidateRight += tr.dx;

      // Include right margin since line layout accounts for margins horizontally
      // when distributing inline-level boxes.
      candidateRight += rs.marginRight.computedValue;

      if (candidateRight > maxRight) maxRight = candidateRight;
    }

    final double extra = maxRight - baseRight;
    return extra > 0 ? extra : 0.0;
  }

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
    final bool clipText = (container as RenderBoxModel).renderStyle.backgroundClip == CSSBackgroundBoundary.text;
    final Color baseColor = rs.color.value;
    final Color effectiveColor = clipText ? baseColor.withAlpha(0xFF) : baseColor;
    return ui.TextStyle(
      // For clip-text, force fully-opaque glyphs for the mask (ignore alpha).
      color: effectiveColor,
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

  // (moved) _Boundary is defined at top-level below.

  // Compute a visual longest line that accounts for trailing extras (padding/border/margin)
  // on the last fragment of inline elements. This adjusts for our choice to not insert
  // right-extras placeholders for non-empty spans.
  double _computeVisualLongestLine() {
    if (_paragraph == null || _paraLines.isEmpty) {
      _paragraphMinLeft = 0.0;
      return _paragraph?.longestLine ?? 0;
    }
    double minLeft = double.infinity; // Track smallest line-left reported by Paragraph.
    // Base rights from paragraph line metrics
    final rights = List<double>.generate(
      _paraLines.length,
      (i) {
        final line = _paraLines[i];
        if (line.left.isFinite) {
          minLeft = math.min(minLeft, line.left);
        }
        return line.left + line.width;
      },
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
      if (last.left.isFinite) {
        minLeft = math.min(minLeft, last.left);
      }
      final li = _lineIndexForRect(last);
      if (li < 0) return;
      final s = box.renderStyle;
      final double padR = s.paddingRight.computedValue;
      final double bR = s.effectiveBorderRightWidth.computedValue;
      final double mR = s.marginRight.computedValue;
      final double extended = last.right + padR + bR + mR;
      if (extended > rights[li]) rights[li] = extended;
    });
    if (!minLeft.isFinite) {
      minLeft = 0;
    }
    final bool applyShift = _paragraphShapedWithHugeWidth && minLeft > 0.01;
    _paragraphMinLeft = applyShift ? minLeft : 0.0;
    double baseLongest = _paragraph!.longestLine;
    double visualRight = rights.fold<double>(double.negativeInfinity, (p, v) => v > p ? v : p);
    if (!visualRight.isFinite) {
      visualRight = baseLongest + _paragraphMinLeft;
    }
    double visualWidth = math.max(0, visualRight - _paragraphMinLeft);
    if (!visualWidth.isFinite) {
      visualWidth = baseLongest;
    }
    final double result = visualWidth > baseLongest ? visualWidth : baseLongest;
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.metrics,
      level: Level.FINE,
      message: () => 'visualLongestLine=${result.toStringAsFixed(2)} (base=${baseLongest.toStringAsFixed(2)})',
    );
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
      // Do not paint inline backgrounds/borders for visibility:hidden.
      if (style.isVisibilityHidden) {
        return;
      }
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
        // Filter out any left-extras placeholder boxes for this owner wherever they appear
        // in the rects list (bidi reordering may place them non-leading visually).
        final tbPH = _leftExtraTextBoxFor(box);
        if (tbPH != null) {
          rects = rects.where((r) => !_sameRect(r, tbPH)).toList(growable: false);
        }
      }
      entries.add(_SpanPaintEntry(box, style, rects, _depthFromContainer(box), synthesized));
    });
    entries.sort((a, b) => a.depth.compareTo(b.depth));
    return entries;
  }

  // Shrink paragraph width, if needed, so EACH line can accommodate trailing
  // extras (padding/border/margin) of inline elements that end on that line,
  // without causing glyphs to overlap borders. Avoids over-reserving by
  // skipping elements that already have a right-extras placeholder (their
  // width is already accounted for by the paragraph).
  void _shrinkWidthForTrailingExtras(ui.Paragraph paragraph, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.maxWidth.isFinite || constraints.maxWidth <= 0) return;
    // Do not shrink paragraph width in scrollable-X mode; we want a single line
    // with horizontal overflow rather than forced wrapping.
    if (_avoidWordBreakInScrollableX) return;
    // Also skip shrinking when CSS white-space suppresses soft wrapping
    // (nowrap or pre). In these modes, automatic line breaks must not be
    // introduced by width shrinking; overflow should remain horizontal.
    final WhiteSpace ws = (container as RenderBoxModel).renderStyle.whiteSpace;
    if (ws == WhiteSpace.nowrap || ws == WhiteSpace.pre) return;

    double maxW = constraints.maxWidth;

    // Helper to compute per-line trailing reserve based on current paragraph layout.
    List<double> _computePerLineReserve(ui.Paragraph p) {
      final lines = p.computeLineMetrics();
      if (lines.isEmpty) return const [];
      final reserves = List<double>.filled(lines.length, 0.0, growable: false);

      // Build a quick lookup for which elements already emitted a right-extras placeholder
      final Set<RenderBoxModel> hasRightPH = {};
      for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
        final ph = _allPlaceholders[i];
        if (ph.kind == _PHKind.rightExtra && ph.owner != null) {
          hasRightPH.add(ph.owner!);
        }
      }

      _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
        final int sIdx = range.$1;
        final int eIdx = range.$2;
        if (eIdx <= sIdx) return;
        final rects = p.getBoxesForRange(sIdx, eIdx);
        if (rects.isEmpty) return;
        final last = rects.last;
        final linesLocal = p.computeLineMetrics();
        final int li = _bestOverlapLineIndexForBox(last, linesLocal);
        if (li < 0) return;
        // Skip reserve if a right-extras placeholder already accounts for it.
        if (hasRightPH.contains(box)) return;
        final s = box.renderStyle;
        final double extra = s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue +
            s.marginRight.computedValue;
        if (extra > reserves[li]) reserves[li] = extra;
      });
      return reserves;
    }

    // Iteratively shrink width so each line satisfies width + reserve <= maxW.
    // Cap iterations to avoid long loops.
    double chosen = maxW;
    for (int iter = 0; iter < 6; iter++) {
      final lines = paragraph.computeLineMetrics();
      if (lines.isEmpty) break;
      final reserves = _computePerLineReserve(paragraph);
      if (reserves.isEmpty) break;
      bool ok = true;
      for (int i = 0; i < lines.length && i < reserves.length; i++) {
        final int idx = i;
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.metrics,
          message: () => 'line[$idx] width=${lines[idx].width.toStringAsFixed(2)} '
              '+ reserve=${reserves[idx].toStringAsFixed(2)} '
              '→ sum=${(lines[idx].width + reserves[idx]).toStringAsFixed(2)} maxW=${maxW.toStringAsFixed(2)}',
        );
      }
      for (int i = 0; i < lines.length && i < reserves.length; i++) {
        if (lines[i].width + reserves[i] > maxW + 0.1) {
          ok = false;
          break;
        }
      }
      if (ok) break;

      // Compute an estimate of how much we need to shrink, but broaden the
      // search space to allow crossing word-break thresholds. Limiting the
      // lower bound to (chosen - worstNeed) can be insufficient when a tiny
      // reduction does not trigger a new line break. Use [0, chosen] to ensure
      // we find a width that satisfies width + reserve <= maxW.
      double hi = chosen;
      double lo = 0.0;
      double midChosen = chosen;
      for (int it = 0; it < 6; it++) {
        final double mid = (hi + lo) / 2.0;
        paragraph.layout(ui.ParagraphConstraints(width: mid));
        final testLines = paragraph.computeLineMetrics();
        final testRes = _computePerLineReserve(paragraph);
        bool pass = true;
        for (int i = 0; i < testLines.length && i < testRes.length; i++) {
          if (testLines[i].width + testRes[i] > maxW + 0.1) {
            pass = false;
            break;
          }
        }
        if (pass) {
          midChosen = mid;
          lo = mid;
        } else {
          hi = mid;
        }
      }
      chosen = midChosen;
      paragraph.layout(ui.ParagraphConstraints(width: chosen));
    }

    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.sizing,
      level: Level.FINE,
      message: () => 'reserve trailing extras (all lines): width '
          '${maxW.toStringAsFixed(2)} → ${chosen.toStringAsFixed(2)}',
    );
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
  // CSS min-content width depends on white-space:
  //  - For normal/pre-wrap: roughly the longest unbreakable segment (“word”).
  //  - For nowrap/pre: no soft wrap opportunities; min-content equals the
  //    max-content width (entire line width).
  // This value feeds flex auto-min-size to prevent over/under‑constraining.
  double get paragraphMinIntrinsicWidth {
    if (_paragraph == null) return 0;

    final CSSRenderStyle cStyle = (container as RenderBoxModel).renderStyle;
    final WhiteSpace ws = cStyle.whiteSpace;
    // Treat nowrap/pre as unbreakable content: min-content equals max-content.
    if (ws == WhiteSpace.nowrap || ws == WhiteSpace.pre) {
      return paragraphMaxIntrinsicWidth;
    }

    double? engineMin;
    try {
      engineMin = (_paragraph as dynamic).minIntrinsicWidth as double?;
    } catch (_) {
      engineMin = null;
    }
    final double approx = _approxParagraphMinIntrinsicWidth();
    if (engineMin != null && engineMin.isFinite && engineMin > 0) {
      // Use the smaller of engine-provided minIntrinsic and our token-based
      // approximation to better match CSS min-content behavior around hyphens
      // and similar break opportunities.
      if (approx.isFinite && approx > 0) return math.min(engineMin, approx);
      return engineMin;
    }
    if (approx.isFinite && approx > 0) return approx;
    return _paragraph!.longestLine;
  }

  // Approximate the paragraph's min intrinsic width by measuring the widest
  // unbreakable segment. Split on whitespace, hard hyphen '-', soft hyphen
  // U+00AD, zero-width space U+200B, and '/'. This reduces the auto min-size
  // of flex items to a content-based minimum closer to browsers.
  double _approxParagraphMinIntrinsicWidth() {
    if (_paragraph == null || _textContent == null || _textContent!.isEmpty) return 0;
    final String s = _textContent!;
    int i = 0;
    double maxToken = 0;
    while (i < s.length) {
      // Skip break chars
      while (i < s.length && _isBreakChar(s.codeUnitAt(i))) i++;
      final int start = i;
      while (i < s.length && !_isBreakChar(s.codeUnitAt(i))) i++;
      final int end = i;
      if (end > start) {
        final double w = _measureRangeWidth(start, end);
        if (w.isFinite) maxToken = math.max(maxToken, w);
      }
    }
    if (maxToken <= 0) return _paragraph!.longestLine;
    return maxToken;
  }

  bool _isBreakChar(int cu) {
    // Whitespace
    if (cu == 0x20 || cu == 0x09 || cu == 0x0A || cu == 0x0D || cu == 0x0B || cu == 0x0C) return true;
    // Hyphen-minus, slash, soft hyphen, zero-width space
    if (cu == 0x2D || cu == 0x2F || cu == 0x00AD || cu == 0x200B) return true;
    return false;
  }

  double _measureRangeWidth(int start, int end) {
    try {
      final boxes = _paragraph!.getBoxesForRange(start, end);
      if (boxes.isEmpty) return 0;
      double minL = double.infinity;
      double maxR = 0;
      for (final b in boxes) {
        if (b.left < minL) minL = b.left;
        if (b.right > maxR) maxR = b.right;
      }
      final double w = (maxR - minL).abs();
      if (!w.isFinite || w <= 0) {
        double maxSingle = 0;
        for (final b in boxes) {
          final double bw = (b.right - b.left).abs();
          if (bw > maxSingle) maxSingle = bw;
        }
        return maxSingle;
      }
      return w;
    } catch (_) {
      return 0;
    }
  }

  // Expose visual longest line width (accounts for trailing extras) for
  // consumers that need a scrollable content width when using paragraph path.
  double get paragraphVisualMaxLineWidth => _computeVisualLongestLine();

  // Expose max-intrinsic width when available from the engine; fall back to
  // longestLine which approximates the unwrapped content width.
  double get paragraphMaxIntrinsicWidth {
    if (_paragraph != null) {
      try {
        final double w = (_paragraph as dynamic).maxIntrinsicWidth as double? ?? _paragraph!.longestLine;
        return w.isFinite ? w : _paragraph!.longestLine;
      } catch (_) {
        return _paragraph!.longestLine;
      }
    }
    return 0;
  }

  // Expose paragraph object for consumers (Flow) that need paragraph height fallback.
  ui.Paragraph? get paragraph => _paragraph;

  // Relayout the existing paragraph to a new width and refresh line/placeholder caches.
  // Used by shrink-to-fit adjustments (e.g., inline-block auto width) so that
  // text inside the element is positioned relative to the final used width.
  void relayoutParagraphToWidth(double width) {
    if (_paragraph == null) return;
    if (!width.isFinite || width <= 0) return;
    _paragraph!.layout(ui.ParagraphConstraints(width: width));
    _paraLines = _paragraph!.computeLineMetrics();
    _placeholderBoxes = _paragraph!.getBoxesForPlaceholders();
    // After changing line breaks/positions, refresh atomic inline offsets so
    // paint and hit testing use the updated placeholder positions (e.g., after
    // shrink-to-fit adjusts the used content width of an inline-block).
    _applyAtomicInlineParentDataOffsets();
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.sizing,
      level: Level.FINE,
      message: () => 'relayout paragraph to width=${width.toStringAsFixed(2)}',
    );
  }

  // Leading spacer logic removed; pass 2 only re-enables right extras for
  // single-line owners and relies on per-line reserves for others.

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
    // Two-pass build: first lay out without right-extras placeholders to
    // observe natural breaks, then re-layout with right-extras only for
    // inline elements that do not fragment across lines.
    _suppressAllRightExtras = true;
    _forceRightExtrasOwners.clear();
    _buildAndLayoutParagraph(constraints);
    // Compute baseline offsets for text-run vertical-align placeholders (top/middle/bottom)
    bool needsVARebuild = _computeTextRunBaselineOffsets() | _computeAtomicBaselineOffsets();

    // Second pass: Only add right-extras placeholders for inline elements that
    // did NOT fragment across lines in pass 1. For fragmented spans, we rely on
    // per-line trailing reserves to avoid altering the chosen breaks.
    _forceRightExtrasOwners.clear();
    for (final entry in _elementRanges.entries) {
      final box = entry.key;
      final (int sIdx, int eIdx) = entry.value;
      if (eIdx <= sIdx) continue;
      final styleR = box.renderStyle;
      final double extraR = styleR.paddingRight.computedValue + styleR.effectiveBorderRightWidth.computedValue +
          styleR.marginRight.computedValue;
      if (extraR <= 0) continue;
      final rects = _paragraph!.getBoxesForRange(sIdx, eIdx);
      if (rects.isEmpty) continue;
      final int firstLine = _lineIndexForRect(rects.first);
      final int lastLine = _lineIndexForRect(rects.last);
      if (firstLine >= 0 && firstLine == lastLine) {
        _forceRightExtrasOwners.add(box);
      }
    }
    if (_forceRightExtrasOwners.isNotEmpty || needsVARebuild) {
      _suppressAllRightExtras = false;
      InlineLayoutLog.log(
        impl: InlineImpl.paragraphIFC,
        feature: InlineFeature.placeholders,
        level: Level.FINE,
        message: () => 'PASS 2: enable right extras for ${_forceRightExtrasOwners.length} single-line owners'
            '${needsVARebuild ? ' + apply text-run baseline offsets' : ''}',
      );
      _buildAndLayoutParagraph(constraints);
      // Clear offsets after they are consumed in PASS 2
      _textRunBaselineOffsets = null;
      _atomicBaselineOffsets = null;
    }

    // Compute size from paragraph
    final para = _paragraph!;
    // For nowrap+ellipsis scenarios (with overflow not visible), browsers keep the
    // line box width equal to the available content width so truncation/ellipsis
    // can occur at the right edge. Honor the bounded width directly in this case.
    final CSSRenderStyle cStyle = (container as RenderBoxModel).renderStyle;
    final bool wantsEllipsis = cStyle.effectiveTextOverflow == TextOverflow.ellipsis &&
        (cStyle.effectiveOverflowX != CSSOverflowType.visible) &&
        (cStyle.whiteSpace == WhiteSpace.nowrap || cStyle.whiteSpace == WhiteSpace.pre);
    // Use visual longest line for general shrink-to-fit; override with bounded width when keeping ellipsis.
    double width = _computeVisualLongestLine();
    if (wantsEllipsis && constraints.hasBoundedWidth && constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
      width = constraints.maxWidth;
    }
    double height = para.height;
    // If there's no text (only placeholders) and the container explicitly sets
    // line-height: 0, browsers size each line to the tallest atomic inline on
    // that line without adding extra leading. Flutter's paragraph may report a
    // slightly larger line height due to internal metrics. Normalize by
    // summing per-line max placeholder heights.
    if (_placeholderBoxes.isNotEmpty) {
      // Determine if the paragraph has any real text glyphs (exclude placeholders).
      final int _placeholderCount = math.min(_placeholderBoxes.length, _allPlaceholders.length);
      final bool _hasTextGlyphs = (_paraCharCount - _placeholderCount) > 0;
      // When there is no in-flow text (only atomic inline boxes like inline-block/replaced),
      // browsers size each line to the tallest atomic inline on that line. Vertical margins
      // do not contribute to the line box height. Flutter's paragraph may include margins or
      // extra leading in placeholder rectangles; normalize by summing the per-line maximum
      // owner border-box heights and using that as the paragraph height.
      if (!_hasTextGlyphs) {
        // Build per-line maxes for two measures:
        // - owner border-box height (ignores vertical margins)
        // - placeholder (paragraph) height (includes vertical margins if any)
        final Map<int, double> lineMaxOwner = <int, double>{};
        final Map<int, double> lineMaxTB = <int, double>{};
        final int n = math.min(_placeholderBoxes.length, _allPlaceholders.length);
        for (int i = 0; i < n; i++) {
          final ph = _allPlaceholders[i];
          if (ph.kind != _PHKind.atomic) continue;
          final tb = _placeholderBoxes[i];
          final double tbH = tb.bottom - tb.top;
          final int li = _lineIndexForRect(tb);
          if (li < 0) continue;
          final RenderBox? rb = i < _placeholderOrder.length ? _placeholderOrder[i] : null;
          final RenderBoxModel? styleBox = _resolveStyleBoxForPlaceholder(rb);
          double ownerBorderHeight = 0.0;
          if (styleBox != null) {
            final Size sz = styleBox.boxSize ?? (styleBox.hasSize ? styleBox.size : Size.zero);
            ownerBorderHeight = sz.height.isFinite ? sz.height : 0.0;
          }
          final double prevOwner = lineMaxOwner[li] ?? 0.0;
          if (ownerBorderHeight > prevOwner) lineMaxOwner[li] = ownerBorderHeight;
          final double prevTB = lineMaxTB[li] ?? 0.0;
          if (tbH > prevTB) lineMaxTB[li] = tbH;
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.metrics,
            message: () => 'lh0 line=$li phIdx=$i ownerH=${ownerBorderHeight.toStringAsFixed(2)} '
                'tbH=${tbH.toStringAsFixed(2)}',
          );
        }
        double sumOwner = 0.0;
        if (lineMaxOwner.isNotEmpty) {
          final keys = lineMaxOwner.keys.toList()..sort();
          for (final k in keys) {
            sumOwner += lineMaxOwner[k] ?? 0.0;
          }
        }
        double sumTB = 0.0;
        if (lineMaxTB.isNotEmpty) {
          final keys = lineMaxTB.keys.toList()..sort();
          for (final k in keys) {
            sumTB += lineMaxTB[k] ?? 0.0;
          }
        }
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.metrics,
          level: Level.FINE,
          message: () => 'lh0 adjust: paraH=${para.height.toStringAsFixed(2)} '
              'sumOwner=${sumOwner.toStringAsFixed(2)} sumTB=${sumTB.toStringAsFixed(2)}',
        );
        // Apply spec-driven behavior:
        // - If line-height<=0 explicitly, use placeholder heights (includes inline-block vertical margins)
        //   so lines reflect atomic inline margin-box height as browsers do in this case.
        // - Otherwise, only adjust upward using owner border-box sums when paragraph underestimates.
        final CSSRenderStyle cStyle = (container as RenderBoxModel).renderStyle;
        final CSSLengthValue lh = cStyle.lineHeight;
        if (lh.type != CSSLengthType.NORMAL && lh.computedValue <= 0) {
          if (sumTB > 0.0) {
            height = sumTB;
          }
        } else {
          if (sumOwner > 0.0 && (sumOwner - height) > 0.5) {
            height = sumOwner;
          }
        }
      }
    }
    // If there is no text and no placeholders, an IFC with purely out-of-flow content
    // contributes 0 to the in-flow content height per CSS.
    if (_paraCharCount == 0 && _placeholderBoxes.isEmpty) {
      height = 0;
    }
    // Emit diagnostics on paragraph sizing vs. atomic overflow so callers can
    // understand why container scrollable height may exceed box height.
    final double baseHeight = _paraLines.isEmpty
        ? (_paragraph?.height ?? 0.0)
        : _paraLines.fold<double>(0.0, (sum, lm) => sum + lm.height);
    final double extraRel = additionalPositiveYOffsetFromAtomicPlaceholders();
    final double extraAtomic = additionalOverflowHeightFromAtomicPlaceholders();
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.sizing,
      level: Level.FINER,
      message: () =>
          'size result width=${width.toStringAsFixed(2)} height=${height.toStringAsFixed(2)} baseParaH=${baseHeight.toStringAsFixed(2)} extraY(rel/transform)=${extraRel.toStringAsFixed(2)} extraY(atomicOverflow)=${extraAtomic.toStringAsFixed(2)}',
    );

    // After paragraph is ready, update parentData.offset for atomic inline children so that
    // paint and hit testing can rely on the standard Flutter offset mechanism.
    _applyAtomicInlineParentDataOffsets();
    return Size(width, height);
  }

  // Compute baseline offsets for text-run placeholders from the current paragraph layout.
  // Returns true if any offsets were computed (triggering a second build to apply them).
  bool _computeTextRunBaselineOffsets() {
    if (_paragraph == null || _placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return false;
    // Count number of textRun placeholders and compute offsets in their encounter order.
    final List<double> offsets = [];
    bool any = false;
    for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.textRun) continue;
      final tb = _placeholderBoxes[i];
      final int li = _lineIndexForRect(tb);
      if (li < 0 || li >= _paraLines.length) {
        offsets.add(0.0);
        continue;
      }
      final lm = _paraLines[li];
      final double h = tb.bottom - tb.top;
      // Determine desired alignment from the owner style
      final va = ph.owner?.renderStyle.verticalAlign ?? VerticalAlign.baseline;
      double baselineOffset;
      switch (va) {
        case VerticalAlign.top:
        case VerticalAlign.textTop:
          baselineOffset = lm.ascent;
          break;
        case VerticalAlign.bottom:
        case VerticalAlign.textBottom:
          baselineOffset = h - lm.descent;
          break;
        case VerticalAlign.middle:
          baselineOffset = (lm.ascent - lm.descent + h) / 2.0;
          break;
        default:
        // baseline (or others): keep baseline alignment with default sub-para baseline
          baselineOffset = h; // fallback harmless value; will not be used if va==baseline
          break;
      }
      offsets.add(baselineOffset);
      if (va != VerticalAlign.baseline) any = true;
      InlineLayoutLog.log(
        impl: InlineImpl.paragraphIFC,
        feature: InlineFeature.offsets,
        level: Level.FINER,
        message: () =>
            'compute VA offset kind=textRun line=$li ascent=${lm.ascent.toStringAsFixed(2)} descent=${lm.descent.toStringAsFixed(2)} h=${h.toStringAsFixed(2)} va=$va → baselineOffset=${baselineOffset.toStringAsFixed(2)}',
      );
    }
    if (any) {
      _textRunBaselineOffsets = offsets;
    }
    return any;
  }

  // Compute baseline offsets for atomic (inline-block/replaced) placeholders with
  // CSS vertical-align set to top/middle/bottom. This aligns their margin-box
  // top/middle/bottom to the line band's top/middle/bottom per CSS.
  bool _computeAtomicBaselineOffsets() {
    if (_paragraph == null || _placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return false;
    final List<double> offsets = [];
    bool any = false;
    for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      // Resolve the render box for this atomic placeholder, unwrapping wrappers for baseline.
      final RenderBox? raw = ph.atomic;
      if (raw == null) continue;
      final RenderBox resolved = _resolveAtomicChildForBaseline(raw);
      if (resolved is! RenderBoxModel) {
        offsets.add(0.0);
        continue;
      }
      final RenderBoxModel rb = resolved;
      final va = rb.renderStyle.verticalAlign;
      if (va == VerticalAlign.baseline) continue;
      final tb = _placeholderBoxes[i];
      final int li = _lineIndexForRect(tb);
      if (li < 0 || li >= _paraLines.length) {
        offsets.add(0.0);
        any = true;
        continue;
      }
      final lm = _paraLines[li];
      final double h = tb.bottom - tb.top;
      double baselineOffset;
      switch (va) {
        case VerticalAlign.top:
        case VerticalAlign.textTop:
          baselineOffset = lm.ascent; // baseline - ascent = line top
          break;
        case VerticalAlign.bottom:
        case VerticalAlign.textBottom:
          baselineOffset = h - lm.descent; // baseline - (h - desc) = line bottom - h
          break;
        case VerticalAlign.middle:
          baselineOffset = (lm.ascent - lm.descent + h) / 2.0;
          break;
        default:
          baselineOffset = h; // should not be used
          break;
      }
      offsets.add(baselineOffset);
      any = true;
      InlineLayoutLog.log(
        impl: InlineImpl.paragraphIFC,
        feature: InlineFeature.offsets,
        message: () => 'compute atomic VA offset line=$li ascent=${lm.ascent.toStringAsFixed(2)} '
            'descent=${lm.descent.toStringAsFixed(2)} h=${h.toStringAsFixed(2)} va=$va → baselineOffset=${baselineOffset.toStringAsFixed(2)}',
      );
    }
    if (any) {
      _atomicBaselineOffsets = offsets;
    }
    return any;
  }

  /// Paint the inline content.
  void paint(PaintingContext context, Offset offset) {
    if (_paragraph == null) return;

    final double shiftX = _paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0;
    final bool applyShift = shiftX.abs() > 0.01;
    if (applyShift) {
      context.canvas.save();
      context.canvas.translate(-shiftX, 0.0);
    }

    try {
      final CSSRenderStyle containerStyle = (container as RenderBoxModel).renderStyle;
      final bool _clipText = containerStyle.backgroundClip == CSSBackgroundBoundary.text;


      // Interleave line background and text painting so that later lines can
      // visually overlay earlier lines when they cross vertically.
      // For each paragraph line: paint decorations for that line, then clip and paint text for that line.
      final para = _paragraph!;
      if (_paraLines.isEmpty) {
        // Fallback: paint decorations then text if no line metrics
        _paintInlineSpanDecorations(context, offset);
        if (!_clipText) {
          context.canvas.drawParagraph(para, offset);
        }
      } else {
        // Pre-scan lines to see if any requires right-side shifting for trailing extras.
        bool anyShift = false;
        if (_elementRanges.isNotEmpty) {
          final Set<RenderBoxModel> hasRightPH = <RenderBoxModel>{};
          for (int p = 0; p < _allPlaceholders.length && p < _placeholderBoxes.length; p++) {
            final ph = _allPlaceholders[p];
            if (ph.kind == _PHKind.rightExtra && ph.owner != null) {
              hasRightPH.add(ph.owner!);
            }
          }
          for (int i = 0; i < _paraLines.length && !anyShift; i++) {
            double shiftSum = 0.0;
            _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
              if (range.$2 <= range.$1) return;
              if (hasRightPH.contains(box)) return; // single-line owners already accounted
              final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
              if (rects.isEmpty) return;
              final last = rects.last;
              final int li = _lineIndexForRect(last);
              if (li != i) return;
              final s = box.renderStyle;
              final double extraR = s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue +
                  s.marginRight.computedValue;
              if (extraR > 0) shiftSum += extraR;
            });
            if (shiftSum > 0) anyShift = true;
          }
        }

        // Collect per-line vertical-align adjustments for non-atomic inline spans (not needed when using
        // text-run placeholders, but kept for future parity; remains empty in common paths).
        final Map<int, List<(ui.TextBox tb, double dy)>> vaAdjust = <int, List<(ui.TextBox, double)>>{};
        if (_elementRanges.isNotEmpty) {
          _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
            final va = box.renderStyle.verticalAlign;
            if (va == VerticalAlign.baseline) return;
            if (range.$2 <= range.$1) return;
            final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
            if (rects.isEmpty) return;
            for (final tb in rects) {
              final int li = _lineIndexForRect(tb);
              if (li < 0 || li >= _paraLines.length) continue;
              final (bandTop, bandBottom, _) = _bandForLine(li);
              double dy = 0.0;
              switch (va) {
                case VerticalAlign.top:
                  dy = bandTop - tb.top;
                  break;
                case VerticalAlign.bottom:
                  dy = bandBottom - tb.bottom;
                  break;
                case VerticalAlign.middle:
                  final double lineMid = (bandTop + bandBottom) / 2.0;
                  final double boxMid = (tb.top + tb.bottom) / 2.0;
                  dy = lineMid - boxMid;
                  break;
                default:
                  // Approximate text-top/text-bottom using line box top/bottom
                  dy = (va == VerticalAlign.textTop)
                      ? (bandTop - tb.top)
                      : (va == VerticalAlign.textBottom)
                          ? (bandBottom - tb.bottom)
                          : 0.0;
                  break;
              }
              if (dy.abs() > 0.01) {
                (vaAdjust[li] ??= []).add((tb, dy));
              }
            }
          });
        }
        final bool anyVAAdjust = vaAdjust.values.any((l) => l.isNotEmpty);

        // Build relative-position adjustments for inline elements with position:relative
        final Map<int, List<(ui.TextBox tb, double dx, double dy)>> relAdjust = <int, List<(ui.TextBox, double, double)>>{};
        if (_elementRanges.isNotEmpty) {
          _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
            final rs = box.renderStyle;
            if (rs.position != CSSPositionType.relative) return;
            final Offset? rel = CSSPositionedLayout.getRelativeOffset(rs);
            if (rel == null || (rel.dx == 0 && rel.dy == 0)) return;
            if (range.$2 <= range.$1) return;
            final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
            if (rects.isEmpty) return;
            for (final tb in rects) {
              final int li = _lineIndexForRect(tb);
              if (li < 0 || li >= _paraLines.length) continue;
              (relAdjust[li] ??= <(ui.TextBox, double, double)>[]).add((tb, rel.dx, rel.dy));
            }
          });
        }
        final bool anyRelAdjust = relAdjust.values.any((l) => l.isNotEmpty);

        // If no line needs shifting for trailing extras, and no vertical-align/relative adjustment,
        // just paint decorations once and draw paragraph once.
        if (!anyShift && !anyVAAdjust && !anyRelAdjust) {
          _paintInlineSpanDecorations(context, offset);
          if (!_clipText) {
            context.canvas.drawParagraph(para, offset);
          }
        } else {
          for (int i = 0; i < _paraLines.length; i++) {
          final lm = _paraLines[i];
          final double lineTop = lm.baseline - lm.ascent;
          final double lineBottom = lm.baseline + lm.descent;

          // Paint only the decorations belonging to this line
          _paintInlineSpanDecorations(context, offset, lineTop: lineTop, lineBottom: lineBottom);

          // Determine aggregate right-extras shift for multi-line owners that end on this line.
          double shiftSum = 0.0;
          double boundaryX = lm.left; // rightmost boundary among owners on this line
          if (_elementRanges.isNotEmpty) {
            final Set<RenderBoxModel> hasRightPH = <RenderBoxModel>{};
            for (int p = 0; p < _allPlaceholders.length && p < _placeholderBoxes.length; p++) {
              final ph = _allPlaceholders[p];
              if (ph.kind == _PHKind.rightExtra && ph.owner != null) {
                hasRightPH.add(ph.owner!);
              }
            }
            _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
              if (range.$2 <= range.$1) return;
              if (hasRightPH.contains(box)) return; // single-line owners already accounted
              final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
              if (rects.isEmpty) return;
              final last = rects.last;
              final int li = _lineIndexForRect(last);
              if (li != i) return;
              final s = box.renderStyle;
              final double extraR = s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue +
                  s.marginRight.computedValue;
              if (extraR > 0) {
                shiftSum += extraR;
                if (last.right > boundaryX) boundaryX = last.right;
              }
            });
          }

          // Build clip regions for normal paint (excluding vertical-align adjusted fragments)
          final double lineRight = lm.left + lm.width;
          final double clipRight = math.max(para.width, lineRight + shiftSum);
          final double lineClipTop = offset.dy + lineTop;
          final double lineClipBottom = offset.dy + lineBottom;

          final Rect leftBase = Rect.fromLTRB(
            offset.dx,
            lineClipTop,
            offset.dx + boundaryX,
            lineClipBottom,
          );
          final Rect rightBase = Rect.fromLTRB(
            offset.dx + boundaryX + shiftSum,
            lineClipTop,
            offset.dx + clipRight,
            lineClipBottom,
          );

          ui.Path _clipMinusVA(Rect base, bool isRightSlice) {
            ui.Path p = ui.Path()
              ..addRect(base);
            final adj = vaAdjust[i] ?? const <(ui.TextBox, double)>[];
            final rel = relAdjust[i] ?? const <(ui.TextBox, double, double)>[];
            if (adj.isEmpty && rel.isEmpty) return p;
            ui.Path sub = ui.Path();
            for (final (tb, _) in adj) {
              final double xShift = isRightSlice ? shiftSum : 0.0;
              final Rect r = Rect.fromLTRB(
                offset.dx + tb.left + xShift,
                offset.dy + tb.top,
                offset.dx + tb.right + xShift,
                offset.dy + tb.bottom,
              );
              if (r.overlaps(base)) sub.addRect(r.intersect(base));
            }
            for (final (tb, dx, dy) in rel) {
              final double xShift = isRightSlice ? shiftSum : 0.0;
              final Rect r0 = Rect.fromLTRB(
                offset.dx + tb.left + xShift,
                offset.dy + tb.top,
                offset.dx + tb.right + xShift,
                offset.dy + tb.bottom,
              );
              final Rect r = Rect.fromLTRB(
                dx < 0 ? r0.left + dx : r0.left,
                dy < 0 ? r0.top + dy : r0.top,
                dx > 0 ? r0.right + dx : r0.right,
                dy > 0 ? r0.bottom + dy : r0.bottom,
              );
              if (r.overlaps(base)) sub.addRect(r.intersect(base));
            }
            if (sub
                .getBounds()
                .isEmpty) return p;
            return ui.Path.combine(ui.PathOperation.difference, p, sub);
          }

          // Left slice (no horizontal shift)
          if (!_clipText) {
            context.canvas.save();
            context.canvas.clipPath(_clipMinusVA(leftBase, false));
            context.canvas.drawParagraph(para, offset);
            context.canvas.restore();
          }

          // Right slice (apply shift if needed)
          if (!_clipText) {
            context.canvas.save();
            context.canvas.clipPath(_clipMinusVA(rightBase, true));
            if (shiftSum != 0.0) {
              context.canvas.translate(shiftSum, 0.0);
            }
            context.canvas.drawParagraph(para, offset);
            context.canvas.restore();
          }

          // Repaint vertical-align adjusted fragments with vertical translation (and horizontal if in right slice)
          final adj = vaAdjust[i] ?? const <(ui.TextBox, double)>[];
          for (final (tb, dy) in adj) {
            final double leftPartRight = math.min(tb.right, boundaryX);
            final double rightPartLeft = math.max(tb.left, boundaryX);

            // Left portion (no x shift)
            if (tb.left < boundaryX && leftPartRight > tb.left) {
              final Rect target = Rect.fromLTRB(
                offset.dx + tb.left,
                offset.dy + tb.top + dy,
                offset.dx + leftPartRight,
                offset.dy + tb.bottom + dy,
              );
              if (!_clipText) {
                context.canvas.save();
                context.canvas.clipRect(target);
                context.canvas.translate(0.0, dy);
                context.canvas.drawParagraph(para, offset);
                context.canvas.restore();
              }
            }
            // Right portion (apply x shift)
            if (tb.right > boundaryX && rightPartLeft < tb.right) {
              final Rect target = Rect.fromLTRB(
                offset.dx + rightPartLeft + shiftSum,
                offset.dy + tb.top + dy,
                offset.dx + tb.right + shiftSum,
                offset.dy + tb.bottom + dy,
              );
              if (!_clipText) {
                context.canvas.save();
                context.canvas.clipRect(target);
                context.canvas.translate(shiftSum, dy);
                context.canvas.drawParagraph(para, offset);
                context.canvas.restore();
              }
            }
          }

          // Repaint relative-position adjusted fragments with XY translation (and horizontal shift if in right slice)
          final rel = relAdjust[i] ?? const <(ui.TextBox, double, double)>[];
          for (final (tb, dx, dy) in rel) {
            final double leftPartRight = math.min(tb.right, boundaryX);
            final double rightPartLeft = math.max(tb.left, boundaryX);

            // Left portion (no x shift)
            if (tb.left < boundaryX && leftPartRight > tb.left) {
              final Rect target = Rect.fromLTRB(
                offset.dx + tb.left + dx,
                offset.dy + tb.top + dy,
                offset.dx + leftPartRight + dx,
                offset.dy + tb.bottom + dy,
              );
              if (!_clipText) {
                context.canvas.save();
                context.canvas.clipRect(target);
                context.canvas.translate(dx, dy);
                context.canvas.drawParagraph(para, offset);
                context.canvas.restore();
              }
            }
            // Right portion (apply x shift)
            if (tb.right > boundaryX && rightPartLeft < tb.right) {
              final Rect target = Rect.fromLTRB(
                offset.dx + rightPartLeft + shiftSum + dx,
                offset.dy + tb.top + dy,
                offset.dx + tb.right + shiftSum + dx,
                offset.dy + tb.bottom + dy,
              );
              if (!_clipText) {
                context.canvas.save();
                context.canvas.clipRect(target);
                context.canvas.translate(shiftSum + dx, dy);
                context.canvas.drawParagraph(para, offset);
                context.canvas.restore();
              }
            }
          }
        }
      }
    }

    // Paint synthetic text-run placeholders (vertical-align on text spans)
    if (_textRunParas.isNotEmpty && _allPlaceholders.isNotEmpty && _placeholderBoxes.isNotEmpty) {
      // Precompute per-line boundary and shift for right-extras, mirroring the logic above
      final List<(double boundaryX, double shiftSum)> lineShift = List.filled(_paraLines.length, (0.0, 0.0));
      if (_elementRanges.isNotEmpty) {
        final Set<RenderBoxModel> hasRightPH = <RenderBoxModel>{};
        for (int p = 0; p < _allPlaceholders.length && p < _placeholderBoxes.length; p++) {
          final ph = _allPlaceholders[p];
          if (ph.kind == _PHKind.rightExtra && ph.owner != null) hasRightPH.add(ph.owner!);
        }
        for (int i = 0; i < _paraLines.length; i++) {
          double boundaryX = _paraLines[i].left;
          double shiftSum = 0.0;
          _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
            if (range.$2 <= range.$1) return;
            if (hasRightPH.contains(box)) return;
            final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
            if (rects.isEmpty) return;
            final last = rects.last;
            final int li = _lineIndexForRect(last);
            if (li != i) return;
            final s = box.renderStyle;
            final double extraR = s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue +
                s.marginRight.computedValue;
            if (extraR > 0) {
              if (last.right > boundaryX) boundaryX = last.right;
              shiftSum += extraR;
            }
          });
          lineShift[i] = (boundaryX, shiftSum);
        }
      }

      for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length && i < _textRunParas.length; i++) {
        final ph = _allPlaceholders[i];
        final sub = _textRunParas[i];
        if (ph.kind != _PHKind.textRun || sub == null) continue;
        final tb = _placeholderBoxes[i];
        final li = _lineIndexForRect(tb);
        double xShift = 0.0;
        if (li >= 0 && li < lineShift.length) {
          final (boundaryX, shiftSum) = lineShift[li];
          if (tb.right > boundaryX) xShift = shiftSum;
        }
        context.canvas.save();
        // Clip to placeholder rect (with applied horizontal shift) to avoid overdraw
        final Rect clip = Rect.fromLTRB(
          offset.dx + tb.left + xShift,
          offset.dy + tb.top,
          offset.dx + tb.right + xShift,
          offset.dy + tb.bottom,
        );
        context.canvas.clipRect(clip);
        context.canvas.drawParagraph(sub, offset.translate(tb.left + xShift, tb.top));
        context.canvas.restore();
      }
    }

    // Gradient text via background-clip: text
    // Draw a gradient (or background color) clipped to glyphs when requested on the container.
    final CSSRenderStyle _rs = (container as RenderBoxModel).renderStyle;
    if (_rs.backgroundClip == CSSBackgroundBoundary.text) {
      final ui.Paragraph? _para = _paragraph;
      if (_para != null) {
        final Gradient? _grad = _rs.backgroundImage?.gradient;
        final Color? _bgc = _rs.backgroundColor?.value;
        if (_grad != null || (_bgc != null && _bgc.alpha != 0)) {
          final double w = _para.longestLine;
          final double h = _para.height;
          if (w > 0 && h > 0) {
            final Rect layer = Rect.fromLTWH(offset.dx, offset.dy, w, h);

            // Compute container border-box rect in current canvas coordinates.
            final double padL = _rs.paddingLeft.computedValue;
            final double padT = _rs.paddingTop.computedValue;
            final double borL = _rs.effectiveBorderLeftWidth.computedValue;
            final double borT = _rs.effectiveBorderTopWidth.computedValue;
            final double contLeft = offset.dx - padL - borL;
            final double contTop = offset.dy - padT - borT;
            final Rect contRect = Rect.fromLTWH(contLeft, contTop, container.size.width, container.size.height);

            // Removed verbose background-clip text diagnostics after stabilization.

            // Use a layer so we can mask the background with glyph alpha using srcIn.
            context.canvas.saveLayer(layer, Paint());
            // Draw the paragraph shape into the layer (uses its own style; color may be null/black).
            context.canvas.drawParagraph(_para, offset);
            // Now overlay the background with srcIn so it is clipped to the glyphs we just drew.
            final Paint p = Paint()
              ..blendMode = BlendMode.srcIn;
            if (_grad != null) {
              p.shader = _grad.createShader(contRect);
              context.canvas.drawRect(layer, p);
            } else {
              p.color = _bgc!;
              context.canvas.drawRect(layer, p);
            }
            context.canvas.restore();

            // Overlay text fill color on top (browser paints text after background).
            // This allows CSS color alpha to tint/cover the gradient, matching browser behavior.
            final Color textFill = _rs.color.value;
            if (textFill.alpha != 0) {
              context.canvas.saveLayer(layer, Paint());
              // Paragraph as mask again
              context.canvas.drawParagraph(_para, offset);
              final Paint fill = Paint()
                ..blendMode = BlendMode.srcIn
                ..color = textFill;
              context.canvas.drawRect(layer, fill);
              context.canvas.restore();
            }
            // End glyph-mask background pass
          }
        }
      }
    }

    // Paint atomic inline children using parentData.offset for consistency.
    // Convert container-origin offsets to content-local by subtracting the content origin.
    final double contentOriginX =
        container.renderStyle.paddingLeft.computedValue + container.renderStyle.effectiveBorderLeftWidth.computedValue;
    final double contentOriginY =
        container.renderStyle.paddingTop.computedValue + container.renderStyle.effectiveBorderTopWidth.computedValue;

    for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      final rb = ph.atomic;
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

    if (DebugFlags.debugPaintInlineLayoutEnabled) {
      _debugPaintParagraph(context, offset);
    }
    } finally {
      if (applyShift) {
        context.canvas.restore();
      }
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

      // Build lookup for owners that already emitted a right-extras placeholder
      final Set<RenderBoxModel> hasRightPH = <RenderBoxModel>{};
      for (int p = 0; p < _allPlaceholders.length && p < _placeholderBoxes.length; p++) {
        final ph = _allPlaceholders[p];
        if (ph.kind == _PHKind.rightExtra && ph.owner != null) {
          hasRightPH.add(ph.owner!);
        }
      }

      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        final double lineTop = lm.baseline - lm.ascent;

        // Compute visual right bound for this line to match paint() behavior
        double boundaryX = lm.left;
        double shiftSum = 0.0;
        if (_elementRanges.isNotEmpty) {
          _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
            if (range.$2 <= range.$1) return;
            if (hasRightPH.contains(box)) return; // single-line owners handled by placeholder
            final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
            if (rects.isEmpty) return;
            final last = rects.last;
            final int li = _lineIndexForRect(last);
            if (li != i) return; // consider owners ending on this line only
            final s = box.renderStyle;
            final double extraR = s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue +
                s.marginRight.computedValue;
            if (extraR > 0) {
              if (last.right > boundaryX) boundaryX = last.right;
              shiftSum += extraR;
            }
          });
        }

        // Match paint(): the right slice is translated by shiftSum, so the
        // visual right edge extends to line.width + shiftSum from line.left.
        final double visualRight = lm.left + lm.width + shiftSum;
        final rect = Rect.fromLTWH(
          offset.dx + lm.left,
          offset.dy + lineTop,
          visualRight - lm.left,
          lm.height,
        );
        canvas.drawRect(rect, lineRectPaint);
        // Baseline line across the visual line width
        final double by = offset.dy + lm.baseline;
        canvas.drawLine(Offset(offset.dx + lm.left, by), Offset(offset.dx + visualRight, by), baselinePaint);
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
        final bL = s.effectiveBorderLeftWidth.computedValue;
        final bR = s.effectiveBorderRightWidth.computedValue;
        final bT = s.effectiveBorderTopWidth.computedValue;
        final bB = s.effectiveBorderBottomWidth.computedValue;

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

    for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      final rb = ph.atomic;
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
        final bL = style.effectiveBorderLeftWidth.computedValue;
        final bR = style.effectiveBorderRightWidth.computedValue;
        final bT = style.effectiveBorderTopWidth.computedValue;
        final bB = style.effectiveBorderBottomWidth.computedValue;

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

    // In RTL, distribute atomic inline boxes from the right by reversing the
    // mapping of placeholders-to-rects within each visual line. Flutter's
    // placeholder ordering is left-to-right; CSS inline formatting in RTL packs
    // boxes from the right edge. Compute a per-line remap: index -> TextBox.
    Map<int, ui.TextBox>? rtlRemap;
    if ((container as RenderBoxModel).renderStyle.direction == TextDirection.rtl) {
      // Group indices by paragraph line index.
      final Map<int, List<int>> byLine = <int, List<int>>{};
      for (int i = 0; i < _allPlaceholders.length && i < _placeholderBoxes.length; i++) {
        final tb = _placeholderBoxes[i];
        final int li = _lineIndexForRect(tb);
        if (li < 0) continue;
        byLine.putIfAbsent(li, () => <int>[]).add(i);
      }
      // Build remap: for each line, reverse the order of TextBoxes.
      rtlRemap = <int, ui.TextBox>{};
      byLine.forEach((int li, List<int> idxs) {
        for (int j = 0; j < idxs.length; j++) {
          final int src = idxs[j];
          final int dst = idxs[idxs.length - 1 - j];
          rtlRemap![src] = _placeholderBoxes[dst];
        }
      });
    }

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

      final tb = (rtlRemap != null && rtlRemap.containsKey(i)) ? rtlRemap[i]! : _placeholderBoxes[i];
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
      InlineLayoutLog.log(
        impl: InlineImpl.paragraphIFC,
        feature: InlineFeature.offsets,
        level: Level.FINER,
        message: () {
          final String desc;
          if (rb is RenderBoxModel) {
            final tag = rb.renderStyle.target.tagName.toLowerCase();
            final id = (rb.renderStyle.target.id ?? '').trim();
            desc = id.isNotEmpty ? '$tag#$id' : tag;
          } else {
            desc = rb.runtimeType.toString();
          }
          return 'set atomic parentData.offset for <$desc> tb=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)},'
              '${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) contentOrigin=('
              '${contentOriginX.toStringAsFixed(2)},${contentOriginY.toStringAsFixed(2)}) → '
              'offset=(${relativeOffset.dx.toStringAsFixed(2)},${relativeOffset.dy.toStringAsFixed(2)})';
        },
      );
      CSSPositionedLayout.applyRelativeOffset(relativeOffset, paintBox);
    }
  }

  /// Get the bounding rectangle for a specific inline element across all line fragments.
  Rect? getBoundsForRenderBox(RenderBox targetBox) {
    // Paragraph path: bounds for atomic inline placeholders
    final idx = _placeholderOrder.indexOf(targetBox);
    if (idx >= 0 && idx < _placeholderBoxes.length) {
      final r = _placeholderBoxes[idx];
      final double left = r.left - (_paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0);
      return Rect.fromLTWH(left, r.top, r.right - r.left, r.bottom - r.top);
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
            final double offsetX = (_paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0);
            for (final tb in rects) {
              final double adjLeft = tb.left - offsetX;
              final double adjRight = tb.right - offsetX;
              minX = (minX == null) ? adjLeft : math.min(minX, adjLeft);
              minY = (minY == null) ? tb.top : math.min(minY, tb.top);
              maxX = (maxX == null) ? adjRight : math.max(maxX, adjRight);
              maxY = (maxY == null) ? tb.bottom : math.max(maxY, tb.bottom);
            }
            return Rect.fromLTRB(minX!, minY!, maxX!, maxY!);
          } else {
            // For synthesized empty spans, include effective line-height vertically to match visual area
            final style = targetBox.renderStyle;
            final padT = style.paddingTop.computedValue;
            final bT = style.effectiveBorderTopWidth.computedValue;
            final padB = style.paddingBottom.computedValue;
            final bB = style.effectiveBorderBottomWidth.computedValue;
            final lh = _effectiveLineHeightPx(style);
            final tb = rects.first;
            final double offsetX = (_paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0);
            final double left = tb.left - offsetX;
            final double right = tb.right - offsetX;
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
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.placeholders,
      level: Level.FINE,
      message: () => 'PASS ${_suppressAllRightExtras ? '1' : '2'}: '
          'suppressRightExtras=${_suppressAllRightExtras} forceRightCount=${_forceRightExtrasOwners.length}',
    );
    // Lay out atomic inlines first to obtain sizes for placeholders
    _layoutAtomicInlineItemsForParagraph();

    // Configure a paragraph-level strut so the block container's computed line-height
    // establishes the minimum line box height for each line, per CSS. This centers
    // smaller runs (e.g., inline elements with smaller line-height) inside a taller
    // block line-height without requiring per-line paint shifts.
    ui.StrutStyle? _paragraphStrut;
    final CSSRenderStyle _containerStyle = (container as RenderBoxModel).renderStyle;
    final CSSLengthValue _containerLH = _containerStyle.lineHeight;
    if (_containerLH.type != CSSLengthType.NORMAL) {
      final double fontSize = _containerStyle.fontSize.computedValue;
      final double multiple = _containerLH.computedValue / fontSize;
      // Guard against non-finite or non-positive multiples
      if (multiple.isFinite && multiple > 0) {
        _paragraphStrut = ui.StrutStyle(
          fontSize: fontSize,
          height: multiple,
          fontFamilyFallback: _containerStyle.fontFamily,
          fontStyle: _containerStyle.fontStyle,
          fontWeight: _containerStyle.fontWeight,
          // Use as minimum line height; let larger content expand the line.
          forceStrutHeight: false,
        );
      }
    }

    // Compute an effective maxLines for paragraph shaping. In CSS, text-overflow: ellipsis
    // works with white-space: nowrap and overflow not visible. For Flutter's paragraph
    // engine to emit ellipsis glyphs, a maxLines must be provided. When nowrap+ellipsis
    // are active and no explicit line-clamp is set, constrain to a single line.
    final int? _effectiveMaxLines = style.lineClamp ??
        ((style.whiteSpace == WhiteSpace.nowrap && style.effectiveTextOverflow == TextOverflow.ellipsis) ? 1 : null);

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: style.textAlign,
      textDirection: style.direction,
      maxLines: _effectiveMaxLines,
      ellipsis: style.effectiveTextOverflow == TextOverflow.ellipsis ? '\u2026' : null,
      // Distribute extra line-height evenly above/below the glyphs so a single
      // line with large line-height (e.g., equal to box height) is vertically
      // centered as in CSS.
      textHeightBehavior: const ui.TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
        leadingDistribution: ui.TextLeadingDistribution.even,
      ),
      // Apply strut when the container specifies a concrete line-height; this makes the
      // paragraph respect the block container’s min line box height across all lines.
      strutStyle: _paragraphStrut,
    ));

    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _textRunParas = <ui.Paragraph?>[];
    _textRunBuildIndex = 0;
    _atomicBuildIndex = 0;
    _elementRanges.clear();
    _measuredVisualSizes.clear();
    // Track open inline element frames for deferred extras handling
    final List<_OpenInlineFrame> openFrames = [];

    // Track current paragraph code-unit position as we add text/placeholders
    int paraPos = 0;
    // Track an inline element stack to record ranges
    final List<RenderBoxModel> elementStack = [];

    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.text,
      level: Level.FINE,
      message: () => 'Build paragraph: maxWidth=${constraints.maxWidth.toStringAsFixed(2)} '
          'dir=${style.direction} textAlign=${style.textAlign} lineClamp=${style.lineClamp}',
    );

    // Record overflow flags for debugging
    final CSSOverflowType containerOverflowX = style.effectiveOverflowX;
    final CSSOverflowType containerOverflowY = style.effectiveOverflowY;
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.scrollable,
      level: Level.FINE,
      message: () => 'overflow flags: overflowX=$containerOverflowX overflowY=$containerOverflowY',
    );

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

    // Apply text-indent on the first line by inserting a leading placeholder.
    // Positive values indent from the inline-start; negative values create a hanging indent.
    // For now, we support positive values by reserving space; for negative values, we still
    // insert a placeholder of zero width (layout unaffected) and rely on authors to pair
    // with padding-inline-start to simulate hanging markers (common pattern).
    final CSSLengthValue indent = style.textIndent;
    double indentPx = 0;
    if (indent.type != CSSLengthType.INITIAL && indent.type != CSSLengthType.UNKNOWN &&
        indent.type != CSSLengthType.AUTO) {
      indentPx = indent.computedValue;
    }
    if (indentPx != 0) {
      final (ph, bo) = _measureTextMetricsFor(style);
      final double reserved = indentPx > 0 ? indentPx : 0.0;
      if (reserved > 0) {
        pb.addPlaceholder(reserved, ph, ui.PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic, baselineOffset: bo);
        paraPos += 1;
        _textRunParas.add(null);
        // In RTL, reserve space on the inline-start (right) by forcing the
        // indent placeholder to precede content visually: insert a zero-width
        // no-break space with strong RTL property.
        if (style.direction == TextDirection.rtl) {
          pb.pushStyle(_uiTextStyleFromCss(style));
          pb.addText('\uFEFF'); // ZWNBSP to ensure grapheme advance at start
          pb.pop();
          paraPos += 1;
        }
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.text,
          message: () => 'apply text-indent=${indentPx.toStringAsFixed(2)} dir=${style.direction} reserved=${reserved.toStringAsFixed(2)}',
        );
      }
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
          _textRunParas.add(null);
          frame.leftFlushed = true;
          final effLH = _effectiveLineHeightPx(rs);
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.placeholders,
            message: () => 'open extras <${_getElementDescription(frame.box)}> '
                'leftExtras=${frame.leftExtras.toStringAsFixed(2)} '
                'metrics(height=${ph.toStringAsFixed(2)}, baselineOffset=${bo.toStringAsFixed(2)}, '
                'effectiveLineHeight=${effLH.toStringAsFixed(2)}, fontSize=${rs.fontSize.computedValue.toStringAsFixed(2)})',
          );
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
            final t = p.renderStyle.target.tagName.toLowerCase();
            InlineLayoutLog.log(
              impl: InlineImpl.paragraphIFC,
              feature: InlineFeature.scrollable,
              level: Level.FINE,
              message: () => 'ancestor scroll-x detected at <$t> overflowX=$o',
            );
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
      const int A = 0x41,
          Z = 0x5A; // A-Z
      const int a = 0x61,
          z = 0x7A; // a-z
      const int zero = 0x30,
          nine = 0x39; // 0-9
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

    // Avoid breaking within ASCII words when:
    // - this container itself clips or scrolls horizontally (overflow-x != visible), or
    // - any ancestor (excluding HTML/BODY) scrolls horizontally.
    // This matches CSS expectations that long unbreakable words should overflow
    // (and be clipped/scrollable) rather than wrap arbitrarily when overflow-x
    // is not visible.
    final bool localClipsOrScrollsX = container.renderStyle.effectiveOverflowX != CSSOverflowType.visible;
    _avoidWordBreakInScrollableX = localClipsOrScrollsX || _ancestorHasHorizontalScroll();

    int _itemIndex = -1;
    for (final item in _items) {
      _itemIndex += 1;
      if (item.isOpenTag && item.renderBox != null) {
        final rb = item.renderBox!;
        elementStack.add(rb);
        if (item.style != null) {
          final st = item.style!;
          // Defer left extras until we know this span has content; for empty spans we will merge.
          final leftExtras = (st.marginLeft.computedValue) +
              (st.effectiveBorderLeftWidth.computedValue) +
              (st.paddingLeft.computedValue);
          final rightExtras = (st.paddingRight.computedValue) +
              (st.effectiveBorderRightWidth.computedValue) +
              (st.marginRight.computedValue);
          if (rb is RenderBoxModel) {
            openFrames.add(_OpenInlineFrame(rb, leftExtras: leftExtras, rightExtras: rightExtras));
          }
          pb.pushStyle(_uiTextStyleFromCss(st));
          final fam = st.fontFamily;
          final fs = st.fontSize.computedValue;
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.text,
            message: () => 'pushStyle <${_getElementDescription(rb)}> fontSize=${fs.toStringAsFixed(2)} family=${fam?.join(',') ?? 'default'}',
          );
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
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.text,
            message: () => 'popStyle </${_getElementDescription(item.renderBox!)}>',
          );
          // Handle right extras or merged extras for empty spans
          if (item.renderBox is RenderBoxModel) {
            // Find and remove the corresponding open frame
            int idx = openFrames.lastIndexWhere((f) => f.box == item.renderBox);
            if (idx != -1) {
              final frame = openFrames.removeAt(idx);
              if (frame.hadContent) {
                // Non-empty inline span: ensure left extras flushed, then add a trailing
                // right-extras placeholder only if allowed in this pass.
                _flushPendingLeftExtras();
                if (frame.rightExtras > 0) {
                  // Only add a right-extras placeholder in PASS 2 for inline elements
                  // that did not fragment across lines in PASS 1. For fragmented spans,
                  // we reserve trailing extras per-line instead (via width shrink) to
                  // avoid shifting break positions and placing the right border on the
                  // wrong line.
                  final shouldAddRight = !_suppressAllRightExtras && _forceRightExtrasOwners.contains(frame.box);
                  if (shouldAddRight) {
                    final rs = frame.box.renderStyle;
                    final (ph, bo) = _measureTextMetricsFor(rs);
                    pb.addPlaceholder(frame.rightExtras, ph, ui.PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic, baselineOffset: bo);
                    paraPos += 1;
                    _allPlaceholders.add(_InlinePlaceholder.rightExtra(frame.box));
                    _textRunParas.add(null);
                    InlineLayoutLog.log(
                      impl: InlineImpl.paragraphIFC,
                      feature: InlineFeature.placeholders,
                      message: () => 'add right extras placeholder for </${_getElementDescription(frame.box)}> '
                          'rightExtras=${frame.rightExtras.toStringAsFixed(2)}',
                    );
                  } else if (frame.rightExtras > 0) {
                    InlineLayoutLog.log(
                      impl: InlineImpl.paragraphIFC,
                      feature: InlineFeature.placeholders,
                      message: () => 'suppress right extras placeholder for </${_getElementDescription(frame.box)}> '
                          '(pass=${_suppressAllRightExtras ? '1' : '2'})',
                    );
                  }
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
                  _textRunParas.add(null);
                  InlineLayoutLog.log(
                    impl: InlineImpl.paragraphIFC,
                    feature: InlineFeature.placeholders,
                    message: () => 'empty span extras <${_getElementDescription(frame.box)}>'
                        ' merged=${merged.toStringAsFixed(2)}',
                  );
                } else {
                  InlineLayoutLog.log(
                    impl: InlineImpl.paragraphIFC,
                    feature: InlineFeature.placeholders,
                    message: () => 'suppress empty span placeholder for '
                        '<${_getElementDescription(frame.box)}> (no padding/border/margins)',
                  );
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

        // Baseline offset for inline-block: use the element's own cached CSS baseline.
        // This ensures spec-accurate behavior:
        //  - If there are line boxes anywhere inside (in-flow), baseline is that last line box.
        //  - Otherwise, baseline is the bottom margin edge.
        // The cached baseline is measured from the border-box top; placeholder top is at margin-top.
        double? baselineOffset;
        // Unwrap wrappers (e.g., RenderEventListener) to the underlying RenderBoxModel
        final RenderBox resolvedForBaseline = _resolveAtomicChildForBaseline(rb);
        RenderBoxModel? styleBoxForBaseline;
        if (resolvedForBaseline is RenderBoxModel) {
          styleBoxForBaseline = resolvedForBaseline;
        } else if (rb is RenderBoxModel) {
          styleBoxForBaseline = rb;
        }
        if (styleBoxForBaseline != null) {
          final double? cssBaseline = styleBoxForBaseline.computeCssLastBaselineOf(TextBaseline.alphabetic);
          if (cssBaseline != null) {
            baselineOffset = mT + cssBaseline;
          }
        }
        // Fallback to bottom margin edge if no baseline is available yet.
        baselineOffset ??= height;

        // Map CSS vertical-align to dart:ui PlaceholderAlignment for atomic inline items.
        // For textTop/textBottom we approximate using top/bottom as Flutter does not
        // distinguish font-box vs line-box alignment at this level.
        final ui.PlaceholderAlignment align = _placeholderAlignmentFromCss(rbStyle.verticalAlign);
        // If we have a precomputed baseline offset for atomic vertical-align, prefer baseline alignment
        // to precisely match CSS line box top/middle/bottom against paragraph metrics.
        final double? preOffset = (rbStyle.verticalAlign != VerticalAlign.baseline &&
            _atomicBaselineOffsets != null && _atomicBuildIndex < (_atomicBaselineOffsets?.length ?? 0))
            ? _atomicBaselineOffsets![_atomicBuildIndex]
            : null;
        if (preOffset != null) {
          pb.addPlaceholder(width, height, ui.PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic, baselineOffset: preOffset);
        } else {
          if (align == ui.PlaceholderAlignment.baseline ||
              align == ui.PlaceholderAlignment.aboveBaseline ||
              align == ui.PlaceholderAlignment.belowBaseline) {
            pb.addPlaceholder(width, height, align,
                baseline: TextBaseline.alphabetic, baselineOffset: baselineOffset);
          } else {
            pb.addPlaceholder(width, height, align);
          }
        }
        _placeholderOrder.add(rb);
        // In RTL, ensure atomic placeholders participate as strong RTL so that
        // sequences of inline-blocks order visually right-to-left. Insert an RLM
        // (U+200F) as a zero-width strong RTL character prior to the placeholder.
        if (style.direction == TextDirection.rtl) {
          pb.pushStyle(_uiTextStyleFromCss(style));
          pb.addText('\u200F');
          pb.pop();
          paraPos += 1;
        }
        _allPlaceholders.add(_InlinePlaceholder.atomic(rb));
        _textRunParas.add(null);
        if (rbStyle.verticalAlign != VerticalAlign.baseline) {
          _atomicBuildIndex += 1;
        }
        paraPos += 1; // placeholder adds a single object replacement char

        final bw = rb.boxSize?.width ?? (rb.hasSize ? rb.size.width : 0.0);
        final bh = rb.boxSize?.height ?? (rb.hasSize ? rb.size.height : 0.0);
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.placeholders,
          message: () => 'placeholder <${_getElementDescription(rb)}> borderBox=(${bw.toStringAsFixed(2)}x${bh.toStringAsFixed(2)}) '
              'margins=(L:${mL.toStringAsFixed(2)},T:${mT.toStringAsFixed(2)},R:${mR.toStringAsFixed(2)},B:${mB.toStringAsFixed(2)}) '
              'placeholder=(w:${width.toStringAsFixed(2)}, h:${height.toStringAsFixed(2)}, baselineOffset:${(baselineOffset ?? 0).toStringAsFixed(2)})',
        );
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
        // If the nearest enclosing inline element specifies vertical-align other than baseline,
        // represent this text segment as a placeholder so Flutter positions it by alignment.
        RenderBoxModel? ownerBox = elementStack.isNotEmpty ? elementStack.last : null;
        final VerticalAlign ownerVA = ownerBox?.renderStyle.verticalAlign ?? VerticalAlign.baseline;
        final bool usePlaceholderForText = ownerBox != null && ownerVA != VerticalAlign.baseline;
        if (usePlaceholderForText) {
          // Shape the text in its own paragraph to measure width/height.
          final subPB = ui.ParagraphBuilder(ui.ParagraphStyle(
            textDirection: style.direction,
            textHeightBehavior: const ui.TextHeightBehavior(
              applyHeightToFirstAscent: true,
              applyHeightToLastDescent: true,
              leadingDistribution: ui.TextLeadingDistribution.even,
            ),
          ));
          subPB.pushStyle(_uiTextStyleFromCss(item.style!));
          subPB.addText(text);
          subPB.pop();
          final subPara = subPB.build();
          subPara.layout(const ui.ParagraphConstraints(width: 1000000.0));
          final double phWidth = subPara.longestLine;
          final double phHeight = subPara.height;
          // Prefer baseline alignment with a precomputed baselineOffset when available from a prior pass,
          // so we can align to line top/bottom/middle precisely.
          final double? preOffset = _textRunBaselineOffsets != null &&
              _textRunBuildIndex < (_textRunBaselineOffsets?.length ?? 0)
              ? _textRunBaselineOffsets![_textRunBuildIndex]
              : null;
          if (preOffset != null) {
            pb.addPlaceholder(phWidth, phHeight, ui.PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic, baselineOffset: preOffset);
          } else {
            pb.addPlaceholder(phWidth, phHeight, _placeholderAlignmentFromCss(ownerVA));
          }
          paraPos += 1;
          _allPlaceholders.add(_InlinePlaceholder.textRun(ownerBox!));
          _textRunParas.add(subPara);
          _textRunBuildIndex += 1;
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.text,
            message: () {
              final t = text.replaceAll('\n', '\\n');
              return 'addText-as-placeholder len=${text.length} at=$paraPos "$t" '
                  'size=(${phWidth.toStringAsFixed(2)}x${phHeight.toStringAsFixed(2)}) va=$ownerVA';
            },
          );
        } else {
          pb.pushStyle(_uiTextStyleFromCss(item.style!));
          pb.addText(text);
          pb.pop();
          paraPos += text.length;
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.text,
            message: () {
              final t = text.replaceAll('\n', '\\n');
              return 'addText len=${text.length} at=$paraPos "$t"';
            },
          );
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
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.text,
          message: () {
            final t = text.replaceAll('\n', '\\n');
            return 'addCtrl len=${text.length} at=$paraPos "$t"';
          },
        );
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
    bool shapedWithHugeWidth = false;
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
    bool _hasExplicitBreaks = _items.any((it) =>
    it.type == InlineItemType.control || it.type == InlineItemType.lineBreakOpportunity);
    bool _hasWhitespaceInText = false;
    bool _hasInteriorWhitespaceInText = false;
    for (final it in _items) {
      if (it.isText) {
        final t = it.getText(_textContent);
        if (_containsSoftWrapWhitespace(t)) {
          _hasWhitespaceInText = true;
        }
        // Detect interior (between non-space) soft wrap whitespace, not just leading/trailing
        if (!_hasInteriorWhitespaceInText) {
          if (RegExp(r"\S\s+\S").hasMatch(t)) {
            _hasInteriorWhitespaceInText = true;
          }
        }
        if (_hasWhitespaceInText && _hasInteriorWhitespaceInText) break;
      }
    }
    final bool _preferZeroWidthShaping = _hasAtomicInlines || _hasExplicitBreaks || _hasWhitespaceInText;
    if (!constraints.hasBoundedWidth) {
      // Unbounded: prefer a reasonable fallback if available, otherwise use a very large width
      initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
          ? fallbackContentMaxWidth
          : 1000000.0;
      if (initialWidth >= 1000000.0) {
        shapedWithHugeWidth = true;
      }
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
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.sizing,
          level: Level.FINE,
          message: () => 'respect zero maxWidth for shaping (has breaks)',
        );
        } else {
          initialWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
              ? fallbackContentMaxWidth
              : 1000000.0;
          if (initialWidth >= 1000000.0) {
            shapedWithHugeWidth = true;
          }
          InlineLayoutLog.log(
            impl: InlineImpl.paragraphIFC,
            feature: InlineFeature.sizing,
            level: Level.FINE,
            message: () => 'avoid zero-width shaping for unbreakable text; '
                'use fallback=${initialWidth.toStringAsFixed(2)}',
          );
        }
      }
    }

    // If an ancestor has horizontal scrolling and there are no interior
    // Avoid disabling wrapping solely due to scrollable-X. CSS allows breaks
    // between atomic inline-level boxes regardless of ancestor scrollability.
    // We only shape to an extremely wide width when the content has no natural
    // break opportunities at all (no atomic inlines, no explicit breaks, and
    // no whitespace in text), i.e. a single unbreakable run, so that long
    // words/numbers can overflow horizontally for scrolling.
    final bool _ancestorScrollX = _ancestorHasHorizontalScroll();
    final bool _localIsScrollableX = style.effectiveOverflowX == CSSOverflowType.scroll ||
        style.effectiveOverflowX == CSSOverflowType.auto;
    final bool _contentHasNoBreaks = !_hasAtomicInlines && !_hasExplicitBreaks && !_hasWhitespaceInText;
    final bool _wideShapeForScrollableX = (_ancestorScrollX || _localIsScrollableX) && _contentHasNoBreaks;
    if (_wideShapeForScrollableX) {
      initialWidth = 1000000.0;
      shapedWithHugeWidth = true;
      InlineLayoutLog.log(
        impl: InlineImpl.paragraphIFC,
        feature: InlineFeature.sizing,
        level: Level.FINE,
        message: () => 'scrollable-x with unbreakable content → shape wide initialWidth='
            '${initialWidth.toStringAsFixed(2)}',
      );
    }

    // CSS white-space: nowrap and white-space: pre both suppress automatic
    // line wrapping. Lines only break at explicit line breaks (<br> or
    // newline characters). To honor this, shape with a very wide width so
    // that soft wrapping never occurs; the final content width is taken from
    // the paragraph's longestLine, and painting/clipping is handled by the
    // container.
    final bool _noSoftWrap = style.whiteSpace == WhiteSpace.nowrap || style.whiteSpace == WhiteSpace.pre;
    if (_noSoftWrap) {
      // Preserve bounded shaping when we intend to show ellipsis; otherwise disable soft wraps
      // by shaping with a very wide width.
      final bool wantsEllipsis = style.effectiveTextOverflow == TextOverflow.ellipsis &&
          // Ellipsis only effective when overflow is not visible.
          (style.effectiveOverflowX != CSSOverflowType.visible);
      if (!wantsEllipsis) {
        initialWidth = 1000000.0;
        shapedWithHugeWidth = true;
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.sizing,
          level: Level.FINE,
          message: () => 'white-space=${style.whiteSpace} → disable soft wrap; initialWidth='
              '${initialWidth.toStringAsFixed(2)}',
        );
      } else {
        InlineLayoutLog.log(
          impl: InlineImpl.paragraphIFC,
          feature: InlineFeature.sizing,
          level: Level.FINE,
          message: () => 'nowrap + ellipsis → keep bounded width for truncation',
        );
      }
    }
    InlineLayoutLog.log(
      impl: InlineImpl.paragraphIFC,
      feature: InlineFeature.sizing,
      level: Level.FINE,
      message: () => 'initialWidth=${initialWidth.toStringAsFixed(2)} '
          '(bounded=${constraints.hasBoundedWidth}, maxW=${constraints.maxWidth.toStringAsFixed(2)}, '
          'fallback=${(fallbackContentMaxWidth ?? 0).toStringAsFixed(2)})',
    );
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
          if (false) {
            renderingLogger.fine('[IFC] block-like reflow with fallback width '
                '${targetWidth.toStringAsFixed(2)} (had maxWidth=${constraints.maxWidth})');
          }
          paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
        } else if (false) {
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
    _shrinkWidthForTrailingExtras(paragraph, constraints);

    _paragraph = paragraph;
    _paraLines = paragraph.computeLineMetrics();
    _placeholderBoxes = paragraph.getBoxesForPlaceholders();
    _paraCharCount = paraPos; // record final character count

    if (false) {
      // Try to extract intrinsic widths when available on this engine.
      double? minIntrinsic;
      double? maxIntrinsic;
      try {
        minIntrinsic = (paragraph as dynamic).minIntrinsicWidth as double?;
      } catch (_) {}
      try {
        maxIntrinsic = (paragraph as dynamic).maxIntrinsicWidth as double?;
      } catch (_) {}

      renderingLogger.fine(
          '[IFC] paragraph: width=${paragraph.width.toStringAsFixed(2)} height=${paragraph.height.toStringAsFixed(2)} '
              'longestLine=${paragraph.longestLine.toStringAsFixed(2)} maxLines=${style.lineClamp} exceeded=${paragraph
              .didExceedMaxLines}');
      if (minIntrinsic != null || maxIntrinsic != null) {
        renderingLogger.fine('[IFC] intrinsic: min=${(minIntrinsic ?? double.nan).toStringAsFixed(2)} '
            'max=${(maxIntrinsic ?? double.nan).toStringAsFixed(2)}');
      }
      // Log flags related to break avoidance in scrollable containers.
      renderingLogger.fine(
          '[IFC] flags: avoidWordBreakInScrollableX=${_avoidWordBreakInScrollableX} whiteSpace=${style.whiteSpace}');
      for (int i = 0; i < _paraLines.length; i++) {
        final lm = _paraLines[i];
        renderingLogger.finer(
            '  [line $i] baseline=${lm.baseline.toStringAsFixed(2)} height=${lm.height.toStringAsFixed(2)} '
                'ascent=${lm.ascent.toStringAsFixed(2)} descent=${lm.descent.toStringAsFixed(2)} left=${lm.left
                .toStringAsFixed(2)} width=${lm.width.toStringAsFixed(2)}');
      }
      // Log all placeholders including extras (left/right/empty) and atomics
      for (int i = 0; i < _placeholderBoxes.length && i < _allPlaceholders.length; i++) {
        final tb = _placeholderBoxes[i];
        final ph = _allPlaceholders[i];
        final kind = ph.kind
            .toString()
            .split('.')
            .last;
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
          renderingLogger.finer(
              '  [ph $i] kind=$kind owner=<$ownerDesc> rect=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(
                  2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
                  'h=${height.toStringAsFixed(2)} metrics(height=${h.toStringAsFixed(2)}, baselineOffset=${b
                  .toStringAsFixed(2)}, effLineHeight=${effLH.toStringAsFixed(2)})$lineStr');
        } else {
          String childDesc = '';
          if (ph.kind == _PHKind.atomic && i < _placeholderOrder.length) {
            final rb = _placeholderOrder[i];
            childDesc = ' child=<${_getElementDescription(rb is RenderBoxModel ? rb : null)}>';
          }
          renderingLogger.finer(
              '  [ph $i] kind=$kind owner=<$ownerDesc> rect=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(
                  2)} - ${tb.right.toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
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
            renderingLogger.finer(
                '    [frag $i] tb=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right
                    .toStringAsFixed(2)},${tb.bottom.toStringAsFixed(2)}) '
                    '→ line=$li topDelta=${dt.toStringAsFixed(2)} bottomDelta=${db.toStringAsFixed(2)}');
          }
        }
      });
    }

    _paragraphShapedWithHugeWidth = shapedWithHugeWidth;
  }

  void _layoutAtomicInlineItemsForParagraph() {
    final Set<RenderBox> laidOut = {};
    for (final item in _items) {
      if (item.isAtomicInline && item.renderBox != null) {
        final child = item.renderBox!;
        if (laidOut.contains(child)) continue;
        final constraints = child.getConstraints();
        if (false) {
          renderingLogger.finer(
              '[IFC] layout atomic <${_getElementDescription(child is RenderBoxModel ? child : null)}>'
                  ' constraints=${constraints.toString()}');
        }
        // Pre-measure atomic inline without depending on parent's size readbacks.
        // Using parentUsesSize=false avoids relying on parent's relayout boundary
        // when IFC pre-measures before the parent completes its own layout pass.
        child.layout(constraints, parentUsesSize: false);
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
      // Use effective border widths so `border-*-style: none` collapses to 0
      final bL = s.effectiveBorderLeftWidth.computedValue;
      final bR = s.effectiveBorderRightWidth.computedValue;
      final bT = s.effectiveBorderTopWidth.computedValue;
      final bB = s.effectiveBorderBottomWidth.computedValue;
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
          if (((top - baseTop).abs() > 0.5 || (bottom - baseBottom).abs() > 0.5)) {
            InlineLayoutLog.log(
              impl: InlineImpl.paragraphIFC,
              feature: InlineFeature.metrics,
              message: () => '    [metrics] span frag to content band: '
                  'top ${top.toStringAsFixed(2)}→${baseTop.toStringAsFixed(2)} '
                  'bottom ${bottom.toStringAsFixed(2)}→${baseBottom.toStringAsFixed(2)}',
            );
          }
          top = baseTop;
          bottom = baseBottom;
        }

        // For empty height rects we keep the clamped band; vertical padding/border
        // will be applied conditionally below to avoid exaggerated heights.

        // Determine visual-first/last fragments on this line (physical left/right),
        // instead of relying on logical order (i==0/last). This is important in RTL,
        // where the first logical fragment can be at the visual right.
        bool _overlapsLine(ui.TextBox r) {
          if (lineTop == null || lineBottom == null) return true;
          return !(r.bottom <= lineTop || r.top >= lineBottom);
        }
        int _lineOf(ui.TextBox r) =>
            (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                ? currentLineIndex
                : _lineIndexForRect(r);
        // Visual edge within the current line band
        bool isFirst = true;
        bool isLast = true;
        for (int k = 0; k < e.rects.length; k++) {
          if (k == i) continue;
          final rk = e.rects[k];
          if (!_overlapsLine(rk)) continue;
          // Only compare fragments that belong to the same line band
          if (_lineOf(rk) != _lineOf(tb)) continue;
          if (rk.left < left - 0.01) isFirst = false; // there's something more to the left
          if (rk.right > right + 0.01) isLast = false; // there's something more to the right
          if (!isFirst && !isLast) break;
        }

        // Physical edge flags (before adjustments below)
        final bool physLeftEdge = isFirst;
        final bool physRightEdge = isLast;

        // Include atomic inline placeholders owned by this inline element on the same line,
        // so background/borders of the inline span wrap its atomic children as per CSS.
        // We detect ownership by render tree ancestry (atomic box is a descendant of e.box).
        if (_allPlaceholders.isNotEmpty && _placeholderBoxes.isNotEmpty) {
          for (int pi = 0; pi < _allPlaceholders.length && pi < _placeholderBoxes.length; pi++) {
            final ph = _allPlaceholders[pi];
            if (ph.kind != _PHKind.atomic) continue;
            final ui.TextBox ptb = _placeholderBoxes[pi];
            // Filter to same line when line clipping requested
            if (lineTop != null && lineBottom != null) {
              final int li = _lineIndexForRect(ptb);
              if (li < 0 || li >= _paraLines.length) continue;
              final int thisLi = _lineIndexForRect(tb);
              if (thisLi != li) continue;
            }
            final RenderBox? atomicBox = ph.atomic;
            if (atomicBox == null) continue;
            // Is atomicBox a descendant of this span's render box?
            RenderObject? p = atomicBox;
            bool isDescendant = false;
            while (p != null && p != container) {
              if (identical(p, e.box)) { isDescendant = true; break; }
              p = p.parent;
            }
            if (!isDescendant) continue;
            // Expand rect to include the atomic placeholder bounds
            if (ptb.left < left) left = ptb.left;
            if (ptb.right > right) right = ptb.right;
            if (ptb.top < top) top = ptb.top;
            if (ptb.bottom > bottom) bottom = ptb.bottom;
          }
        }

        // Logical fragment edges across the entire element (independent of line).
        // These are used for left/right border painting so borders only appear
        // on the very first and very last fragment of the element, not on
        // every per-line fragment.
        final bool logicalFirstFrag = (i == 0);
        final bool logicalLastFrag = (i == e.rects.length - 1);

        // Extend horizontally on first/last fragments
        if (!e.synthetic) {
          // Heuristic: avoid attaching padding/border to edge fragments that are
          // effectively only collapsible whitespace on the line edge. If this
          // fragment is very narrow and there exists another wider fragment on
          // the same line for this element, treat this as not-first/last.
          final double fs = s.fontSize.computedValue;
          final double smallThresh = math.max(1.0, fs * 0.35);
          final double fragWidth = right - left;
          if (isFirst || isLast) {
            bool hasOtherWideOnLine = false;
            for (int k = 0; k < e.rects.length; k++) {
              if (k == i) continue;
              final rk = e.rects[k];
              if (lineTop != null && lineBottom != null) {
                if (rk.bottom <= lineTop || rk.top >= lineBottom) continue;
              }
              // Same line only
              final liK = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                  ? currentLineIndex
                  : _lineIndexForRect(rk);
              final liI = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                  ? currentLineIndex
                  : _lineIndexForRect(tb);
              if (liK != liI) continue;
              final double w = rk.right - rk.left;
              if (w > smallThresh) {
                hasOtherWideOnLine = true;
                break;
              }
            }
            if (fragWidth <= smallThresh && hasOtherWideOnLine) {
              if (isFirst) isFirst = false;
              if (isLast) isLast = false;
            }
          }
          // Expand horizontally using logical edges so horizontal padding/border
          // is only attached once (first/last fragment across the element),
          // matching browser behavior for multi-line inline boxes.
          if (logicalFirstFrag) left -= (padL + bL);
          if (logicalLastFrag) right += (padR + bR);
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
          final cBL = cs.effectiveBorderLeftWidth.computedValue;
          final cBR = cs.effectiveBorderRightWidth.computedValue;
          for (int j = 0; j < childEntry.rects.length; j++) {
            final cr = childEntry.rects[j];
            if (lineTop != null && lineBottom != null) {
              if (cr.bottom <= lineTop || cr.top >= lineBottom) continue;
            }
            double cLeft = cr.left;
            double cRight = cr.right;
            // Use visual-first/last for child fragments too (important in RTL).
            bool cIsFirst = true;
            bool cIsLast = true;
            for (int m = 0; m < childEntry.rects.length; m++) {
              if (m == j) continue;
              final rm = childEntry.rects[m];
              if (lineTop != null && lineBottom != null) {
                if (rm.bottom <= lineTop || rm.top >= lineBottom) continue;
              }
              // Same line only
              final lmIdx = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                  ? currentLineIndex
                  : _lineIndexForRect(rm);
              final ljIdx = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                  ? currentLineIndex
                  : _lineIndexForRect(cr);
              if (lmIdx != ljIdx) continue;
              if (rm.left < cLeft - 0.01) cIsFirst = false;
              if (rm.right > cRight + 0.01) cIsLast = false;
              if (!cIsFirst && !cIsLast) break;
            }
            // Avoid attaching padding to whitespace-only edge fragments for child.
            final double fsC = cs.fontSize.computedValue;
            final double smallThreshC = math.max(1.0, fsC * 0.35);
            final double cFragW = cRight - cLeft;
            if ((cIsFirst || cIsLast) && cFragW <= smallThreshC) {
              bool hasOtherWide = false;
              for (int m = 0; m < childEntry.rects.length; m++) {
                if (m == j) continue;
                final rm = childEntry.rects[m];
                if (lineTop != null && lineBottom != null) {
                  if (rm.bottom <= lineTop || rm.top >= lineBottom) continue;
                }
                final lmIdx = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                    ? currentLineIndex
                    : _lineIndexForRect(rm);
                final ljIdx = (lineTop != null && lineBottom != null && currentLineIndex >= 0)
                    ? currentLineIndex
                    : _lineIndexForRect(cr);
                if (lmIdx != ljIdx) continue;
                final double w = rm.right - rm.left;
                if (w > smallThreshC) {
                  hasOtherWide = true;
                  break;
                }
              }
              if (hasOtherWide) {
                if (cIsFirst) cIsFirst = false;
                if (cIsLast) cIsLast = false;
              }
            }
            if (cIsFirst) cLeft -= (cPadL + cBL);
            if (cIsLast) cRight += (cPadR + cBR);
            if (cLeft < left) left = cLeft;
            if (cRight > right) right = cRight;
          }
        }

        final rect = Rect.fromLTRB(left, top, right, bottom).shift(offset);

        if (false) {
          final bool drawTop = (bT > 0);
          final bool drawBottom = (bB > 0);
          final bool drawLeft = (logicalFirstFrag && bL > 0);
          final bool drawRight = (logicalLastFrag && bR > 0);
          final String lineInfo = (currentLineIndex >= 0)
              ? ' line=$currentLineIndex'
              : '';
          // Diagnostics for tiny-edge suppression
          final double _dbgFs = s.fontSize.computedValue;
          final double _dbgThresh = math.max(1.0, _dbgFs * 0.35);
          final double _dbgFragW = right - left;
          bool _dbgHasOtherWide = false;
          for (int k = 0; k < e.rects.length; k++) {
            if (k == i) continue;
            final rk = e.rects[k];
            if (lineTop != null && lineBottom != null) {
              if (rk.bottom <= lineTop || rk.top >= lineBottom) continue;
            }
            if (_lineOf(rk) != _lineOf(tb)) continue;
            if ((rk.right - rk.left) > _dbgThresh) {
              _dbgHasOtherWide = true;
              break;
            }
          }
          final bool _dbgTinyEdge = (_dbgFragW <= _dbgThresh) && _dbgHasOtherWide && (physLeftEdge || physRightEdge);
          renderingLogger.finer('[DECOR] <${_getElementDescription(e.box)}> frag=${i}' +
              lineInfo +
              ' rect=(${rect.left.toStringAsFixed(2)},${rect.top.toStringAsFixed(2)} - ' +
              '${rect.right.toStringAsFixed(2)},${rect.bottom.toStringAsFixed(2)}) size=(' +
              '${rect.width.toStringAsFixed(2)}x${rect.height.toStringAsFixed(2)}) ' +
              'borders(T:${drawTop ? bT.toStringAsFixed(2) : '0'}, ' +
              'R:${drawRight ? bR.toStringAsFixed(2) : '0'}, ' +
              'B:${drawBottom ? bB.toStringAsFixed(2) : '0'}, ' +
              'L:${drawLeft ? bL.toStringAsFixed(2) : '0'}) '
                  'phys(L:${physLeftEdge},R:${physRightEdge}) '
                  'fragW=${_dbgFragW.toStringAsFixed(2)} thresh=${_dbgThresh.toStringAsFixed(2)} '
                  'hasOtherWide=${_dbgHasOtherWide} tinyEdge=${_dbgTinyEdge}');
        }

        // Background: optionally suppress tiny edge whitespace fragment painting to avoid slivers
        bool _suppressTinyEdgePaint() {
          final double fs = s.fontSize.computedValue;
          final double smallThresh = math.max(1.0, fs * 0.35);
          final double fragW = right - left;
          if (!(physLeftEdge || physRightEdge)) return false;
          if (fragW > smallThresh) return false;
          for (int k = 0; k < e.rects.length; k++) {
            if (k == i) continue;
            final rk = e.rects[k];
            if (lineTop != null && lineBottom != null) {
              if (rk.bottom <= lineTop || rk.top >= lineBottom) continue;
            }
            if (_lineOf(rk) != _lineOf(tb)) continue;
            if ((rk.right - rk.left) > smallThresh) return true;
          }
          return false;
        }
        final bool suppressEdge = _suppressTinyEdgePaint();
        if (false) {
          renderingLogger.finer('    [paint] frag=${i} suppressEdge=${suppressEdge} ' +
              'phys(L:${physLeftEdge},R:${physRightEdge}) w=${(right - left).toStringAsFixed(2)}');
        }
        // Skip painting inline background rectangles when background-clip:text is set
        if (!suppressEdge && s.backgroundColor?.value != null && s.backgroundClip != CSSBackgroundBoundary.text) {
          final bg = Paint()
            ..color = s.backgroundColor!.value;
          canvas.drawRect(rect, bg);
        }

        // Borders
        final p = Paint()
          ..style = PaintingStyle.fill;
        // Paint top border on every fragment (spec behavior). With clamped bands
        // and conditional padding, the shared join sits at a single y.
        if (!suppressEdge && bT > 0) {
          p.color = s.borderTopColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, bT), p);
        }
        // Paint bottom border on every fragment.
        if (!suppressEdge && bB > 0) {
          p.color = s.borderBottomColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - bB, rect.width, bB), p);
        }
        if (!suppressEdge && logicalFirstFrag && bL > 0) {
          p.color = s.borderLeftColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, bL, rect.height), p);
        }
        if (!suppressEdge && logicalLastFrag && bR > 0) {
          p.color = s.borderRightColor?.value ?? const Color(0xFF000000);
          canvas.drawRect(Rect.fromLTWH(rect.right - bR, rect.top, bR, rect.height), p);
        }
      }
    }

    if (false) {
      for (final e in entries) {
        for (int i = 0; i < e.rects.length; i++) {
          final tb = e.rects[i];
          renderingLogger.finer('  [span] <${_getElementDescription(e.box)}> frag=$i '
              'tb=(${tb.left.toStringAsFixed(2)},${tb.top.toStringAsFixed(2)} - ${tb.right.toStringAsFixed(2)},${tb
              .bottom.toStringAsFixed(2)})');
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
    final double? heightMultiple = (() {
      if (rs.lineHeight.type == CSSLengthType.NORMAL) {
        return kTextHeightNone; // CSS 'normal' approximation
      }
      if (rs.lineHeight.type == CSSLengthType.EM) {
        return rs.lineHeight.value;
      }
      return rs.lineHeight.computedValue / rs.fontSize.computedValue;
    })();

    final bool clipText = (container as RenderBoxModel).renderStyle.backgroundClip == CSSBackgroundBoundary.text;
    // visibility:hidden should not paint text or its text decorations, but must still
    // participate in layout. Achieve this by using a fully transparent text color and
    // disabling text decorations for the hidden run. Background/border for inline boxes
    // are handled separately and are also suppressed in their painter.
    final bool hidden = rs.isVisibilityHidden;
    final Color baseColor = hidden ? const Color(0x00000000) : rs.color.value;
    final Color effectiveColor = clipText ? baseColor.withAlpha(hidden ? 0x00 : 0xFF) : baseColor;
    return ui.TextStyle(
      // For clip-text, force fully-opaque glyphs for the mask (ignore alpha).
      color: effectiveColor,
      decoration: hidden ? TextDecoration.none : rs.textDecorationLine,
      decorationColor: hidden ? const Color(0x00000000) : rs.textDecorationColor?.value,
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
        final typeStr = item.type
            .toString()
            .split('.')
            .last;
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
enum _PHKind { atomic, leftExtra, rightExtra, emptySpan, textRun }

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

  factory _InlinePlaceholder.textRun(RenderBoxModel owner) => _InlinePlaceholder._(_PHKind.textRun, owner: owner);
}

class _SpanPaintEntry {
  _SpanPaintEntry(this.box, this.style, this.rects, this.depth, [this.synthetic = false]);

  final RenderBoxModel box;
  final CSSRenderStyle style;
  final List<ui.TextBox> rects;
  final int depth;
  final bool synthetic;
}

//

// No leading-spacer placeholders retained.
