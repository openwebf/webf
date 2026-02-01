import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS gap invalid values', () {
    test('ignores invalid gap token', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10px');

      style.setProperty(GAP, 'invalid');
      expect(style.getPropertyValue(ROW_GAP), '10px');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });

    test('ignores invalid negative gap token', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10px');

      style.setProperty(GAP, '-10px');
      expect(style.getPropertyValue(ROW_GAP), '10px');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });

    test('accepts percentage gap', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, '10%');

      expect(style.getPropertyValue(ROW_GAP), '10%');
      expect(style.getPropertyValue(COLUMN_GAP), '10%');
    });

    test('accepts calc() in two-value gap', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty(GAP, 'calc(10px + 5px) 10px');

      expect(style.getPropertyValue(ROW_GAP), 'calc(10px + 5px)');
      expect(style.getPropertyValue(COLUMN_GAP), '10px');
    });
  });
}
