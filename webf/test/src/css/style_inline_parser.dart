/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

Map<String, InlineStyleEntry> parseInlineStyle(String style) {
  return CSSParser(style).parseInlineStyle();
}

void main() {
  group('CSSStyleRuleParser', () {
    test('0', () {
      Map<String, InlineStyleEntry> style = parseInlineStyle('color : red; background: red;');
      expect(style['color']?.value, 'red');
      expect(style['color']?.important, isFalse);
    });

    test('important', () {
      Map<String, InlineStyleEntry> style =
          parseInlineStyle('color: red !important; background: red;');
      expect(style['color']?.value, 'red');
      expect(style['color']?.important, isTrue);
      expect(style['background']?.important, isFalse);
    });
  });
}
