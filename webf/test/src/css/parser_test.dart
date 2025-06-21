/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:test/test.dart';

void main() {
  group('CSSParser', () {
    group('Declaration parsing with identifier processing', () {
      test('should handle identifier processing correctly when resetProperty is false', () {
        final parser = CSSParser('div { color: red; font-size: 16px; }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.declaration.getPropertyValue('color'), 'red');
        expect(rule.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle identifier processing when resetProperty is true after semicolon', () {
        final parser = CSSParser('div { color: red; ; font-size: 16px; }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.declaration.getPropertyValue('color'), 'red');
        expect(rule.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle multiple identifiers in declaration correctly', () {
        final parser = CSSParser('div { color red blue; font-size: 16px; }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle malformed declarations with identifier processing', () {
        final parser = CSSParser('div { color red; font-size: 16px; }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle identifier after newline in declaration', () {
        final parser = CSSParser('''div { 
          color: red;
          
          font-size: 16px; 
        }''');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.declaration.getPropertyValue('color'), 'red');
        expect(rule.declaration.getPropertyValue('fontSize'), '16px');
      });
    });

    group('Media directive rule processing', () {
      test('should break from media rule processing when processRule returns null', () {
        final parser = CSSParser('@media screen { .foo { color: red; } }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.selectorGroup.selectorText, '.foo');
        expect(rule.declaration.getPropertyValue('color'), 'red');
      });

      test('should handle empty media directive correctly', () {
        final parser = CSSParser('@media screen { }');
        final stylesheet = parser.parse();
        
        // Should not have any rules since media directive is empty
        expect(stylesheet.cssRules.length, 0);
      });

      test('should handle media directive with valid rules', () {
        final parser = CSSParser('@media screen { .foo { color: red; } }');
        final stylesheet = parser.parse();
        
        // Should process valid rules
        expect(stylesheet.cssRules.length, 1);
        final rule = stylesheet.cssRules[0] as CSSStyleRule;
        expect(rule.selectorGroup.selectorText, '.foo');
        expect(rule.declaration.getPropertyValue('color'), 'red');
      });

      test('should handle media directive with multiple rules', () {
        final parser = CSSParser('@media screen { .foo { color: red; } .bar { font-size: 16px; } }');
        final stylesheet = parser.parse();
        
        expect(stylesheet.cssRules.length, 2);
        final rule1 = stylesheet.cssRules[0] as CSSStyleRule;
        final rule2 = stylesheet.cssRules[1] as CSSStyleRule;
        
        expect(rule1.selectorGroup.selectorText, '.foo');
        expect(rule1.declaration.getPropertyValue('color'), 'red');
        expect(rule2.selectorGroup.selectorText, '.bar');
        expect(rule2.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle complex media directive processing', () {
        final parser = CSSParser('@media screen { .foo { color: red; } .bar { font-size: 16px; } }');
        final stylesheet = parser.parse();
        
        // Should handle media directives properly
        expect(stylesheet.cssRules.length, 2);
        final rule1 = stylesheet.cssRules[0] as CSSStyleRule;
        final rule2 = stylesheet.cssRules[1] as CSSStyleRule;
        
        expect(rule1.selectorGroup.selectorText, '.foo');
        expect(rule1.declaration.getPropertyValue('color'), 'red');
        expect(rule2.selectorGroup.selectorText, '.bar');
        expect(rule2.declaration.getPropertyValue('fontSize'), '16px');
      });

      test('should handle malformed media directive gracefully', () {
        final parser = CSSParser('@media screen { .foo { color: red; } invalid-syntax .bar { font-size: 16px; } }');
        final stylesheet = parser.parse();
        
        // Should process valid rules and handle malformed ones gracefully
        expect(stylesheet.cssRules.length, 2);
        final rule1 = stylesheet.cssRules[0] as CSSStyleRule;
        final rule2 = stylesheet.cssRules[1] as CSSStyleRule;
        
        expect(rule1.selectorGroup.selectorText, '.foo');
        expect(rule1.declaration.getPropertyValue('color'), 'red');
        expect(rule2.selectorGroup.selectorText, 'invalid-syntax .bar');
        expect(rule2.declaration.getPropertyValue('fontSize'), '16px');
      });
    });

    group('Edge cases and error handling', () {
      test('should handle completely empty CSS', () {
        final parser = CSSParser('');
        final stylesheet = parser.parse();
        expect(stylesheet.cssRules.length, 0);
      });

      test('should handle CSS with only whitespace', () {
        final parser = CSSParser('   \n\t  \n  ');
        final stylesheet = parser.parse();
        expect(stylesheet.cssRules.length, 0);
      });

      test('should handle CSS with only comments', () {
        final parser = CSSParser('/* comment only */');
        final stylesheet = parser.parse();
        expect(stylesheet.cssRules.length, 0);
      });
    });
  });
}