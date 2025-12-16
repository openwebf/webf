/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

/// East Asian Width property classifier based on Unicode Standard Annex #11
/// https://www.unicode.org/reports/tr11/
class EastAsianWidth {
  /// East Asian Width categories
  static const String FULLWIDTH = 'F';  // Fullwidth
  static const String HALFWIDTH = 'H';  // Halfwidth
  static const String WIDE = 'W';       // Wide
  static const String NARROW = 'Na';    // Narrow
  static const String AMBIGUOUS = 'A';  // Ambiguous
  static const String NEUTRAL = 'N';    // Neutral
  
  /// Get the East Asian Width property of a character
  static String getEastAsianWidth(int codePoint) {
    // Fullwidth ASCII variants (U+FF00-U+FF5E)
    if (codePoint >= 0xFF01 && codePoint <= 0xFF5E) {
      return FULLWIDTH;
    }
    
    // Halfwidth CJK punctuation and Katakana (U+FF61-U+FFDC)
    if (codePoint >= 0xFF61 && codePoint <= 0xFFDC) {
      return HALFWIDTH;
    }
    
    // CJK Unified Ideographs (U+4E00-U+9FFF)
    if (codePoint >= 0x4E00 && codePoint <= 0x9FFF) {
      return WIDE;
    }
    
    // CJK Extension A (U+3400-U+4DBF)
    if (codePoint >= 0x3400 && codePoint <= 0x4DBF) {
      return WIDE;
    }
    
    // Hiragana (U+3040-U+309F)
    if (codePoint >= 0x3040 && codePoint <= 0x309F) {
      return WIDE;
    }
    
    // Katakana (U+30A0-U+30FF)
    if (codePoint >= 0x30A0 && codePoint <= 0x30FF) {
      return WIDE;
    }
    
    // Hangul Syllables (U+AC00-U+D7AF)
    if (codePoint >= 0xAC00 && codePoint <= 0xD7AF) {
      return WIDE;
    }
    
    // CJK Compatibility Ideographs (U+F900-U+FAFF)
    if (codePoint >= 0xF900 && codePoint <= 0xFAFF) {
      return WIDE;
    }
    
    // CJK punctuation and symbols
    if (codePoint >= 0x3000 && codePoint <= 0x303F) {
      if (codePoint == 0x3000) return FULLWIDTH; // Ideographic space
      return WIDE;
    }
    
    // General punctuation that are ambiguous
    // Common quotation marks
    if (codePoint == 0x0022 || // Quotation mark "
        codePoint == 0x0027 || // Apostrophe '
        codePoint == 0x2018 || // Left single quotation mark '
        codePoint == 0x2019 || // Right single quotation mark '
        codePoint == 0x201C || // Left double quotation mark "
        codePoint == 0x201D || // Right double quotation mark "
        codePoint == 0x00AB || // Left-pointing double angle quotation mark «
        codePoint == 0x00BB) { // Right-pointing double angle quotation mark »
      return AMBIGUOUS;
    }
    
    // Parentheses and brackets
    if (codePoint == 0x0028 || // Left parenthesis (
        codePoint == 0x0029 || // Right parenthesis )
        codePoint == 0x005B || // Left square bracket [
        codePoint == 0x005D || // Right square bracket ]
        codePoint == 0x007B || // Left curly bracket {
        codePoint == 0x007D) { // Right curly bracket }
      return AMBIGUOUS;
    }
    
    // Other ambiguous punctuation
    if (codePoint == 0x00A1 || // Inverted exclamation mark ¡
        codePoint == 0x00A7 || // Section sign §
        codePoint == 0x00B6 || // Pilcrow sign ¶
        codePoint == 0x00BF || // Inverted question mark ¿
        codePoint == 0x2010 || // Hyphen ‐
        codePoint == 0x2013 || // En dash –
        codePoint == 0x2014 || // Em dash —
        codePoint == 0x2026) { // Horizontal ellipsis …
      return AMBIGUOUS;
    }
    
    // Greek letters (ambiguous)
    if (codePoint >= 0x0391 && codePoint <= 0x03A9) { // Greek capital letters
      return AMBIGUOUS;
    }
    if (codePoint >= 0x03B1 && codePoint <= 0x03C9) { // Greek small letters
      return AMBIGUOUS;
    }
    
    // Cyrillic letters (ambiguous)
    if (codePoint >= 0x0410 && codePoint <= 0x044F) {
      return AMBIGUOUS;
    }
    
    // ASCII letters and digits (narrow)
    if ((codePoint >= 0x0041 && codePoint <= 0x005A) || // A-Z
        (codePoint >= 0x0061 && codePoint <= 0x007A) || // a-z
        (codePoint >= 0x0030 && codePoint <= 0x0039)) { // 0-9
      return NARROW;
    }
    
    // Default to neutral for other characters
    return NEUTRAL;
  }
  
  /// Check if a character is East Asian Wide (F, W, or H)
  static bool isEastAsianWide(int codePoint) {
    final width = getEastAsianWidth(codePoint);
    return width == FULLWIDTH || width == WIDE || width == HALFWIDTH;
  }
  
  /// Check if a character is ambiguous width
  static bool isAmbiguous(int codePoint) {
    return getEastAsianWidth(codePoint) == AMBIGUOUS;
  }
  
  /// Check if both characters should remove segment break between them
  /// according to CSS Text Module Level 3 rules
  static bool shouldRemoveSegmentBreak(int? charBefore, int? charAfter, String? language) {
    if (charBefore == null || charAfter == null) return false;
    
    // Zero-width space always removes the break
    if (charBefore == 0x200B || charAfter == 0x200B) return true;
    
    final widthBefore = getEastAsianWidth(charBefore);
    final widthAfter = getEastAsianWidth(charAfter);
    
    // Check if neither side is Hangul Jamo
    bool isHangulJamo(int codePoint) {
      return codePoint >= 0x1100 && codePoint <= 0x11FF;
    }
    
    // Check if both are Korean Hangul Syllables
    bool isHangulSyllable(int codePoint) {
      return codePoint >= 0xAC00 && codePoint <= 0xD7AF;
    }
    
    // Hangul Jamo should not remove breaks with non-Hangul characters
    if ((isHangulJamo(charBefore) && !isHangulJamo(charAfter)) ||
        (!isHangulJamo(charBefore) && isHangulJamo(charAfter))) {
      return false;
    }
    
    // Korean Hangul Syllables should not remove breaks (Korean uses spaces)
    if (isHangulSyllable(charBefore) && isHangulSyllable(charAfter)) {
      return false;
    }
    
    // If both are F, W, or H (not Jamo/Hangul), remove the break
    if ((widthBefore == FULLWIDTH || widthBefore == WIDE || widthBefore == HALFWIDTH) &&
        (widthAfter == FULLWIDTH || widthAfter == WIDE || widthAfter == HALFWIDTH)) {
      return true;
    }
    
    // Handle ambiguous characters with language context
    if (widthBefore == AMBIGUOUS || widthAfter == AMBIGUOUS) {
      // If we have language context
      if (language != null) {
        // Check if it's a CJK language
        if (language.startsWith('zh') || // Chinese
            language.startsWith('ja') || // Japanese
            language.startsWith('ko') || // Korean
            language == 'ii') {          // Yi
          // In CJK context, treat ambiguous as wide
          // If one is ambiguous and the other is wide, remove break
          if ((widthBefore == AMBIGUOUS && isEastAsianWide(charAfter)) ||
              (widthAfter == AMBIGUOUS && isEastAsianWide(charBefore))) {
            return true;
          }
          // If both are ambiguous in CJK context, remove break
          if (widthBefore == AMBIGUOUS && widthAfter == AMBIGUOUS) {
            return true;
          }
        }
      } else {
        // Without language context, use heuristic:
        // If one side is ambiguous and other is CJK, remove break
        if ((widthBefore == AMBIGUOUS && isEastAsianWide(charAfter)) ||
            (widthAfter == AMBIGUOUS && isEastAsianWide(charBefore))) {
          return true;
        }
      }
    }
    
    return false;
  }
}
