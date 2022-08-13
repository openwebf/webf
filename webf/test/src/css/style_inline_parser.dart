/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

CSSStyleDeclaration parseInlineStyle(String style) {
  return CSSParser(style).parseInlineStyle();
}

void main() {
  group('CSSStyleRuleParser', () {
    test('0', () {
      CSSStyleDeclaration style = parseInlineStyle('color : red; background: red;');
      expect(style.getPropertyValue('color'), 'red');
    });
  });
}
