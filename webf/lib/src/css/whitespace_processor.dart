/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';
import 'package:webf/src/css/east_asian_width.dart';

/// Processes whitespace according to CSS Text Module Level 3 specification.
/// This implementation follows the two-phase processing model defined in the spec.
class WhitespaceProcessor {
  /// Document whitespace characters as defined by CSS spec
  static const int SPACE = 0x0020;
  static const int TAB = 0x0009;
  static const int LINE_FEED = 0x000A;
  static const int CARRIAGE_RETURN = 0x000D;
  
  /// Object replacement character for atomic inlines
  static const int OBJECT_REPLACEMENT_CHAR = 0xFFFC;
  
  /// Check if a character is a space (U+0020)
  static bool isSpace(int codeUnit) => codeUnit == SPACE;
  
  /// Check if a character is a tab (U+0009)
  static bool isTab(int codeUnit) => codeUnit == TAB;
  
  /// Check if a character is a line feed (U+000A)
  static bool isLineFeed(int codeUnit) => codeUnit == LINE_FEED;
  
  /// Check if a character is a carriage return (U+000D)
  static bool isCarriageReturn(int codeUnit) => codeUnit == CARRIAGE_RETURN;
  
  /// Check if a character is a segment break (LF or CR)
  static bool isSegmentBreak(int codeUnit) {
    return codeUnit == LINE_FEED || codeUnit == CARRIAGE_RETURN;
  }
  
  /// Check if a character is document whitespace
  static bool isDocumentWhitespace(int codeUnit) {
    return codeUnit == SPACE || 
           codeUnit == TAB || 
           codeUnit == LINE_FEED || 
           codeUnit == CARRIAGE_RETURN;
  }
  
  /// Check if a character is an other space separator (Unicode Zs except space and no-break space)
  static bool isOtherSpaceSeparator(int codeUnit) {
    // Unicode category Zs characters except U+0020 (space) and U+00A0 (no-break space)
    return codeUnit == 0x1680 || // OGHAM SPACE MARK
           codeUnit == 0x2000 || // EN QUAD
           codeUnit == 0x2001 || // EM QUAD
           codeUnit == 0x2002 || // EN SPACE
           codeUnit == 0x2003 || // EM SPACE
           codeUnit == 0x2004 || // THREE-PER-EM SPACE
           codeUnit == 0x2005 || // FOUR-PER-EM SPACE
           codeUnit == 0x2006 || // SIX-PER-EM SPACE
           codeUnit == 0x2007 || // FIGURE SPACE
           codeUnit == 0x2008 || // PUNCTUATION SPACE
           codeUnit == 0x2009 || // THIN SPACE
           codeUnit == 0x200A || // HAIR SPACE
           codeUnit == 0x202F || // NARROW NO-BREAK SPACE
           codeUnit == 0x205F || // MEDIUM MATHEMATICAL SPACE
           codeUnit == 0x3000;   // IDEOGRAPHIC SPACE
  }
  
  /// Phase I: Collapsing and Transformation
  /// This phase happens before line breaking and bidi reordering
  static String processPhaseOne(String text, WhiteSpace whiteSpace, [String? language]) {
    if (text.isEmpty) return text;
    
    // Process whitespace based on mode
    
    switch (whiteSpace) {
      case WhiteSpace.normal:
      case WhiteSpace.nowrap:
      case WhiteSpace.preLine:
        return _collapseWhitespace(text, whiteSpace, language);
      
      case WhiteSpace.pre:
      case WhiteSpace.preWrap:
      case WhiteSpace.breakSpaces:
        return _preserveWhitespace(text, whiteSpace);
    }
  }
  
  /// Collapse whitespace for normal, nowrap, and pre-line modes
  static String _collapseWhitespace(String text, WhiteSpace whiteSpace, [String? language]) {
    final output = StringBuffer();
    final length = text.length;
    
    // State tracking
    bool previousWasCollapsibleSpace = false;
    bool previousWasSegmentBreak = false;
    int? lastNonWhitespaceChar;
    
    for (int i = 0; i < length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      if (isSegmentBreak(codeUnit)) {
        // Handle segment breaks
        if (whiteSpace == WhiteSpace.preLine) {
          // For pre-line, preserve segment breaks as forced line breaks
          output.writeCharCode(LINE_FEED);
          previousWasSegmentBreak = false;  // Reset for pre-line
          previousWasCollapsibleSpace = false;
        } else {
          // For normal and nowrap, segment breaks are collapsible
          if (previousWasSegmentBreak) {
            // Consecutive segment breaks: remove all but first
            continue;
          }
          previousWasSegmentBreak = true;
          // Don't output yet - will be transformed based on context
        }
      } else if (isSpace(codeUnit) || isTab(codeUnit)) {
        // Handle spaces and tabs
        if (previousWasSegmentBreak && whiteSpace != WhiteSpace.preLine) {
          // Remove spaces/tabs adjacent to segment breaks (except for pre-line)
          continue;
        }
        
        if (!previousWasCollapsibleSpace) {
          // Convert tab to space and output
          output.writeCharCode(SPACE);
          previousWasCollapsibleSpace = true;
        }
        // Else: collapse consecutive spaces
      } else {
        // Regular character
        if (previousWasSegmentBreak) {
          // Look ahead to find the next non-whitespace character for context
          int? nextNonWhitespace;
          for (int j = i; j < length; j++) {
            final nextCode = text.codeUnitAt(j);
            if (!isSpace(nextCode) && !isTab(nextCode) && !isSegmentBreak(nextCode)) {
              nextNonWhitespace = nextCode;
              break;
            }
          }
          
          // Transform segment break based on context
          final transformation = SegmentBreakTransformer.transformSegmentBreak(
            lastNonWhitespaceChar,
            nextNonWhitespace ?? codeUnit,
            language,
          );
          
          if (transformation != null && !previousWasCollapsibleSpace) {
            output.write(transformation);
            previousWasCollapsibleSpace = transformation == ' ';
          }
          
          previousWasSegmentBreak = false;
        }
        
        output.writeCharCode(codeUnit);
        lastNonWhitespaceChar = codeUnit;
        previousWasCollapsibleSpace = false;
      }
    }
    
    // Handle trailing segment break
    if (previousWasSegmentBreak && whiteSpace != WhiteSpace.preLine) {
      // Transform final segment break based on context
      final transformation = SegmentBreakTransformer.transformSegmentBreak(
        lastNonWhitespaceChar,
        null,
        language,
      );
      
      if (transformation != null && !previousWasCollapsibleSpace) {
        output.write(transformation);
      }
    }
    
    return output.toString();
  }
  
  /// Preserve whitespace for pre, pre-wrap, and break-spaces modes
  static String _preserveWhitespace(String text, WhiteSpace whiteSpace) {
    final output = StringBuffer();
    final length = text.length;
    
    for (int i = 0; i < length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      if (isSegmentBreak(codeUnit)) {
        // Preserve segment breaks as line feeds
        output.writeCharCode(LINE_FEED);
      } else if (isTab(codeUnit)) {
        // Preserve tab characters in pre-like modes; visual expansion is handled by layout (tab-size)
        output.writeCharCode(TAB);
      } else if (isSpace(codeUnit) && whiteSpace == WhiteSpace.breakSpaces) {
        // For break-spaces, spaces remain as regular spaces (not non-breaking)
        // The breaking behavior is handled during line breaking
        output.writeCharCode(SPACE);
      } else {
        // Preserve character as-is
        output.writeCharCode(codeUnit);
      }
    }
    
    return output.toString();
  }

  /// Expand tab characters into spaces for pre-like modes at layout time.
  /// - `startingColumn` is the current column from the last line break.
  /// - `tabSize` is the effective CSS tab-size (number of spaces per tab stop).
  /// This does not alter Phase I semantics; callers opt-in during layout.
  static String expandTabsForPre(String text, int startingColumn, double tabSize) {
    if (text.isEmpty) return text;
    int ts = tabSize.isFinite ? tabSize.round() : 8;
    if (ts <= 0) ts = 8;
    int col = startingColumn;
    final out = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final int cu = text.codeUnitAt(i);
      if (cu == LINE_FEED) {
        out.writeCharCode(LINE_FEED);
        col = 0;
      } else if (cu == TAB) {
        final int spacesToNext = ts - (col % ts);
        for (int j = 0; j < spacesToNext; j++) {
          out.writeCharCode(SPACE);
        }
        col += spacesToNext;
      } else {
        out.writeCharCode(cu);
        col += 1;
      }
    }
    return out.toString();
  }
}

/// Result of Phase II line processing
class LineProcessingResult {
  final String processedText;
  final List<HangingSpace> hangingSpaces;
  final bool hasConditionallyHangingSpaces;
  
  const LineProcessingResult({
    required this.processedText,
    required this.hangingSpaces,
    required this.hasConditionallyHangingSpaces,
  });
}

/// Represents a space that should hang at the end of a line
class HangingSpace {
  final int offset;
  final bool isConditional;
  
  const HangingSpace({
    required this.offset,
    required this.isConditional,
  });
}

/// Handles language-aware segment break transformation
class SegmentBreakTransformer {
  /// Transform a segment break based on surrounding context
  /// Returns null to remove the break, or a string to replace it with
  static String? transformSegmentBreak(
    int? codeUnitBefore,
    int? codeUnitAfter,
    String? language,
  ) {
    if (codeUnitBefore == null || codeUnitAfter == null) {
      // If we don't have context, default to space
      return ' ';
    }
    
    // Check if we should remove the segment break based on East Asian Width
    if (EastAsianWidth.shouldRemoveSegmentBreak(codeUnitBefore, codeUnitAfter, language)) {
      return null; // Remove the break
    }
    
    // Additional heuristic: Check if either character is CJK
    // This helps handle cases not covered by East Asian Width
    if (TextScriptDetector.isCJKCharacter(codeUnitBefore) || 
        TextScriptDetector.isCJKCharacter(codeUnitAfter)) {
      // Check for Hangul Jamo first
      bool isHangulJamo(int codePoint) {
        return codePoint >= 0x1100 && codePoint <= 0x11FF;
      }
      
      // Don't remove break if one side is Hangul Jamo and other is non-Jamo
      if ((isHangulJamo(codeUnitBefore) && !isHangulJamo(codeUnitAfter)) ||
          (!isHangulJamo(codeUnitBefore) && isHangulJamo(codeUnitAfter))) {
        return ' '; // Keep space
      }
      
      // Check if both are Korean Hangul Syllables
      bool isHangulSyllable(int codePoint) {
        return codePoint >= 0xAC00 && codePoint <= 0xD7AF;
      }
      
      // Korean uses spaces between words, so preserve segment breaks as spaces
      if (isHangulSyllable(codeUnitBefore) && isHangulSyllable(codeUnitAfter)) {
        return ' '; // Keep space for Korean text
      }
      
      // If at least one side is CJK, check the other side
      // If it's also CJK or ambiguous punctuation, remove the break
      final widthBefore = EastAsianWidth.getEastAsianWidth(codeUnitBefore);
      final widthAfter = EastAsianWidth.getEastAsianWidth(codeUnitAfter);
      
      if (TextScriptDetector.isCJKCharacter(codeUnitBefore) && 
          TextScriptDetector.isCJKCharacter(codeUnitAfter)) {
        return null; // Both are CJK (Chinese/Japanese), remove break
      }
      
      // If one is CJK and the other is ambiguous, remove break
      if ((TextScriptDetector.isCJKCharacter(codeUnitBefore) && widthAfter == EastAsianWidth.AMBIGUOUS) ||
          (TextScriptDetector.isCJKCharacter(codeUnitAfter) && widthBefore == EastAsianWidth.AMBIGUOUS)) {
        return null;
      }
    }
    
    // Default behavior: transform to space
    return ' ';
  }
}

/// Phase II: Trimming and Positioning processor
/// This phase happens during line layout after bidi reordering
class LineTrimmer {
  /// Process the start of a line
  static String trimLineStart(String lineText, WhiteSpace whiteSpace) {
    if (lineText.isEmpty) return lineText;
    
    // Only trim for collapsible whitespace modes
    if (whiteSpace == WhiteSpace.normal || 
        whiteSpace == WhiteSpace.nowrap || 
        whiteSpace == WhiteSpace.preLine) {
      
      int trimEnd = 0;
      final length = lineText.length;
      
      // Find the end of collapsible spaces at start
      while (trimEnd < length && WhitespaceProcessor.isSpace(lineText.codeUnitAt(trimEnd))) {
        trimEnd++;
      }
      
      if (trimEnd > 0) {
        return lineText.substring(trimEnd);
      }
    }
    
    return lineText;
  }
  
  /// Process the end of a line
  static LineEndResult processLineEnd(
    String lineText, 
    WhiteSpace whiteSpace,
    bool hasFollowingForcedBreak,
    bool wouldOverflow,
  ) {
    if (lineText.isEmpty) {
      return LineEndResult(
        trimmedText: lineText,
        hangingSpaces: const [],
      );
    }
    
    final hangingSpaces = <HangingSpace>[];
    String trimmedText = lineText;
    
    // Find trailing whitespace
    int trailingStart = lineText.length;
    while (trailingStart > 0) {
      final codeUnit = lineText.codeUnitAt(trailingStart - 1);
      if (!WhitespaceProcessor.isDocumentWhitespace(codeUnit) && 
          !WhitespaceProcessor.isOtherSpaceSeparator(codeUnit)) {
        break;
      }
      trailingStart--;
    }
    
    if (trailingStart < lineText.length) {
      // We have trailing whitespace
      switch (whiteSpace) {
        case WhiteSpace.normal:
        case WhiteSpace.nowrap:
        case WhiteSpace.preLine:
          // Remove trailing spaces and mark as hanging
          trimmedText = lineText.substring(0, trailingStart);
          for (int i = trailingStart; i < lineText.length; i++) {
            hangingSpaces.add(HangingSpace(
              offset: i,
              isConditional: false,
            ));
          }
          break;
          
        case WhiteSpace.pre:
          // Preserve all spaces - no hanging
          break;
          
        case WhiteSpace.preWrap:
          // Hang unconditionally, unless followed by forced break
          if (hasFollowingForcedBreak) {
            // Conditionally hang when followed by forced break
            for (int i = trailingStart; i < lineText.length; i++) {
              hangingSpaces.add(HangingSpace(
                offset: i,
                isConditional: true,
              ));
            }
          } else {
            // Unconditionally hang when not followed by forced break
            for (int i = trailingStart; i < lineText.length; i++) {
              hangingSpaces.add(HangingSpace(
                offset: i,
                isConditional: false,
              ));
            }
          }
          break;
          
        case WhiteSpace.breakSpaces:
          // Never hang - spaces take up space and can wrap
          break;
      }
    }
    
    return LineEndResult(
      trimmedText: trimmedText,
      hangingSpaces: hangingSpaces,
    );
  }
}

/// Result of line end processing
class LineEndResult {
  final String trimmedText;
  final List<HangingSpace> hangingSpaces;
  
  const LineEndResult({
    required this.trimmedText,
    required this.hangingSpaces,
  });
  
  bool get hasHangingSpaces => hangingSpaces.isNotEmpty;
  bool get hasConditionalHanging => hangingSpaces.any((s) => s.isConditional);
}
