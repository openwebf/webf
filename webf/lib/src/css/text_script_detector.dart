/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

/// Detects the script type of text for proper baseline adjustment
class TextScriptDetector {
  // Unicode ranges for different scripts
  static const int _cjkUnifiedIdeographsStart = 0x4E00;
  static const int _cjkUnifiedIdeographsEnd = 0x9FFF;
  static const int _cjkExtensionAStart = 0x3400;
  static const int _cjkExtensionAEnd = 0x4DBF;
  static const int _hiraganaStart = 0x3040;
  static const int _hiraganaEnd = 0x309F;
  static const int _katakanaStart = 0x30A0;
  static const int _katakanaEnd = 0x30FF;
  static const int _hangulSyllablesStart = 0xAC00;
  static const int _hangulSyllablesEnd = 0xD7AF;
  static const int _hangulJamoStart = 0x1100;
  static const int _hangulJamoEnd = 0x11FF;

  static bool isCJKCharacter(int codePoint) {
    return (codePoint >= _cjkUnifiedIdeographsStart && codePoint <= _cjkUnifiedIdeographsEnd) ||
           (codePoint >= _cjkExtensionAStart && codePoint <= _cjkExtensionAEnd) ||
           (codePoint >= _hiraganaStart && codePoint <= _hiraganaEnd) ||
           (codePoint >= _katakanaStart && codePoint <= _katakanaEnd) ||
           (codePoint >= _hangulSyllablesStart && codePoint <= _hangulSyllablesEnd) ||
           (codePoint >= _hangulJamoStart && codePoint <= _hangulJamoEnd);
  }

  static bool containsCJK(String text) {
    if (text.isEmpty) return false;

    for (int i = 0; i < text.length; i++) {
      int codePoint = text.codeUnitAt(i);
      // Handle surrogate pairs for characters outside BMP
      if (codePoint >= 0xD800 && codePoint <= 0xDBFF && i + 1 < text.length) {
        int low = text.codeUnitAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) {
          codePoint = 0x10000 + ((codePoint - 0xD800) << 10) + (low - 0xDC00);
          i++; // Skip the low surrogate
        }
      }

      if (isCJKCharacter(codePoint)) {
        return true;
      }
    }
    return false;
  }

  /// Get the dominant script type for a text span
  /// Returns the ratio of CJK characters in the text
  static double getCJKRatio(String text) {
    if (text.isEmpty) return 0.0;

    int cjkCount = 0;
    int totalCount = 0;

    for (int i = 0; i < text.length; i++) {
      int codePoint = text.codeUnitAt(i);
      // Handle surrogate pairs
      if (codePoint >= 0xD800 && codePoint <= 0xDBFF && i + 1 < text.length) {
        int low = text.codeUnitAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) {
          codePoint = 0x10000 + ((codePoint - 0xD800) << 10) + (low - 0xDC00);
          i++; // Skip the low surrogate
        }
      }

      // Skip whitespace and punctuation for ratio calculation
      if (codePoint == 0x20 || codePoint == 0x09 || codePoint == 0x0A || codePoint == 0x0D) {
        continue;
      }

      totalCount++;
      if (isCJKCharacter(codePoint)) {
        cjkCount++;
      }
    }

    return totalCount > 0 ? cjkCount / totalCount.toDouble() : 0.0;
  }

  /// Analyze text and return segments with their script types
  static List<TextScriptSegment> analyzeTextSegments(String text) {
    if (text.isEmpty) return [];

    List<TextScriptSegment> segments = [];
    int start = 0;
    bool? currentIsCJK;

    for (int i = 0; i < text.length; i++) {
      int codePoint = text.codeUnitAt(i);
      // Handle surrogate pairs
      if (codePoint >= 0xD800 && codePoint <= 0xDBFF && i + 1 < text.length) {
        int low = text.codeUnitAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) {
          codePoint = 0x10000 + ((codePoint - 0xD800) << 10) + (low - 0xDC00);
        }
      }

      // Skip neutral characters (space, punctuation)
      if (codePoint == 0x20 || codePoint == 0x09 || codePoint == 0x0A || codePoint == 0x0D ||
          (codePoint >= 0x21 && codePoint <= 0x2F) || // ASCII punctuation
          (codePoint >= 0x3A && codePoint <= 0x40)) { // More ASCII punctuation
        continue;
      }

      bool isCJK = isCJKCharacter(codePoint);

      if (currentIsCJK == null) {
        currentIsCJK = isCJK;
      } else if (currentIsCJK != isCJK) {
        // Script change detected
        segments.add(TextScriptSegment(
          start: start,
          end: i,
          text: text.substring(start, i),
          isCJK: currentIsCJK,
        ));
        start = i;
        currentIsCJK = isCJK;
      }
    }

    // Add the last segment
    if (start < text.length) {
      segments.add(TextScriptSegment(
        start: start,
        end: text.length,
        text: text.substring(start),
        isCJK: currentIsCJK ?? false,
      ));
    }

    return segments;
  }
}

class TextScriptSegment {
  final int start;
  final int end;
  final String text;
  final bool isCJK;

  TextScriptSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.isCJK,
  });
}
