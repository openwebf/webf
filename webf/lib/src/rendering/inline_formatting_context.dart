/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:math' as math;
import 'dart:ui' as ui
    show
        Paragraph,
        ParagraphBuilder,
        ParagraphStyle,
        ParagraphConstraints,
        PlaceholderAlignment,
        TextBox,
        LineMetrics,
        TextStyle,
        FontFeature,
        TextHeightBehavior,
        TextLeadingDistribution,
        StrutStyle,
        Path,
        Rect,
        ImageFilter,
        PathOperation;
import 'dart:developer' as developer;
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

import 'inline_item.dart';

// Legacy line-box based IFC removed; paragraph-based IFC only.
import 'inline_items_builder.dart';
import 'inline_layout_debugger.dart';

final RegExp _softWrapWhitespaceRegExp = RegExp(r'[\s\u200B\u2060]'); // include ZWSP/WORD JOINER
final RegExp _interiorWhitespaceRegExp = RegExp(r'\S\s+\S');

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

  // Legacy line boxes removed.

  // New: Paragraph-based layout artifacts
  ui.Paragraph? _paragraph;
  List<ui.LineMetrics> _paraLines = const [];
  double _paragraphMinLeft = 0.0; // Painting translation applied to paragraph output.
  // When aligning wide-shaped single-line paragraphs inside a bounded container
  // (without reflow), retain a forced left translation so subsequent metric
  // queries keep the same paint-time shift.
  double? _forcedParagraphMinLeftAlignShift;
  bool _paragraphShapedWithHugeWidth = false; // Track when layout used extremely wide shaping.
  // When we intentionally reflow a wide-shaped paragraph to the container's available
  // width to honor text-align (e.g., center/right) without wrapping, record it so the
  // IFC reported width can reflect the container width rather than the longest line.
  bool _paraReflowedToAvailWidthForAlign = false;

  // Track how many code units were added to the paragraph (text + placeholders)
  int _paraCharCount = 0;

  // Expose paragraph line metrics for baseline consumers
  List<ui.LineMetrics> get paragraphLineMetrics => _paraLines;

  // Placeholder boxes as reported by Paragraph, in the order placeholders were added.
  List<ui.TextBox> _placeholderBoxes = const [];

  // Positive text-indent applied to the first line (px). Used to avoid shifting
  // atomic inline boxes when indent is realized via a leading placeholder.
  double _leadingTextIndentPx = 0.0;

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

  // Caches used during the (often two-pass) paragraph build to avoid recomputing
  // expensive text styles/metrics across `_buildAndLayoutParagraph` invocations.
  final Map<CSSRenderStyle, ui.TextStyle> _cachedUiTextStyles = Map.identity();
  final Map<CSSRenderStyle, (double height, double baselineOffset)> _cachedParagraphTextMetrics = Map.identity();
  List<ui.Paragraph>? _cachedTextRunParagraphsForReuse;

  // Public helpers for consumers outside IFC to query inline element metrics
  // without relying on legacy line boxes.
  double inlineElementMaxLineWidth(RenderBoxModel box) {
    if (_paragraph == null) return 0.0;
    final range = _elementRanges[box];
    if (range == null) return 0.0;
    final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
    if (rects.isEmpty) return 0.0;
    final Map<int, (double left, double right)> perLine = {};
    for (final tb in rects) {
      final int li = _lineIndexForRect(tb);
      if (li < 0) continue;
      final prev = perLine[li];
      final double l = tb.left;
      final double r = tb.right;
      if (prev == null) {
        perLine[li] = (l, r);
      } else {
        final double nl = l < prev.$1 ? l : prev.$1;
        final double nr = r > prev.$2 ? r : prev.$2;
        perLine[li] = (nl, nr);
      }
    }
    double maxW = 0.0;
    perLine.forEach((_, bounds) {
      final double w = bounds.$2 - bounds.$1;
      if (w > maxW) maxW = w;
    });
    return maxW;
  }

  double inlineElementMaxLineHeight(RenderBoxModel box) {
    if (_paragraph == null || _paraLines.isEmpty) return 0.0;
    final range = _elementRanges[box];
    if (range == null) return 0.0;
    final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
    if (rects.isEmpty) return 0.0;
    double maxH = 0.0;
    for (final tb in rects) {
      final int li = _lineIndexForRect(tb);
      if (li < 0 || li >= _paraLines.length) continue;
      final double h = _paraLines[li].height;
      if (h > maxH) maxH = h;
    }
    return maxH;
  }

  // Total visual height that this inline element spans across lines.
  // Sums the heights of unique paragraph lines that intersect the element's
  // text range. This is useful for sizing the element's render box to match
  // the visual union of all its fragments (e.g., for hit testing or serving as
  // a containing block for positioned descendants).
  double inlineElementTotalHeight(RenderBoxModel box) {
    if (_paragraph == null || _paraLines.isEmpty) return 0.0;
    final range = _elementRanges[box];
    if (range == null) return 0.0;
    final rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
    if (rects.isEmpty) return 0.0;

    final Set<int> lineIndexes = <int>{};
    for (final tb in rects) {
      final int li = _lineIndexForRect(tb);
      if (li >= 0 && li < _paraLines.length) lineIndexes.add(li);
    }
    double sum = 0.0;
    for (final li in lineIndexes) {
      sum += _paraLines[li].height;
    }
    return sum;
  }

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
    final double baseHeight =
        _paraLines.isEmpty ? (_paragraph?.height ?? 0.0) : _paraLines.fold<double>(0.0, (sum, lm) => sum + lm.height);

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
    final double baseHeight =
        _paraLines.isEmpty ? (_paragraph?.height ?? 0.0) : _paraLines.fold<double>(0.0, (sum, lm) => sum + lm.height);

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
      final bool childScrolls =
          rs.effectiveOverflowX != CSSOverflowType.visible || rs.effectiveOverflowY != CSSOverflowType.visible;
      final Size childExtent = childScrolls ? (styleBox.boxSize ?? styleBox.size) : styleBox.scrollableSize;

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
      final bool childScrolls =
          rs.effectiveOverflowX != CSSOverflowType.visible || rs.effectiveOverflowY != CSSOverflowType.visible;
      final Size childExtent = childScrolls ? (styleBox.boxSize ?? styleBox.size) : styleBox.scrollableSize;

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
    return (a.left - b.left).abs() < eps &&
        (a.top - b.top).abs() < eps &&
        (a.right - b.right).abs() < eps &&
        (a.bottom - b.bottom).abs() < eps;
  }

  void _resetBuildAndLayoutParagraphCaches() {
    _cachedUiTextStyles.clear();
    _cachedParagraphTextMetrics.clear();
    _cachedTextRunParagraphsForReuse = null;
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

  // Measure text metrics (height and baseline offset) for paragraph-building
  // tasks such as placeholders and text-indent, using the full text style
  // (including line-height) so metrics match the main paragraph runs.
  (double height, double baselineOffset) _measureParagraphTextMetricsFor(CSSRenderStyle rs) {
    final cached = _cachedParagraphTextMetrics[rs];
    if (cached != null) return cached;
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
    mpb.pushStyle(_uiTextStyleFromCss(rs));
    mpb.addText('M');
    final mp = mpb.build();
    mp.layout(const ui.ParagraphConstraints(width: 1000000.0));
    final lines = mp.computeLineMetrics();
    if (lines.isNotEmpty) {
      final lm = lines.first;
      final double ascent = lm.ascent;
      final double descent = lm.descent;
      final result = (ascent + descent, ascent);
      _cachedParagraphTextMetrics[rs] = result;
      return result;
    }
    final double baseline = mp.alphabeticBaseline;
    final double ph = mp.height;
    if (ph.isFinite && ph > 0 && baseline.isFinite && baseline > 0) {
      final result = (ph, baseline);
      _cachedParagraphTextMetrics[rs] = result;
      return result;
    }
    final fs = rs.fontSize.computedValue;
    final result = (fs, fs * 0.8);
    _cachedParagraphTextMetrics[rs] = result;
    return result;
  }

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
          return true;
        }
      }
      // Stop at widget boundary to avoid leaking outside this subtree.
      if (p is RenderWidget) break;
      p = p.parent;
    }
    return false;
  }

  bool _whiteSpaceEligibleForNoWordBreak(WhiteSpace ws) {
    return ws == WhiteSpace.normal || ws == WhiteSpace.preLine || ws == WhiteSpace.nowrap;
  }

  String _insertWordJoinersForAsciiWords(String input) {
    if (input.isEmpty) return input;
    const int A = 0x41, Z = 0x5A; // A-Z
    const int a = 0x61, z = 0x7A; // a-z
    const int zero = 0x30, nine = 0x39; // 0-9

    bool isAsciiAlphaNum(int cu) {
      return (cu >= A && cu <= Z) || (cu >= a && cu <= z) || (cu >= zero && cu <= nine);
    }

    final sb = StringBuffer();
    int i = 0;
    final int n = input.length;
    while (i < n) {
      final int cu = input.codeUnitAt(i);
      if (isAsciiAlphaNum(cu)) {
        // Start of an ASCII alphanumeric run.
        sb.writeCharCode(cu);
        i++;
        while (i < n) {
          final int c = input.codeUnitAt(i);
          if (!isAsciiAlphaNum(c)) break;
          // Insert a WORD JOINER (U+2060) between ascii alphanumerics.
          sb.write('\u2060');
          sb.writeCharCode(c);
          i++;
        }
      } else {
        sb.writeCharCode(cu);
        i++;
      }
    }
    return sb.toString();
  }

  // Insert ZERO WIDTH SPACE (U+200B) between code units to create soft
  // break opportunities. This approximates CSS word-break: break-all and is
  // sufficient for ASCII test cases. We avoid inserting between surrogate
  // pairs by checking for high-surrogate/low-surrogate boundaries.
  String _insertZeroWidthBreaks(String input) {
    if (input.isEmpty) return input;
    final StringBuffer out = StringBuffer();
    int i = 0;
    while (i < input.length) {
      final int cu = input.codeUnitAt(i);
      out.writeCharCode(cu);
      // If next code unit exists and current is not a high surrogate and next is not a low surrogate,
      // insert ZWSP between them to allow break.
      if (i + 1 < input.length) {
        final int next = input.codeUnitAt(i + 1);
        final bool isHigh = (cu & 0xFC00) == 0xD800;
        final bool isNextLow = (next & 0xFC00) == 0xDC00;
        if (!(isHigh && isNextLow)) {
          out.write('\u200B');
        }
      }
      i++;
    }
    return out.toString();
  }

  // Helper to build a first-line override text style (color, font-size, small-caps)
  // from a ::first-line declaration and a base render style.
  ui.TextStyle? _firstLineOverrideFor(CSSStyleDeclaration firstLineDecl, CSSRenderStyle base) {
    Color? ovColor;
    double? ovFontSize;
    List<ui.FontFeature>? ovFeatures;

    final String colorVal = firstLineDecl.getPropertyValue(COLOR);
    if (colorVal.isNotEmpty) {
      ovColor = CSSColor.parseColor(colorVal, renderStyle: base, propertyName: COLOR);
    }

    final String fsVal = firstLineDecl.getPropertyValue(FONT_SIZE);
    if (fsVal.isNotEmpty) {
      final CSSLengthValue parsed = CSSLength.parseLength(fsVal, base, FONT_SIZE);
      final double comp = parsed.computedValue;
      if (comp.isFinite && comp > 0) {
        ovFontSize = comp;
      }
    }

    String fvVal = firstLineDecl.getPropertyValue('fontVariant');
    if (fvVal.isEmpty) {
      fvVal = firstLineDecl.getPropertyValue('font-variant');
    }
    if (fvVal.isNotEmpty && fvVal.contains('small-caps')) {
      ovFeatures = const [ui.FontFeature.enable('smcp')];
    }

    if (ovColor != null || ovFontSize != null || ovFeatures != null) {
      return ui.TextStyle(color: ovColor, fontSize: ovFontSize, fontFeatures: ovFeatures);
    }
    return null;
  }

  static int _firstLetterPrefixLength(String text) {
    if (text.isEmpty) return 0;
    final int c0 = text.codeUnitAt(0);
    bool isAsciiLetter(int c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
    bool isQuote(int c) => c == 0x22 || c == 0x27 || c == 0x201C || c == 0x201D || c == 0x2018 || c == 0x2019;
    if (isQuote(c0) && text.length >= 2 && isAsciiLetter(text.codeUnitAt(1))) return 2;
    if (isAsciiLetter(c0)) return 1;
    return 0;
  }

  ui.TextStyle? _firstLetterOverrideFor(CSSStyleDeclaration firstLetterDecl, CSSRenderStyle base) {
    Color? ovColor;
    double? ovFontSize;

    final String colorVal = firstLetterDecl.getPropertyValue(COLOR);
    if (colorVal.isNotEmpty) {
      ovColor = CSSColor.parseColor(colorVal, renderStyle: base, propertyName: COLOR);
    }
    final String fsVal = firstLetterDecl.getPropertyValue(FONT_SIZE);
    if (fsVal.isNotEmpty) {
      final CSSLengthValue parsed = CSSLength.parseLength(fsVal, base, FONT_SIZE);
      ovFontSize = parsed.computedValue;
    }

    if (ovColor != null || (ovFontSize != null && ovFontSize.isFinite)) {
      return ui.TextStyle(color: ovColor, fontSize: ovFontSize);
    }
    return null;
  }

  // Resolve effective text-decoration for a run by combining ancestor lines
  // and choosing the nearest origin's color/style per CSS propagation rules.
  (TextDecoration, TextDecorationStyle?, Color?) _computeEffectiveTextDecoration(CSSRenderStyle rs) {
    TextDecoration combined = TextDecoration.none;
    TextDecorationStyle? chosenStyle;
    Color? chosenColor;

    CSSRenderStyle? cur = rs;
    CSSRenderStyle? nearestWithLine;
    // Walk up render style chain, combining lines and capturing nearest origin.
    while (cur != null) {
      final TextDecoration line = cur.textDecorationLine;
      if (line != TextDecoration.none) {
        // Combine multiple sources of decoration lines.
        if (combined == TextDecoration.none) {
          combined = line;
        } else {
          combined = TextDecoration.combine([combined, line]);
        }
        nearestWithLine ??= cur;
      }
      cur = cur.getAttachedRenderParentRenderStyle() as CSSRenderStyle?;
    }

    if (nearestWithLine != null) {
      chosenStyle = nearestWithLine.textDecorationStyle;
      // textDecorationColor getter defaults to currentColor when unset.
      chosenColor = nearestWithLine.textDecorationColor?.value;
    }

    return (combined, chosenStyle, chosenColor);
  }

  // Variant of _uiTextStyleFromCss that ignores CSS line-height (height multiple)
  // so we can measure pure font metrics (ascent+descent) for decoration bands.
  ui.TextStyle _uiTextStyleFromCssNoLineHeight(CSSRenderStyle rs) {
    final families = rs.fontFamily;
    final FontWeight weight = (rs.boldText && rs.fontWeight.index < FontWeight.w700.index) ? FontWeight.w700 : rs.fontWeight;
    if (families != null && families.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(families[0], weight, rs);
    }
    final bool clipText = (container as RenderBoxModel).renderStyle.backgroundClip == CSSBackgroundBoundary.text;
    final Color baseColor = rs.color.value;
    final Color effectiveColor = clipText ? baseColor.withAlpha(0xFF) : baseColor;
    final (TextDecoration effLine, TextDecorationStyle? effStyle, Color? effColor) =
        _computeEffectiveTextDecoration(rs);
    final double baseFontSize = rs.fontSize.computedValue;
    final double safeBaseFontSize = baseFontSize.isFinite && baseFontSize >= 0 ? baseFontSize : 0.0;
    final double scaledFontSize = rs.textScaler.scale(safeBaseFontSize);
    final double scaleFactor = safeBaseFontSize > 0 ? (scaledFontSize / safeBaseFontSize) : 1.0;
    return ui.TextStyle(
      // For clip-text, force fully-opaque glyphs for the mask (ignore alpha).
      color: effectiveColor,
      // For clip-text mask style we suppress text decorations to avoid
      // duplicating underline/overline in subsequent dedicated painters.
      decoration: clipText ? TextDecoration.none : effLine,
      decorationColor: clipText ? null : effColor,
      decorationStyle: clipText ? null : effStyle,
      fontWeight: weight,
      fontStyle: rs.fontStyle,
      textBaseline: CSSText.getTextBaseLine(),
      fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
      fontFamilyFallback: families,
      fontSize: scaledFontSize,
      letterSpacing: rs.letterSpacing?.computedValue != null ? rs.letterSpacing!.computedValue * scaleFactor : null,
      wordSpacing: rs.wordSpacing?.computedValue != null ? rs.wordSpacing!.computedValue * scaleFactor : null,
      // height intentionally null to ignore CSS line-height
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
      // Do not include text-shadow in mask styles for clip-text; shadows are
      // painted explicitly in a separate pass to preserve their color.
      shadows: clipText ? null : rs.textShadow,
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
    // Normal path: compute from paragraph lines and trailing extras.
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
    // Do not apply left-shift when we reflowed the paragraph to the container's
    // available width for alignment; in that case, we want the paragraph's
    // internal alignment (e.g., center/right) to be honored without additional
    // translation.
    final bool applyShift = _paragraphShapedWithHugeWidth && !_paraReflowedToAvailWidthForAlign && minLeft > 0.01;
    // If a forced align-based shift is present (set during layout), prefer it.
    final double usedLeft =
        (_forcedParagraphMinLeftAlignShift != null && applyShift) ? _forcedParagraphMinLeftAlignShift! : minLeft;
    _paragraphMinLeft = applyShift ? usedLeft : 0.0;
    double baseLongest = _paragraph!.longestLine;
    double visualRight = rights.fold<double>(double.negativeInfinity, (p, v) => v > p ? v : p);
    if (!visualRight.isFinite) {
      // Use the paragraph's base longest line extended by the raw minLeft for width calculation.
      visualRight = baseLongest + minLeft;
    }
    // For width calculation, subtract the raw minLeft (not the forced paint-time shift)
    // so visualLongestLine remains independent of alignment adjustments.
    double visualWidth = math.max(0, visualRight - minLeft);
    if (!visualWidth.isFinite) {
      visualWidth = baseLongest;
    }
    final double result = visualWidth > baseLongest ? visualWidth : baseLongest;
    return result;
  }

  // Whether this inline element had a left-extras placeholder inserted.
  bool _elementHasLeftExtrasPlaceholder(RenderBoxModel box) {
    for (final ph in _allPlaceholders) {
      if (ph.kind == _PHKind.leftExtra && ph.owner == box) return true;
    }
    return false;
  }

  // Whether this inline element had a right-extras placeholder inserted.
  bool _elementHasRightExtrasPlaceholder(RenderBoxModel box) {
    for (final ph in _allPlaceholders) {
      if (ph.kind == _PHKind.rightExtra && ph.owner == box) return true;
    }
    return false;
  }

  ui.Rect? inlineElementBoundingRect(RenderBoxModel box) {
    if (_paragraph == null) return null;
    final (int start, int end)? range = _elementRanges[box];
    if (range == null) return null;
    List<ui.TextBox> rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
    bool synthesized = false;
    if (rects.isEmpty) {
      rects = _synthesizeRectsForEmptySpan(box);
      if (rects.isEmpty) return null;
      synthesized = true;
    }

    final CSSRenderStyle style = box.renderStyle;
    final double padL = style.paddingLeft.computedValue;
    final double padR = style.paddingRight.computedValue;
    final double padT = style.paddingTop.computedValue;
    final double padB = style.paddingBottom.computedValue;
    final double borderL = style.effectiveBorderLeftWidth.computedValue;
    final double borderR = style.effectiveBorderRightWidth.computedValue;
    final double borderT = style.effectiveBorderTopWidth.computedValue;
    final double borderB = style.effectiveBorderBottomWidth.computedValue;
    final double marginL = style.marginLeft.computedValue;
    final double marginR = style.marginRight.computedValue;
    final double marginT = style.marginTop.computedValue;
    final double marginB = style.marginBottom.computedValue;

    double left = double.infinity;
    double top = double.infinity;
    double right = double.negativeInfinity;
    double bottom = double.negativeInfinity;

    for (int i = 0; i < rects.length; i++) {
      final ui.TextBox tb = rects[i];
      final bool isFirst = i == 0;
      final bool isLast = i == rects.length - 1;
      double l = tb.left;
      double r = tb.right;
      double t = tb.top;
      double b = tb.bottom;

      if (!synthesized) {
        if (isFirst) l -= (padL + borderL + marginL);
        if (isLast) r += (padR + borderR + marginR);
        t -= (padT + borderT + marginT);
        b += (padB + borderB + marginB);
      } else {
        l -= (padL + borderL + marginL);
        r += (padR + borderR + marginR);
        t -= (padT + borderT + marginT);
        b += (padB + borderB + marginB);
      }

      if (l < left) left = l;
      if (t < top) top = t;
      if (r > right) right = r;
      if (b > bottom) bottom = b;
    }

    if (!left.isFinite || !right.isFinite || !top.isFinite || !bottom.isFinite) {
      return null;
    }

    final double shiftX = _paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0;
    left -= shiftX;
    right -= shiftX;

    return ui.Rect.fromLTRB(left, top, right, bottom);
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
      // Use effective border widths so `border-*-style: none` collapses to 0
      final hasBorder = (style.effectiveBorderLeftWidth.computedValue > 0) ||
          (style.effectiveBorderTopWidth.computedValue > 0) ||
          (style.effectiveBorderRightWidth.computedValue > 0) ||
          (style.effectiveBorderBottomWidth.computedValue > 0);
      final hasPadding = ((style.paddingLeft.value ?? 0) > 0) ||
          ((style.paddingTop.value ?? 0) > 0) ||
          ((style.paddingRight.value ?? 0) > 0) ||
          ((style.paddingBottom.value ?? 0) > 0);
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

    // Pre-filter candidates that can contribute trailing reserve.
    final Set<RenderBoxModel> hasRightPH = <RenderBoxModel>{};
    for (final ph in _allPlaceholders) {
      if (ph.kind == _PHKind.rightExtra && ph.owner != null) {
        hasRightPH.add(ph.owner!);
      }
    }
    final List<(RenderBoxModel box, int start, int end, double extra)> candidates =
        <(RenderBoxModel box, int start, int end, double extra)>[];
    for (final entry in _elementRanges.entries) {
      final RenderBoxModel box = entry.key;
      final (int start, int end) = entry.value;
      if (end <= start) continue;
      if (hasRightPH.contains(box)) continue;
      final CSSRenderStyle s = box.renderStyle;
      final double extra =
          s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue + s.marginRight.computedValue;
      if (extra <= 0) continue;
      candidates.add((box, start, end, extra));
    }
    if (candidates.isEmpty) return;

    ui.TextBox? lastTextBoxForRange(ui.Paragraph p, int start, int end) {
      if (end <= start) return null;
      // Fast path: the last code unit usually maps to the final fragment.
      int idx = end - 1;
      // Trailing whitespace/markers can yield empty boxes; scan backwards a few code units.
      for (int attempt = 0; attempt < 8 && idx >= start; attempt++, idx--) {
        final boxes = p.getBoxesForRange(idx, idx + 1);
        if (boxes.isNotEmpty) return boxes.last;
      }
      // Fallback: query the whole range.
      final boxes = p.getBoxesForRange(start, end);
      if (boxes.isEmpty) return null;
      return boxes.last;
    }

    bool layoutPasses(ui.Paragraph p, List<ui.LineMetrics> lines) {
      if (lines.isEmpty) return true;
      final reserves = List<double>.filled(lines.length, 0.0, growable: false);
      for (final (_, int start, int end, double extra) in candidates) {
        final ui.TextBox? tb = lastTextBoxForRange(p, start, end);
        if (tb == null) continue;
        final int li = _bestOverlapLineIndexForBox(tb, lines);
        if (li < 0 || li >= reserves.length) continue;
        if (extra > reserves[li]) reserves[li] = extra;
      }
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].width + reserves[i] > maxW + 0.1) {
          return false;
        }
      }
      return true;
    }

    // Iteratively shrink width so each line satisfies width + reserve <= maxW.
    // Cap iterations to avoid long loops.
    double chosen = paragraph.width.isFinite && paragraph.width > 0 ? math.min(paragraph.width, maxW) : maxW;
    for (int iter = 0; iter < 6; iter++) {
      final lines = paragraph.computeLineMetrics();
      if (lines.isEmpty) break;
      if (layoutPasses(paragraph, lines)) break;

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
        final bool pass = layoutPasses(paragraph, testLines);
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
    if (_paragraph == null || _textContent.isEmpty) return 0;
    final String s = _textContent;
    int i = 0;
    double maxToken = 0;
    double maxNonCjkToken = 0;
    double maxCjkGlyph = 0;

    // If the content contains CJK and white-space allows wrapping, treat each CJK
    // codepoint as individually breakable and approximate min-content width as the
    // width of the widest single CJK glyph (per CSS Text and UAX#14).
    final CSSRenderStyle cStyle = (container as RenderBoxModel).renderStyle;
    final bool wsSoftWrap = cStyle.whiteSpace != WhiteSpace.nowrap && cStyle.whiteSpace != WhiteSpace.pre;
    final bool containsCJK = TextScriptDetector.containsCJK(s);
    if (containsCJK && wsSoftWrap) {
      for (int j = 0; j < s.length; j++) {
        final int cu = s.codeUnitAt(j);
        // Skip common whitespace/control; measure only visible glyphs
        if (cu == 0x20 || cu == 0x09 || cu == 0x0A || cu == 0x0D) continue;
        if (TextScriptDetector.isCJKCharacter(cu)) {
          final double w = _measureRangeWidth(j, j + 1);
          if (w.isFinite) {
            maxCjkGlyph = math.max(maxCjkGlyph, w);
          }
        }
      }
    }
    while (i < s.length) {
      // Skip break chars
      while (i < s.length && _isBreakChar(s.codeUnitAt(i))) {
        i++;
      }
      final int start = i;
      bool tokenHasNonCjk = false;
      while (i < s.length && !_isBreakChar(s.codeUnitAt(i))) {
        final int cu = s.codeUnitAt(i);
        if (!TextScriptDetector.isCJKCharacter(cu)) {
          tokenHasNonCjk = true;
        }
        i++;
      }
      final int end = i;
      if (end > start) {
        final double w = _measureRangeWidth(start, end);
        if (w.isFinite) {
          maxToken = math.max(maxToken, w);
          if (tokenHasNonCjk) {
            int runStart = start;
            bool inNonCjkRun = false;
            for (int k = start; k < end; k++) {
              final int cu = s.codeUnitAt(k);
              final bool isCjk = TextScriptDetector.isCJKCharacter(cu);
              if (!isCjk) {
                if (!inNonCjkRun) {
                  runStart = k;
                  inNonCjkRun = true;
                }
              } else if (inNonCjkRun) {
                final double runWidth = _measureRangeWidth(runStart, k);
                if (runWidth.isFinite) {
                  maxNonCjkToken = math.max(maxNonCjkToken, runWidth);
                }
                inNonCjkRun = false;
              }
            }
            if (inNonCjkRun) {
              final double runWidth = _measureRangeWidth(runStart, end);
              if (runWidth.isFinite) {
                maxNonCjkToken = math.max(maxNonCjkToken, runWidth);
              }
            }
          }
        }
      }
    }
    double approx;
    if (containsCJK && wsSoftWrap) {
      final double candidate = math.max(maxNonCjkToken, maxCjkGlyph);
      approx = candidate > 0 ? candidate : math.max(maxToken, maxCjkGlyph);
    } else {
      approx = math.max(maxToken, maxCjkGlyph);
    }
    if (approx > 0) return approx;
    return _paragraph!.longestLine;
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

  // Expose the paragraph's left shift applied at paint so consumers can map
  // paragraph coordinates back to container content-box coordinates.
  double get paragraphLeftShift => _paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0;

  // Whether this inline element had a right-extras placeholder inserted.
  bool elementHasRightExtrasPlaceholder(RenderBoxModel box) => _elementHasRightExtrasPlaceholder(box);

  // Compute inline horizontal advance (in container content-box space) to the
  // end of the owning inline element for a given descendant render object. The
  // returned value reflects where subsequent inline content would begin on the
  // same line, excluding any trailing right-extras placeholder that may have
  // been inserted for positive padding/border/margin.
  double inlineAdvanceForDescendant(RenderObject descendant) {
    if (_paragraph == null) return 0.0;

    // Ascend to find an owning inline RenderBoxModel that participates in this IFC.
    RenderObject? cur = descendant;
    RenderBoxModel? owner;
    int guard = 0;
    while (cur != null && cur != container && guard++ < 64) {
      if (cur is RenderBoxModel) {
        owner = cur;
        // Prefer the nearest RenderBoxModel that actually has a recorded range.
        final hasRange = _elementRanges.containsKey(owner);
        if (hasRange) break;
      }
      cur = cur.parent;
    }
    if (owner == null) return 0.0;
    final range = _elementRanges[owner];
    if (range == null) return 0.0;

    final List<ui.TextBox> rects = _paragraph!.getBoxesForRange(range.$1, range.$2);
    if (rects.isEmpty) return 0.0;

    // Use the right edge of the last fragment; subtract any paragraph left shift
    // so the result is in container content-box coordinates.
    double right = rects.last.right - paragraphLeftShift;

    // If a right-extras placeholder was inserted for this owner (positive padding/border/margin),
    // subtract those extras to get the end of inline content where following content would start.
    if (elementHasRightExtrasPlaceholder(owner)) {
      final s = owner.renderStyle;
      final double extrasR =
          s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue + s.marginRight.computedValue;
      right -= extrasR;
    }

    if (!right.isFinite) return 0.0;
    return right;
  }

  // Relayout the existing paragraph to a new width and refresh line/placeholder caches.
  // Used by shrink-to-fit adjustments (e.g., inline-block auto width) so that
  // text inside the element is positioned relative to the final used width.
  void relayoutParagraphToWidth(double width) {
    if (!width.isFinite || width <= 0) return;
    _resetBuildAndLayoutParagraphCaches();
    // Make the container's content logical width definite so descendants with
    // percentage widths (e.g., <img width:50%>) can resolve against it.
    final RenderBoxModel container = this.container as RenderBoxModel;
    final CSSRenderStyle cStyle = container.renderStyle;
    cStyle.contentBoxLogicalWidth = width;

    // Rebuild and layout the paragraph at the resolved width so that:
    //  - atomic inline items are remeasured with updated constraints
    //  - placeholders get refreshed with new sizes
    // Use loose vertical constraints; height grows with content.
    final BoxConstraints c = BoxConstraints(
      minWidth: 0,
      maxWidth: width,
      minHeight: 0,
      maxHeight: double.infinity,
    );
    // Perform a full two-pass build like initial layout() to keep behavior consistent.
    _suppressAllRightExtras = true;
    _forceRightExtrasOwners.clear();
    _buildAndLayoutParagraph(c);
    final bool needsVARebuild = _computeTextRunBaselineOffsets() | _computeAtomicBaselineOffsets();
    _forceRightExtrasOwners.clear();
    // Enable right-extras only for single-line owners (pass 2) as in initial layout.
    for (final entry in _elementRanges.entries) {
      final box = entry.key;
      final (int sIdx, int eIdx) = entry.value;
      if (eIdx <= sIdx || _paragraph == null) continue;
      final styleR = box.renderStyle;
      final double extraR = styleR.paddingRight.computedValue +
          styleR.effectiveBorderRightWidth.computedValue +
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
      _buildAndLayoutParagraph(c);
    }
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
    if (!kReleaseMode) {
      developer.Timeline.startSync('InlineFormattingContext.layout');
    }
    try {
      // Prepare items if needed
      prepareLayout();
      _resetBuildAndLayoutParagraphCaches();
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
        final double extraR = styleR.paddingRight.computedValue +
            styleR.effectiveBorderRightWidth.computedValue +
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
      // If we reflowed the paragraph to the available width for alignment,
      // report that width as the IFC width so block containers use the full
      // content inline-size (preserving text-align).
      if (_paraReflowedToAvailWidthForAlign &&
          constraints.hasBoundedWidth &&
          constraints.maxWidth.isFinite &&
          constraints.maxWidth > 0) {
        width = constraints.maxWidth;
      }
      // For left/start alignment, if we shaped wide due to unbreakable detection but the
      // natural single-line width fits within the bounded available width, report the
      // bounded width as the IFC width. Keep left-shift in painting for coordinate mapping.
      if (!_paraReflowedToAvailWidthForAlign &&
          _paragraphShapedWithHugeWidth &&
          constraints.hasBoundedWidth &&
          constraints.maxWidth.isFinite &&
          constraints.maxWidth > 0) {
        // Avoid overriding width reporting for out-of-flow positioned containers
        // (absolute/fixed). In those cases, leave the paragraph width based on
        // natural line width to prevent interfering with positioned layout.
        final CSSPositionType posType = (container as RenderBoxModel).renderStyle.position;
        final bool containerIsOutOfFlow = posType == CSSPositionType.absolute || posType == CSSPositionType.fixed;
        if (!containerIsOutOfFlow) {
          final double natural = _paragraph?.longestLine ?? width;
          if (constraints.maxWidth + 0.5 >= natural) {
            width = constraints.maxWidth;
          }
        }
      }
      if (wantsEllipsis && constraints.hasBoundedWidth && constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
        width = constraints.maxWidth;
      }
      double height = para.height;

      if (!_paraReflowedToAvailWidthForAlign && _paragraphShapedWithHugeWidth) {
        if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          final CSSRenderStyle cStyle2 = (container as RenderBoxModel).renderStyle;
          final TextAlign ta = cStyle2.textAlign;
          final TextDirection dir = cStyle2.direction;
          final bool isRtl = dir == TextDirection.rtl;
          final bool wantsAlignShift = ta == TextAlign.center ||
              ta == TextAlign.right ||
              ta == TextAlign.end ||
              (ta == TextAlign.start && isRtl);
          if (wantsAlignShift) {
            final double cw = constraints.maxWidth;
            final double lineW = _paragraph?.longestLine ?? width;
            double desiredLeft;
            switch (ta) {
              case TextAlign.center:
                desiredLeft = (cw - lineW) / 2.0;
                break;
              case TextAlign.right:
                desiredLeft = cw - lineW;
                break;
              case TextAlign.end:
                desiredLeft = isRtl ? 0.0 : (cw - lineW);
                break;
              case TextAlign.start:
                desiredLeft = isRtl ? (cw - lineW) : 0.0;
                break;
              default:
                desiredLeft = 0.0;
                break;
            }
            double minLeft = 0.0;
            if (_paraLines.isNotEmpty) {
              double m = double.infinity;
              for (final lm in _paraLines) {
                if (lm.left.isFinite) m = math.min(m, lm.left);
              }
              if (m.isFinite) minLeft = m;
            }
            final double forced = minLeft - desiredLeft;
            _paragraphMinLeft = forced;
            _forcedParagraphMinLeftAlignShift = forced;
          }
        }
      }
      // If there's no text (only placeholders) and the container explicitly sets
      // line-height: 0, browsers size each line to the tallest atomic inline on
      // that line without adding extra leading. Flutter's paragraph may report a
      // slightly larger line height due to internal metrics. Normalize by
      // summing per-line max placeholder heights.
      if (_placeholderBoxes.isNotEmpty) {
        // Determine if the paragraph has any real text glyphs (exclude placeholders).
        final int placeholderCount = math.min(_placeholderBoxes.length, _allPlaceholders.length);
        final bool hasTextGlyphs = (_paraCharCount - placeholderCount) > 0;
        // When there is no in-flow text (only atomic inline boxes like inline-block/replaced),
        // browsers size each line to the tallest atomic inline on that line. Vertical margins
        // do not contribute to the line box height. Flutter's paragraph may include margins or
        // extra leading in placeholder rectangles; normalize by summing the per-line maximum
        // owner border-box heights and using that as the paragraph height.
        if (!hasTextGlyphs) {
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
            final RenderBox? rb = ph.atomic;
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
      // Special-case: if the IFC contains only hard line breaks (e.g., one or more
      // <br> elements) and no text or atomic inline content, CSS expects the block
      // to contribute one line box per <br>. Flutter's Paragraph reports an extra
      // trailing empty line in this situation (n breaks -> n+1 lines). Compensate
      // by subtracting the last line height so that a single <br> yields one line
      // instead of two.
      if (_paraLines.isNotEmpty) {
        bool onlyHardBreaks = true;
        for (final it in _items) {
          if (it.type == InlineItemType.text || it.type == InlineItemType.atomicInline) {
            onlyHardBreaks = false;
            break;
          }
        }
        if (onlyHardBreaks) {
          int breakCount = 0;
          for (int i = 0; i < _textContent.length; i++) {
            if (_textContent.codeUnitAt(i) == 0x0A) breakCount++; // '\n'
          }
          if (breakCount > 0) {
            // Paragraph tends to produce breakCount + 1 lines for pure newlines.
            // Subtract the trailing empty line height to match CSS behavior.
            final int expectedParaLines = breakCount + 1;
            if (_paraLines.length >= expectedParaLines) {
              final double lastH = _paraLines.isNotEmpty ? _paraLines.last.height : 0.0;
              if (lastH.isFinite && lastH > 0) {
                height = math.max(0.0, height - lastH);
              }
            }
          }
        }
      }
      // If there is no text and no placeholders, an IFC with purely out-of-flow content
      // contributes 0 to the in-flow content height per CSS.
      if (_paraCharCount == 0 && _placeholderBoxes.isEmpty) {
        height = 0;
      }
      // Scrollable height should account for atomic inline overflow beyond paragraph lines.
      // After paragraph is ready, update parentData.offset for atomic inline children so that
      // paint and hit testing can rely on the standard Flutter offset mechanism.
      _applyAtomicInlineParentDataOffsets();
      return Size(width, height);
    } finally {
      if (!kReleaseMode) {
        developer.Timeline.finishSync();
      }
    }
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
    // Diagnostics previously logged paint-time info; now omitted for performance.
    if (applyShift) {
      context.canvas.save();
      context.canvas.translate(-shiftX, 0.0);
    }

    try {
      final CSSRenderStyle containerStyle = (container as RenderBoxModel).renderStyle;
      final bool clipText = containerStyle.backgroundClip == CSSBackgroundBoundary.text;

      // Interleave line background and text painting so that later lines can
      // visually overlay earlier lines when they cross vertically.
      // For each paragraph line: paint decorations for that line, then clip and paint text for that line.
      final para = _paragraph!;
      if (_paraLines.isEmpty) {
        // Fallback: paint decorations then text if no line metrics
        _paintInlineSpanDecorations(context, offset);
        if (!clipText) {
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
              final double extraR = s.paddingRight.computedValue +
                  s.effectiveBorderRightWidth.computedValue +
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
        final Map<int, List<(ui.TextBox tb, double dx, double dy)>> relAdjust =
            <int, List<(ui.TextBox, double, double)>>{};
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
          if (!clipText) {
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
                final double extraR = s.paddingRight.computedValue +
                    s.effectiveBorderRightWidth.computedValue +
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

            ui.Path clipMinusVA(Rect base, bool isRightSlice) {
              ui.Path p = ui.Path()..addRect(base);
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
              if (sub.getBounds().isEmpty) return p;
              return ui.Path.combine(ui.PathOperation.difference, p, sub);
            }

            // Left slice (no horizontal shift)
            if (!clipText) {
              context.canvas.save();
              context.canvas.clipPath(clipMinusVA(leftBase, false));
              context.canvas.drawParagraph(para, offset);
              context.canvas.restore();
            }

            // Right slice (apply shift if needed)
            if (!clipText) {
              context.canvas.save();
              context.canvas.clipPath(clipMinusVA(rightBase, true));
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
                if (!clipText) {
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
                if (!clipText) {
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
                if (!clipText) {
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
                if (!clipText) {
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

        // When using background-clip:text, paint text-shadow separately before the
        // gradient mask so that shadows retain their own color instead of being
        // tinted by the background.
        if (clipText && _paragraph != null) {
          final CSSRenderStyle rs0 = (container as RenderBoxModel).renderStyle;
          final List<Shadow>? shadows = rs0.textShadow;
          if (shadows != null && shadows.isNotEmpty) {
            final ui.Paragraph para0 = _paragraph!;
            final double intrinsicLineWidth = para0.longestLine;
            final double layoutWidth = para0.width;
            final double w = math.max(layoutWidth, intrinsicLineWidth);
            final double h = para0.height;
            if (w > 0 && h > 0) {
              for (final Shadow s in shadows) {
                if (s.color.a == 0) continue;
                final double blur = s.blurRadius;
                // Approximate Flutter's radius→sigma conversion.
                double radiusToSigma(double r) => r > 0 ? (r * 0.57735 + 0.5) : 0.0;
                final double sigma = radiusToSigma(blur);
                // Expand layer to accommodate blur spread and offset.
                final double pad = blur * 2 + 2;
                final Rect layer = Rect.fromLTWH(
                  offset.dx + s.offset.dx - pad,
                  offset.dy + s.offset.dy - pad,
                  w + pad * 2,
                  h + pad * 2,
                );
                final Paint layerPaint = Paint();
                if (sigma > 0) {
                  layerPaint.imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
                }
                context.canvas.saveLayer(layer, layerPaint);
                // Draw glyph mask shifted by the shadow offset.
                context.canvas.drawParagraph(para0, offset.translate(s.offset.dx, s.offset.dy));
                // Tint the mask with the shadow color.
                final Paint tint = Paint()
                  ..blendMode = BlendMode.srcIn
                  ..color = s.color;
                context.canvas.drawRect(layer, tint);
                context.canvas.restore();
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
              final double extraR = s.paddingRight.computedValue +
                  s.effectiveBorderRightWidth.computedValue +
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
      final CSSRenderStyle rs0 = (container as RenderBoxModel).renderStyle;
      if (rs0.backgroundClip == CSSBackgroundBoundary.text) {
        final ui.Paragraph? para0 = _paragraph;
        if (para0 != null) {
          final Gradient? grad0 = rs0.backgroundImage?.gradient;
          final Color? bgc0 = rs0.backgroundColor?.value;

          if (grad0 != null || (bgc0 != null && bgc0.a != 0)) {
            final double intrinsicLineWidth = para0.longestLine;
            final double layoutWidth = para0.width;
            final double w = math.max(layoutWidth, intrinsicLineWidth);
            final double h = para0.height;
            if (w > 0 && h > 0) {
              final Rect layer = Rect.fromLTWH(offset.dx, offset.dy, w, h);

              // Compute container border-box rect in current canvas coordinates.
              final double padL = rs0.paddingLeft.computedValue;
              final double padT = rs0.paddingTop.computedValue;
              final double borL = rs0.effectiveBorderLeftWidth.computedValue;
              final double borT = rs0.effectiveBorderTopWidth.computedValue;
              final double contLeft = offset.dx - padL - borL;
              final double contTop = offset.dy - padT - borT;
              final Rect contRect = Rect.fromLTWH(contLeft, contTop, container.size.width, container.size.height);

              // Use a layer so we can mask the background with glyph alpha using srcIn.
              context.canvas.saveLayer(layer, Paint());
              // Draw the paragraph shape into the layer (mask only; no shadows/decoration in clip-text).
              context.canvas.drawParagraph(para0, offset);
              // Now overlay the background with srcIn so it is clipped to the glyphs we just drew.
              final Paint p = Paint()..blendMode = BlendMode.srcIn;
              if (grad0 != null) {
                p.shader = grad0.createShader(contRect);
                context.canvas.drawRect(layer, p);
              } else {
                p.color = bgc0!;
                context.canvas.drawRect(layer, p);
              }
              context.canvas.restore();

              // Overlay text fill color on top (browser paints text after background).
              // This allows CSS color alpha to tint/cover the gradient, matching browser behavior.
              final Color textFill = rs0.color.value;
              if (textFill.a != 0) {
                context.canvas.saveLayer(layer, Paint());
                // Paragraph as mask again
                context.canvas.drawParagraph(para0, offset);
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

      // Detect inline elements within this paragraph that request background-clip:text.
      // Paint inline elements with background-clip:text by masking their glyphs and
      // overlaying their background gradient within each text box rect.
      if (_elementRanges.isNotEmpty && _paragraph != null) {
        final para = _paragraph!;
        _elementRanges.forEach((RenderBoxModel box, (int start, int end) range) {
          final CSSRenderStyle s = box.renderStyle;
          if (s.backgroundClip != CSSBackgroundBoundary.text) return;

          final Gradient? grad = s.backgroundImage?.gradient;
          final Color? bgc = s.backgroundColor?.value;
          if (grad == null && (bgc == null || bgc.a == 0)) return;
          if (range.$2 <= range.$1) return;

          // Text boxes for this element's range
          final List<ui.TextBox> rects = para.getBoxesForRange(range.$1, range.$2);
          if (rects.isEmpty) return;

          // Union of rects for shader bounds
          double minL = rects.first.left, minT = rects.first.top, maxR = rects.first.right, maxB = rects.first.bottom;
          for (final tb in rects) {
            if (tb.left < minL) minL = tb.left;
            if (tb.top < minT) minT = tb.top;
            if (tb.right > maxR) maxR = tb.right;
            if (tb.bottom > maxB) maxB = tb.bottom;
          }
          final Rect union = Rect.fromLTRB(minL, minT, maxR, maxB);

          // Helper to build a mask paragraph for a given text (forced opaque glyph color).
          ui.Paragraph buildMaskPara(String text) {
            final ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
              textDirection: (container as RenderBoxModel).renderStyle.direction,
              textHeightBehavior: const ui.TextHeightBehavior(
                applyHeightToFirstAscent: true,
                applyHeightToLastDescent: true,
                leadingDistribution: ui.TextLeadingDistribution.even,
              ),
            ));
            final families = s.fontFamily;
            if (families != null && families.isNotEmpty) {
              CSSFontFace.ensureFontLoaded(families[0], s.fontWeight, s);
            }
            final double baseFontSize = s.fontSize.computedValue;
            final double safeBaseFontSize = baseFontSize.isFinite && baseFontSize >= 0 ? baseFontSize : 0.0;
            final double? heightMultiple = (() {
              if (s.lineHeight.type == CSSLengthType.NORMAL) return kTextHeightNone;
              if (s.lineHeight.type == CSSLengthType.EM) return s.lineHeight.value;
              if (safeBaseFontSize <= 0) return null;
              return s.lineHeight.computedValue / baseFontSize;
            })();
            final Color maskColor = s.isVisibilityHidden ? const Color(0x00000000) : s.color.value.withAlpha(0xFF);
            final variant = CSSText.resolveFontFeaturesForVariant(s);
            final ui.TextStyle maskStyle = ui.TextStyle(
              color: maskColor,
              // Suppress decoration/shadow in the mask paragraph for clip-text; they
              // are painted via dedicated passes to preserve color/ordering.
              decoration: TextDecoration.none,
              decorationColor: const Color(0x00000000),
              decorationStyle: null,
              fontWeight: s.fontWeight,
              fontStyle: s.fontStyle,
              textBaseline: CSSText.getTextBaseLine(),
              fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
              fontFamilyFallback: families,
              fontSize: safeBaseFontSize,
              letterSpacing: s.letterSpacing?.computedValue,
              wordSpacing: s.wordSpacing?.computedValue,
              height: heightMultiple,
              locale: CSSText.getLocale(),
              background: CSSText.getBackground(),
              foreground: CSSText.getForeground(),
              shadows: null,
              fontFeatures: variant.features.isNotEmpty ? variant.features : null,
            );
            pb.pushStyle(maskStyle);
            _addTextWithFontVariant(pb, text, s, safeBaseFontSize);
            final ui.Paragraph p = pb.build();
            p.layout(const ui.ParagraphConstraints(width: 1000000.0));
            return p;
          }

          // Group rects by paragraph line index to preserve multi-line runs.
          final Map<int, List<ui.TextBox>> lineRects = <int, List<ui.TextBox>>{};
          for (final tb in rects) {
            final int li = _lineIndexForRect(tb);
            (lineRects[li] ??= <ui.TextBox>[]).add(tb);
          }
          final List<int> lines = lineRects.keys.toList()..sort();

          // Binary search to find the maximal end index on a paragraph line.
          int findLineEnd(int startIndex, int targetLine) {
            int lo = startIndex + 1;
            int hi = range.$2;
            int best = startIndex + 1;
            while (lo <= hi) {
              final int mid = lo + ((hi - lo) >> 1);
              final boxes = para.getBoxesForRange(startIndex, mid);
              if (boxes.isEmpty) {
                lo = mid + 1;
                continue;
              }
              final int lastLine = _lineIndexForRect(boxes.last);
              if (lastLine == targetLine) {
                best = mid;
                lo = mid + 1;
              } else if (lastLine < targetLine) {
                lo = mid + 1;
              } else {
                hi = mid - 1;
              }
            }
            return best;
          }

          int segStart = range.$1;
          // Shader rect covers the element’s entire union area.
          final Rect shaderRect =
              Rect.fromLTWH(offset.dx + union.left, offset.dy + union.top, union.width, union.height);

          for (final int li in lines) {
            final boxes = lineRects[li]!;
            boxes.sort((a, b) => a.left.compareTo(b.left));
            // Compute substring end for this line using binary search.
            final int segEnd = findLineEnd(segStart, li);
            if (segEnd <= segStart) {
              continue;
            }
            final String segText = _textContent.substring(segStart, segEnd);
            final ui.Paragraph segPara = buildMaskPara(segText);

            // Build union clip for the line's boxes.
            double l = boxes.first.left, t = boxes.first.top, r = boxes.first.right, b = boxes.first.bottom;
            final ui.Path clip = ui.Path();
            for (final tb in boxes) {
              clip.addRect(
                  Rect.fromLTRB(offset.dx + tb.left, offset.dy + tb.top, offset.dx + tb.right, offset.dy + tb.bottom));
              if (tb.left < l) l = tb.left;
              if (tb.top < t) t = tb.top;
              if (tb.right > r) r = tb.right;
              if (tb.bottom > b) b = tb.bottom;
            }
            final Rect layer = Rect.fromLTRB(offset.dx + l, offset.dy + t, offset.dx + r, offset.dy + b);

            // Paint text shadows for this inline segment before gradient to keep shadow color.
            final List<Shadow>? segShadows = s.textShadow;
            if (segShadows != null && segShadows.isNotEmpty) {
              final ui.TextBox firstBox = boxes.first;
              for (final Shadow sh in segShadows) {
                if (sh.color.a == 0) continue;
                double radiusToSigma(double r) => r > 0 ? (r * 0.57735 + 0.5) : 0.0;
                final double sigma = radiusToSigma(sh.blurRadius);
                final double pad = sh.blurRadius * 2 + 2;
                final Rect shadowLayer = Rect.fromLTRB(
                  layer.left + sh.offset.dx - pad,
                  layer.top + sh.offset.dy - pad,
                  layer.right + sh.offset.dx + pad,
                  layer.bottom + sh.offset.dy + pad,
                );
                final Paint lp = Paint();
                if (sigma > 0) {
                  lp.imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
                }
                context.canvas.saveLayer(shadowLayer, lp);
                context.canvas.drawParagraph(
                  segPara,
                  offset.translate(firstBox.left + sh.offset.dx, firstBox.top + sh.offset.dy),
                );
                final Paint tint = Paint()
                  ..blendMode = BlendMode.srcIn
                  ..color = sh.color;
                context.canvas.drawRect(shadowLayer, tint);
                context.canvas.restore();
              }
            }

            // Paint: mask paragraph at the first fragment origin on this line, then srcIn gradient.
            context.canvas.saveLayer(layer, Paint());
            context.canvas.clipPath(clip);
            final ui.TextBox first = boxes.first;
            context.canvas.drawParagraph(segPara, offset.translate(first.left, first.top));
            final Paint p = Paint()..blendMode = BlendMode.srcIn;
            if (grad != null) {
              p.shader = grad.createShader(shaderRect);
              context.canvas.drawRect(layer, p);
            } else {
              p.color = bgc!;
              context.canvas.drawRect(layer, p);
            }
            context.canvas.restore();

            segStart = segEnd;
          }
        });
      }

      // Paint atomic inline children using parentData.offset for consistency.
      // Convert container-origin offsets to content-local by subtracting the content origin.
      final double contentOriginX = container.renderStyle.paddingLeft.computedValue +
          container.renderStyle.effectiveBorderLeftWidth.computedValue;
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
            final double extraR =
                s.paddingRight.computedValue + s.effectiveBorderRightWidth.computedValue + s.marginRight.computedValue;
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

          if (position.dx >= left && position.dx <= right && position.dy >= top && position.dy <= bottom) {
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
    // We must align atomic placeholders with their actual placeholder indices
    // in the paragraph. Do not assume atomic placeholders start from index 0:
    // other placeholders (e.g., text-indent, left/right extras, textRun) may
    // precede them. Use _allPlaceholders to map each atomic to its TextBox.
    if (_placeholderBoxes.isEmpty || _allPlaceholders.isEmpty) return;

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

    // Walk all placeholders; for atomic ones, map to their corresponding
    // TextBox by the same index and update the render object's offset.
    final int n = math.min(_allPlaceholders.length, _placeholderBoxes.length);
    for (int i = 0; i < n; i++) {
      final ph = _allPlaceholders[i];
      if (ph.kind != _PHKind.atomic) continue;
      final RenderBox? rb = ph.atomic;
      if (rb == null) continue;

      // Find the direct RenderBox child under the container; it carries RenderLayoutParentData
      RenderBox paintBox = rb;
      RenderObject? p = rb.parent;
      while (p != null && p != container) {
        if (p is RenderBox) paintBox = p;
        p = p.parent;
      }

      final ui.TextBox tb = (rtlRemap != null && rtlRemap.containsKey(i)) ? rtlRemap[i]! : _placeholderBoxes[i];
      // Subtract any paragraph paint-time left shift so offsets stay in container coords.
      double left = tb.left - (_paragraphMinLeft.isFinite ? _paragraphMinLeft : 0.0);
      double top = tb.top;
      // If a positive text-indent was applied using a leading placeholder, and
      // this atomic placeholder sits at the very start of the first line, do
      // not include the indent in its x offset. This preserves expected
      // behavior where atomic inlines are not shifted by first-line indent.
      final TextDirection dir = (container as RenderBoxModel).renderStyle.direction;
      if (_leadingTextIndentPx > 0 && dir == TextDirection.ltr) {
        final int li = _lineIndexForRect(tb);
        if (li == 0 && left <= _leadingTextIndentPx + 0.01) {
          left -= _leadingTextIndentPx;
        }
      }
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
    // Reset alignment reflow flag for this build.
    _paraReflowedToAvailWidthForAlign = false;
    // Clear any previous forced align shift; may be recomputed below when applicable.
    _forcedParagraphMinLeftAlignShift = null;
    // Reset paragraph paint-time left shift from prior builds.
    _paragraphMinLeft = 0.0;
    // Lay out atomic inlines first to obtain sizes for placeholders
    _layoutAtomicInlineItemsForParagraph();

    // Configure a paragraph-level strut so the block container's computed line-height
    // establishes the minimum line box height for each line, per CSS. This centers
    // smaller runs (e.g., inline elements with smaller line-height) inside a taller
    // block line-height without requiring per-line paint shifts.
    ui.StrutStyle? paragraphStrut;
    final CSSRenderStyle containerStyle = (container as RenderBoxModel).renderStyle;
    final CSSLengthValue containerLH = containerStyle.lineHeight;
    if (containerLH.type != CSSLengthType.NORMAL) {
      final double fontSize = containerStyle.fontSize.computedValue;
      if (fontSize.isFinite && fontSize > 0) {
        final double multiple = containerLH.computedValue / fontSize;
        // Guard against non-finite or non-positive multiples
        if (multiple.isFinite && multiple > 0) {
          final double scaledFontSize = containerStyle.textScaler.scale(fontSize);
          final FontWeight weight = (containerStyle.boldText && containerStyle.fontWeight.index < FontWeight.w700.index)
              ? FontWeight.w700
              : containerStyle.fontWeight;
          paragraphStrut = ui.StrutStyle(
            fontSize: scaledFontSize,
            height: multiple,
            fontFamilyFallback: containerStyle.fontFamily,
            fontStyle: containerStyle.fontStyle,
            fontWeight: weight,
            // Use as minimum line height; let larger content expand the line.
            forceStrutHeight: false,
          );
        }
      }
    }

    // Compute an effective maxLines for paragraph shaping. In CSS, text-overflow: ellipsis
    // works with white-space: nowrap and overflow not visible. For Flutter's paragraph
    // engine to emit ellipsis glyphs, a maxLines must be provided. When nowrap+ellipsis
    // are active and no explicit line-clamp is set, constrain to a single line.
    final int? effectiveMaxLines = style.lineClamp ??
        ((style.whiteSpace == WhiteSpace.nowrap && style.effectiveTextOverflow == TextOverflow.ellipsis) ? 1 : null);

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: style.textAlign,
      textDirection: style.direction,
      maxLines: effectiveMaxLines,
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
      strutStyle: paragraphStrut,
    ));

    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _textRunParas = <ui.Paragraph?>[];
    _textRunBuildIndex = 0;
    _atomicBuildIndex = 0;
    _elementRanges.clear();
    // Track open inline element frames for deferred extras handling
    final List<_OpenInlineFrame> openFrames = [];

    // Track current paragraph code-unit position as we add text/placeholders
    int paraPos = 0;
    // Track an inline element stack to record ranges
    final List<RenderBoxModel> elementStack = [];

    // Reuse sub-paragraphs for text-run placeholders between pass 1 and pass 2.
    final List<ui.Paragraph>? reuseTextRunParas = _cachedTextRunParagraphsForReuse;
    int reuseTextRunIndex = 0;
    final List<ui.Paragraph> builtTextRunParas = <ui.Paragraph>[];

    // Whether ::first-letter styling should be applied once for this paragraph
    bool firstLetterDone = false;

    // Apply text-indent on the first line by inserting a leading placeholder.
    // Reset cached first-line indent on each build; set when we insert a real indent.
    _leadingTextIndentPx = 0.0;
    // Positive values indent from the inline-start; negative values create a hanging indent.
    // For now, we support positive values by reserving space; for negative values, we still
    // insert a placeholder of zero width (layout unaffected) and rely on authors to pair
    // with padding-inline-start to simulate hanging markers (common pattern).
    final CSSLengthValue indent = style.textIndent;
    double indentPx = 0;
    if (indent.type != CSSLengthType.INITIAL &&
        indent.type != CSSLengthType.UNKNOWN &&
        indent.type != CSSLengthType.AUTO) {
      indentPx = indent.computedValue;
    }
    if (indentPx != 0) {
      final (ph, bo) = _measureParagraphTextMetricsFor(style);
      final double reserved = indentPx > 0 ? indentPx : 0.0;
      if (reserved > 0) {
        _leadingTextIndentPx = reserved;
        // Ensure the indent placeholder is resolved on the inline-start in RTL.
        // Flutter treats placeholders as neutral for bidi reordering; when the
        // paragraph begins with a placeholder, it can be resolved to the wrong
        // direction. Prepending an RTL mark makes the placeholder strongly RTL
        // without affecting layout width.
        if (style.direction == TextDirection.rtl) {
          pb.pushStyle(_uiTextStyleFromCss(style));
          pb.addText('\u200F'); // RLM
          pb.pop();
          paraPos += 1;
        }
        pb.addPlaceholder(reserved, ph, ui.PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic, baselineOffset: bo);
        // Keep placeholder indices aligned: record a neutral placeholder so that
        // subsequent atomic placeholders map to the correct TextBox indices.
        _allPlaceholders.add(_InlinePlaceholder.emptySpan(container as RenderBoxModel, reserved));
        paraPos += 1;
        _textRunParas.add(null);
      }
    }

    // Helper to flush pending left extras for all open frames (from outermost to innermost)
    void flushPendingLeftExtras() {
      for (final frame in openFrames) {
        if (!frame.leftFlushed && frame.leftExtras > 0) {
          final rs = frame.box.renderStyle;
          final (ph, bo) = _measureParagraphTextMetricsFor(rs);
          // Use measured text metrics for placeholder height and baseline to
          // align with the paragraph's line box for this style.
          pb.addPlaceholder(frame.leftExtras, ph, ui.PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic, baselineOffset: bo);
          paraPos += 1; // account for placeholder char
          _allPlaceholders.add(_InlinePlaceholder.leftExtra(frame.box));
          _textRunParas.add(null);
          frame.leftFlushed = true;
        }
      }
    }

    // Mark first content within any open frames and flush left extras once.
    void markContentInOpenFrames() {
      if (openFrames.isEmpty) return;
      bool anyNew = false;
      for (final f in openFrames) {
        if (!f.hadContent) {
          f.hadContent = true;
          anyNew = true;
        }
      }
      if (anyNew) {
        flushPendingLeftExtras();
      }
    }

    // Determine whether we should avoid breaking within ASCII words.
    // This helps match CSS behavior where long unbreakable words in a
    // horizontally scrollable container should overflow and allow scroll
    // instead of wrapping arbitrarily.
    // Avoid breaking within ASCII words when:
    // - this container itself clips or scrolls horizontally (overflow-x != visible), or
    // - any ancestor (excluding HTML/BODY) scrolls horizontally.
    // This matches CSS expectations that long unbreakable words should overflow
    // (and be clipped/scrollable) rather than wrap arbitrarily when overflow-x
    // is not visible.
    final bool localClipsOrScrollsX = container.renderStyle.effectiveOverflowX != CSSOverflowType.visible;
    _avoidWordBreakInScrollableX = localClipsOrScrollsX || _ancestorHasHorizontalScroll();

    for (final item in _items) {
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
          openFrames.add(_OpenInlineFrame(rb, leftExtras: leftExtras, rightExtras: rightExtras));
          pb.pushStyle(_uiTextStyleFromCss(st));
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
          // Handle right extras or merged extras for empty spans
          if (item.renderBox is RenderBoxModel) {
            // Find and remove the corresponding open frame
            int idx = openFrames.lastIndexWhere((f) => f.box == item.renderBox);
            if (idx != -1) {
              final frame = openFrames.removeAt(idx);
              if (frame.hadContent) {
                // Non-empty inline span: ensure left extras flushed, then add a trailing
                // right-extras placeholder only if allowed in this pass.
                flushPendingLeftExtras();
                if (frame.rightExtras > 0) {
                  // Only add a right-extras placeholder in PASS 2 for inline elements
                  // that did not fragment across lines in PASS 1. For fragmented spans,
                  // we reserve trailing extras per-line instead (via width shrink) to
                  // avoid shifting break positions and placing the right border on the
                  // wrong line.
                  final shouldAddRight = !_suppressAllRightExtras && _forceRightExtrasOwners.contains(frame.box);
                  if (shouldAddRight) {
                    final rs = frame.box.renderStyle;
                    final (ph, bo) = _measureParagraphTextMetricsFor(rs);
                    pb.addPlaceholder(frame.rightExtras, ph, ui.PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic, baselineOffset: bo);
                    paraPos += 1;
                    _allPlaceholders.add(_InlinePlaceholder.rightExtra(frame.box));
                    _textRunParas.add(null);
                  } else if (frame.rightExtras > 0) {}
                }
              } else {
                // Empty span: merge left+right extras into a single placeholder only if non-zero.
                // When merged == 0, do NOT add any placeholder; an empty inline with no extras
                // must not create a line box contribution (content height should remain 0).
                final double merged = frame.leftExtras + frame.rightExtras;
                if (merged > 0) {
                  final rs = frame.box.renderStyle;
                  final (ph, bo) = _measureParagraphTextMetricsFor(rs);
                  pb.addPlaceholder(merged, ph, ui.PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic, baselineOffset: bo);
                  paraPos += 1;
                  _allPlaceholders.add(_InlinePlaceholder.emptySpan(frame.box, merged));
                  _textRunParas.add(null);
                } else {}
              }
            }
          }
        }
      } else if (item.isAtomicInline && item.renderBox != null) {
        // First content inside any open frames
        markContentInOpenFrames();
        // Add placeholder for atomic inline
        final rb = item.renderBox!;
        final rbStyle = rb.renderStyle;
        // Width impacts line-breaking: include horizontal margins.
        final mL = rbStyle.marginLeft.computedValue;
        final mR = rbStyle.marginRight.computedValue;
        final mT = rbStyle.marginTop.computedValue;
        final mB = rbStyle.marginBottom.computedValue;
        final width = ((rb.boxSize?.width ?? (rb.hasSize ? rb.boxSize!.width : 0.0)) + mL + mR);
        // Include vertical margins in placeholder height
        final borderBoxHeight = (rb.boxSize?.height ?? (rb.hasSize ? rb.boxSize!.height : 0.0));
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
        } else {
          styleBoxForBaseline = rb;
        }

        final double? cssBaseline = styleBoxForBaseline.computeCssLastBaselineOf(TextBaseline.alphabetic);
        if (cssBaseline != null) {
          baselineOffset = mT + cssBaseline;
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
                _atomicBaselineOffsets != null &&
                _atomicBuildIndex < (_atomicBaselineOffsets?.length ?? 0))
            ? _atomicBaselineOffsets![_atomicBuildIndex]
            : null;
        if (preOffset != null) {
          pb.addPlaceholder(width, height, ui.PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic, baselineOffset: preOffset);
        } else {
          if (align == ui.PlaceholderAlignment.baseline ||
              align == ui.PlaceholderAlignment.aboveBaseline ||
              align == ui.PlaceholderAlignment.belowBaseline) {
            pb.addPlaceholder(width, height, align, baseline: TextBaseline.alphabetic, baselineOffset: baselineOffset);
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
      } else if (item.isText) {
        String text = item.getText(_textContent);
        if (text.isEmpty || item.style == null) continue;
        // First content inside any open frames
        markContentInOpenFrames();
        // If any ancestor establishes horizontal scroll/auto overflow,
        // prevent breaking within ASCII words so long sequences (e.g., digits)
        // overflow horizontally and can be scrolled instead of wrapping.
        if (_avoidWordBreakInScrollableX && _whiteSpaceEligibleForNoWordBreak(item.style!.whiteSpace)) {
          text = _insertWordJoinersForAsciiWords(text);
        }
        // Apply CSS word-break: break-all by inserting soft break opportunities
        // between grapheme clusters when white-space allows wrapping.
        final WhiteSpace ws = item.style!.whiteSpace;
        if (style.wordBreak == WordBreak.breakAll && ws != WhiteSpace.pre && ws != WhiteSpace.nowrap) {
          text = _insertZeroWidthBreaks(text);
        }
        // If the nearest enclosing inline element specifies vertical-align other than baseline,
        // represent this text segment as a placeholder so Flutter positions it by alignment.
        RenderBoxModel? ownerBox = elementStack.isNotEmpty ? elementStack.last : null;
        final VerticalAlign ownerVA = ownerBox?.renderStyle.verticalAlign ?? VerticalAlign.baseline;
        final bool usePlaceholderForText = ownerBox != null && ownerVA != VerticalAlign.baseline;
        if (usePlaceholderForText) {
          ui.Paragraph subPara;
          if (reuseTextRunParas != null && reuseTextRunIndex < reuseTextRunParas.length) {
            subPara = reuseTextRunParas[reuseTextRunIndex++];
          } else {
            // Shape the text in its own paragraph to measure width/height.
            final subPB = ui.ParagraphBuilder(ui.ParagraphStyle(
              textDirection: style.direction,
              textHeightBehavior: const ui.TextHeightBehavior(
                applyHeightToFirstAscent: true,
                applyHeightToLastDescent: true,
                leadingDistribution: ui.TextLeadingDistribution.even,
              ),
            ));
            final ui.TextStyle subStyle = _uiTextStyleFromCss(item.style!);
            subPB.pushStyle(subStyle);
            _addTextWithFontVariant(subPB, text, item.style!, item.style!.fontSize.computedValue);
            subPB.pop();
            subPara = subPB.build();
            subPara.layout(const ui.ParagraphConstraints(width: 1000000.0));
          }
          builtTextRunParas.add(subPara);
          final double phWidth = subPara.longestLine;
          final double phHeight = subPara.height;
          // Prefer baseline alignment with a precomputed baselineOffset when available from a prior pass,
          // so we can align to line top/bottom/middle precisely.
          final double? preOffset =
              _textRunBaselineOffsets != null && _textRunBuildIndex < (_textRunBaselineOffsets?.length ?? 0)
                  ? _textRunBaselineOffsets![_textRunBuildIndex]
                  : null;
          if (preOffset != null) {
            pb.addPlaceholder(phWidth, phHeight, ui.PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic, baselineOffset: preOffset);
          } else {
            pb.addPlaceholder(phWidth, phHeight, _placeholderAlignmentFromCss(ownerVA));
          }
          paraPos += 1;
          _allPlaceholders.add(_InlinePlaceholder.textRun(ownerBox));
          _textRunParas.add(subPara);
          _textRunBuildIndex += 1;
        } else {
          final ui.TextStyle baseRunStyle = _uiTextStyleFromCss(item.style!);
          final double baseFontSize = item.style!.fontSize.computedValue;
          pb.pushStyle(baseRunStyle);

          // Apply ::first-letter if present and not yet applied.
          final ownerEl = (container as RenderBoxModel).renderStyle.target;
          final CSSStyleDeclaration? fl = ownerEl.style.pseudoFirstLetterStyle;
          if (!firstLetterDone && fl != null) {
            // Determine prefix length to style: include leading quote if followed by ASCII letter.
            int prefixLen = 0;
            if (text.isNotEmpty) {
              int c0 = text.codeUnitAt(0);
              bool isAsciiLetter(int c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
              bool isQuote(int c) => c == 0x22 || c == 0x27 || c == 0x201C || c == 0x201D || c == 0x2018 || c == 0x2019;
              if (isQuote(c0) && text.length >= 2 && isAsciiLetter(text.codeUnitAt(1))) {
                prefixLen = 2;
              } else if (isAsciiLetter(c0)) {
                prefixLen = 1;
              }
            }

            if (prefixLen > 0) {
              // Build override style for color/font-size if provided.
              Color? ovColor;
              double? ovFontSize;

              final String colorVal = fl.getPropertyValue(COLOR);
              if (colorVal.isNotEmpty) {
                ovColor = CSSColor.parseColor(colorVal, renderStyle: item.style!, propertyName: COLOR);
              }
              final String fsVal = fl.getPropertyValue(FONT_SIZE);
              if (fsVal.isNotEmpty) {
                final CSSLengthValue parsed = CSSLength.parseLength(fsVal, item.style!, FONT_SIZE);
                ovFontSize = parsed.computedValue;
              }

              if (ovColor != null || (ovFontSize != null && ovFontSize.isFinite)) {
                final ui.TextStyle ovStyle = ui.TextStyle(
                  color: ovColor,
                  fontSize: ovFontSize,
                );
                pb.pushStyle(ovStyle);
                _addTextWithFontVariant(pb, text.substring(0, prefixLen), item.style!, ovFontSize ?? baseFontSize);
                pb.pop();
                if (prefixLen < text.length) {
                  _addTextWithFontVariant(pb, text.substring(prefixLen), item.style!, baseFontSize);
                }
                firstLetterDone = true;
              } else {
                // No supported overrides; fall back to emitting the whole text.
                _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
                firstLetterDone = true; // consider applied so we don't try again
              }
            } else {
              // No eligible prefix in this run; emit as-is and wait for next.
              _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
            }
          } else {
            // No ::first-letter or already applied
            _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
          }

          pb.pop();
          paraPos += text.length;
        }
      } else if (item.type == InlineItemType.control) {
        // Control characters (e.g., from <br>) act as hard line breaks.
        final text = item.getText(_textContent);
        if (text.isEmpty) continue;
        markContentInOpenFrames();
        // Use container style to ensure a style is on the stack for ParagraphBuilder
        pb.pushStyle(_uiTextStyleFromCss(style));
        pb.addText(text);
        pb.pop();
        paraPos += text.length;
      }
    }

    ui.Paragraph paragraph = pb.build();
    final double? fallbackContentMaxWidth = _computeFallbackContentMaxWidth(style);
    final layoutResult = _layoutParagraphForConstraints(
      paragraph: paragraph,
      constraints: constraints,
      style: style,
      fallbackContentMaxWidth: fallbackContentMaxWidth,
    );
    paragraph = layoutResult.paragraph;
    final bool shapedWithHugeWidth = layoutResult.shapedWithHugeWidth;
    final bool isBlockLike = layoutResult.isBlockLike;

    _paragraph = paragraph;
    _paraLines = paragraph.computeLineMetrics();
    _placeholderBoxes = paragraph.getBoxesForPlaceholders();
    _paraCharCount = paraPos; // record final character count

    _applyFirstLinePseudoElementStyles(
      constraints: constraints,
      style: style,
      paragraphStrut: paragraphStrut,
      effectiveMaxLines: effectiveMaxLines,
      fallbackContentMaxWidth: fallbackContentMaxWidth,
      isBlockLike: isBlockLike,
    );

    _paragraphShapedWithHugeWidth = shapedWithHugeWidth;

    // Make text-run sub-paragraphs available for reuse in a subsequent build
    // (pass 2) during the same layout cycle.
    _cachedTextRunParagraphsForReuse = builtTextRunParas;
  }

  double? _computeFallbackContentMaxWidth(CSSRenderStyle style) {
    double? fallbackContentMaxWidth;
    bool parentIsFlex = false;
    bool parentIsInlineBlockAutoWidth = false;
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
        }
        if (p is RenderWidget) {
          break;
        }
      }
      p = p.parent;
    }

    final double cmw = style.contentMaxConstraintsWidth;
    if (!parentIsFlex && !parentIsInlineBlockAutoWidth && cmw.isFinite && cmw > 0) {
      fallbackContentMaxWidth = cmw;
    }

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
        p = p.parent;
      }
    }

    return fallbackContentMaxWidth;
  }

  ({ui.Paragraph paragraph, bool shapedWithHugeWidth, bool isBlockLike}) _layoutParagraphForConstraints({
    required ui.Paragraph paragraph,
    required BoxConstraints constraints,
    required CSSRenderStyle style,
    required double? fallbackContentMaxWidth,
  }) {
    double initialWidth;
    bool shapedWithHugeWidth = false;
    bool shapedWithZeroWidth = false; // Track when we intentionally shape with 0 width

    final bool hasAtomicInlines = _items.any((it) => it.isAtomicInline);
    final bool hasExplicitBreaks =
        _items.any((it) => it.type == InlineItemType.control || it.type == InlineItemType.lineBreakOpportunity);
    bool hasWhitespaceInText = false;
    bool hasInteriorWhitespaceInText = false;
    bool hasBreakablePunctuationInText = false; // e.g., hyphen '-' or soft hyphen
    bool hasCJKBreaks = false; // CJK characters introduce break opportunities under normal line-breaking
    for (final it in _items) {
      if (it.isText) {
        final t = it.getText(_textContent);
        if (!hasWhitespaceInText && _softWrapWhitespaceRegExp.hasMatch(t)) {
          hasWhitespaceInText = true;
        }
        if (!hasInteriorWhitespaceInText && _interiorWhitespaceRegExp.hasMatch(t)) {
          hasInteriorWhitespaceInText = true;
        }
        if (!hasBreakablePunctuationInText) {
          if (t.contains('-') || t.contains('\u00AD') || t.contains('/')) {
            hasBreakablePunctuationInText = true;
          }
        }
        if (!hasCJKBreaks && TextScriptDetector.containsCJK(t)) {
          hasCJKBreaks = true;
        }
        if (hasWhitespaceInText && hasInteriorWhitespaceInText && hasBreakablePunctuationInText && hasCJKBreaks) {
          break;
        }
      }
    }

    final bool breakAll = style.wordBreak == WordBreak.breakAll;
    final bool preferZeroWidthShaping =
        hasAtomicInlines || hasExplicitBreaks || hasWhitespaceInText || hasCJKBreaks || breakAll;
    if (!constraints.hasBoundedWidth) {
      initialWidth =
          (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0) ? fallbackContentMaxWidth : 1000000.0;
      if (initialWidth >= 1000000.0) {
        shapedWithHugeWidth = true;
      }
    } else {
      if (constraints.maxWidth > 0) {
        initialWidth = constraints.maxWidth;
      } else {
        if (preferZeroWidthShaping) {
          initialWidth = 0.0;
          shapedWithZeroWidth = true;
        } else {
          initialWidth =
              (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0) ? fallbackContentMaxWidth : 1000000.0;
          if (initialWidth >= 1000000.0) {
            shapedWithHugeWidth = true;
          }
        }
      }
    }

    final bool contentHasNoBreaks = !hasAtomicInlines &&
        !hasExplicitBreaks &&
        !hasInteriorWhitespaceInText &&
        !hasBreakablePunctuationInText &&
        !hasCJKBreaks &&
        !breakAll;
    if (contentHasNoBreaks) {
      initialWidth = 1000000.0;
      shapedWithHugeWidth = true;
    }

    final bool noSoftWrap = style.whiteSpace == WhiteSpace.nowrap || style.whiteSpace == WhiteSpace.pre;
    if (noSoftWrap) {
      final bool wantsEllipsis = style.effectiveTextOverflow == TextOverflow.ellipsis &&
          (style.effectiveOverflowX != CSSOverflowType.visible);
      if (!wantsEllipsis) {
        initialWidth = 1000000.0;
        shapedWithHugeWidth = true;
      }
    }
    paragraph.layout(ui.ParagraphConstraints(width: initialWidth));

    final CSSDisplay display = (container as RenderBoxModel).renderStyle.effectiveDisplay;
    final bool isBlockLike = display == CSSDisplay.block || display == CSSDisplay.inlineBlock;

    if (shapedWithHugeWidth &&
        constraints.hasBoundedWidth &&
        constraints.maxWidth.isFinite &&
        constraints.maxWidth > 0) {
      final CSSPositionType posType = (container as RenderBoxModel).renderStyle.position;
      final bool containerIsOutOfFlow = posType == CSSPositionType.absolute || posType == CSSPositionType.fixed;
      if (!containerIsOutOfFlow) {
        final double naturalSingleLine = paragraph.longestLine;
        if (constraints.maxWidth + 0.5 >= naturalSingleLine) {
          paragraph.layout(ui.ParagraphConstraints(width: constraints.maxWidth));
          final TextAlign ta = style.textAlign;
          final bool alignForCentering =
              (ta == TextAlign.center || ta == TextAlign.right || ta == TextAlign.end || ta == TextAlign.justify);
          _paraReflowedToAvailWidthForAlign = alignForCentering;
        }
      }
    }

    if (isBlockLike) {
      if (!constraints.hasBoundedWidth) {
        final double targetWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
            ? fallbackContentMaxWidth
            : paragraph.longestLine;
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      } else if (constraints.maxWidth <= 0) {
        if (!shapedWithZeroWidth) {
          final double targetWidth = (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0)
              ? fallbackContentMaxWidth
              : paragraph.longestLine;
          paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
        }
      }
    } else {
      final double targetWidth =
          math.min(paragraph.longestLine, constraints.maxWidth.isFinite ? constraints.maxWidth : paragraph.longestLine);
      if (targetWidth != initialWidth) {
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    }

    if (!shapedWithHugeWidth) {
      _shrinkWidthForTrailingExtras(paragraph, constraints);
    }

    return (paragraph: paragraph, shapedWithHugeWidth: shapedWithHugeWidth, isBlockLike: isBlockLike);
  }

  void _applyFirstLinePseudoElementStyles({
    required BoxConstraints constraints,
    required CSSRenderStyle style,
    required ui.StrutStyle? paragraphStrut,
    required int? effectiveMaxLines,
    required double? fallbackContentMaxWidth,
    required bool isBlockLike,
  }) {
    if (_paragraph == null || _paraLines.isEmpty) return;
    final ownerEl = (container as RenderBoxModel).renderStyle.target;
    final CSSStyleDeclaration? firstLineDecl = ownerEl.style.pseudoFirstLineStyle;
    if (firstLineDecl == null) return;

    final int firstLineLimit = _firstLineCharLimit(_paragraph!, _paraCharCount);
    _rebuildParagraphForFirstLineLimit(
      constraints: constraints,
      style: style,
      paragraphStrut: paragraphStrut,
      effectiveMaxLines: effectiveMaxLines,
      fallbackContentMaxWidth: fallbackContentMaxWidth,
      isBlockLike: isBlockLike,
      firstLineLimit: firstLineLimit,
      firstLineDecl: firstLineDecl,
      firstLetterDecl: ownerEl.style.pseudoFirstLetterStyle,
    );

    final int correctedLimit = _firstLineCharLimit(_paragraph!, _paraCharCount);
    if (correctedLimit != firstLineLimit) {
      _rebuildParagraphForFirstLineLimit(
        constraints: constraints,
        style: style,
        paragraphStrut: paragraphStrut,
        effectiveMaxLines: effectiveMaxLines,
        fallbackContentMaxWidth: fallbackContentMaxWidth,
        isBlockLike: isBlockLike,
        firstLineLimit: correctedLimit,
        firstLineDecl: firstLineDecl,
        firstLetterDecl: ownerEl.style.pseudoFirstLetterStyle,
      );
    }
  }

  int _firstLineCharLimit(ui.Paragraph paragraph, int charCount) {
    int lo = 1;
    int hi = charCount;
    int limit = 0;
    while (lo <= hi) {
      final int mid = lo + ((hi - lo) >> 1);
      final boxes = paragraph.getBoxesForRange(0, mid);
      if (boxes.isEmpty) {
        lo = mid + 1;
        continue;
      }
      final int lastLine = _lineIndexForRect(boxes.last);
      if (lastLine == 0) {
        limit = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return limit;
  }

  void _rebuildParagraphForFirstLineLimit({
    required BoxConstraints constraints,
    required CSSRenderStyle style,
    required ui.StrutStyle? paragraphStrut,
    required int? effectiveMaxLines,
    required double? fallbackContentMaxWidth,
    required bool isBlockLike,
    required int firstLineLimit,
    required CSSStyleDeclaration firstLineDecl,
    required CSSStyleDeclaration? firstLetterDecl,
  }) {
    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _textRunParas = <ui.Paragraph?>[];
    _textRunBuildIndex = 0;
    _atomicBuildIndex = 0;
    _elementRanges.clear();

    int paraPos = 0;
    int firstLineRemaining = firstLineLimit;
    bool firstLetterApplied = false;

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: style.textAlign,
      textDirection: style.direction,
      maxLines: effectiveMaxLines,
      ellipsis: style.effectiveTextOverflow == TextOverflow.ellipsis ? '\u2026' : null,
      textHeightBehavior: const ui.TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
        leadingDistribution: ui.TextLeadingDistribution.even,
      ),
      strutStyle: paragraphStrut,
    ));

    for (final item in _items) {
      if (item.isAtomicInline) {
        final RenderBoxModel rb = item.renderBox as RenderBoxModel;
        final CSSRenderStyle rbStyle = rb.renderStyle;
        final (double height, double baselineOffset) = _measureParagraphTextMetricsFor(rbStyle);
        final double mL = rbStyle.marginLeft.computedValue;
        final double mR = rbStyle.marginRight.computedValue;
        final double width = math.max(0.0, (rb.boxSize?.width ?? (rb.hasSize ? rb.boxSize!.width : 0.0)) + mL + mR);
        final ui.PlaceholderAlignment align = _placeholderAlignmentFromCss(rbStyle.verticalAlign);
        pb.addPlaceholder(width, height, align, baseline: TextBaseline.alphabetic, baselineOffset: baselineOffset);
        _placeholderOrder.add(rb);
        _allPlaceholders.add(_InlinePlaceholder.atomic(rb));
        _textRunParas.add(null);
        if (rbStyle.verticalAlign != VerticalAlign.baseline) {
          _atomicBuildIndex += 1;
        }
        paraPos += 1;
        if (firstLineRemaining > 0) firstLineRemaining -= 1;
      } else if (item.isText) {
        final String text = item.getText(_textContent);
        if (text.isEmpty || item.style == null) continue;
        final ui.TextStyle baseRunStyle = _uiTextStyleFromCss(item.style!);
        final double baseFontSize = item.style!.fontSize.computedValue;
        pb.pushStyle(baseRunStyle);
        if (firstLineRemaining > 0) {
          final int segLen = math.min(firstLineRemaining, text.length);
          final ui.TextStyle? flOv = _firstLineOverrideFor(firstLineDecl, item.style!);

          ui.TextStyle? flLetterOv;
          int letterPrefix = 0;
          if (!firstLetterApplied && firstLetterDecl != null) {
            letterPrefix = _firstLetterPrefixLength(text);
            if (letterPrefix > 0) {
              flLetterOv = _firstLetterOverrideFor(firstLetterDecl, item.style!) ?? ui.TextStyle();
            }
          }

          if (segLen > 0) {
            // dart:ui.TextStyle does not expose fontSize; keep synthesis relative
            // to the element's computed font-size for now.
            final double effectiveFirstLineFontSize = baseFontSize;
            if (flOv != null) pb.pushStyle(flOv);
            if (letterPrefix > 0) {
              final int used = math.min(letterPrefix, segLen);
              final double effectiveLetterFontSize = effectiveFirstLineFontSize;
              if (flLetterOv != null) pb.pushStyle(flLetterOv);
              _addTextWithFontVariant(pb, text.substring(0, used), item.style!, effectiveLetterFontSize);
              if (flLetterOv != null) pb.pop();
              if (segLen > used) {
                _addTextWithFontVariant(pb, text.substring(used, segLen), item.style!, effectiveFirstLineFontSize);
              }
              firstLetterApplied = true;
            } else {
              _addTextWithFontVariant(pb, text.substring(0, segLen), item.style!, effectiveFirstLineFontSize);
            }
            if (flOv != null) pb.pop();
          }
          if (text.length > segLen) {
            _addTextWithFontVariant(pb, text.substring(segLen), item.style!, baseFontSize);
          }
          firstLineRemaining -= segLen;
        } else {
          if (!firstLetterApplied && firstLetterDecl != null) {
            final int letterPrefix = _firstLetterPrefixLength(text);
            if (letterPrefix > 0) {
              final ui.TextStyle? ov = _firstLetterOverrideFor(firstLetterDecl, item.style!);
              if (ov != null) {
                pb.pushStyle(ov);
                _addTextWithFontVariant(pb, text.substring(0, letterPrefix), item.style!, baseFontSize);
                pb.pop();
                if (letterPrefix < text.length) {
                  _addTextWithFontVariant(pb, text.substring(letterPrefix), item.style!, baseFontSize);
                }
              } else {
                _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
              }
              firstLetterApplied = true;
            } else {
              _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
            }
          } else {
            _addTextWithFontVariant(pb, text, item.style!, baseFontSize);
          }
        }
        pb.pop();
        paraPos += text.length;
      } else if (item.type == InlineItemType.control) {
        final String text = item.getText(_textContent);
        if (text.isEmpty) continue;
        pb.pushStyle(_uiTextStyleFromCss(style));
        pb.addText(text);
        pb.pop();
        paraPos += text.length;
        if (firstLineRemaining > 0) firstLineRemaining -= math.min(firstLineRemaining, text.length);
      }
    }

    ui.Paragraph paragraph = pb.build();
    double initialWidth = constraints.hasBoundedWidth ? constraints.maxWidth : paragraph.longestLine;
    if (initialWidth <= 0) initialWidth = paragraph.longestLine;
    paragraph.layout(ui.ParagraphConstraints(width: initialWidth));

    if (isBlockLike) {
      if (!constraints.hasBoundedWidth) {
        final double targetWidth =
            (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0) ? fallbackContentMaxWidth : paragraph.longestLine;
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      } else if (constraints.maxWidth <= 0) {
        final double targetWidth =
            (fallbackContentMaxWidth != null && fallbackContentMaxWidth > 0) ? fallbackContentMaxWidth : paragraph.longestLine;
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    } else {
      final double targetWidth =
          math.min(paragraph.longestLine, constraints.maxWidth.isFinite ? constraints.maxWidth : paragraph.longestLine);
      if (targetWidth != initialWidth) {
        paragraph.layout(ui.ParagraphConstraints(width: targetWidth));
      }
    }

    _paragraph = paragraph;
    _paraLines = paragraph.computeLineMetrics();
    _placeholderBoxes = paragraph.getBoxesForPlaceholders();
    _paraCharCount = paraPos;
  }

  void _layoutAtomicInlineItemsForParagraph() {
    final Set<RenderBox> laidOut = {};
    for (final item in _items) {
      if (item.isAtomicInline && item.renderBox != null) {
        final child = item.renderBox!;
        if (laidOut.contains(child)) continue;
        final constraints = child.getConstraints();
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
          top = baseTop;
          bottom = baseBottom;
        } else {
          // Clamp vertical extent to the line's content band even when not painting per-line.
          final int li = _lineIndexForRect(tb);
          if (li >= 0 && li < _paraLines.length) {
            final lm = _paraLines[li];
            final double baseTop = lm.baseline - mBaseline;
            final double baseBottom = baseTop + mHeight;
            top = baseTop;
            bottom = baseBottom;
          }
        }

        // Apply CSS vertical-align adjustments for decoration bands so backgrounds/borders move
        // together with the text when using text-run placeholders (e.g., vertical-align: top).
        final va = s.verticalAlign;
        final int liForVA =
            (lineTop != null && lineBottom != null && currentLineIndex >= 0) ? currentLineIndex : _lineIndexForRect(tb);
        if (liForVA >= 0 && liForVA < _paraLines.length && va != VerticalAlign.baseline) {
          final (bandTop, bandBottom, _) = _bandForLine(liForVA);
          double newTop = top;
          double newBottom = bottom;
          switch (va) {
            case VerticalAlign.top:
              newTop = bandTop;
              newBottom = bandTop + (bottom - top);
              break;
            case VerticalAlign.bottom:
              newBottom = bandBottom;
              newTop = bandBottom - (bottom - top);
              break;
            case VerticalAlign.middle:
              final double bandMid = (bandTop + bandBottom) / 2.0;
              final double half = (bottom - top) / 2.0;
              newTop = bandMid - half;
              newBottom = bandMid + half;
              break;
            default:
              // For textTop/textBottom and unknowns, approximate to top/bottom behavior.
              if (va == VerticalAlign.textTop) {
                newTop = bandTop;
                newBottom = bandTop + (bottom - top);
              } else if (va == VerticalAlign.textBottom) {
                newBottom = bandBottom;
                newTop = bandBottom - (bottom - top);
              }
              break;
          }
          if ((newTop - top).abs() > 0.01 || (newBottom - bottom).abs() > 0.01) {
            top = newTop;
            bottom = newBottom;
          }
        }

        // For empty height rects we keep the clamped band; vertical padding/border
        // will be applied conditionally below to avoid exaggerated heights.

        // Determine visual-first/last fragments on this line (physical left/right),
        // instead of relying on logical order (i==0/last). This is important in RTL,
        // where the first logical fragment can be at the visual right.
        bool overlapsLine(ui.TextBox r) {
          if (lineTop == null || lineBottom == null) return true;
          return !(r.bottom <= lineTop || r.top >= lineBottom);
        }

        int lineOf(ui.TextBox r) =>
            (lineTop != null && lineBottom != null && currentLineIndex >= 0) ? currentLineIndex : _lineIndexForRect(r);
        // Visual edge within the current line band
        bool isFirst = true;
        bool isLast = true;
        for (int k = 0; k < e.rects.length; k++) {
          if (k == i) continue;
          final rk = e.rects[k];
          if (!overlapsLine(rk)) continue;
          // Only compare fragments that belong to the same line band
          if (lineOf(rk) != lineOf(tb)) continue;
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
              if (identical(p, e.box)) {
                isDescendant = true;
                break;
              }
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

        // Background: optionally suppress tiny edge whitespace fragment painting to avoid slivers
        bool suppressTinyEdgePaint() {
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
            if (lineOf(rk) != lineOf(tb)) continue;
            if ((rk.right - rk.left) > smallThresh) return true;
          }
          return false;
        }

        final bool suppressEdge = suppressTinyEdgePaint();
        // Skip painting inline background rectangles when background-clip:text is set
        if (!suppressEdge && s.backgroundColor?.value != null && s.backgroundClip != CSSBackgroundBoundary.text) {
          final bg = Paint()..color = s.backgroundColor!.value;
          canvas.drawRect(rect, bg);
        }

        // Borders: do not suppress on tiny edge fragments; borders must remain continuous.
        final p = Paint()..style = PaintingStyle.fill;

        // Precompute side styles and colors with 3D adjustments
        final topStyle = s.borderTopStyle;
        final rightStyle = s.borderRightStyle;
        final bottomStyle = s.borderBottomStyle;
        final leftStyle = s.borderLeftStyle;

        Color cTop = s.borderTopColor.value;
        Color cRight = s.borderRightColor.value;
        Color cBottom = s.borderBottomColor.value;
        Color cLeft = s.borderLeftColor.value;

        bool is3DInsetOutset(CSSBorderStyleType t) => t == CSSBorderStyleType.outset || t == CSSBorderStyleType.inset;
        bool is3DGrooveRidge(CSSBorderStyleType t) => t == CSSBorderStyleType.groove || t == CSSBorderStyleType.ridge;

        // Apply 3D shading per side
        if (topStyle == CSSBorderStyleType.outset) cTop = CSSColor.transformToLightColor(cTop);
        if (topStyle == CSSBorderStyleType.inset) cTop = CSSColor.tranformToDarkColor(cTop);
        if (bottomStyle == CSSBorderStyleType.outset) cBottom = CSSColor.tranformToDarkColor(cBottom);
        if (bottomStyle == CSSBorderStyleType.inset) cBottom = CSSColor.transformToLightColor(cBottom);
        if (leftStyle == CSSBorderStyleType.outset) cLeft = CSSColor.transformToLightColor(cLeft);
        if (leftStyle == CSSBorderStyleType.inset) cLeft = CSSColor.tranformToDarkColor(cLeft);
        if (rightStyle == CSSBorderStyleType.outset) cRight = CSSColor.tranformToDarkColor(cRight);
        if (rightStyle == CSSBorderStyleType.inset) cRight = CSSColor.transformToLightColor(cRight);

        final bool anyInsetOutset = is3DInsetOutset(topStyle) ||
            is3DInsetOutset(rightStyle) ||
            is3DInsetOutset(bottomStyle) ||
            is3DInsetOutset(leftStyle);
        final bool anyGrooveRidge = is3DGrooveRidge(topStyle) ||
            is3DGrooveRidge(rightStyle) ||
            is3DGrooveRidge(bottomStyle) ||
            is3DGrooveRidge(leftStyle);

        if (!anyInsetOutset && !anyGrooveRidge) {
          // Helper painters for dashed/dotted sides (rectangular segments)
          void paintDashedHorizontal(double x0, double x1, double y, double h, Color color, bool dotted) {
            if (x1 <= x0 || h <= 0) return;
            final Paint dashPaint = Paint()
              ..style = PaintingStyle.fill
              ..color = color;
            final double unit = dotted ? h : math.max(h, h * 1.8);
            final double gap = unit; // simple equal dash-gap pattern
            double x = x0;
            while (x < x1) {
              final double w = math.min(unit, x1 - x);
              if (w <= 0) break;
              canvas.drawRect(Rect.fromLTWH(x, y, w, h), dashPaint);
              x += unit + gap;
            }
          }

          void paintDashedVertical(double y0, double y1, double x, double w, Color color, bool dotted) {
            if (y1 <= y0 || w <= 0) return;
            final Paint dashPaint = Paint()
              ..style = PaintingStyle.fill
              ..color = color;
            final double unit = dotted ? w : math.max(w, w * 1.8);
            final double gap = unit;
            double y = y0;
            while (y < y1) {
              final double h = math.min(unit, y1 - y);
              if (h <= 0) break;
              canvas.drawRect(Rect.fromLTWH(x, y, w, h), dashPaint);
              y += unit + gap;
            }
          }

          // Original behavior (including double borders) when no 3D styles are involved.
          if (bT > 0) {
            p.color = cTop;
            if (topStyle == CSSBorderStyleType.dashed || topStyle == CSSBorderStyleType.dotted) {
              paintDashedHorizontal(rect.left, rect.right, rect.top, bT, cTop, topStyle == CSSBorderStyleType.dotted);
            } else if (topStyle == CSSBorderStyleType.double && bT >= 3.0) {
              final double band = (bT / 3.0).floorToDouble().clamp(1.0, bT);
              final double gap = (bT - 2 * band).clamp(0.0, bT);
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, band), p);
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + band + gap, rect.width, band), p);
            } else {
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, bT), p);
            }
          }
          if (bB > 0) {
            p.color = cBottom;
            if (bottomStyle == CSSBorderStyleType.dashed || bottomStyle == CSSBorderStyleType.dotted) {
              paintDashedHorizontal(
                  rect.left, rect.right, rect.bottom - bB, bB, cBottom, bottomStyle == CSSBorderStyleType.dotted);
            } else if (bottomStyle == CSSBorderStyleType.double && bB >= 3.0) {
              final double band = (bB / 3.0).floorToDouble().clamp(1.0, bB);
              final double gap = (bB - 2 * band).clamp(0.0, bB);
              final double topY = rect.bottom - bB;
              canvas.drawRect(Rect.fromLTWH(rect.left, topY, rect.width, band), p);
              canvas.drawRect(Rect.fromLTWH(rect.left, topY + band + gap, rect.width, band), p);
            } else {
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - bB, rect.width, bB), p);
            }
          }
          if (logicalFirstFrag && bL > 0) {
            p.color = cLeft;
            if (leftStyle == CSSBorderStyleType.dashed || leftStyle == CSSBorderStyleType.dotted) {
              paintDashedVertical(rect.top, rect.bottom, rect.left, bL, cLeft, leftStyle == CSSBorderStyleType.dotted);
            } else if (leftStyle == CSSBorderStyleType.double && bL >= 3.0) {
              final double band = (bL / 3.0).floorToDouble().clamp(1.0, bL);
              final double gap = (bL - 2 * band).clamp(0.0, bL);
              // Outer band (left-most)
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, band, rect.height), p);
              // Inner band (toward content)
              canvas.drawRect(Rect.fromLTWH(rect.left + band + gap, rect.top, band, rect.height), p);
            } else {
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, bL, rect.height), p);
            }
          }
          if (logicalLastFrag && bR > 0) {
            p.color = cRight;
            if (rightStyle == CSSBorderStyleType.dashed || rightStyle == CSSBorderStyleType.dotted) {
              paintDashedVertical(
                  rect.top, rect.bottom, rect.right - bR, bR, cRight, rightStyle == CSSBorderStyleType.dotted);
            } else if (rightStyle == CSSBorderStyleType.double && bR >= 3.0) {
              final double band = (bR / 3.0).floorToDouble().clamp(1.0, bR);
              final double gap = (bR - 2 * band).clamp(0.0, bR);
              // Inner band (toward content)
              canvas.drawRect(Rect.fromLTWH(rect.right - band - gap - band, rect.top, band, rect.height), p);
              // Outer band (right-most)
              canvas.drawRect(Rect.fromLTWH(rect.right - band, rect.top, band, rect.height), p);
            } else {
              canvas.drawRect(Rect.fromLTWH(rect.right - bR, rect.top, bR, rect.height), p);
            }
          }
        } else if (anyInsetOutset) {
          // 3D corners with miter joins: draw central bands excluding corner squares,
          // then draw corner triangles splitting along 45-degree diagonals.
          double tlX = rect.left, tlY = rect.top;
          double trX = rect.right, trY = rect.top;
          double blX = rect.left, blY = rect.bottom;
          double brX = rect.right, brY = rect.bottom;

          // Helper: draw a filled triangle path given three points
          void tri(double x1, double y1, double x2, double y2, double x3, double y3, Color color) {
            final path = Path()
              ..moveTo(x1, y1)
              ..lineTo(x2, y2)
              ..lineTo(x3, y3)
              ..close();
            p.color = color;
            canvas.drawPath(path, p);
          }

          // Top central band
          if (bT > 0) {
            final double x = rect.left + bL;
            final double w = math.max(0.0, rect.width - bL - bR);
            if (w > 0) {
              p.color = cTop;
              if (topStyle == CSSBorderStyleType.double && bT >= 3.0) {
                final double band = (bT / 3.0).floorToDouble().clamp(1.0, bT);
                final double gap = (bT - 2 * band).clamp(0.0, bT);
                canvas.drawRect(Rect.fromLTWH(x, rect.top, w, band), p);
                canvas.drawRect(Rect.fromLTWH(x, rect.top + band + gap, w, band), p);
              } else {
                canvas.drawRect(Rect.fromLTWH(x, rect.top, w, bT), p);
              }
            }
          }
          // Bottom central band
          if (bB > 0) {
            final double x = rect.left + bL;
            final double w = math.max(0.0, rect.width - bL - bR);
            if (w > 0) {
              p.color = cBottom;
              if (bottomStyle == CSSBorderStyleType.double && bB >= 3.0) {
                final double band = (bB / 3.0).floorToDouble().clamp(1.0, bB);
                final double gap = (bB - 2 * band).clamp(0.0, bB);
                final double topY = rect.bottom - bB;
                canvas.drawRect(Rect.fromLTWH(x, topY, w, band), p);
                canvas.drawRect(Rect.fromLTWH(x, topY + band + gap, w, band), p);
              } else {
                canvas.drawRect(Rect.fromLTWH(x, rect.bottom - bB, w, bB), p);
              }
            }
          }
          // Left central band (on first logical fragment only)
          if (logicalFirstFrag && bL > 0) {
            final double y = rect.top + bT;
            final double h = math.max(0.0, rect.height - bT - bB);
            if (h > 0) {
              p.color = cLeft;
              canvas.drawRect(Rect.fromLTWH(rect.left, y, bL, h), p);
            }
          }
          // Right central band (on last logical fragment only)
          if (logicalLastFrag && bR > 0) {
            final double y = rect.top + bT;
            final double h = math.max(0.0, rect.height - bT - bB);
            if (h > 0) {
              p.color = cRight;
              canvas.drawRect(Rect.fromLTWH(rect.right - bR, y, bR, h), p);
            }
          }

          // Corner triangles: split corner squares along diagonals; each side paints its half.
          // Top-left
          if (bT > 0 && bL > 0) {
            // Top half
            tri(tlX, tlY, tlX + bL, tlY, tlX, tlY + bT, cTop);
            // Left half
            if (logicalFirstFrag) tri(tlX + bL, tlY, tlX + bL, tlY + bT, tlX, tlY + bT, cLeft);
          }
          // Top-right
          if (bT > 0 && bR > 0) {
            // Diagonal from OUTER (trX,trY) to INNER (trX - bR, trY + bT)
            // Top half (adjacent to top edge): (outer, top-left, inner)
            tri(trX, trY, trX - bR, trY, trX - bR, trY + bT, cTop);
            // Right half (adjacent to right edge): (outer, right-bottom, inner)
            if (logicalLastFrag) tri(trX, trY, trX, trY + bT, trX - bR, trY + bT, cRight);
          }
          // Bottom-left
          if (bB > 0 && bL > 0) {
            // Diagonal from OUTER (blX, blY) to INNER (blX + bL, blY - bB)
            // Bottom half (adjacent to bottom edge): (SW, SE, NE)
            tri(blX, blY, blX + bL, blY, blX + bL, blY - bB, cBottom);
            // Left half (adjacent to left edge): (SW, NW, NE)
            if (logicalFirstFrag) tri(blX, blY, blX, blY - bB, blX + bL, blY - bB, cLeft);
          }
          // Bottom-right
          if (bB > 0 && bR > 0) {
            // Diagonal from (right - bR, bottom) to (right, bottom - bB)
            // Bottom half (adjacent to bottom edge)
            tri(brX - bR, brY, brX, brY, brX, brY - bB, cBottom);
            // Right half (adjacent to right edge)
            if (logicalLastFrag) tri(brX - bR, brY, brX - bR, brY - bB, brX, brY - bB, cRight);
          }
        } else {
          // groove/ridge: two-band 3D shading per side.
          // Compute light/dark per side from the base color.
          Color topLight = CSSColor.transformToLightColor(s.borderTopColor.value);
          Color topDark = CSSColor.tranformToDarkColor(s.borderTopColor.value);
          Color rightLight = CSSColor.transformToLightColor(s.borderRightColor.value);
          Color rightDark = CSSColor.tranformToDarkColor(s.borderRightColor.value);
          Color bottomLight = CSSColor.transformToLightColor(s.borderBottomColor.value);
          Color bottomDark = CSSColor.tranformToDarkColor(s.borderBottomColor.value);
          Color leftLight = CSSColor.transformToLightColor(s.borderLeftColor.value);
          Color leftDark = CSSColor.tranformToDarkColor(s.borderLeftColor.value);

          bool isGrooveTop = topStyle == CSSBorderStyleType.groove;
          bool isGrooveRight = rightStyle == CSSBorderStyleType.groove;
          bool isGrooveBottom = bottomStyle == CSSBorderStyleType.groove;
          bool isGrooveLeft = leftStyle == CSSBorderStyleType.groove;

          // Top: split into two horizontal bands.
          if (bT > 0) {
            final double h1 = (bT / 2.0).floorToDouble().clamp(0.0, bT);
            final double h2 = bT - h1;
            if (h1 > 0) {
              p.color = isGrooveTop ? topDark : topLight; // outer band (top)
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, h1), p);
            }
            if (h2 > 0) {
              p.color = isGrooveTop ? topLight : topDark; // inner band (toward content)
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + h1, rect.width, h2), p);
            }
          }
          // Bottom: split into two horizontal bands.
          if (bB > 0) {
            final double h1 = (bB / 2.0).floorToDouble().clamp(0.0, bB);
            final double h2 = bB - h1;
            // Outer band (bottom-most)
            if (h1 > 0) {
              p.color = isGrooveBottom ? bottomLight : bottomDark;
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - h1, rect.width, h1), p);
            }
            if (h2 > 0) {
              p.color = isGrooveBottom ? bottomDark : bottomLight; // inner band (above)
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - h1 - h2, rect.width, h2), p);
            }
          }
          // Left: split into two vertical bands (only on logical first fragment).
          if (logicalFirstFrag && bL > 0) {
            final double w1 = (bL / 2.0).floorToDouble().clamp(0.0, bL);
            final double w2 = bL - w1;
            if (w1 > 0) {
              p.color = isGrooveLeft ? leftDark : leftLight; // outer band (left-most)
              canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, w1, rect.height), p);
            }
            if (w2 > 0) {
              p.color = isGrooveLeft ? leftLight : leftDark; // inner band
              canvas.drawRect(Rect.fromLTWH(rect.left + w1, rect.top, w2, rect.height), p);
            }
          }
          // Right: split into two vertical bands (only on logical last fragment).
          if (logicalLastFrag && bR > 0) {
            final double w1 = (bR / 2.0).floorToDouble().clamp(0.0, bR);
            final double w2 = bR - w1;
            if (w1 > 0) {
              p.color = isGrooveRight ? rightLight : rightDark; // outer band (right-most)
              canvas.drawRect(Rect.fromLTWH(rect.right - w1, rect.top, w1, rect.height), p);
            }
            if (w2 > 0) {
              p.color = isGrooveRight ? rightDark : rightLight; // inner band
              canvas.drawRect(Rect.fromLTWH(rect.right - w1 - w2, rect.top, w2, rect.height), p);
            }
          }
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
    if (mergedIndex != null && mergedIndex < _placeholderBoxes.length) {
      final anchor = _placeholderBoxes[mergedIndex];
      final double leftEdge = anchor.left;
      final double rightEdge = anchor.left + (mergedWidth ?? (anchor.right - anchor.left));
      final double top = anchor.top;
      final double bottom = anchor.bottom;
      return [ui.TextBox.fromLTRBD(leftEdge, top, rightEdge, bottom, TextDirection.ltr)];
    }
    // Fallback to separate left/right extras if present
    if (leftIndex == null || rightIndex == null) return const [];
    if (leftIndex >= _placeholderBoxes.length || rightIndex >= _placeholderBoxes.length) return const [];
    final left = _placeholderBoxes[leftIndex];
    final right = _placeholderBoxes[rightIndex];
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
      case VerticalAlign.textTop:
      case VerticalAlign.top:
        return ui.PlaceholderAlignment.top;
      case VerticalAlign.textBottom:
      case VerticalAlign.bottom:
        return ui.PlaceholderAlignment.bottom;
      case VerticalAlign.middle:
        return ui.PlaceholderAlignment.middle;
    }
  }

  // Convert CSSRenderStyle to dart:ui TextStyle for ParagraphBuilder
  ui.TextStyle _uiTextStyleFromCss(CSSRenderStyle rs) {
    final cached = _cachedUiTextStyles[rs];
    if (cached != null) return cached;
    final families = rs.fontFamily;
    final FontWeight weight = (rs.boldText && rs.fontWeight.index < FontWeight.w700.index) ? FontWeight.w700 : rs.fontWeight;
    if (families != null && families.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(families[0], weight, rs);
    }
    // Map CSS line-height to a multiplier for dart:ui. For 'normal', align with CSS by
    // using 1.2× font-size instead of letting Flutter pick a font-driven band.
    final double baseFontSize = rs.fontSize.computedValue;
    final double safeBaseFontSize = baseFontSize.isFinite && baseFontSize >= 0 ? baseFontSize : 0.0;

    final double? heightMultiple = (() {
      if (rs.lineHeight.type == CSSLengthType.NORMAL) {
        return kTextHeightNone; // CSS 'normal' approximation
      }
      if (rs.lineHeight.type == CSSLengthType.EM) {
        return rs.lineHeight.value;
      }
      if (safeBaseFontSize <= 0) return null;
      return rs.lineHeight.computedValue / baseFontSize;
    })();
    final double scaledFontSize = rs.textScaler.scale(safeBaseFontSize);
    final double scaleFactor = safeBaseFontSize > 0 ? (scaledFontSize / safeBaseFontSize) : 1.0;

    final bool clipText = (container as RenderBoxModel).renderStyle.backgroundClip == CSSBackgroundBoundary.text;
    // visibility:hidden should not paint text or its text decorations, but must still
    // participate in layout. Achieve this by using a fully transparent text color and
    // disabling text decorations for the hidden run. Background/border for inline boxes
    // are handled separately and are also suppressed in their painter.
    final bool hidden = rs.isVisibilityHidden;
    final Color baseColor = hidden ? const Color(0x00000000) : rs.color.value;
    final Color effectiveColor = clipText ? baseColor.withAlpha(hidden ? 0x00 : 0xFF) : baseColor;
    final (TextDecoration effLine, TextDecorationStyle? effStyle, Color? effColor) =
        _computeEffectiveTextDecoration(rs);
    final variant = CSSText.resolveFontFeaturesForVariant(rs);
    final List<ui.FontFeature>? fontFeatures = variant.features.isNotEmpty ? variant.features : null;
    final result = ui.TextStyle(
      // For clip-text, force fully-opaque glyphs for the mask (ignore alpha).
      color: effectiveColor,
      // Suppress decorations in clip-text mask paragraph; they are painted separately.
      decoration: (hidden || clipText) ? TextDecoration.none : effLine,
      decorationColor: (hidden || clipText) ? const Color(0x00000000) : effColor,
      decorationStyle: clipText ? null : effStyle,
      fontWeight: weight,
      fontStyle: rs.fontStyle,
      textBaseline: CSSText.getTextBaseLine(),
      fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
      fontFamilyFallback: families,
      fontSize: scaledFontSize,
      fontFeatures: fontFeatures,
      letterSpacing: rs.letterSpacing?.computedValue != null ? rs.letterSpacing!.computedValue * scaleFactor : null,
      wordSpacing: rs.wordSpacing?.computedValue != null ? rs.wordSpacing!.computedValue * scaleFactor : null,
      height: heightMultiple,
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
      // Do not include text-shadow on the mask paragraph for clip-text.
      shadows: clipText ? null : rs.textShadow,
      // fontFeatures/fontVariations could be mapped from CSS if available
    );
    _cachedUiTextStyles[rs] = result;
    return result;
  }

  static const double _syntheticSmallCapsScale = 0.8;

  bool _isLowerAsciiLetter(int cu) => cu >= 0x61 && cu <= 0x7A;

  void _addTextWithFontVariant(ui.ParagraphBuilder pb, String text, CSSRenderStyle rs, double baseFontSize) {
    final FontVariantCapsSynthesis synth = CSSText.resolveFontFeaturesForVariant(rs).synth;
    if (synth == FontVariantCapsSynthesis.none) {
      pb.addText(text);
      return;
    }

    final double safeBaseFontSize = baseFontSize.isFinite && baseFontSize >= 0 ? baseFontSize : 0.0;
    final double scaledBaseFontSize = rs.textScaler.scale(safeBaseFontSize);
    if (!scaledBaseFontSize.isFinite || scaledBaseFontSize <= 0) {
      pb.addText(text);
      return;
    }

    final double smallCapsSize = scaledBaseFontSize * _syntheticSmallCapsScale;
    if (synth == FontVariantCapsSynthesis.allLetters) {
      pb.pushStyle(ui.TextStyle(fontSize: smallCapsSize));
      pb.addText(text.toUpperCase());
      pb.pop();
      return;
    }

    int runStart = 0;
    bool inLower = false;
    for (int i = 0; i < text.length; i++) {
      final bool isLower = _isLowerAsciiLetter(text.codeUnitAt(i));
      if (i == 0) {
        inLower = isLower;
        continue;
      }
      if (isLower != inLower) {
        final String seg = text.substring(runStart, i);
        if (inLower) {
          pb.pushStyle(ui.TextStyle(fontSize: smallCapsSize));
          pb.addText(seg.toUpperCase());
          pb.pop();
        } else {
          pb.addText(seg);
        }
        runStart = i;
        inLower = isLower;
      }
    }
    final String tail = text.substring(runStart);
    if (inLower) {
      pb.pushStyle(ui.TextStyle(fontSize: smallCapsSize));
      pb.addText(tail.toUpperCase());
      pb.pop();
    } else {
      pb.addText(tail);
    }
  }

  void dispose() {
    _resetBuildAndLayoutParagraphCaches();
    _items.clear();
    _placeholderBoxes = const [];
    _placeholderOrder.clear();
    _allPlaceholders.clear();
    _elementRanges.clear();
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
    if (renderBox == null) {
      return 'unknown';
    }

    final element = renderBox.renderStyle.target;
    final String tagName = element.tagName;
    final String tagLower = tagName.toLowerCase();

    final id = element.id;
    final className = element.className;
    if (id != null && id.isNotEmpty) {
      return '$tagLower#$id';
    }
    if (className.isNotEmpty) {
      return '$tagLower.$className';
    }

    if (tagName.isNotEmpty) {
      return tagLower;
    }

    final typeStr = renderBox.runtimeType.toString();
    if (typeStr.startsWith('Render')) {
      return typeStr.substring(6);
    }
    return typeStr;
  }

  /// Add debugging information for the inline formatting context.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<RenderLayoutBox>('container', container));
    properties.add(IntProperty('items', _items.length));
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

    // Add paragraph line information (legacy line boxes removed)
    if (_paraLines.isNotEmpty) {
      final lines = <String>[];
      double totalHeight = 0;
      for (int i = 0; i < _paraLines.length && i < 5; i++) {
        final lm = _paraLines[i];
        totalHeight += lm.height;
        lines.add('Line ${i + 1}: w=${lm.width.toStringAsFixed(1)}, h=${lm.height.toStringAsFixed(1)}, '
            'baseline=${lm.baseline.toStringAsFixed(1)}');
      }
      if (_paraLines.length > 5) {
        lines.add('... ${_paraLines.length - 5} more lines');
      }
      properties.add(
          DiagnosticsProperty<List<String>>('paragraphLines', lines, style: DiagnosticsTreeStyle.truncateChildren));
      final layoutMetrics = <String, String>{
        'totalLines': _paraLines.length.toString(),
        'totalHeight': totalHeight.toStringAsFixed(1),
        'avgLineHeight': (_paraLines.isEmpty ? 0 : totalHeight / _paraLines.length).toStringAsFixed(1),
      };
      properties.add(
          DiagnosticsProperty<Map<String, String>>('layoutMetrics', layoutMetrics, style: DiagnosticsTreeStyle.sparse));
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
    if (_items.isNotEmpty && _paraLines.isNotEmpty) {
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
