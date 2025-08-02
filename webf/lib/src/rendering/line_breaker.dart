import 'package:flutter/painting.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';


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
      // Process item

      if (item.isOpenTag || item.isCloseTag) {
        // For inline elements with padding and margins, we need to account for their width
        double inlineSize = 0;
        if (item.shouldCreateBoxFragment && item.style != null) {
          if (item.isOpenTag) {
            // Add left padding and margin width
            inlineSize = item.style!.paddingLeft.computedValue +
                        item.style!.marginLeft.computedValue;
          } else if (item.isCloseTag) {
            // Add right padding and margin width
            inlineSize = item.style!.paddingRight.computedValue +
                        item.style!.marginRight.computedValue;
          }
        }

        // Check if adding padding/margin would exceed line width
        if (_currentWidth + inlineSize > availableWidth && _currentLine.isNotEmpty) {
          // Need to break line before this tag
          _commitLine();
        }

        _addToCurrentLine(InlineItemResult(
          item: item,
          inlineSize: inlineSize,
          startOffset: item.startOffset,
          endOffset: item.endOffset,
        ));
        _itemIndex++;
      } else if (item.isText) {
        // Process text item
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
    

    // Break text

    if (style == null || text.isEmpty) {
      _itemIndex++;
      return;
    }

    // Start offset within the item
    int startOffset = _textOffset > 0 ? _textOffset : 0;

    // Create text painter for measurement using unified text rendering from CSSTextMixin
    final textSpan = CSSTextMixin.createTextSpan(text, style);
    final textPainter = TextPainter(
      text: textSpan,
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
        // Can't fit any text from this item
        if (_currentLine.isNotEmpty) {
          // Check if we should break before this entire text item
          // This happens when we're at the start of a word that doesn't fit
          if (startOffset == 0) {
            // We're at the beginning of this text item
            // Try measuring if the entire first word would fit on a new line
            final firstWordEnd = _findFirstWordEnd(text, 0);
            final firstWord = text.substring(0, firstWordEnd);
            final firstWordPainter = TextPainter(
              text: TextSpan(text: firstWord, style: textPainter.text?.style),
              textDirection: TextDirection.ltr,
            );
            firstWordPainter.layout();

            // If the first word would fit on a new line, break before this item
            if (firstWordPainter.width <= availableWidth) {
              _commitLine();
              continue;
            }
          }
          // Otherwise just break the line and try again
          _commitLine();
          continue;
        } else {
          // Force at least one character
          breakPoint = startOffset + 1;
        }
      }

      // Measure text segment
      final segment = text.substring(startOffset, breakPoint);
      // Create segment

      // Create text painter for the segment
      final segmentTextSpan = CSSTextMixin.createTextSpan(segment, style);
      final segmentPainter = TextPainter(
        text: segmentTextSpan,
        textDirection: TextDirection.ltr,
      );
      segmentPainter.layout();

      // Use full width for measurement - trailing spaces should NOT be excluded
      // when determining if text fits on a line. They are only visually removed
      // at the end of lines but still contribute to line breaking decisions.
      final measureWidth = segmentPainter.width;

      // Measure segment

      // Create item result with the adjusted width
      final itemResult = InlineItemResult(
        item: item,
        inlineSize: measureWidth,
        startOffset: item.startOffset + startOffset,
        endOffset: item.startOffset + breakPoint,
      );

      // Store shape result with the actual segment painter
      // Get the actual baseline
      final baseline = segmentPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      // Use the text painter's height which includes line height
      final height = segmentPainter.height;

      itemResult.shapeResult = ShapeResult(
        width: segmentPainter.width,
        height: height,
        ascent: baseline,
        descent: height - baseline,
        glyphData: segmentPainter,
      );

      _addToCurrentLine(itemResult);

      if (breakPoint < text.length) {
        // We didn't process all the text
        // For pre-wrap, only break if we actually hit the width limit
        if (style.whiteSpace == WhiteSpace.preWrap) {
          // Check if the break was due to width limit or just a word boundary
          // If we can still fit more text, continue on the same line
          if (_currentWidth >= availableWidth * 0.9) { // Allow some tolerance
            _commitLine();
          }
        } else {
          // For other modes, commit the line
          _commitLine();
        }
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

    // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
    final renderBox = item.renderBox!;
    final double width = renderBox is RenderBoxModel ?
        (renderBox.boxSize?.width ?? 0.0) :
        (renderBox.hasSize ? renderBox.size.width : 0.0);

    // Add margins to the width for RenderBoxModel
    double totalWidth = width;
    if (renderBox is RenderBoxModel) {
      totalWidth += renderBox.renderStyle.marginLeft.computedValue +
                    renderBox.renderStyle.marginRight.computedValue;
    }

    if (_currentWidth + totalWidth > availableWidth && _currentLine.isNotEmpty) {
      _commitLine();
    }

    final itemResult = InlineItemResult(
      item: item,
      inlineSize: totalWidth,
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
    // Calculate the actual available width for this text segment
    final remainingWidth = availableWidth - _currentWidth;
    // Handle white-space property
    if (style.whiteSpace == WhiteSpace.nowrap) {
      // No breaking within this text
      return text.length;
    }

    // Check if the entire remaining text fits
    final fullText = text.substring(startOffset);
    final fullTextPainter = TextPainter(
      text: TextSpan(
        text: fullText,
        style: painter.text?.style,
      ),
      textDirection: TextDirection.ltr,
    );
    fullTextPainter.layout();

    if (fullTextPainter.width <= remainingWidth) {
      return text.length;
    }

    // Binary search for break point
    int low = startOffset;
    int high = text.length + 1; // Include one past the end to test full string
    int lastGood = startOffset;

    // Find break point

    while (low < high) {
      final mid = (low + high) ~/ 2;

      // Clamp mid to text.length
      final testEnd = mid > text.length ? text.length : mid;

      // Measure text up to mid point
      final segment = text.substring(startOffset, testEnd);

      final segmentPainter = TextPainter(
        text: TextSpan(
          text: segment,
          style: painter.text?.style,
        ),
        textDirection: TextDirection.ltr,
      );
      segmentPainter.layout();

      if (segmentPainter.width <= remainingWidth) {
        lastGood = testEnd;
        low = mid + 1;
        // Segment fits
      } else {
        high = mid;
        // Segment does not fit
      }
    }

    // Find actual break opportunity
    if (lastGood > startOffset && lastGood < text.length) {
      // Only look for word boundary if we're actually breaking the line
      // Binary search found break point
      
      // For pre-wrap, check if we actually need to break
      // If lastGood equals text.length, we can fit the entire remaining text
      if (style.whiteSpace == WhiteSpace.preWrap && lastGood == text.length) {
        return lastGood;
      }
      
      final breakPoint = _findWordBoundary(text, startOffset, lastGood, style.whiteSpace);
      if (breakPoint > startOffset) {
        return breakPoint;
      } else if (breakPoint == startOffset) {
        // We can't break in this segment
        if (startOffset == 0) {
          // This is the beginning of the text item
          // If we're not at the start of a line, break before this item
          if (_currentWidth > 0) {
            return 0;
          }
          // Otherwise, we must include at least some text
          // Return lastGood to force break in the middle of the word
          return lastGood;
        } else {
          // We're in the middle of the text item
          // Return startOffset to indicate no progress
          return startOffset;
        }
      }
    }

    return lastGood;
  }

  /// Find word boundary for breaking.
  int _findWordBoundary(String text, int start, int end, [WhiteSpace? whiteSpace]) {
    // For break-spaces and pre-wrap modes, we can break at space characters
    if (whiteSpace == WhiteSpace.breakSpaces || whiteSpace == WhiteSpace.preWrap) {
      // Look backwards from end to find the last space that fits
      // We want to break after a space, not in the middle of a word
      
      // Check if we're at the end of the text
      if (end >= text.length) {
        return end;
      }
      
      // Check if the position is already at a space
      if (text[end - 1] == ' ') {
        return end;
      }
      
      // We're in the middle of a word, look for the last space before this position
      for (int i = end - 1; i > start; i--) {
        if (text[i - 1] == ' ') {
          // Found space, break after it
          return i;
        }
      }
      
      // No space found in this segment
      // This means the entire segment is one word that doesn't fit
      // Return start to indicate we should break before this segment
      return start;
    }

    // Check if we're dealing with CJK text
    // For CJK text, we can break at any character boundary
    bool hasCJK = false;
    for (int i = start; i < end; i++) {
      if (_isCJKCharacter(text.codeUnitAt(i))) {
        hasCJK = true;
        break;
      }
    }

    if (hasCJK) {
      // For CJK text, we can break at any character boundary
      // But prefer breaking before or after CJK characters rather than in the middle of English words

      // First, check if we're at a CJK/non-CJK boundary
      if (end < text.length) {
        final charBefore = text.codeUnitAt(end - 1);
        final charAfter = text.codeUnitAt(end);
        final isBeforeCJK = _isCJKCharacter(charBefore);
        final isAfterCJK = _isCJKCharacter(charAfter);

        // If we're at a script boundary, this is a good break point
        if (isBeforeCJK != isAfterCJK) {
          return end;
        }
      }

      // Look backwards for a good break point
      for (int i = end; i > start; i--) {
        // Check for space (always a good break point)
        if (text[i - 1] == ' ') {
          return i;
        }

        // Check for CJK/non-CJK boundary
        if (i > 1 && i < text.length) {
          final charBefore = text.codeUnitAt(i - 1);
          final charAfter = text.codeUnitAt(i);
          final isBeforeCJK = _isCJKCharacter(charBefore);
          final isAfterCJK = _isCJKCharacter(charAfter);

          // Break at script boundaries
          if (isBeforeCJK != isAfterCJK) {
            return i;
          }

          // For consecutive CJK characters, we can break anywhere
          if (isBeforeCJK && isAfterCJK) {
            return i;
          }
        }
      }

      // If no better break point found, break at the end
      return end;
    } else {
      // For non-CJK text, look for space
      // But we need to find the last space that would leave a meaningful word on the line
      int lastSpace = -1;
      for (int i = end; i > start; i--) {
        if (text[i - 1] == ' ') {
          // Check if breaking here would leave only spaces on the current line
          bool onlySpaces = true;
          for (int j = start; j < i - 1; j++) {
            if (text[j] != ' ') {
              onlySpaces = false;
              break;
            }
          }

          if (!onlySpaces) {
            lastSpace = i;
            break;
          }
        }
      }

      if (lastSpace > start) {
        return lastSpace;
      }

      // No space found - check if we're in the middle of a word
      // If we are, we should not break here
      if (end < text.length && text[end - 1] != ' ' && text[end] != ' ') {
        // We're in the middle of a word, return start to indicate no break
        return start;
      }

      // Otherwise break at character boundary
      return end;
    }
  }

  /// Find the end of the first word in text
  int _findFirstWordEnd(String text, int start) {
    for (int i = start; i < text.length; i++) {
      if (text[i] == ' ') {
        return i;
      }
    }
    return text.length;
  }

  /// Check if a character is CJK (Chinese, Japanese, Korean)
  bool _isCJKCharacter(int codePoint) {
    return (codePoint >= 0x4E00 && codePoint <= 0x9FFF) || // CJK Unified Ideographs
           (codePoint >= 0x3400 && codePoint <= 0x4DBF) || // CJK Extension A
           (codePoint >= 0x3040 && codePoint <= 0x309F) || // Hiragana
           (codePoint >= 0x30A0 && codePoint <= 0x30FF) || // Katakana
           (codePoint >= 0xAC00 && codePoint <= 0xD7AF) || // Hangul Syllables
           (codePoint >= 0x1100 && codePoint <= 0x11FF) || // Hangul Jamo
           (codePoint >= 0x3130 && codePoint <= 0x318F) || // Hangul Compatibility Jamo
           (codePoint >= 0xA960 && codePoint <= 0xA97F) || // Hangul Jamo Extended-A
           (codePoint >= 0xD7B0 && codePoint <= 0xD7FF);   // Hangul Jamo Extended-B
  }

  /// Add item result to current line.
  void _addToCurrentLine(InlineItemResult itemResult) {
    _currentLine.add(itemResult);
    _currentWidth += itemResult.inlineSize;
    // Item added
  }

  /// Commit current line.
  void _commitLine() {
    if (_currentLine.isNotEmpty) {
      _lines.add(List.from(_currentLine));
      _currentLine.clear();
      _currentWidth = 0;
    }
  }

}
