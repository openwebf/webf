/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

List<CSSRule> parseRules(String rule) {
  CSSStyleSheet sheet = CSSParser(rule).parse();
  return sheet.cssRules;
}

void main() {
  group('CSSStyleSheetParser', () {
    test('1', () {
      List<CSSRule> rules = parseRules('.foo {color: red} \n .bar {}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
      expect((rules[1] as CSSStyleRule).selectorGroup.selectorText, '.bar');
    });

    test('2', () {
      List<CSSRule> rules = parseRules('{} \n .foo {color: red;} ;\n .bar {;;}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
      expect((rules[1] as CSSStyleRule).selectorGroup.selectorText, '.bar');
    });

    test('3', () {
      List<CSSRule> rules = parseRules('.foo {color: red;} .bar { .x {}; color: #aaa} .baz {}');
      expect(rules.length, 4);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
      expect((rules[1] as CSSStyleRule).selectorGroup.selectorText, '.bar');
      expect((rules[1] as CSSStyleRule).declaration.getPropertyValue('color'), '#aaa');
      expect((rules[2] as CSSStyleRule).selectorGroup.selectorText, '.bar .x');
      expect((rules[3] as CSSStyleRule).selectorGroup.selectorText, '.baz');
    });

    test('4', () {
      List<CSSRule> rules = parseRules('.foo {color: red} .bar {background: url(data:image/png;base64...)}');
      expect(rules.length, 2);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
      expect((rules[1] as CSSStyleRule).selectorGroup.selectorText, '.bar');
      expect(
          (rules[1] as CSSStyleRule).declaration.getPropertyValue('backgroundImage'), 'url(data:image/png;base64...)');
    });

    test('5', () {
      List<CSSRule> rules = parseRules('@charset "utf-8"; .foo {color: red}');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
    });

    test('6', () {
      List<CSSRule> rules = parseRules('''
        @media screen and (min-width: 900.5px) { }
        .foo {
          color: red
        }
      ''');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
    });

    test('7', () {
      List<CSSRule> rules = parseRules('.foo h6{color: red}');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo h6');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
    });

    test('8', () {
      List<CSSRule> rules = parseRules('@css-compile@model-base 75/750; .foo {color: red}');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.foo');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('color'), 'red');
    });
    test('9', () {
      List<CSSRule> rules = parseRules('.item { animation: testAni .5s 1 ease forwards }');
      expect(rules.length, 1);
      expect((rules[0] as CSSStyleRule).selectorGroup.selectorText, '.item');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('animationDelay'), '0s');
      expect((rules[0] as CSSStyleRule).declaration.getPropertyValue('animationFillMode'), 'forwards');
    });
  });
}
