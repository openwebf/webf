import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS background shorthand', () {
    test('parses trailing `text` as background-clip', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();

      style.setProperty(
        'background',
        'linear-gradient(90deg, #a8edea 0%, #fed6e3 100%) text',
      );

      expect(style.getPropertyValue('backgroundClip'), 'text');
      expect(style.getPropertyValue('backgroundOrigin'), 'padding-box');
    });

    test('dynamic shorthand update keeps clip text when provided', () {
      final CSSStyleDeclaration style = CSSStyleDeclaration();

      style.setProperty('background', 'linear-gradient(45deg, #ff6b6b, #4ecdc4)');
      style.setProperty('backgroundClip', 'text');

      style.setProperty(
        'background',
        'linear-gradient(90deg, #a8edea 0%, #fed6e3 100%) text',
      );

      expect(style.getPropertyValue('backgroundClip'), 'text');
    });
  });
}
