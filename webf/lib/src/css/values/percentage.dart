/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages

import 'package:quiver/collection.dart';

final LinkedLruHashMap<String, double?> _cachedParsedPercentage = LinkedLruHashMap(maximumSize: 100);

class CSSPercentage {
  static const String percentageSymbol = '%';

  static bool _isPercentageToken(String value, {required bool nonNegative}) {
    final int len = value.length;
    if (len < 2) return false;
    if (value.codeUnitAt(len - 1) != 0x25 /* % */) return false;

    int i = 0;
    final int first = value.codeUnitAt(0);
    if (first == 0x2B /* + */) {
      i++;
    } else if (first == 0x2D /* - */) {
      if (nonNegative) return false;
      i++;
    }
    if (i >= len - 1) return false;

    bool sawDigit = false;
    while (i < len - 1) {
      final int cu = value.codeUnitAt(i);
      if (cu >= 0x30 && cu <= 0x39) {
        sawDigit = true;
        i++;
        continue;
      }
      break;
    }
    if (!sawDigit) return false;

    if (i < len - 1 && value.codeUnitAt(i) == 0x2E /* . */) {
      i++;
      while (i < len - 1) {
        final int cu = value.codeUnitAt(i);
        if (cu >= 0x30 && cu <= 0x39) {
          i++;
          continue;
        }
        return false;
      }
    }

    return i == len - 1;
  }

  static double? parsePercentage(String value) {
    if (_cachedParsedPercentage.containsKey(value)) {
      return _cachedParsedPercentage[value];
    }
    double? parsed;
    if (value.endsWith(percentageSymbol)) {
      final String raw = value.substring(0, value.length - 1);
      final double? n = double.tryParse(raw);
      if (n != null) parsed = n / 100;
    }
    return _cachedParsedPercentage[value] = parsed;
  }

  static bool isPercentage(String? percentageValue) {
    return percentageValue != null && _isPercentageToken(percentageValue, nonNegative: false);
  }

  static bool isNonNegativePercentage(String? percentageValue) {
    return percentageValue != null && _isPercentageToken(percentageValue, nonNegative: true);
  }
}
