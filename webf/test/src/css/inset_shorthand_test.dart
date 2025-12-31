import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS inset shorthand', () {
    test('expands 1 value', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '20px');

      expect(style.getPropertyValue(TOP), '20px');
      expect(style.getPropertyValue(RIGHT), '20px');
      expect(style.getPropertyValue(BOTTOM), '20px');
      expect(style.getPropertyValue(LEFT), '20px');
    });

    test('expands 2 values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '10px 20px');

      expect(style.getPropertyValue(TOP), '10px');
      expect(style.getPropertyValue(RIGHT), '20px');
      expect(style.getPropertyValue(BOTTOM), '10px');
      expect(style.getPropertyValue(LEFT), '20px');
    });

    test('expands 3 values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '5px 10px 15px');

      expect(style.getPropertyValue(TOP), '5px');
      expect(style.getPropertyValue(RIGHT), '10px');
      expect(style.getPropertyValue(BOTTOM), '15px');
      expect(style.getPropertyValue(LEFT), '10px');
    });

    test('expands 4 values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '1px 2px 3px 4px');

      expect(style.getPropertyValue(TOP), '1px');
      expect(style.getPropertyValue(RIGHT), '2px');
      expect(style.getPropertyValue(BOTTOM), '3px');
      expect(style.getPropertyValue(LEFT), '4px');
    });

    test('accepts calc() tokens', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, 'calc(10px + 5%)');

      expect(style.getPropertyValue(TOP), 'calc(10px + 5%)');
      expect(style.getPropertyValue(RIGHT), 'calc(10px + 5%)');
      expect(style.getPropertyValue(BOTTOM), 'calc(10px + 5%)');
      expect(style.getPropertyValue(LEFT), 'calc(10px + 5%)');
    });

    test('removes to initial longhands', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '20px');
      style.removeProperty(INSET);

      expect(style.getPropertyValue(TOP), AUTO);
      expect(style.getPropertyValue(RIGHT), AUTO);
      expect(style.getPropertyValue(BOTTOM), AUTO);
      expect(style.getPropertyValue(LEFT), AUTO);
    });

    test('ignores invalid inset values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(INSET, '20px');

      style.setProperty(INSET, '20px not-a-length');
      expect(style.getPropertyValue(TOP), '20px');
      expect(style.getPropertyValue(RIGHT), '20px');
      expect(style.getPropertyValue(BOTTOM), '20px');
      expect(style.getPropertyValue(LEFT), '20px');
    });
  });
}

