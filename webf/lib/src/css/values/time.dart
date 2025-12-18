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

final _timeRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?(?:ms|s){1}$', caseSensitive: false);
final _zeroSeconds = '0s';
final _zeroMilliseconds = '0ms';
final LinkedLruHashMap<String, int?> _cachedParsedTime = LinkedLruHashMap(maximumSize: 100);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#time
class CSSTime {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';

  static bool isTime(String value) {
    return (value == _zeroSeconds || value == _zeroMilliseconds || _timeRegExp.firstMatch(value) != null);
  }

  static int? _parseTimeValue(String input) {
    int? milliseconds;
    if (input.endsWith(MILLISECONDS)) {
      milliseconds = double.tryParse(input.split(MILLISECONDS)[0])!.toInt();
    } else if (input.endsWith(SECOND)) {
      milliseconds = (double.tryParse(input.split(SECOND)[0])! * 1000).toInt();
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
