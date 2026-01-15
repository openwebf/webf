import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS gap shorthand', () {
    test('expands 1 value', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '20px');

      expect(style.getPropertyValue(ROW_GAP), '20px');
      expect(style.getPropertyValue(COLUMN_GAP), '20px');
    });

    test('expands 2 values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '20px 10px');

      expect(style.getPropertyValue(ROW_GAP), '20px');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });

    test('accepts percentage values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10% 20%');

      expect(style.getPropertyValue(ROW_GAP), '10%');
      expect(style.getPropertyValue(COLUMN_GAP), '20%');
    });

    test('ignores invalid gap values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10px');

      style.setProperty(GAP, 'invalid');
      expect(style.getPropertyValue(ROW_GAP), '10px');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });

    test('ignores negative gap values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10px');

      style.setProperty(GAP, '-1px');
      expect(style.getPropertyValue(ROW_GAP), '10px');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });
  });

  group('CSS row-gap/column-gap', () {
    test('ignores invalid longhand values', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(ROW_GAP, '10px');
      style.setProperty(COLUMN_GAP, '12px');

      style.setProperty(ROW_GAP, 'invalid');
      style.setProperty(COLUMN_GAP, 'invalid');
      expect(style.getPropertyValue(ROW_GAP), '10px');
      expect(style.getPropertyValue(COLUMN_GAP), '12px');
    });
  });
}

