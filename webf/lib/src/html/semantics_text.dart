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

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#inline_text_semantics
const String SPAN = 'SPAN';
const String B = 'B';
const String ABBR = 'ABBR';
const String EM = 'EM';
const String CITE = 'CITE';
const String I = 'I';
const String CODE = 'CODE';
const String SAMP = 'SAMP';
const String TT = 'TT';
const String STRONG = 'STRONG';
const String SMALL = 'SMALL';
const String S = 'S';
const String U = 'U';
const String VAR = 'VAR';
const String TIME = 'TIME';
const String DATA = 'DATA';
const String MARK = 'MARK';
const String Q = 'Q';
const String KBD = 'KBD';
const String DFN = 'DFN';
const String BR = 'BR';
const String HR = 'HR';
const String SUB = 'SUB';
const String SUP = 'SUP';

const Map<String, dynamic> _uDefaultStyle = {TEXT_DECORATION: UNDERLINE};

const Map<String, dynamic> _sDefaultStyle = {TEXT_DECORATION: LINE_THROUGH};

const Map<String, dynamic> _smallDefaultStyle = {FONT_SIZE: SMALLER};

const Map<String, dynamic> _subDefaultStyle = {
  DISPLAY: INLINE,
  // UA stylesheet behavior: subscripts are smaller and lowered
  FONT_SIZE: SMALLER,
  VERTICAL_ALIGN: TEXT_BOTTOM,
};

const Map<String, dynamic> _supDefaultStyle = {
  DISPLAY: INLINE,
  // UA stylesheet behavior: superscripts are smaller and raised
  FONT_SIZE: SMALLER,
  VERTICAL_ALIGN: TEXT_TOP,
};

const Map<String, dynamic> _codeDefaultStyle = {
  DISPLAY: INLINE,
  FONT_FAMILY: 'monospace'
};

const Map<String, dynamic> _boldDefaultStyle = {FONT_WEIGHT: BOLD};

const Map<String, dynamic> _abbrDefaultStyle = {
  TEXT_DECORATION_LINE: UNDERLINE,
  TEXT_DECORATION_STYLE: DOTTED,
};

const Map<String, dynamic> _emDefaultStyle = {
  DISPLAY: INLINE,
  FONT_STYLE: ITALIC
};

const Map<String, dynamic> _markDefaultStyle = {BACKGROUND_COLOR: 'yellow', COLOR: 'black'};

const Map<String, dynamic> _hrDefaultStyle = {
  DISPLAY: BLOCK,
  MARGIN: '1em 0',
  BORDER_WIDTH: '0.5px',
  BORDER_STYLE: SOLID,
  BORDER_COLOR: 'rgb(136,136,136)',
};

const Map<String, dynamic> _defaultStyle = {FONT_STYLE: ITALIC};

class BringElement extends Element {
  BringElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _boldDefaultStyle;
}

class AbbreviationElement extends Element {
  AbbreviationElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _abbrDefaultStyle;
}

class EmphasisElement extends Element {
  EmphasisElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _emDefaultStyle;
}

class CitationElement extends Element {
  CitationElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class DefinitionElement extends Element {
  DefinitionElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i
class IdiomaticElement extends Element {
  IdiomaticElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class CodeElement extends Element {
  CodeElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _codeDefaultStyle;
}

class SampleElement extends Element {
  SampleElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _codeDefaultStyle;
}

class KeyboardElement extends Element {
  KeyboardElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _codeDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/obsolete.html#the-tt-element
// The <tt> element is obsolete; for compatibility it maps to monospace font.
class TeletypeElement extends Element {
  TeletypeElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _codeDefaultStyle;
}

class SpanElement extends Element {
  SpanElement([super.context]);
}

class DataElement extends Element {
  DataElement([super.context]);
}

// TODO: enclosed text is a short inline quotation
class QuoteElement extends Element {
  QuoteElement([super.context]);
}

class StrongElement extends Element {
  StrongElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _boldDefaultStyle;
}

class TimeElement extends Element {
  TimeElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _boldDefaultStyle;
}

class SmallElement extends Element {
  SmallElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _smallDefaultStyle;
}

class StrikethroughElement extends Element {
  StrikethroughElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _sDefaultStyle;
}

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-u-element
class UnarticulatedElement extends Element {
  UnarticulatedElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _uDefaultStyle;
}

class VariableElement extends Element {
  VariableElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class MarkElement extends Element {
  MarkElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _markDefaultStyle;
}

class HRElement extends Element {
  HRElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _hrDefaultStyle;
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/sub
// Render subscripts with smaller font size and lowered baseline.
class SubscriptElement extends Element {
  SubscriptElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _subDefaultStyle;
}

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/sup
// Render superscripts with smaller font size and raised baseline.
class SuperscriptElement extends Element {
  SuperscriptElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _supDefaultStyle;
}
