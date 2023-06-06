/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';

final List<String> supportedFonts = [
  'ttc',
  'ttf',
  'otf'
];

class _Font {
  String src;
  String format;
  _Font(this.src, this.format);
}

class CSSFontFace {
  static void resolveFontFaceRules(CSSFontFaceRule fontFaceRule, int contextId) async {
    CSSStyleDeclaration declaration = fontFaceRule.declarations;
    String fontFamily = declaration.getPropertyValue('fontFamily');
    String url = declaration.getPropertyValue('src');
    if (fontFamily.isNotEmpty && url.isNotEmpty && CSSFunction.isFunction(url)) {
      String? tmp_src;
      List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(url);

      List<_Font> fonts = [];

      for(int i = 0; i < functions.length; i ++) {
        CSSFunctionalNotation notation = functions[i];
        if (notation.name == 'url') {
          tmp_src = notation.args[0];

          tmp_src = removeQuotationMark(tmp_src);

          String formatFromExt = tmp_src.split('.').last;
          fonts.add(_Font(tmp_src, formatFromExt));
        }
      }

      _Font? targetFont = fonts.firstWhereOrNull((f) {
        return supportedFonts.contains(f.format);
      });

      if (targetFont == null) return;

      try {
        WebFBundle bundle = WebFBundle.fromUrl(targetFont.src);
        await bundle.resolve(contextId);
        assert(bundle.isResolved, 'Failed to obtain $url');
        FontLoader loader = FontLoader(fontFamily);
        Future<ByteData> bytes = Future.value(bundle.data?.buffer.asByteData());
        loader.addFont(bytes);
        loader.load();
      } catch(e) {
        return;
      }
    }
  }
}
