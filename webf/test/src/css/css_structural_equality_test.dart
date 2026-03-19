import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSS structural equality', () {
    test(
        'declaration structural equality includes property value, importance and baseHref',
        () {
      final CSSStyleDeclaration left = CSSStyleDeclaration()
        ..setProperty(
          'backgroundImage',
          'url(foo.png)',
          baseHref: 'https://a.test/a.css',
        )
        ..setProperty('color', 'red', isImportant: true);
      final CSSStyleDeclaration right = CSSStyleDeclaration()
        ..setProperty(
          'backgroundImage',
          'url(foo.png)',
          baseHref: 'https://a.test/a.css',
        )
        ..setProperty('color', 'red', isImportant: true);
      final CSSStyleDeclaration differentBaseHref = CSSStyleDeclaration()
        ..setProperty(
          'backgroundImage',
          'url(foo.png)',
          baseHref: 'https://b.test/b.css',
        )
        ..setProperty('color', 'red', isImportant: true);

      expect(left == right, isFalse);
      expect(left.structurallyEquals(right), isTrue);
      expect(left.structuralHashCode, right.structuralHashCode);
      expect(left.structurallyEquals(differentBaseHref), isFalse);
    });

    test(
        'style rules from reparsed CSS compare structurally but not by identity',
        () {
      final CSSStyleRule left =
          CSSParser('@layer ui { .foo::before { color: red; } }')
              .parse()
              .cssRules
              .whereType<CSSLayerBlockRule>()
              .single
              .cssRules
              .whereType<CSSStyleRule>()
              .single;
      final CSSStyleRule right =
          CSSParser('@layer ui { .foo::before { color: red; } }')
              .parse()
              .cssRules
              .whereType<CSSLayerBlockRule>()
              .single
              .cssRules
              .whereType<CSSStyleRule>()
              .single;

      expect(left == right, isFalse);
      expect(left.structurallyEquals(right), isTrue);
      expect(left.structuralHashCode, right.structuralHashCode);
    });

    test('stylesheet structural equality survives reparsing and respects href',
        () {
      final CSSStyleSheet left = CSSParser(
        '.foo { background-image: url(foo.png); }',
        href: 'https://a.test/a.css',
      ).parse();
      final CSSStyleSheet same = CSSParser(
        '.foo { background-image: url(foo.png); }',
        href: 'https://a.test/a.css',
      ).parse();
      final CSSStyleSheet differentHref = CSSParser(
        '.foo { background-image: url(foo.png); }',
        href: 'https://b.test/b.css',
      ).parse();

      expect(left == same, isFalse);
      expect(left.structurallyEquals(same), isTrue);
      expect(left.structuralHashCode, same.structuralHashCode);
      expect(left.structurallyEquals(differentHref), isFalse);
    });

    test('rule list structural equality handles nested layer blocks', () {
      final List<CSSRule> left =
          CSSParser('@layer ui { @layer chrome { .foo { color: red; } } }')
              .parse()
              .cssRules;
      final List<CSSRule> right =
          CSSParser('@layer ui { @layer chrome { .foo { color: red; } } }')
              .parse()
              .cssRules;

      expect(cssRuleListsStructurallyEqual(left, right), isTrue);
      expect(cssRuleListStructuralHash(left), cssRuleListStructuralHash(right));
    });
  });
}
