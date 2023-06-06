/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

final RegExp matchPseudoContentRegExp = RegExp(r'''["']([\s\S]+)?["']''');

class QuoteStringContentValue {
  String value;
  QuoteStringContentValue(this.value);
}

class FunctionContentValue {
  List<CSSFunctionalNotation> functions;
  FunctionContentValue(this.functions);
}

class KeywordContentValue {
  String value;
  KeywordContentValue(this.value);
}

class CSSPseudo {
  static dynamic resolveContent(String? content) {
    if (content == null) return null;

    if (matchPseudoContentRegExp.hasMatch(content)) {
      RegExpMatch? match = matchPseudoContentRegExp.firstMatch(content);
      return QuoteStringContentValue(match?[1] ?? '');
    }

    if (CSSFunction.isFunction(content)) {
      return FunctionContentValue(CSSFunction.parseFunction(content));
    }

    return KeywordContentValue(content);
  }
}
