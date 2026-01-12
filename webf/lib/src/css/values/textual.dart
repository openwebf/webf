/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#common-keywords

@pragma('vm:prefer-inline')
bool _isAsciiAlpha(int cu) => (cu >= 0x41 && cu <= 0x5A) || (cu >= 0x61 && cu <= 0x7A);

@pragma('vm:prefer-inline')
bool _isIdentStart(int cu) => cu == 0x5F /* _ */ || _isAsciiAlpha(cu);

@pragma('vm:prefer-inline')
bool _isIdentContinue(int cu) =>
    _isIdentStart(cu) || (cu >= 0x30 && cu <= 0x39) || cu == 0x2D /* - */;

/// All of these keywords are normatively defined in the Cascade module.
enum CSSWideKeywords {
  /// The initial keyword represents the value specified as the property’s
  /// initial value.
  initial,

  /// The inherit keyword represents the computed value of the property on
  /// the element’s parent.
  inherit,

  /// The unset keyword acts as either inherit or initial, depending on whether
  /// the property is inherited or not.
  unset,
}

class CSSTextual {
  static bool isCustomIdent(String value) {
    if (value.isEmpty) return false;
    int i = 0;
    if (value.codeUnitAt(0) == 0x2D /* - */) {
      i++;
      if (i >= value.length) return false;
    }
    if (!_isIdentStart(value.codeUnitAt(i))) return false;
    i++;
    while (i < value.length) {
      if (!_isIdentContinue(value.codeUnitAt(i))) return false;
      i++;
    }
    return true;
  }

  static bool isDashedIdent(String value) {
    if (value.length < 3) return false;
    if (value.codeUnitAt(0) != 0x2D /* - */ || value.codeUnitAt(1) != 0x2D /* - */) return false;
    if (!_isIdentStart(value.codeUnitAt(2))) return false;
    for (int i = 3; i < value.length; i++) {
      if (!_isIdentContinue(value.codeUnitAt(i))) return false;
    }
    return true;
  }
}
