/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/painting.dart';
import 'package:webf/css.dart';
import 'package:quiver/collection.dart';
import 'package:webf/src/foundation/logger.dart';

final RegExp splitRegExp = RegExp(r'(?<!\+|-|\*|\/)\s+(?!\+\s|-\s|\*\s|\/\s)');
final LinkedLruHashMap<String, List<String>> _cachedParsedPosition = LinkedLruHashMap(maximumSize: 100);


// Helpers
bool _isLenPct(String t) => CSSLength.isLength(t) || CSSPercentage.isPercentage(t);
bool _looksNumeric(String t) => _isLenPct(t) || CSSFunction.isFunction(t, functionName: CALC);

String _axisToValue(String? keyword, String? offset, {required bool horizontal}) {
  // No keyword and no offset => center
  if (keyword == null && offset == null) return CENTER;
  // No offset => return keyword or center
  if (offset == null) return keyword ?? CENTER;

  // Have offset: convert logical keyword + offset into calc() where needed
  if (keyword == null || keyword == (horizontal ? LEFT : TOP)) {
    // left/top with offset equals the offset itself
    return offset; // e.g. '20px' or '10%'
  }
  if (keyword == (horizontal ? RIGHT : BOTTOM)) {
    // right/bottom with offset => calc(100% - offset)
    return 'calc(100% - $offset)';
  }
  // center with offset => calc(50% + offset) (offset may be negative)
  return 'calc(50% + $offset)';
}

// Fast-path the 2-keyword reversal rule to match CSS grammar:
// If first token is vertical-ish (top/bottom/center) and second is horizontal-ish (left/right/center),
// swap to x,y = second, first.
bool _isHorizKW(String t) => t == LEFT || t == RIGHT || t == CENTER;
bool _isVertKW(String t) => t == TOP || t == BOTTOM || t == CENTER;

/// CSS Values and Units: https://drafts.csswg.org/css-values-3/#position
/// The `<position>` value specifies the position of a object area
/// (e.g. background image) inside a positioning area (e.g. background
/// positioning area). It is interpreted as specified for background-position.
/// [CSS3-BACKGROUND]
class CSSPosition {
  // [0, 1]
  static Alignment initial = Alignment.topLeft; // default value.

  /// Parse background-position shorthand to background-position-x and background-position-y list.
  static List<String> parsePositionShorthand(String input) {
    if (_cachedParsedPosition.containsKey(input)) {
      return _cachedParsedPosition[input]!;
    }

    final List<String> tokens = input.split(splitRegExp).where((s) => s.isNotEmpty).toList();

    if (tokens.length == 2) {
      final String a = tokens[0];
      final String b = tokens[1];
      if (!_looksNumeric(a) && !_looksNumeric(b)) {
        if (_isVertKW(a) && _isHorizKW(b)) {
          final List<String> swapped = <String>[b, a];
          _cachedParsedPosition[input] = swapped;
          cssLogger.finer('[CSSPosition] Parsed background-position "$input" => x="${swapped[0]}", y="${swapped[1]}"');
          return swapped;
        }
      }
      // Horizontal keyword followed by numeric => x=keyword, y=numeric.
      if (_isHorizKW(a) && _looksNumeric(b)) {
        final List<String> pair = <String>[a, b];
        _cachedParsedPosition[input] = pair;
        cssLogger.finer('[CSSPosition] Parsed background-position "$input" => x="${pair[0]}", y="${pair[1]}"');
        return pair;
      }
      // Numeric followed by vertical keyword => x=numeric, y=keyword.
      if (_looksNumeric(a) && _isVertKW(b)) {
        final List<String> pair = <String>[a, b];
        _cachedParsedPosition[input] = pair;
        cssLogger.finer('[CSSPosition] Parsed background-position "$input" => x="${pair[0]}", y="${pair[1]}"');
        return pair;
      }
    }
    if (tokens.isEmpty) {
      cssLogger.warning('[CSSPosition] Empty background-position input. Falling back to center center.');
      return _cachedParsedPosition[input] = [CENTER, CENTER];
    }


    String? hKeyword;
    String? vKeyword;
    String? hOffset;
    String? vOffset;
    String? lastAxis; // 'x' or 'y'

    for (int i = 0; i < tokens.length; i++) {
      final String t = tokens[i];
      if (t == LEFT || t == RIGHT) {
        hKeyword ??= t;
        lastAxis = 'x';
        continue;
      }
      if (t == TOP || t == BOTTOM) {
        vKeyword ??= t;
        lastAxis = 'y';
        continue;
      }
      if (t == CENTER) {
        // Assign CENTER to the axis that isn't specified yet; if both unset, prefer x first.
        if (hKeyword == null) {
          hKeyword = CENTER;
          lastAxis = 'x';
        } else if (vKeyword == null) {
          vKeyword = CENTER;
          lastAxis = 'y';
        } else {
          // Extra center token; ignore.
        }
        continue;
      }
      if (_looksNumeric(t)) {
        if (lastAxis == 'x') {
          if (hOffset == null) {
            hOffset = t;
          } else if (vOffset == null) {
            // Two-value syntax: second numeric goes to y.
            vOffset = t;
            lastAxis = 'y';
          }
        } else if (lastAxis == 'y') {
          if (vOffset == null) {
            vOffset = t;
          } else if (hOffset == null) {
            hOffset = t;
            lastAxis = 'x';
          }
        } else {
          // No prior axis keyword: first length -> x, second -> y.
          if (hOffset == null) {
            hOffset = t;
            lastAxis = 'x';
          } else if (vOffset == null) {
            vOffset = t;
            lastAxis = 'y';
          }
        }
        continue;
      }
      // Unknown token: ignore but log once.
      cssLogger.fine('[CSSPosition] Ignoring unknown token in background-position: "$t"');
    }

    // Defaults per spec when a side/offset is omitted.
    // If only a vertical keyword/offset provided, horizontal defaults to center.
    // If only a horizontal provided, vertical defaults to center.
    // If first token is a length/percentage only, treat as horizontal offset.
    if (hKeyword == null && hOffset == null) {
      if (vKeyword != null || vOffset != null) {
        hKeyword = CENTER;
      }
    }
    if (vKeyword == null && vOffset == null) {
      if (hKeyword != null || hOffset != null) {
        vKeyword = CENTER;
      }
    }

    // Compute final axis values.
    final String xValue = _axisToValue(hKeyword, hOffset, horizontal: true);
    final String yValue = _axisToValue(vKeyword, vOffset, horizontal: false);

    final List<String> result = <String>[xValue, yValue];
    _cachedParsedPosition[input] = result;

    cssLogger.finer('[CSSPosition] Parsed background-position "$input" => x="$xValue", y="$yValue"');
    return result;
  }

  /// Parse background-position-x/background-position-y from string to CSSBackgroundPosition type.
  static CSSBackgroundPosition resolveBackgroundPosition(
      String input, RenderStyle renderStyle, String propertyName, bool isHorizontal) {
    dynamic calcValue = CSSCalcValue.tryParse(renderStyle, propertyName, input);
    if (calcValue != null && calcValue is CSSCalcValue) {
      return CSSBackgroundPosition(calcValue: calcValue);
    }
    if (CSSPercentage.isPercentage(input)) {
      return CSSBackgroundPosition(percentage: _gatValuePercentage(input));
    } else if (CSSLength.isLength(input)) {
      return CSSBackgroundPosition(length: CSSLength.parseLength(input, renderStyle, propertyName));
    } else {
      if (isHorizontal) {
        switch (input) {
          case LEFT:
            return CSSBackgroundPosition(percentage: -1);
          case RIGHT:
            return CSSBackgroundPosition(percentage: 1);
          case CENTER:
            return CSSBackgroundPosition(percentage: 0);
          default:
            return CSSBackgroundPosition(percentage: -1);
        }
      } else {
        switch (input) {
          case TOP:
            return CSSBackgroundPosition(percentage: -1);
          case BOTTOM:
            return CSSBackgroundPosition(percentage: 1);
          case CENTER:
            return CSSBackgroundPosition(percentage: 0);
          default:
            return CSSBackgroundPosition(percentage: -1);
        }
      }
    }
  }

  static double _gatValuePercentage(String input) {
    var percentageValue = input.substring(0, input.length - 1);
    return (double.tryParse(percentageValue) ?? 0) / 50 - 1;
  }
}
