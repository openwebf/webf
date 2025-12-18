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

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#content_sectioning

const String ADDRESS = 'ADDRESS';
const String ARTICLE = 'ARTICLE';
const String ASIDE = 'ASIDE';
const String FOOTER = 'FOOTER';
const String HEADER = 'HEADER';
const String MAIN = 'MAIN';
const String NAV = 'NAV';
const String SECTION = 'SECTION';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

const Map<String, dynamic> _addressDefaultStyle = {DISPLAY: BLOCK, FONT_STYLE: ITALIC};

class AddressElement extends Element {
  AddressElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _addressDefaultStyle;
}

class ArticleElement extends Element {
  ArticleElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class AsideElement extends Element {
  AsideElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class FooterElement extends Element {
  FooterElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class HeaderElement extends Element {
  HeaderElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class MainElement extends Element {
  MainElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class NavElement extends Element {
  NavElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class SectionElement extends Element {
  SectionElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
