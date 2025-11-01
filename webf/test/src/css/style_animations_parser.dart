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

    test('keyframe-level easing via animation-timing-function', () {
      const css = '@keyframes bounceSeg {'
          '  0% { animation-timing-function: ease-in; transform: translateY(0); }'
          '  50% { animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1); transform: translateY(-10px); }'
          '  100% { transform: translateY(0); }'
          '}';
      final CSSRule? rule = parseSingleRule(css);
      expect(rule is CSSKeyframesRule, true);
      final kf = (rule as CSSKeyframesRule).keyframes;

      // Should not treat animation-timing-function as an animatable property.
      expect(kf.any((e) => e.property == 'animationTimingFunction'), false);

      // Collect transform keyframes by offset for easier assertions.
      Keyframe? at(double o) => kf.firstWhere((e) => e.property == 'transform' && (e.offset - o).abs() < 0.0001);

      expect(at(0)!.easing, 'ease-in');
      expect(at(0.5)!.easing, 'cubic-bezier(0.215, 0.61, 0.355, 1)');
      // Default to linear when not specified on the block.
      expect(at(1)!.easing, LINEAR);
    });

    test('combined selectors (0%, 100%) produce multiple keyframes', () {
      const css = '@keyframes bounce { 0%, 100% { transform: translateY(-25%); } }';
      final CSSRule? rule = parseSingleRule(css);
      expect(rule is CSSKeyframesRule, true);
      final kf = (rule as CSSKeyframesRule).keyframes;

      final transforms = kf.where((e) => e.property == 'transform').toList();
      // Should have two transform keyframes: offsets 0 and 1.
      expect(transforms.length, 2);
      final offsets = transforms.map((e) => e.offset).toList()..sort();
      expect(offsets[0], 0);
      expect(offsets[1], 1);
    });
  });
}
