import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';

import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('CSSStyleDeclaration CSSOM property names', () {
    test('accepts kebab-case property names', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();

      style.setProperty('background-color', 'blue', isImportant: true);

      expect(style.getPropertyValue('background-color'), 'blue');
      expect(style.getPropertyValue(BACKGROUND_COLOR), 'blue');
      expect(style.isImportant('background-color'), isTrue);
      expect(style.isImportant(BACKGROUND_COLOR), isTrue);
    });
  });

  group('CSSStyleDeclaration.union', () {
    test('adopts important declarations into an empty receiver', () {
      final CSSStyleDeclaration current = CSSStyleDeclaration();
      final CSSStyleDeclaration incoming = CSSStyleDeclaration();

      incoming.setProperty(COLOR, 'red', isImportant: true);
      incoming.setProperty(WIDTH, '10px');

      current.union(incoming);

      expect(current.getPropertyValue(COLOR), 'red');
      expect(current.isImportant(COLOR), isTrue);
      expect(current.getPropertyValue(WIDTH), '10px');
    });

    test('overlays non-important pending declarations directly', () {
      final CSSStyleDeclaration current = CSSStyleDeclaration();
      final CSSStyleDeclaration first = CSSStyleDeclaration();
      final CSSStyleDeclaration second = CSSStyleDeclaration();

      first.setProperty(COLOR, 'red');
      second.setProperty(COLOR, 'blue');
      second.setProperty(WIDTH, '10px');

      current.union(first);
      current.union(second);

      expect(current.getPropertyValue(COLOR), 'blue');
      expect(current.getPropertyValue(WIDTH), '10px');
      expect(current.isImportant(COLOR), isFalse);
    });
  });

  group('CSSStyleDeclaration.merge', () {
    test('removes missing non-inherited properties to their initial value', () {
      final CSSStyleDeclaration current = CSSStyleDeclaration();
      final CSSStyleDeclaration next = CSSStyleDeclaration();

      current.setProperty(WIDTH, '10px');

      expect(current.merge(next), isTrue);
      expect(current.getPropertyValue(WIDTH), 'auto');
    });

    test('preserves non-important fallback values for later removals', () {
      final CSSStyleDeclaration current = CSSStyleDeclaration();
      final CSSStyleDeclaration next = CSSStyleDeclaration();

      next.setProperty(COLOR, 'red');

      expect(current.merge(next), isTrue);
      current.removeProperty(COLOR, true);

      expect(current.getPropertyValue(COLOR), 'red');
    });
  });

  group('CSSStyleDeclaration.flushPendingProperties', () {
    CSSStyleDeclaration createStyle(List<String> flushedProperties) {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.target = HTMLElement(null);
      style.onStyleFlushed =
          (List<String> properties) => flushedProperties.addAll(properties);
      return style;
    }

    test('flushes custom properties before dependent properties', () {
      final List<String> flushedProperties = <String>[];
      final CSSStyleDeclaration style = createStyle(flushedProperties);

      style.setProperty(COLOR, 'var(--tone)');
      style.setProperty('--tone', 'red');
      style.flushPendingProperties();

      expect(flushedProperties, <String>['--tone', COLOR]);
    });

    test('preserves priority property flush order', () {
      final List<String> flushedProperties = <String>[];
      final CSSStyleDeclaration style = createStyle(flushedProperties);

      style.setProperty(FONT_SIZE, '16px');
      style.setProperty(COLOR, 'red');
      style.setProperty(WIDTH, '10px');
      style.setProperty(HEIGHT, '20px');
      style.flushPendingProperties();

      expect(flushedProperties, <String>[HEIGHT, WIDTH, COLOR, FONT_SIZE]);
    });
  });
}
