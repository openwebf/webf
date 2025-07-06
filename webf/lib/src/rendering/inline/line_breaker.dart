import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';
import 'inline_formatting_context.dart';

/// Breaks inline items into lines.
/// Based on Blink's LineBreaker.
class LineBreaker {
  LineBreaker({
    required this.items,
    required this.textContent,
    required this.availableWidth,
  });

  /// Inline items to break.
  final List<InlineItem> items;

  /// Text content string.
  final String textContent;

  /// Available width for lines.
  final double availableWidth;

  /// Current position in items.
  int _itemIndex = 0;

  /// Current position within current item.
  int _textOffset = 0;

  /// Current line width.
  double _currentWidth = 0;

  /// Items in current line.
  final List<InlineItemResult> _currentLine = [];

  /// All lines.
  final List<List<InlineItemResult>> _lines = [];

  /// Break items into lines.
  List<List<InlineItemResult>> breakLines() {
    _lines.clear();
    _currentLine.clear();
    _itemIndex = 0;
    _textOffset = 0;
    _currentWidth = 0;

    while (_itemIndex < items.length) {
      final item = items[_itemIndex];
      
      if (item.isOpenTag || item.isCloseTag) {
        // Tags don't affect line breaking but need to be included
        _addToCurrentLine(InlineItemResult(
          item: item,
          inlineSize: 0,
          startOffset: item.startOffset,
          endOffset: item.endOffset,
        ));
        _itemIndex++;
      } else if (item.isText) {
        _breakTextItem(item);
      } else if (item.isAtomicInline) {
        _breakAtomicItem(item);
      } else if (item.isFloat) {
        // TODO: Handle floats
        _itemIndex++;
      } else {
        _itemIndex++;
      }
    }

    // Add remaining line
    if (_currentLine.isNotEmpty) {
      _commitLine();
    }

    return _lines;
  }

  /// Break a text item.
  void _breakTextItem(InlineItem item) {
    final text = item.getText(textContent);
    final style = item.style;
    
    if (style == null || text.isEmpty) {
      _itemIndex++;
      return;
    }

    // Start offset within the item
    int startOffset = _textOffset > 0 ? _textOffset : 0;
    
    // Create text painter for measurement
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: _createTextStyle(style),
      ),
      textDirection: TextDirection.ltr,
    );

    while (startOffset < text.length) {
      // Find break opportunity
      var breakPoint = _findBreakPoint(
        text, 
        startOffset, 
        style, 
        textPainter,
      );

      if (breakPoint <= startOffset) {
        // Can't fit any text, force break
        if (_currentLine.isNotEmpty) {
          _commitLine();
          continue;
        } else {
          // Force at least one character
          breakPoint = startOffset + 1;
        }
      }

      // Measure text segment
      final segment = text.substring(startOffset, breakPoint);
      final segmentPainter = TextPainter(
        text: TextSpan(
          text: segment,
          style: _createTextStyle(style),
        ),
        textDirection: TextDirection.ltr,
      );
      segmentPainter.layout();

      // Create item result
      final itemResult = InlineItemResult(
        item: item,
        inlineSize: segmentPainter.width,
        startOffset: item.startOffset + startOffset,
        endOffset: item.startOffset + breakPoint,
      );

      // Store shape result
      itemResult.shapeResult = ShapeResult(
        width: segmentPainter.width,
        height: segmentPainter.height,
        ascent: segmentPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        descent: segmentPainter.height - segmentPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        glyphData: segmentPainter,
      );

      _addToCurrentLine(itemResult);

      if (breakPoint < text.length) {
        // Need to break line
        _commitLine();
      }

      startOffset = breakPoint;
    }

    // Move to next item
    _itemIndex++;
    _textOffset = 0;
  }

  /// Break an atomic inline item.
  void _breakAtomicItem(InlineItem item) {
    if (item.renderBox == null) {
      _itemIndex++;
      return;
    }

    final width = item.renderBox!.size.width;
    
    // Check if it fits
    if (_currentWidth + width > availableWidth && _currentLine.isNotEmpty) {
      _commitLine();
    }

    final itemResult = InlineItemResult(
      item: item,
      inlineSize: width,
      startOffset: item.startOffset,
      endOffset: item.endOffset,
    );

    _addToCurrentLine(itemResult);
    _itemIndex++;
  }

  /// Find break point in text.
  int _findBreakPoint(
    String text, 
    int startOffset, 
    CSSRenderStyle style,
    TextPainter painter,
  ) {
    // Handle white-space property
    if (style.whiteSpace == WhiteSpace.nowrap) {
      // No breaking within this text
      return text.length;
    }

    // Binary search for break point
    int low = startOffset;
    int high = text.length;
    int lastGood = startOffset;

    while (low < high) {
      final mid = (low + high) ~/ 2;
      
      // Measure text up to mid point
      final segment = text.substring(startOffset, mid);
      final segmentPainter = TextPainter(
        text: TextSpan(
          text: segment,
          style: painter.text?.style,
        ),
        textDirection: TextDirection.ltr,
      );
      segmentPainter.layout();

      if (_currentWidth + segmentPainter.width <= availableWidth) {
        lastGood = mid;
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    // Find actual break opportunity
    if (lastGood > startOffset) {
      // Look for word boundary
      final breakPoint = _findWordBoundary(text, startOffset, lastGood);
      if (breakPoint > startOffset) {
        return breakPoint;
      }
    }

    return lastGood;
  }

  /// Find word boundary for breaking.
  int _findWordBoundary(String text, int start, int end) {
    // Simple word breaking: look for space
    for (int i = end; i > start; i--) {
      if (text[i - 1] == ' ') {
        return i;
      }
    }
    
    // No space found, break at character boundary
    return end;
  }

  /// Add item result to current line.
  void _addToCurrentLine(InlineItemResult itemResult) {
    _currentLine.add(itemResult);
    _currentWidth += itemResult.inlineSize;
  }

  /// Commit current line.
  void _commitLine() {
    if (_currentLine.isNotEmpty) {
      _lines.add(List.from(_currentLine));
      _currentLine.clear();
      _currentWidth = 0;
    }
  }

  /// Create TextStyle from CSSRenderStyle.
  TextStyle _createTextStyle(CSSRenderStyle renderStyle) {
    return TextStyle(
      fontSize: renderStyle.fontSize.computedValue,
      fontWeight: renderStyle.fontWeight,
      fontFamily: renderStyle.fontFamily?.isNotEmpty == true ? renderStyle.fontFamily![0] : null,
      fontFamilyFallback: renderStyle.fontFamily,
      letterSpacing: renderStyle.letterSpacing?.computedValue,
      wordSpacing: renderStyle.wordSpacing?.computedValue,
    );
  }
}