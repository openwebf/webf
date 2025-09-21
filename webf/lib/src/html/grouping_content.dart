/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';

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
  MARGIN_LEFT: '40px',
  MARGIN_RIGHT: '40px'
};

const Map<String, dynamic> _ddDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_LEFT: '40px',
};

Map<String, dynamic> _pDefaultStyle = {DISPLAY: BLOCK, MARGIN_TOP: '1em', MARGIN_BOTTOM: '1em'};

const Map<String, dynamic> _lDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN_TOP: '1em',
  MARGIN_BOTTOM: '1em',
  PADDING_LEFT: '40px'
};

class DivElement extends Element {
  DivElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class FigureElement extends Element {
  FigureElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _bDefaultStyle;
}

class FigureCaptionElement extends Element {
  FigureCaptionElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class BlockQuotationElement extends Element {
  BlockQuotationElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _bDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlparagraphelement
class ParagraphElement extends Element {
  ParagraphElement([BindingContext? context]) : super(context);
  @override
  Map<String, dynamic> get defaultStyle => _pDefaultStyle;
}

void debugOverridePDefaultStyle(Map<String, dynamic> newStyle) {
  _pDefaultStyle = newStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlulistelement
class UListElement extends Element {
  UListElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _lDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlolistelement
class OListElement extends Element {
  OListElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _lDefaultStyle;
}

class LIElement extends Element {
  LIElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // Inject a default marker for UL > LI using ::before content.
  // This approximates UA list-style for unordered lists and respects RTL by
  // leveraging inline content order.
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

    // 3) Provide a default ::before bullet for UL list items.
    // Author styles can override via li::before { content: ... } since
    // handlePseudoRules() merges later with higher priority.
    if (parentElement is UListElement) {
      style.pseudoBeforeStyle ??= CSSStyleDeclaration();
      // Only set a default if author CSS hasn't already provided one.
      if (style.pseudoBeforeStyle!.getPropertyValue(CONTENT).isEmpty) {
        style.pseudoBeforeStyle!.setProperty(CONTENT, '"• "');
        // Make the bullet closer to UA disc size.
        if (style.pseudoBeforeStyle!.getPropertyValue(FONT_SIZE).isEmpty) {
          style.pseudoBeforeStyle!.setProperty(FONT_SIZE, '1.2em');
        }
      }
    }

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
  }
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlpreelement
class PreElement extends Element {
  PreElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _preDefaultStyle;
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dd
class DDElement extends Element {
  DDElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _ddDefaultStyle;
}

class DTElement extends Element {
  DTElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmldlistelement
class DListElement extends Element {
  DListElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _pDefaultStyle;
}
