/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';
import 'package:webf/src/css/whitespace_processor.dart';
import 'text_bindings_generated.dart';

const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

const TEXT = 'TEXT';

class WebFTextElement extends WebFTextBindings {
  WebFTextElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return WebFTextState(this);
  }

  void notifyRootTextElement() {
    if (state == null) {
      // When a TextNode changes, we need to update all ancestor WebFTextElement elements
      // because they may include this text in their nested TextSpan structure
      dom.Node? currentNode = parentNode;
      while (currentNode != null) {
        if (currentNode is WebFTextElement) {
          // If state is not available yet, we need to ensure the update happens when it becomes available
          if (currentNode.state != null) {
            currentNode.state!.requestUpdateState();
          }
        }
        currentNode = currentNode.parentNode;
      }
    } else {
      state!.requestUpdateState();
    }
  }

  @override
  void childrenChanged(dom.ChildrenChange change) {
    super.childrenChanged(change);
    notifyRootTextElement();
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
    final double fs = renderStyle.fontSize.computedValue;
    final double nonNegativeFontSize = fs.isFinite && fs >= 0 ? fs : 0.0;
    TextStyle textStyle = TextStyle(
        color: renderStyle.backgroundClip != CSSBackgroundBoundary.text ? renderStyle.color.value : null,
        decoration: renderStyle.textDecorationLine,
        decorationColor: renderStyle.textDecorationColor?.value,
        decorationStyle: renderStyle.textDecorationStyle,
        fontWeight: renderStyle.fontWeight,
        fontStyle: renderStyle.fontStyle,
        fontFamilyFallback: renderStyle.fontFamily,
        fontSize: nonNegativeFontSize,
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

    for (var node in childNodes) {
      if (node is dom.TextNode) {
        // Process whitespace according to the parent element's white-space property
        final processedText = WhitespaceProcessor.processPhaseOne(node.data, renderStyle.whiteSpace);
        textSpanChildren.add(TextSpan(text: processedText));
      } else if (node is dom.Element && node is WebFTextElement) {
        textSpanChildren.add(node.createTextSpan(node.childNodes));
      }
    }

    TextSpan textSpan = TextSpan(style: createTextStyle(renderStyle), children: textSpanChildren);

    return textSpan;
  }
}

class WebFTextState extends WebFWidgetElementState {
  WebFTextState(super.widgetElement);

  @override
  WebFTextElement get widgetElement => super.widgetElement as WebFTextElement;

  @override
  void initState() {
    super.initState();
    _ensureFontsLoaded();
  }

  void _ensureFontsLoaded() async {
    // Ensure fonts are loaded for the text element and its children
    await _loadFontsForElement(widgetElement);
  }

  Future<void> _loadFontsForElement(dom.Element element) async {
    // Load font for this element
    List<String>? fontFamilies = element.renderStyle.fontFamily;
    if (fontFamilies != null && fontFamilies.isNotEmpty) {
      String primaryFontFamily = fontFamilies[0];
      await CSSFontFace.ensureFontLoaded(primaryFontFamily, element.renderStyle.fontWeight, element.renderStyle);
    }

    // Load fonts for child elements
    for (final node in element.childNodes) {
      if (node is WebFTextElement) {
        await _loadFontsForElement(node);
      }
    }

    // Trigger a rebuild if fonts were loaded
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double lineHeight =
        widgetElement.renderStyle.lineHeight.computedValue / widgetElement.renderStyle.fontSize.computedValue;
    return RichText(
        textScaler: widgetElement.renderStyle.textScaler,
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
