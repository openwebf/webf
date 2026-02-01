import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSSParser :is() selector parsing', () {
    test('parses selector list arguments', () {
      final sheet = CSSParser('div:is(#a, .b) { color: red; }').parse();
      expect(sheet.cssRules, hasLength(1));

      final rule = sheet.cssRules.first as CSSStyleRule;
      expect(rule.selectorGroup.selectorText, 'div:is(#a, .b)');

      final sequences = rule.selectorGroup.selectors.first.simpleSelectorSequences;
      expect(sequences[0].simpleSelector, isA<ElementSelector>());
      expect(sequences[1].simpleSelector, isA<PseudoClassFunctionSelector>());

      final pseudo = sequences[1].simpleSelector as PseudoClassFunctionSelector;
      expect(pseudo.name.toLowerCase(), 'is');
      expect(pseudo.argument, isA<SelectorGroup>());
      expect((pseudo.argument as SelectorGroup).selectorText, '#a, .b');
    });

    test('forgiving selector list drops empty items', () {
      final sheet = CSSParser('div:is(#a,) { color: red; }').parse();
      expect(sheet.cssRules, hasLength(1));

      final rule = sheet.cssRules.first as CSSStyleRule;
      expect(rule.selectorGroup.selectorText, 'div:is(#a)');
    });
  });
}
