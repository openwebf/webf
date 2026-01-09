import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSSStyleDeclaration.union', () {
    test('inline wins over sheet when same importance', () {
      final ElementCSSStyleDeclaration target = ElementCSSStyleDeclaration();
      target.enqueueInlineProperty(COLOR, 'red');

      final CSSStyleDeclaration sheet = CSSStyleDeclaration.sheet();
      sheet.setProperty(COLOR, 'blue');

      target.union(sheet);
      expect(target.getPropertyValue(COLOR), 'red');
    });

    test('sheet overrides sheet when same importance', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red');

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'blue');

      a.union(b);
      expect(a.getPropertyValue(COLOR), 'blue');
    });

    test('important beats non-important', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red', isImportant: true);

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'blue');

      a.union(b);
      expect(a.getPropertyValue(COLOR), 'red');
    });

    test('important overrides non-important', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red');

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'blue', isImportant: true);

      a.union(b);
      expect(a.getPropertyValue(COLOR), 'blue');
    });

    test('important inline wins over important sheet', () {
      final ElementCSSStyleDeclaration target = ElementCSSStyleDeclaration();
      target.enqueueInlineProperty(COLOR, 'red', isImportant: true);

      final CSSStyleDeclaration sheet = CSSStyleDeclaration.sheet();
      sheet.setProperty(COLOR, 'blue', isImportant: true);

      target.union(sheet);
      expect(target.getPropertyValue(COLOR), 'red');
    });
  });

  group('CSSStyleDeclaration.merge', () {
    test('updates changed property values', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red');

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'blue');

      expect(a.merge(b), isTrue);
      expect(a.getPropertyValue(COLOR), 'blue');
    });

    test('removes properties missing from other', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red');

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();

      expect(a.merge(b), isTrue);
      expect(a.getPropertyValue(COLOR), EMPTY_STRING);
      expect(a.length, 0);
    });

    test('adds properties present only on other', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'blue');

      expect(a.merge(b), isTrue);
      expect(a.getPropertyValue(COLOR), 'blue');
    });

    test('returns false when no effective changes', () {
      final CSSStyleDeclaration a = CSSStyleDeclaration.sheet();
      a.setProperty(COLOR, 'red');

      final CSSStyleDeclaration b = CSSStyleDeclaration.sheet();
      b.setProperty(COLOR, 'red');

      expect(a.merge(b), isFalse);
    });

    test('stages empty values when other explicitly clears a missing property', () {
      final ElementCSSStyleDeclaration current = ElementCSSStyleDeclaration();

      final ElementCSSStyleDeclaration other = ElementCSSStyleDeclaration();
      other.removeProperty(COLOR);

      expect(current.length, 0);
      expect(other.length, 1);

      expect(current.merge(other), isTrue);
      expect(current.getPropertyValue(COLOR), EMPTY_STRING);
      expect(current.length, 1);
    });
  });
}

