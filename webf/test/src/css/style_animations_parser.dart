/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

CSSRule? parseSingleRule(String rule) {
  CSSStyleSheet sheet = CSSParser(rule).parse();
  return sheet.cssRules.first;
}

void main() {
  group('CSSStyleRuleParser', () {
    test('0', () {
      CSSRule? style = parseSingleRule('@keyframes ping { 75%, 100% { transform: scale(2); opacity: 0; } }');
      expect(style is CSSKeyframesRule, true);
      expect((style as CSSKeyframesRule).keyframes[0].offset, 0.75);
    });
  });
}
