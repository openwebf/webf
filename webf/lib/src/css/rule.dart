/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';

abstract class CSSRule {
  String get cssText => '';
  CSSStyleSheet? parentStyleSheet;

  int position = -1;

  /// Cascade layer path segments for this rule (e.g. `['framework', 'utilities']`).
  /// Empty means unlayered.
  List<String> layerPath = const <String>[];

  /// Cached cascade layer sort key, assigned by [RuleSet] when rules are added.
  /// `null` means unlayered.
  List<int>? layerOrderKey;

  // https://drafts.csswg.org/cssom/#dom-cssrule-type
  // The following attribute and constants are historical.
  int get type;
  static const int STYLE_RULE = 1;
  static const int CHARSET_RULE = 2;
  static const int IMPORT_RULE = 3;
  static const int MEDIA_RULE = 4;
  static const int FONT_FACE_RULE = 5;
  static const int PAGE_RULE = 6;
  static const int KEYFRAMES_RULE = 7;
  static const int MARGIN_RULE = 9;
  static const int NAMESPACE_RULE = 10;

  // CSS Cascade Layers (CSSOM)
  static const int LAYER_BLOCK_RULE = 18;
  static const int LAYER_STATEMENT_RULE = 19;
}
