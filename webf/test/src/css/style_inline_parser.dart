/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

Map parseInlineStyle(String style) {
  return CSSParser(style).parseInlineStyle();
}

void main() {
  group('CSSStyleRuleParser', () {
    test('0', () {
      Map style = parseInlineStyle('color : red; background: red;');
      expect(style['color'], 'red');
    });
  });
}
