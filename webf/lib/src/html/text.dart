/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';

const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

// White space processing in CSS affects only the document white space characters:
// spaces (U+0020), tabs (U+0009), and segment breaks.
// Carriage returns (U+000D) are treated identically to spaces (U+0020) in all respects.
// https://drafts.csswg.org/css-text/#white-space-rules
final String _documentWhiteSpace = '\u0020\u0009\u000A\u000D';
final RegExp _collapseWhiteSpaceReg = RegExp(r'[' + _documentWhiteSpace + r']+');
final RegExp _trimLeftWhitespaceReg = RegExp(r'^[' + _documentWhiteSpace + r']([^' + _documentWhiteSpace + r']+)');
final RegExp _trimRightWhitespaceReg = RegExp(r'([^' + _documentWhiteSpace + r']+)[' + _documentWhiteSpace + r']$');

const TEXT = 'TEXT';

class WebFTextElement extends WidgetElement {
  WebFTextElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return WebFTextState(this);
  }

  // '  a b  c   \n' => ' a b c '
  static String _collapseWhitespace(String string) {
    return string.replaceAll(_collapseWhiteSpaceReg, WHITE_SPACE_CHAR);
  }

  // '   a b c' => 'a b c'
  static String _trimLeftWhitespace(String string) {
    return string.replaceAllMapped(_trimLeftWhitespaceReg, (Match m) => '${m[1]}');
  }

  // 'a b c    ' => 'a b c'
  static String _trimRightWhitespace(String string) {
    return string.replaceAllMapped(_trimRightWhitespaceReg, (Match m) => '${m[1]}');
  }

  static TextStyle createTextStyle(CSSRenderStyle renderStyle) {
    // Creates a new TextStyle object.
    //   color: The color to use when painting the text. If this is specified, foreground must be null.
    //   decoration: The decorations to paint near the text (e.g., an underline).
    //   decorationColor: The color in which to paint the text decorations.
    //   decorationStyle: The style in which to paint the text decorations (e.g., dashed).
    //   fontWeight: The typeface thickness to use when painting the text (e.g., bold).
    //   fontStyle: The typeface variant to use when drawing the letters (e.g., italics).
    //   fontSize: The size of glyphs (in logical pixels) to use when painting the text.
    //   letterSpacing: The amount of space (in logical pixels) to add between each letter.
    //   wordSpacing: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between /// each word).
    //   textBaseline: The common baseline that should be aligned between this text span and its parent text span, /// or, for the root text spans, with the line box.
    //   height: The height of this text span, as a multiple of the font size.
    //   locale: The locale used to select region-specific glyphs.
    //   background: The paint drawn as a background for the text.
    //   foreground: The paint used to draw the text. If this is specified, color must be null.
    TextStyle textStyle = TextStyle(
        color: renderStyle.backgroundClip != CSSBackgroundBoundary.text ? renderStyle.color.value : null,
        decoration: renderStyle.textDecorationLine,
        decorationColor: renderStyle.textDecorationColor?.value,
        decorationStyle: renderStyle.textDecorationStyle,
        fontWeight: renderStyle.fontWeight,
        fontStyle: renderStyle.fontStyle,
        fontFamilyFallback: renderStyle.fontFamily,
        fontSize: renderStyle.fontSize.computedValue,
        letterSpacing: renderStyle.letterSpacing?.computedValue,
        wordSpacing: renderStyle.wordSpacing?.computedValue,
        shadows: renderStyle.textShadow,
        textBaseline: CSSText.getTextBaseLine(),
        package: CSSText.getFontPackage(),
        locale: CSSText.getLocale(),
        background: CSSText.getBackground(),
        foreground: CSSText.getForeground());
    return textStyle;
  }

  TextSpan createTextSpan(dom.ChildNodeList childNodes) {
    List<InlineSpan> textSpanChildren = [];

    childNodes.forEach((node) {
      if (node is dom.TextNode) {
        textSpanChildren.add(TextSpan(text: _collapseWhitespace(node.data)));
      } else if (node is dom.Element && node is WebFTextElement) {
        textSpanChildren.add(node.createTextSpan(node.childNodes));
      }
    });

    TextSpan textSpan = TextSpan(style: createTextStyle(renderStyle), children: textSpanChildren);

    return textSpan;
  }
}

class WebFTextState extends WebFWidgetElementState {
  WebFTextState(super.widgetElement);

  @override
  WebFTextElement get widgetElement => super.widgetElement as WebFTextElement;

  @override
  Widget build(BuildContext context) {
    double lineHeight =
        widgetElement.renderStyle.lineHeight.computedValue / widgetElement.renderStyle.fontSize.computedValue;
    return RichText(
        text: widgetElement.createTextSpan(widgetElement.childNodes),
        textAlign: widgetElement.renderStyle.textAlign,
        overflow: widgetElement.renderStyle.textOverflow,
        maxLines: widgetElement.renderStyle.lineClamp,
        strutStyle: StrutStyle(
            // fontSize: widgetElement.renderStyle.fontSize.computedValue,
            height: lineHeight,
            fontFamilyFallback: widgetElement.renderStyle.fontFamily,
            fontStyle: widgetElement.renderStyle.fontStyle
        ));
  }
}
