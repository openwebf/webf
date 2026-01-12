/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#numbers

class CSSNumber {
  static double? parseNumber(String input) {
    return double.tryParse(input);
  }

  static bool isNumber(String input) {
    final int len = input.length;
    if (len == 0) return false;
    int i = 0;
    final int first = input.codeUnitAt(0);
    if (first == 0x2B /* + */ || first == 0x2D /* - */) {
      i++;
      if (i >= len) return false;
    }

    bool sawDigit = false;
    while (i < len) {
      final int cu = input.codeUnitAt(i);
      if (cu >= 0x30 && cu <= 0x39) {
        sawDigit = true;
        i++;
        continue;
      }
      break;
    }

    if (i < len && input.codeUnitAt(i) == 0x2E /* . */) {
      i++;
      bool sawFracDigit = false;
      while (i < len) {
        final int cu = input.codeUnitAt(i);
        if (cu >= 0x30 && cu <= 0x39) {
          sawFracDigit = true;
          i++;
          continue;
        }
        return false;
      }
      return sawFracDigit;
    }

    return sawDigit && i == len;
  }
}
