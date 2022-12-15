/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
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
      CSSRule? rule = parseSingleRule('div p, #id:first-line { color : red; }');
      expect(rule is CSSStyleRule, true);
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, 'div p, #id:first-line');
      expect(styleRule.declaration.getPropertyValue('color'), 'red');
    });

    test('1', () {
      CSSRule? rule = parseSingleRule(' .foo { color: red; }');
      expect(rule is CSSStyleRule, true);
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('color'), 'red');
    });

    test('2', () {
      CSSRule? rule = parseSingleRule(' html{\n    color:black;\n}');
      expect(rule is CSSStyleRule, true);
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, 'html');
      expect(styleRule.declaration.getPropertyValue('color'), 'black');
    });

    test('3', () {
      CSSRule? rule = parseSingleRule('/*\nSome Comments\nBaby \n*/\nhtml{\n    color:black;\n}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, 'html');
      expect(styleRule.declaration.getPropertyValue('color'), 'black');
    });

    test('4', () {
      CSSRule? rule = parseSingleRule('/*\nSome Comments\nBaby \n*/\nhtml{\n    color:black;\n}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, 'html');
      expect(styleRule.declaration.getPropertyValue('color'), 'black');
    });

    test('5', () {
      CSSRule? rule = parseSingleRule('.foo{--custom:some\n value;}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('--custom'), 'some\n value');
    });

    test('6', () {
      CSSRule? rule = parseSingleRule('.foo{zoom;\ncolor: red \n}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('color'), 'red');
    });

    test('7', () {
      CSSRule? rule = parseSingleRule('.foo \t {background: url(data:image/png;base64, CNbyblAAAAHElEQVQI12P4) red}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('backgroundColor'), 'red');
      expect(styleRule.declaration.getPropertyValue('backgroundImage'),
          'url(data:image/png;base64, CNbyblAAAAHElEQVQI12P4)');
    });

    test('8', () {
      CSSRule? rule = parseSingleRule('.foo { color: rgb(255, 255, 0)}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('color'), 'rgb(255, 255, 0)');
    });

    test('9', () {
      CSSRule? rule = parseSingleRule('.foo { background : ; color: rgb(255, 255, 0)}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('color'), 'rgb(255, 255, 0)');
    });

    test('10', () {
      CSSRule? rule = parseSingleRule('div:nth-child(4) {color: rgb(255, 255, 0)}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      final simpleSelectors = styleRule.selectorGroup.selectors.first.simpleSelectorSequences;
      expect(simpleSelectors[0].simpleSelector.name, 'div');
      expect(simpleSelectors[1].simpleSelector.name, 'nth-child');
      expect(simpleSelectors[1].simpleSelector is PseudoClassFunctionSelector, true);
      expect((simpleSelectors[1].simpleSelector as PseudoClassFunctionSelector).argument, ['4']);
      expect(styleRule.declaration.getPropertyValue('color'), 'rgb(255, 255, 0)');
    });

    test('11', () {
      CSSRule? rule = parseSingleRule('[hidden] { display: none }');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      final simpleSelectors = styleRule.selectorGroup.selectors.first.simpleSelectorSequences;
      expect(simpleSelectors[0].simpleSelector is AttributeSelector, true);
      expect(simpleSelectors[0].simpleSelector.name, 'hidden');
      expect(styleRule.declaration.getPropertyValue('display'), 'none');
    });

    test('12', () {
      CSSRule? rule = parseSingleRule('/**/ div > p { color: rgb(255, 255, 0);  } /**/');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      final simpleSelectors = styleRule.selectorGroup.selectors.first.simpleSelectorSequences;
      expect(simpleSelectors[0].simpleSelector.name, 'div');
      expect(simpleSelectors[1].simpleSelector.name, 'p');
      expect(styleRule.declaration.getPropertyValue('color'), 'rgb(255, 255, 0)');
    });

    test('13', () {
      CSSRule? rule = parseSingleRule('.foo { background-image: url( "./image (1).jpg" )}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('backgroundImage'), 'url( "./image (1).jpg" )');
    });

    test('14', () {
      CSSRule? rule = parseSingleRule('.foo { .foo{ }; color: red}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
      expect(styleRule.declaration.getPropertyValue('color'), 'red');
    });

    test('15', () {
      CSSRule? rule = parseSingleRule(' .foo {}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
    });

    test('16', () {
      CSSRule? rule = parseSingleRule(' .foo { margin: 64px 0 32px; text-align: center;}');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
    });

    test('17', () {
      CSSRule? rule = parseSingleRule(' .foo { width: calc(100% - 100px); }');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
    });

    test('18', () {
      CSSRule? rule = parseSingleRule(' .foo { --x: red; }');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
    });

    test('19', () {
      CSSRule? rule = parseSingleRule(' .foo { transform: translate(30px, 20px) rotate(20deg); }');
      CSSStyleRule styleRule = rule as CSSStyleRule;
      expect(styleRule.selectorGroup.selectorText, '.foo');
    });

    test('20', () {
      CSSStyleSheet sheet = CSSParser('#header { color: red; h1 { font-size: 26px; }}').parse();
      CSSStyleRule styleRule1 = sheet.cssRules[0] as CSSStyleRule;
      CSSStyleRule styleRule2 = sheet.cssRules[1] as CSSStyleRule;
      final visitor = SelectorTextVisitor();
      visitor.visitSelectorGroup(styleRule1.selectorGroup);
      expect(visitor.toString(), '#header');
      expect(styleRule1.declaration.getPropertyValue('color'), 'red');
      visitor.visitSelectorGroup(styleRule2.selectorGroup);
      expect(visitor.toString(), '#header h1');
      expect(styleRule2.declaration.getPropertyValue('fontSize'), '26px');
    });

    test('21', () {
      CSSStyleSheet sheet = CSSParser('''#header {
          background: -webkit-linear-gradient(right, #00cf37 0, #45dc6d 100%);
          background: -o-linear-gradient(right, #00cf37 0, #45dc6d 100%);
          background: linear-gradient(270deg, #00cf37 0, #45dc6d 100%);
          }''').parse();
      CSSStyleRule styleRule = sheet.cssRules[0] as CSSStyleRule;
      expect(styleRule.declaration.getPropertyValue('backgroundImage'),
          'linear-gradient(270deg, #00cf37 0, #45dc6d 100%)');
    });
  });
}
