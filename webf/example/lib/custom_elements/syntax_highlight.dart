import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

class FlutterSyntaxHighLight extends WidgetElement {
  FlutterSyntaxHighLight(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    String code = childNodes
        .whereType<TextNode>()
        .map((textNode) {
          return textNode.data;
        })
        .toList(growable: false)
        .join('\n');

    return HighlightView(
      // The original code to be highlighted
      code,

      // Specify language
      // It is recommended to give it a value for performance
      language: getAttribute('language'),

      // Specify highlight theme
      // All available themes are listed in `themes` folder
      theme: themeMap['github']!,

      // Specify padding
      padding: EdgeInsets.all(12),

      // Specify text style
      textStyle: TextStyle(
        fontFamily: 'My awesome monospace font',
        fontSize: 16,
      ),
    );
  }
}
