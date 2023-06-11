/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

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

    if (content.startsWith('\'') || content.startsWith('"')) {
      String trimContent = removeQuotationMark(content);

      if (trimContent.startsWith('\\')) {
        int value = int.parse(trimContent.substring(1), radix: 16);
        trimContent = String.fromCharCode(value);
      }

      return QuoteStringContentValue(trimContent);
    }

    if (CSSFunction.isFunction(content)) {
      return FunctionContentValue(CSSFunction.parseFunction(content));
    }

    return KeywordContentValue(content);
  }
}
