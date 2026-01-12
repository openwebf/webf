/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'package:quiver/collection.dart';
import 'number.dart';

final _zeroSeconds = '0s';
final _zeroMilliseconds = '0ms';
final LinkedLruHashMap<String, int?> _cachedParsedTime = LinkedLruHashMap(maximumSize: 100);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#time
class CSSTime {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';

  static bool isTime(String value) {
    if (value == _zeroSeconds || value == _zeroMilliseconds) return true;
    final String lower = value.toLowerCase();
    String unit;
    if (lower.endsWith(MILLISECONDS)) {
      unit = MILLISECONDS;
    } else if (lower.endsWith(SECOND)) {
      unit = SECOND;
    } else {
      return false;
    }
    final String numberPart = value.substring(0, value.length - unit.length);
    return CSSNumber.isNumber(numberPart);
  }

  static int? _parseTimeValue(String input) {
    int? milliseconds;
    final String lower = input.toLowerCase();
    if (lower.endsWith(MILLISECONDS)) {
      final String raw = input.substring(0, input.length - MILLISECONDS.length);
      final double? v = double.tryParse(raw);
      if (v != null) milliseconds = v.toInt();
    } else if (lower.endsWith(SECOND)) {
      final String raw = input.substring(0, input.length - SECOND.length);
      final double? v = double.tryParse(raw);
      if (v != null) milliseconds = (v * 1000).toInt();
    }
    return milliseconds;
  }

  static int? parseTime(String input) {
    if (_cachedParsedTime.containsKey(input)) {
      return _cachedParsedTime[input];
    }

    int? milliseconds = _parseTimeValue(input);

    return _cachedParsedTime[input] = milliseconds;
  }

  static int? parseNotNegativeTime(String input) {
    if (_cachedParsedTime.containsKey(input)) {
      return _cachedParsedTime[input];
    }

    int? milliseconds = _parseTimeValue(input);
    if (milliseconds != null && milliseconds < 0) {
      milliseconds = 0;
    }

    return _cachedParsedTime[input] = milliseconds;
  }
}
