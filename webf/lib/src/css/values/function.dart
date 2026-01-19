/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#functional-notations

// ignore_for_file: constant_identifier_names

import 'package:quiver/collection.dart';

final _functionStart = '(';
final _functionEnd = ')';
final _functionNotationUrl = 'url';

const String FUNCTION_SPLIT = ',';
const String FUNCTION_ARGS_SPLIT = ',';

final LinkedLruHashMap<String, List<CSSFunctionalNotation>> _cachedParsedFunction = LinkedLruHashMap(maximumSize: 100);

@pragma('vm:prefer-inline')
bool _isAsciiAlpha(int cu) => (cu >= 0x41 && cu <= 0x5A) || (cu >= 0x61 && cu <= 0x7A);

bool _isFunctionNotation(String value) {
  final int len = value.length;
  if (len < 4) return false; // "a()x" minimum excluded; "a(b)" minimum is 4.
  final int left = value.indexOf(_functionStart);
  if (left <= 0) return false;
  if (value.codeUnitAt(len - 1) != 0x29 /* ) */) return false;
  // Must have at least 1 char inside parentheses.
  if (left + 1 >= len - 1) return false;
  // Validate function name chars (ASCII letters, '_' or '-').
  for (int i = 0; i < left; i++) {
    final int cu = value.codeUnitAt(i);
    if (!_isAsciiAlpha(cu) && cu != 0x5F /* _ */ && cu != 0x2D /* - */) {
      return false;
    }
  }
  return true;
}

// ignore: public_member_api_docs
class CSSFunction {
  static bool isFunction(String value, {String? functionName}) {
    if (functionName != null) {
      bool isMatch;
      final int functionNameLength = functionName.length;

      if (value.length < functionNameLength) {
        return false;
      }

      for (int i = 0; i < functionNameLength; i++) {
        isMatch = functionName.codeUnitAt(i) == value.codeUnitAt(i);
        if (!isMatch) {
          return false;
        }
      }
    }

    return _isFunctionNotation(value);
  }

  static List<CSSFunctionalNotation> parseFunction(final String value) {
    if (_cachedParsedFunction.containsKey(value)) {
      return _cachedParsedFunction[value]!;
    }

    final int valueLength = value.length;
    final List<CSSFunctionalNotation> notations = [];

    int start = 0;
    int left = value.indexOf(_functionStart, start);

    // Function may contain function, should handle this situation.
    while (left != -1 && start < left) {
      String fn = value.substring(start, left);
      int argsBeginIndex = left + 1;
      List<String> argList = [];
      int argBeginIndex = argsBeginIndex;
      // Contain function count.
      int containLeftCount = 0;
      bool match = false;
      // Find all args in this function.
      while (argsBeginIndex < valueLength) {
        // url() function notation should not be split causing it only accept one URL.
        // https://drafts.csswg.org/css-values-3/#urls
        if (fn != _functionNotationUrl && value[argsBeginIndex] == FUNCTION_ARGS_SPLIT) {
          if (containLeftCount == 0 && argBeginIndex < argsBeginIndex) {
            argList.add(value.substring(argBeginIndex, argsBeginIndex).trim());
            argBeginIndex = argsBeginIndex + 1;
          }
        } else if (value[argsBeginIndex] == _functionStart) {
          containLeftCount++;
        } else if (value[argsBeginIndex] == _functionEnd) {
          if (containLeftCount > 0) {
            containLeftCount--;
          } else {
            if (argBeginIndex < argsBeginIndex) {
              argList.add(value.substring(argBeginIndex, argsBeginIndex).trim());
              argBeginIndex = argsBeginIndex + 1;
            }
            // Function parse success when find the matched right parenthesis.
            match = true;
            break;
          }
        }
        argsBeginIndex++;
      }
      if (match) {
        // Only add the right function.
        fn = fn.trim();
        if (fn.startsWith(FUNCTION_SPLIT)) {
          fn = fn
              .substring(
                1,
              )
              .trim();
        }
        notations.add(CSSFunctionalNotation(fn, argList));
      }
      start = argsBeginIndex + 1;
      if (start >= value.length) {
        break;
      }
      left = value.indexOf(_functionStart, start);
    }

    return _cachedParsedFunction[value] = notations;
  }
}

/// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunctionalNotation {
  final String name;
  final List<String> args;

  CSSFunctionalNotation(this.name, this.args);

  @override
  String toString() => 'CSSFunctionalNotation($name: $args)';
}
