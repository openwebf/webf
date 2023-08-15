/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/text_span.dart';
// White space processing in CSS affects only the document white space characters:
// spaces (U+0020), tabs (U+0009), and segment breaks.
// Carriage returns (U+000D) are treated identically to spaces (U+0020) in all respects.
// https://drafts.csswg.org/css-text/#white-space-rules
final String _documentWhiteSpace = '\u0020\u0009\u000A\u000D';
final RegExp _collapseWhiteSpaceReg = RegExp(r'[' + _documentWhiteSpace + r']+');
final RegExp _trimLeftWhitespaceReg = RegExp(r'^[' + _documentWhiteSpace + r']([^' + _documentWhiteSpace + r']+)');
final RegExp _trimRightWhitespaceReg = RegExp(r'([^' + _documentWhiteSpace + r']+)[' + _documentWhiteSpace + r']$');
final webfTextMaxLines = double.maxFinite.toInt();
Size _miniCharSize = Size.zero;
class TextParentData extends ContainerBoxParentData<RenderBox> {}

enum WhiteSpace { normal, nowrap, pre, preWrap, preLine, breakSpaces }

class RenderTextBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderTextBox(
    data, {
    required this.renderStyle,
  }) : _data = data {
    TextSpan text = CSSTextMixin.createTextSpan(_data, renderStyle);
    _renderParagraph = child = WebFRenderParagraph(
      text,
      textDirection: TextDirection.ltr,
      foregroundCallback: _getForeground,
    );
  }
  RenderTextLineBoxes textInLineBoxes = RenderTextLineBoxes();
  double _lastFirstLineIndent = 0;

  String _data;

  set data(String value) {
    _data = value;
  }

  String get data => _data;

  bool isEndWithSpace(String str) {
    return str.endsWith(WHITE_SPACE_CHAR) ||
        str.endsWith(NEW_LINE_CHAR) ||
        str.endsWith(RETURN_CHAR) ||
        str.endsWith(TAB_CHAR);
  }

  String get _trimmedData {
    if (parentData is RenderLayoutParentData) {
      /// https://drafts.csswg.org/css-text-3/#propdef-white-space
      /// The following table summarizes the behavior of the various white-space values:
      //
      //       New lines / Spaces and tabs / Text wrapping / End-of-line spaces
      // normal    Collapse  Collapse  Wrap     Remove
      // nowrap    Collapse  Collapse  No wrap  Remove
      // pre       Preserve  Preserve  No wrap  Preserve
      // pre-wrap  Preserve  Preserve  Wrap     Hang
      // pre-line  Preserve  Collapse  Wrap     Remove
      // break-spaces  Preserve  Preserve  Wrap  Wrap
      CSSRenderStyle parentRenderStyle = (parent as RenderBoxModel).renderStyle;
      WhiteSpace whiteSpace = parentRenderStyle.whiteSpace;
      if (whiteSpace == WhiteSpace.pre ||
          whiteSpace == WhiteSpace.preLine ||
          whiteSpace == WhiteSpace.preWrap ||
          whiteSpace == WhiteSpace.breakSpaces) {
        return whiteSpace == WhiteSpace.preLine ? _collapseWhitespace(_data) : _data;
      } else {
        String collapsedData = _collapseWhitespace(_data);
        // TODO:
        // Remove the leading space while prev element have space too:
        //   <p><span>foo </span> bar</p>
        // Refs:
        //   https://github.com/WebKit/WebKit/blob/6a970b217d59f36e64606ed03f5238d572c23c48/Source/WebCore/layout/inlineformatting/InlineLineBuilder.cpp#L295
        RenderObject? previousSibling = (parentData as RenderLayoutParentData).previousSibling;

        if (previousSibling == null) {
          collapsedData = _trimLeftWhitespace(collapsedData);
        } else if (previousSibling is RenderBoxModel &&
            (previousSibling.renderStyle.display == CSSDisplay.block ||
                previousSibling.renderStyle.display == CSSDisplay.flex)) {
          // If previousSibling is block,should trimLeft slef.
          CSSDisplay? display = previousSibling.renderStyle.display;
          if (display == CSSDisplay.block || display == CSSDisplay.sliver || display == CSSDisplay.flex) {
            collapsedData = _trimLeftWhitespace(collapsedData);
          }
        } else if (previousSibling is RenderTextBox && isEndWithSpace(previousSibling.data)) {
          collapsedData = _trimLeftWhitespace(collapsedData);
        }

        RenderObject? nextSibling = (parentData as RenderLayoutParentData).nextSibling;
        if (nextSibling == null || !mayHappenLineJoin()) {
          collapsedData = _trimRightWhitespace(collapsedData);
        } else if (nextSibling is RenderBoxModel &&
            (nextSibling.renderStyle.display == CSSDisplay.block ||
                nextSibling.renderStyle.display == CSSDisplay.flex)) {
          // If nextSibling is block,should trimRight slef.
          CSSDisplay? display = nextSibling.renderStyle.display;
          if (display == CSSDisplay.block || display == CSSDisplay.sliver || display == CSSDisplay.flex) {
            collapsedData = _trimRightWhitespace(collapsedData);
          }
        }

        return collapsedData;
      }
    }

    return _data;
  }

  late WebFRenderParagraph _renderParagraph;
  CSSRenderStyle renderStyle;

  BoxSizeType? widthSizeType;
  BoxSizeType? heightSizeType;

  // Nominally, the smallest size a box could take that doesn’t lead to overflow that could be avoided by choosing
  // a larger size. Formally, the size of the box when sized under a min-content constraint.
  // https://www.w3.org/TR/css-sizing-3/#min-content
  double minContentWidth = 0;
  double minContentHeight = 0;

  double get firstLineIndent {
    if (constraints is InlineBoxConstraints) {
      return (constraints as InlineBoxConstraints).leftWidth;
    }
    return 0;
  }

  LogicTextInlineBox get firstTextInlineBox => textInLineBoxes.firstChild;

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData) {
      child.parentData = TextParentData();
    }
  }

  int? get _maxLines {
    int? maxParentLineLimit;
    int? lineClamp = renderStyle.lineClamp;
    if(constraints is MultiLineBoxConstraints) {
      maxParentLineLimit = (constraints as MultiLineBoxConstraints).maxLines;
    }

    // Forcing a break after a set number of lines.
    // https://drafts.csswg.org/css-overflow-3/#max-lines
    if (lineClamp != null || maxParentLineLimit != null) {
      int? realLineLimit = lineClamp ?? maxParentLineLimit;

      realLineLimit = (maxParentLineLimit!=null && realLineLimit!=null) ?
      min(realLineLimit, maxParentLineLimit) : realLineLimit;

      if(constraints is InlineBoxConstraints
          && (constraints as InlineBoxConstraints).isDynamicMaxLines && realLineLimit! < webfTextMaxLines) {
        realLineLimit = realLineLimit + 1;
      }
      return realLineLimit;
    }
    // Force display single line when white-space is nowrap.
    if (renderStyle.whiteSpace == WhiteSpace.nowrap) {
      return 1;
    }
    return null;
  }

  double? get _lineHeight {
    if (renderStyle.lineHeight.type != CSSLengthType.NORMAL) {
      return renderStyle.lineHeight.computedValue;
    }
    return null;
  }

  TextSpan buildTextSpan({TextSpan? oldText}) {
    String clippedText = _getClippedText(_trimmedData);
    WebFTextSpan textSpan = CSSTextMixin.createTextSpan(clippedText, renderStyle, oldTextSpan: oldText) as WebFTextSpan;
    return textSpan;
  }

  int get lines => _renderParagraph.lineMetrics.length;

  // RenderTextBox content's first line will join a LogicLineBox which have some InlineBoxes as children,
  bool happenLineJoin() {
    if (firstLineIndent > 0 &&
        (textInLineBoxes.firstChild.logicRect.left >= firstLineIndent ||
            lines == 1 && textInLineBoxes.firstChild.width < constraints.maxWidth - firstLineIndent)) {
      return true;
    }
    return false;
  }

  List<double>? getLineAscent(int lineNum) {
    LineMetrics lineMetrics = _renderParagraph.getLineMetricsByLineNum(lineNum);
    double lineHeight = _lineHeight ?? 0;
    double leading = 0;
    if (lineHeight > 0) {
      leading = lineHeight - lineMetrics.height;
    }
    return [lineMetrics.ascent + leading / 2, lineMetrics.descent + leading / 2];
  }

  bool mayHappenLineJoin() {
    RenderObject? nextSibling = (parentData as RenderLayoutParentData).nextSibling;

    RenderObject? parentNextSibling = null;
    if (parent != null && parent is RenderBox) {
      ParentData? parentData = (parent as RenderBox).parentData;
      if (parentData != null && parentData is RenderLayoutParentData) {
        parentNextSibling = parentData.nextSibling;
      }
    }

    return nextSibling != null || parentNextSibling != null;
  }

  TextSpan get textSpan {
    String clippedText = _getClippedText(_trimmedData);
    // FIXME(yuanyan): do not create text span every time.
    return CSSTextMixin.createTextSpan(clippedText, renderStyle);
  }

  Paint? _getForeground(Rect bounds) {
    CSSBackgroundImage? backgroundImage = renderStyle.backgroundImage;
    if (backgroundImage?.gradient != null && renderStyle.backgroundClip == CSSBackgroundBoundary.text) {
      return Paint()..shader = backgroundImage?.gradient?.createShader(bounds);
    }
    return null;
  }

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    needsLayout = true;
  }

  void markRenderParagraphNeedsLayout() {
    _renderParagraph.markNeedsLayout();
  }

  // @HACK: sync _needsLayout flag in Flutter to do performance opt.
  void syncNeedsLayoutFlag() {
    needsLayout = true;
  }

  BoxConstraints getConstraints(int maxLinesFromParent) {
    if (renderStyle.whiteSpace == WhiteSpace.nowrap && renderStyle.effectiveTextOverflow != TextOverflow.ellipsis) {
      return InlineBoxConstraints(maxLines: maxLinesFromParent);
    }

    double maxConstraintWidth = double.infinity;
    if (parent is RenderBoxModel) {
      RenderBoxModel parentRenderBoxModel = parent as RenderBoxModel;
      BoxConstraints parentConstraints = parentRenderBoxModel.constraints;

      if (parentRenderBoxModel.isScrollingContentBox && parentRenderBoxModel is! RenderFlexLayout) {
        maxConstraintWidth = (parentRenderBoxModel.parent as RenderBoxModel).constraints.maxWidth;
      } else if (parentConstraints.maxWidth == double.infinity) {
        final ParentData? parentParentData = parentRenderBoxModel.parentData;
        // Width of positioned element does not constrained by parent.
        if (parentParentData is RenderLayoutParentData && parentParentData.isPositioned) {
          maxConstraintWidth = double.infinity;
        } else {
          maxConstraintWidth = parentRenderBoxModel.renderStyle.contentMaxConstraintsWidth;
          // @FIXME: Each character in the text will be placed in a new line when remaining space of
          // parent is 0 cause word-break behavior can not be specified in flutter.
          // https://github.com/flutter/flutter/issues/61081
          // This behavior is not desirable compared to the default word-break:break-word value in the browser.
          // So we choose to not do wrapping for text in this case.
          if (maxConstraintWidth == 0) {
            maxConstraintWidth = double.infinity;
          }
        }
      } else {
        EdgeInsets borderEdge = parentRenderBoxModel.renderStyle.border;
        EdgeInsetsGeometry? padding = parentRenderBoxModel.renderStyle.padding;
        double horizontalBorderLength = borderEdge.horizontal;
        double horizontalPaddingLength = padding.horizontal;

        maxConstraintWidth = parentConstraints.maxWidth - horizontalPaddingLength - horizontalBorderLength;
      }
    }

    // Text will not overflow from container, so it can inherit
    // constraints from parents
    return InlineBoxConstraints(maxLines: maxLinesFromParent,
        minWidth: 0, maxWidth: maxConstraintWidth,
        minHeight: 0, maxHeight: double.infinity);
  }

  // Empty string is the minimum size character, use it as the base size
  // for calculating the maximum characters to display in its container.
  Size get minCharSize {
    if (_miniCharSize == Size.zero) {
      TextStyle textStyle = TextStyle(
        fontFamilyFallback: renderStyle.fontFamily,
        fontSize: renderStyle.fontSize.computedValue,
        textBaseline: CSSText.getTextBaseLine(),
        package: CSSText.getFontPackage(),
        locale: CSSText.getLocale(),
      );
      TextPainter painter = TextPainter(
          text: TextSpan(
            text: ' ',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr);
      painter.layout();
      _miniCharSize = painter.size;
    }
    return _miniCharSize;
  }

  // Avoid to render the whole text when text overflows its parent and text is not
  // displayed fully and parent is not scrollable to improve text layout performance.
  String _getClippedText(String data) {
    // Only clip text in container which meets CSS box model spec.
    if (parent is! RenderBoxModel) {
      return data;
    }

    String clippedText = data;
    RenderBoxModel parentRenderBoxModel = parent as RenderBoxModel;
    BoxConstraints? parentContentConstraints = parentRenderBoxModel.contentConstraints;
    // Text only need to render in parent container's content area when
    // white-space is nowrap and overflow is hidden/clip.
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;

    if (parentContentConstraints != null &&
        (effectiveOverflowX == CSSOverflowType.hidden || effectiveOverflowX == CSSOverflowType.clip)) {
      // Max character to display in one line.
      int? maxCharsOfLine;
      // Max lines in parent.
      int? maxLines;

      if (parentContentConstraints.maxWidth.isFinite) {
        maxCharsOfLine = (parentContentConstraints.maxWidth / minCharSize.width).ceil();
      }
      if (parentContentConstraints.maxHeight.isFinite) {
        maxLines = (parentContentConstraints.maxHeight / (_lineHeight ?? minCharSize.height)).ceil();
      }

      if (renderStyle.whiteSpace == WhiteSpace.nowrap) {
        if (maxCharsOfLine != null) {
          int maxChars = maxCharsOfLine;
          if (data.length > maxChars) {
            clippedText = data.substring(0, maxChars);
          }
        }
      } else {
        if (maxCharsOfLine != null && maxLines != null) {
          int maxChars = maxCharsOfLine * maxLines;
          if (data.length > maxChars) {
            clippedText = data.substring(0, maxChars);
          }
        }
      }
    }
    return clippedText;
  }

  // '  a b  c   \n' => ' a b c '
  static String _collapseWhitespace(String string) {
    return string.replaceAll(_collapseWhiteSpaceReg, WHITE_SPACE_CHAR);
  }

  // '   a b c' => 'a b c'
  static String _trimLeftWhitespace(String string) {
    return string.replaceAllMapped(_trimLeftWhitespaceReg, (Match m) => '${m[1]}');
  }

  // 'a b c    ' => 'a b c'
  static String _trimRightWhitespace(String string) {
    return string.replaceAllMapped(_trimRightWhitespaceReg, (Match m) => '${m[1]}');
  }

  void _updatePlaceHolderDimensions(WebFRenderParagraph paragraph) {
    if (firstLineIndent > 0) {
      double defaultHeight = 1;

      paragraph.setPlaceholderDimensions([
        PlaceholderDimensions(size: Size(firstLineIndent, defaultHeight), alignment: PlaceholderAlignment.bottom)
      ]);
    }
  }

  @override
  void performLayout() {
    WebFRenderParagraph? paragraph = child as WebFRenderParagraph?;
    textInLineBoxes.clear();
    if (paragraph != null) {
      paragraph.overflow = renderStyle.effectiveTextOverflow;
      // paragraph.textAlign = renderStyle.textAlign;

      // first set text is no use, so need check again
      paragraph.text = buildTextSpan(oldText: paragraph.text);

      WebFTextSpan text = (paragraph.text as WebFTextSpan);
      if (firstLineIndent > 0 && firstLineIndent != _lastFirstLineIndent) {
        if (text.children!.isEmpty) {
          WebFTextPlaceHolderSpan placeHolderSpan = WebFTextPlaceHolderSpan();
          text.children!.add(placeHolderSpan);
          text.textSpanPosition.putIfAbsent(placeHolderSpan, () => true);
        }
        _updatePlaceHolderDimensions(paragraph);
      } else if (firstLineIndent == 0 && (firstLineIndent != _lastFirstLineIndent || text.children!.isNotEmpty)) {
        text.children!.clear();
        text.textSpanPosition.clear();
        paragraph.markUpdateTextPainter();
      }
      _lastFirstLineIndent = firstLineIndent;
      paragraph.maxLines = _maxLines;
      paragraph.lineHeight = _lineHeight;
      paragraph.layout(constraints, parentUsesSize: true);
      paragraph.lineRenderList.forEach((element) {
        textInLineBoxes.createAndAppendTextBox(this, element.lineRect);
      });

      size = paragraph.size;

      // @FIXME: Minimum size of text equals to single word in browser
      // which cannot be calculated in Flutter currently.
      // Set minimum width to 0 to allow flex item containing text to shrink into
      // flex container which is similar to the effect of word-break: break-all in the browser.
      minContentWidth = 0;
      minContentWidth = size.height;
    } else {
      performResize();
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  double computeDistanceToBaseline() {
    return parent is RenderFlowLayout
        ? _renderParagraph.computeDistanceToLastLineBaseline()
        : _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToFirstLineBaseline() {
    return _renderParagraph.computeDistanceToFirstLineBaseline();
  }

  double computeDistanceToLastLineBaseline() {
    return _renderParagraph.computeDistanceToLastLineBaseline();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  // Text node need hittest self to trigger scroll
  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return hasSize && size.contains(position!);
  }

  void updateRenderTextLineOffset(int index, Offset offset) {
    if (_renderParagraph.lineRenderList.length > index) {
      _renderParagraph.lineRenderList[index].paintOffset = offset;
    }
  }
}


class RenderTextLineBoxes {
  List<LogicTextInlineBox> inlineBoxList = [];

  LogicTextInlineBox get firstChild => inlineBoxList.first;

  LogicTextInlineBox get lastChild => inlineBoxList.last;

  LogicTextInlineBox createAndAppendTextBox(RenderTextBox renderObject, Rect rect) {
    inlineBoxList.add(LogicTextInlineBox(logicRect: rect, renderObject: renderObject));
    return inlineBoxList.last;
  }

  get length {
    return inlineBoxList.length;
  }

  void clear() {
    inlineBoxList.clear();
  }

  LogicTextInlineBox get(int index) {
    return inlineBoxList[index];
  }

  int findIndex(LogicTextInlineBox box) {
    return inlineBoxList.indexOf(box);
  }

  void updateTextPaintOffset(Offset offset, LogicTextInlineBox box) {
    RenderTextBox renderTextBox = box.renderObject as RenderTextBox;
    int index = findIndex(box);
    renderTextBox.updateRenderTextLineOffset(index, offset);
  }
}

class MultiLineBoxConstraints extends BoxConstraints {
  final int? maxLines;
  final int? joinLineNum;
  final bool? overflow;
  MultiLineBoxConstraints.from(int? maxLines, int? joinLine, bool? overflow, BoxConstraints constraints
      ) : maxLines = maxLines ?? webfTextMaxLines,
        joinLineNum = joinLine ?? 0,
        overflow = overflow ?? false,
        super(minWidth: constraints.minWidth,
          maxWidth: constraints.maxWidth,
          minHeight: constraints.minHeight,
          maxHeight: constraints.maxHeight);

  MultiLineBoxConstraints({
    int? maxLines,
    int? joinLine,
    bool? overflow,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) : maxLines = maxLines ?? webfTextMaxLines, joinLineNum = joinLine ?? 0,
        overflow = overflow ?? false,
        super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

}

class InlineBoxConstraints extends MultiLineBoxConstraints {
  final double leftWidth;
  final double lineMainExtent;

  InlineBoxConstraints({
    this.leftWidth = 0.0,
    this.lineMainExtent = 0.0,
    int? maxLines,
    int? joinLine,
    bool? overflow,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) : super(maxLines: maxLines, overflow: overflow,joinLine: joinLine,minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  bool get isDynamicMaxLines {
    return leftWidth > 0 && joinLineNum != null && joinLineNum! > 0;
  }

  @override
  bool operator ==(Object other) {
    assert(debugAssertIsValid());
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    assert(other is InlineBoxConstraints && other.debugAssertIsValid());
    return other is InlineBoxConstraints &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        other.leftWidth == leftWidth;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(leftWidth, lineMainExtent, minWidth, maxWidth, minHeight, maxHeight);
}
