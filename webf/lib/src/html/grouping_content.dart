/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#text_content
const String UL = 'UL';
const String OL = 'OL';
const String LI = 'LI';
const String DL = 'DL';
const String DT = 'DT';
const String DD = 'DD';
const String FIGURE = 'FIGURE';
const String FIGCAPTION = 'FIGCAPTION';
const String BLOCKQUOTE = 'BLOCKQUOTE';
const String PRE = 'PRE';
const String PARAGRAPH = 'P';
const String DIV = 'DIV';
// TODO: <hr> element

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

const Map<String, dynamic> _preDefaultStyle = {
  DISPLAY: BLOCK,
  WHITE_SPACE: 'pre',
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
};

const Map<String, dynamic> _bDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
  // Logical margins to remain symmetric under RTL/LTR.
  MARGIN_INLINE_START: '40px',
  MARGIN_INLINE_END: '40px'
};

const Map<String, dynamic> _ddDefaultStyle = {
  DISPLAY: BLOCK,
  // Term descriptions are indented on the inline-start side per UA stylesheet.
  MARGIN_INLINE_START: '40px',
};

Map<String, dynamic> _pDefaultStyle = {DISPLAY: BLOCK, MARGIN_TOP: '1em', MARGIN_BOTTOM: '1em'};

const Map<String, dynamic> _lDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
  // Use logical property so inline-start padding follows writing direction.
  PADDING_INLINE_START: '40px'
};

class DivElement extends Element {
  DivElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class FigureElement extends Element {
  FigureElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _bDefaultStyle;
}

class FigureCaptionElement extends Element {
  FigureCaptionElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class BlockQuotationElement extends Element {
  BlockQuotationElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _bDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlparagraphelement
class ParagraphElement extends Element {
  ParagraphElement([super.context]);
  @override
  Map<String, dynamic> get defaultStyle => _pDefaultStyle;
}

void debugOverridePDefaultStyle(Map<String, dynamic> newStyle) {
  _pDefaultStyle = newStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlulistelement
class UListElement extends Element {
  UListElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _lDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlolistelement
class OListElement extends Element {
  OListElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _lDefaultStyle;
}

class LIElement extends Element {
  LIElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // Only synthesize ::before markers for list-style-position: inside.
  // For the default outside position, markers are painted by renderer
  // as separate marker boxes and must not participate in IFC.
  @override
  void applyStyle(CSSStyleDeclaration style) {
    // 1) Apply element default styles (UA defaults).
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((propertyName, value) {
        if (style.contains(propertyName) == false) {
          style.setProperty(propertyName, value);
        }
      });
    }

    // 2) Initialize display early so layout can proceed even before flush.
    renderStyle.initDisplay(style);

    // 4) Attribute styles (none for LI currently but keep for completeness).
    applyAttributeStyle(style);

    // 5) Inline styles (highest priority among author styles).
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, value) {
        style.setProperty(propertyName, value, isImportant: true);
      });
    }

    // 6) Stylesheet rules matching this element.
    final ElementRuleCollector collector = ElementRuleCollector();
    final CSSStyleDeclaration matchRule = collector.collectionFromRuleSet(ownerDocument.ruleSet, this);
    style.union(matchRule);

    // 7) Pseudo rules (::before/::after) from stylesheets to override defaults.
    final List<CSSStyleRule> pseudoRules = collector.matchedPseudoRules(ownerDocument.ruleSet, this);
    style.handlePseudoRules(this, pseudoRules);

    // 8) List marker generation based on list-style-type
    String getProp(CSSStyleDeclaration s, String camel, String kebab) {
      final v1 = s.getPropertyValue(camel);
      if (v1.isNotEmpty) return v1;
      return s.getPropertyValue(kebab);
    }

    String? effectiveListStyleType() {
      // Check self
      String t = getProp(style, 'listStyleType', 'list-style-type');
      if (t.isNotEmpty) return t;
      // Check parent
      if (parentElement != null) {
        String pt = getProp(parentElement!.style, 'listStyleType', 'list-style-type');
        if (pt.isNotEmpty) return pt;
      }
      // Defaults by parent tag
      if (parentElement is OListElement) return 'decimal';
      if (parentElement is UListElement) return 'disc';
      return null;
    }

    int indexWithinList() {
      final p = parentElement;
      if (p == null) return 1;
      int idx = 0;
      for (final child in p.children) {
        if (child is LIElement) idx++;
        if (identical(child, this)) break;
      }
      return idx == 0 ? 1 : idx;
    }

    String toAlpha(int n, {bool upper = false}) {
      // 1->a, 26->z, 27->aa
      int num = n;
      StringBuffer sb = StringBuffer();
      while (num > 0) {
        num--; // make it 0-based
        int rem = num % 26;
        sb.writeCharCode((upper ? 65 : 97) + rem);
        num ~/= 26;
      }
      return sb.toString().split('').reversed.join();
    }

    String toRoman(int n, {bool upper = false}) {
      if (n <= 0) return upper ? 'N' : 'n';
      final List<List<dynamic>> map = [
        [1000, 'M'],
        [900, 'CM'],
        [500, 'D'],
        [400, 'CD'],
        [100, 'C'],
        [90, 'XC'],
        [50, 'L'],
        [40, 'XL'],
        [10, 'X'],
        [9, 'IX'],
        [5, 'V'],
        [4, 'IV'],
        [1, 'I'],
      ];
      int num = n;
      StringBuffer sb = StringBuffer();
      for (final pair in map) {
        int val = pair[0] as int;
        String sym = pair[1] as String;
        while (num >= val) {
          sb.write(sym);
          num -= val;
        }
      }
      String s = sb.toString();
      return upper ? s : s.toLowerCase();
    }

    void ensurePseudo() {
      style.pseudoBeforeStyle ??= CSSStyleDeclaration();
    }

    String effectiveListStylePosition() {
      String p = getProp(style, 'listStylePosition', 'list-style-position');
      if (p.isNotEmpty) return p;
      if (parentElement != null) {
        String pp = getProp(parentElement!.style, 'listStylePosition', 'list-style-position');
        if (pp.isNotEmpty) return pp;
      }
      return 'outside';
    }

    final type = effectiveListStyleType();
    final pos = effectiveListStylePosition();
    if (type != null) {
      if (pos == 'inside') {
        // Only set when author didn't explicitly set ::before content
        final hasAuthorContent = style.pseudoBeforeStyle?.getPropertyValue(CONTENT).isNotEmpty == true;
        if (!hasAuthorContent) {
          if (type == 'none') {
            // no marker
            if (style.pseudoBeforeStyle != null) {
              style.pseudoBeforeStyle!.setProperty(CONTENT, '');
            }
          } else if (type == 'disc') {
            // bullet
            ensurePseudo();
            style.pseudoBeforeStyle!.setProperty(CONTENT, '"• "');
          } else {
            // ordered styles
            final idx = indexWithinList();
            String marker;
            switch (type) {
              case 'decimal':
                marker = idx.toString();
                break;
              case 'lower-alpha':
                marker = toAlpha(idx, upper: false);
                break;
              case 'upper-alpha':
                marker = toAlpha(idx, upper: true);
                break;
              case 'lower-roman':
                marker = toRoman(idx, upper: false);
                break;
              case 'upper-roman':
                marker = toRoman(idx, upper: true);
                break;
              default:
                marker = idx.toString();
                break;
            }
            ensurePseudo();
            style.pseudoBeforeStyle!.setProperty(CONTENT, '"$marker. "');
          }
        }
      } else {
        // Ensure no stale inside-style ::before remains when using outside markers
        if (style.pseudoBeforeStyle != null && style.pseudoBeforeStyle!.getPropertyValue(CONTENT).isNotEmpty) {
          style.pseudoBeforeStyle!.setProperty(CONTENT, '');
        }
      }
    }
  }
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlpreelement
class PreElement extends Element {
  PreElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _preDefaultStyle;
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dd
class DDElement extends Element {
  DDElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _ddDefaultStyle;
}

class DTElement extends Element {
  DTElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmldlistelement
class DListElement extends Element {
  DListElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _pDefaultStyle;
}
