import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:webf/css.dart';

List<CSSStyleRule> _prepareMatchedStyleRules(String css) {
  final sheet = CSSParser(css).parse();
  final tree = CascadeLayerTree();

  var pos = 0;
  final styleRules = <CSSStyleRule>[];

  void visitRule(CSSRule r) {
    r.position = pos++;
    if (r is CSSLayerStatementRule) {
      tree.declareAll(r.layerNamePaths);
      return;
    }
    if (r is CSSLayerBlockRule) {
      // Ensure the layer is declared even if the block is empty.
      if (r.layerNamePath.isNotEmpty) {
        tree.declare(r.layerNamePath);
      }
      // Cascade order is based on flattened document order of style rules.
      for (final child in r.cssRules) {
        visitRule(child);
      }
      return;
    }
    if (r is CSSStyleRule) {
      if (r.layerPath.isNotEmpty) {
        r.layerOrderKey = tree.declare(r.layerPath);
      } else {
        r.layerOrderKey = null;
      }
      final maxSpec = r.selectorGroup.selectors
          .fold<int>(0, (m, s) => math.max(m, s.specificity));
      r.selectorGroup.matchSpecificity = maxSpec;
      styleRules.add(r);
    }
  }

  for (final r in sheet.cssRules) {
    visitRule(r);
  }

  return styleRules;
}

String? _cascadeColor(String css) {
  final rules = _prepareMatchedStyleRules(css);
  final decl = cascadeMatchedStyleRules(rules);
  return decl.getPropertyValue('color');
}

void main() {
  group('@layer cascade', () {
    test('unlayered overrides layered', () {
      expect(_cascadeColor('''
        @layer a { .x { color: red; } }
        .x { color: green; }
      '''), 'green');
    });

    test('unlayered overrides layered (layer later)', () {
      expect(_cascadeColor('''
        .x { color: green; }
        @layer a { .x { color: red; } }
      '''), 'green');
    });

    test('later layer overrides earlier layer (normal)', () {
      expect(_cascadeColor('''
        @layer a { .x { color: red; } }
        @layer b { .x { color: green; } }
      '''), 'green');
    });

    test('layer order statement affects cascade', () {
      expect(_cascadeColor('''
        @layer b, a;
        @layer a { .x { color: red; } }
        @layer b { .x { color: green; } }
      '''), 'red');
    });

    test('!important reverses layer order', () {
      expect(_cascadeColor('''
        @layer a { .x { color: red !important; } }
        @layer b { .x { color: green !important; } }
      '''), 'red');
    });

    test('unlayered !important is lowest among important', () {
      expect(_cascadeColor('''
        .x { color: green !important; }
        @layer a { .x { color: red !important; } }
      '''), 'red');
    });

    test('nested sublayer comes after parent layer (normal)', () {
      expect(_cascadeColor('''
        @layer a {
          .x { color: red; }
          @layer b { .x { color: green; } }
        }
      '''), 'red');
    });
  });

  group('@layer parser', () {
    test('named layer block assigns layerPath', () {
      final sheet = CSSParser('@layer a { .x { color: red; } }').parse();
      final blocks = sheet.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(blocks, hasLength(1));
      final rules = blocks.first.cssRules.whereType<CSSStyleRule>().toList();
      expect(rules, hasLength(1));
      expect(rules.first.layerPath, <String>['a', kWebFImplicitLayerSegment]);
    });

    test('anonymous layer block assigns synthetic layerPath segment', () {
      final sheet = CSSParser('@layer { .x { color: red; } }').parse();
      final blocks = sheet.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(blocks, hasLength(1));
      final rules = blocks.first.cssRules.whereType<CSSStyleRule>().toList();
      expect(rules, hasLength(1));
      expect(rules.first.layerPath, isNotEmpty);
      expect(rules.first.layerPath.first, startsWith('__webf_anon_layer_'));
      expect(rules.first.layerPath.last, kWebFImplicitLayerSegment);
    });

    test('nested layer block composes layerPath', () {
      final sheet =
          CSSParser('@layer a { @layer b { .x { color: red; } } }').parse();
      final outerBlocks =
          sheet.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(outerBlocks, hasLength(1));
      final innerBlocks =
          outerBlocks.first.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(innerBlocks, hasLength(1));
      final rules =
          innerBlocks.first.cssRules.whereType<CSSStyleRule>().toList();
      expect(rules, hasLength(1));
      expect(
          rules.first.layerPath, <String>['a', 'b', kWebFImplicitLayerSegment]);
    });

    test('nested layer name is always relative (qualified names are prefixed)',
        () {
      final sheet =
          CSSParser('@layer a { @layer a.b { .x { color: red; } } }').parse();
      final outerBlocks =
          sheet.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(outerBlocks, hasLength(1));
      final innerBlocks =
          outerBlocks.first.cssRules.whereType<CSSLayerBlockRule>().toList();
      expect(innerBlocks, hasLength(1));
      final rules =
          innerBlocks.first.cssRules.whereType<CSSStyleRule>().toList();
      expect(rules, hasLength(1));
      expect(rules.first.layerPath,
          <String>['a', 'a', 'b', kWebFImplicitLayerSegment]);
    });
  });
}
