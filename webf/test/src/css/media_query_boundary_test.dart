import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSSMediaDirective', () {
    test('min-width/max-width are inclusive', () {
      final sheet = CSSParser('''
        @media (min-width: 500px) { .a { color: green; } }
        @media (max-width: 300px) { .b { color: red; } }
      ''').parse(windowWidth: 300, windowHeight: 300, isDarkMode: false);

      // At width=300: max-width:300 matches, min-width:500 does not.
      expect(
        sheet.cssRules
            .whereType<CSSStyleRule>()
            .map((r) => r.selectorGroup.selectorText)
            .toList(),
        contains('.b'),
      );

      final sheet2 = CSSParser('''
        @media (min-width: 500px) { .a { color: green; } }
      ''').parse(windowWidth: 500, windowHeight: 300, isDarkMode: false);
      // At width=500: min-width:500 matches.
      expect(sheet2.cssRules.whereType<CSSStyleRule>().length, 1);
    });
  });
}
