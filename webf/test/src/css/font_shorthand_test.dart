import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS font shorthand', () {
    test('parses italic small-caps 13pt Helvetica', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty('font', 'italic small-caps 13pt Helvetica');

      expect(style.getPropertyValue('fontStyle'), 'italic');
      expect(style.getPropertyValue('fontVariant'), 'small-caps');
      expect(style.getPropertyValue('fontSize'), '13pt');
      expect(style.getPropertyValue('fontFamily'), 'Helvetica');
    });

    test('ignores normal placeholder before size', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty('font', 'oblique normal 700 18px/200% sans-serif');

      expect(style.getPropertyValue('fontStyle'), 'oblique');
      expect(style.getPropertyValue('fontVariant'), '');
      expect(style.getPropertyValue('fontWeight'), '700');
      expect(style.getPropertyValue('fontSize'), '18px');
      expect(style.getPropertyValue('lineHeight'), '200%');
      expect(style.getPropertyValue('fontFamily'), 'sans-serif');
    });

    test('font-variant longhand parses small-caps', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      // CSSParser camelizes property names; CSSStyleDeclaration stores camelCase keys.
      style.setProperty('fontVariant', 'small-caps');
      expect(style.getPropertyValue('fontVariant'), 'small-caps');
    });

    test('font-variant longhand parses multiple keywords', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty('fontVariant', 'oldstyle-nums tabular-nums slashed-zero');
      expect(style.getPropertyValue('fontVariant'), 'oldstyle-nums tabular-nums slashed-zero');
    });

    test('font-variant longhand rejects unknown keyword', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();
      style.setProperty('fontVariant', 'small-caps definitely-not-a-keyword');
      expect(style.getPropertyValue('fontVariant'), '');
    });
  });
}
