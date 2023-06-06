/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/foundation.dart';
import 'package:webf/svg.dart';

typedef ElementCreator = Element Function(BindingContext? context);

final HTML_ELEMENT_URI = 'http://www.w3.org/1999/xhtml';
final SVG_ELEMENT_URI = 'http://www.w3.org/2000/svg';
final MATHML_ELEMENT_URI = 'http://www.w3.org/1998/Math/MathML';

final Map<String, ElementCreator> _htmlRegistry = {};

final Map<String, ElementCreator> _svgRegistry = {};

final Map<String, Map<String, ElementCreator>> _registries = {};

class _UnknownHTMLElement extends HTMLElement {
  _UnknownHTMLElement([BindingContext? context]) : super(context);
}

class _UnknownNamespaceElement extends Element {
  _UnknownNamespaceElement([BindingContext? context]) : super(context);
}

void defineElement(String name, ElementCreator creator) {
  if (_htmlRegistry.containsKey(name)) {
    throw Exception('An element with name "$name" has already been defined.');
  }
  _htmlRegistry[name] = creator;
}

defineElementNS(String uri, String name, ElementCreator creator) {
  _registries[uri] ??= {};
  final registry = _registries[uri]!;
  if (registry.containsKey(name)) {
    throw Exception(
        'An element with uri "$uri" and name "$name" has already been defined.');
  }

  registry[name] = creator;
}

Element createElement(String name, [BindingContext? context]) {
  ElementCreator? creator = _htmlRegistry[name];
  Element element;
  if (creator == null) {
    print('Unexpected HTML element "$name"');

    element = _UnknownHTMLElement(context);
  } else {
    element = creator(context);
  }

  // Assign tagName, used by inspector.
  element.tagName = name;
  element.namespaceURI = HTML_ELEMENT_URI;
  return element;
}

Element createSvgElement(String name, [BindingContext? context]) {
  ElementCreator? creator = _svgRegistry[name];
  Element element;
  if (creator == null) {
    print('Unexpected SVG element "$name"');
    element = SVGUnknownElement(context);
  } else {
    element = creator(context);
  }

  element.tagName = name;
  element.namespaceURI = SVG_ELEMENT_URI;

  return element;
}

Element createElementNS(String uri, String name, [BindingContext? context]) {
  if (uri == HTML_ELEMENT_URI) {
    return createElement(name, context);
  }

  if (uri == SVG_ELEMENT_URI) {
    return createSvgElement(name, context);
  }

  final ElementCreator? creator = _registries[uri]?[name];
  Element element;

  if (creator == null) {
    print('Unexpected element "$name" of namespace "$uri"');

    element = _UnknownNamespaceElement(context);
  } else {
    element = creator(context);
  }

  element.tagName = name;
  element.namespaceURI = uri;
  return element;
}

bool _isDefined = false;
void defineBuiltInElements() {
  if (_isDefined) return;
  _isDefined = true;
  // Inline text
  defineElement(BR, (context) => BRElement(context));
  defineElement(B, (context) => BringElement(context));
  defineElement(ABBR, (context) => AbbreviationElement(context));
  defineElement(EM, (context) => EmphasisElement(context));
  defineElement(CITE, (context) => CitationElement(context));
  defineElement(I, (context) => IdiomaticElement(context));
  defineElement(CODE, (context) => CodeElement(context));
  defineElement(SAMP, (context) => SampleElement(context));
  defineElement(STRONG, (context) => StrongElement(context));
  defineElement(SMALL, (context) => SmallElement(context));
  defineElement(S, (context) => StrikethroughElement(context));
  defineElement(U, (context) => UnarticulatedElement(context));
  defineElement(VAR, (context) => VariableElement(context));
  defineElement(TIME, (context) => TimeElement(context));
  defineElement(DATA, (context) => DataElement(context));
  defineElement(MARK, (context) => MarkElement(context));
  defineElement(Q, (context) => QuoteElement(context));
  defineElement(KBD, (context) => KeyboardElement(context));
  defineElement(DFN, (context) => DefinitionElement(context));
  defineElement(SPAN, (context) => SpanElement(context));
  defineElement(ANCHOR, (context) => HTMLAnchorElement(context));
  // Content
  defineElement(PRE, (context) => PreElement(context));
  defineElement(PARAGRAPH, (context) => ParagraphElement(context));
  defineElement(DIV, (context) => DivElement(context));
  defineElement(UL, (context) => UListElement(context));
  defineElement(OL, (context) => OListElement(context));
  defineElement(LI, (context) => LIElement(context));
  defineElement(DL, (context) => DListElement(context));
  defineElement(DT, (context) => DTElement(context));
  defineElement(DD, (context) => DDElement(context));
  defineElement(FIGURE, (context) => FigureElement(context));
  defineElement(FIGCAPTION, (context) => FigureCaptionElement(context));
  defineElement(BLOCKQUOTE, (context) => BlockQuotationElement(context));
  defineElement(TEMPLATE, (context) => TemplateElement(context));
  // Sections
  defineElement(ADDRESS, (context) => AddressElement(context));
  defineElement(ARTICLE, (context) => ArticleElement(context));
  defineElement(ASIDE, (context) => AsideElement(context));
  defineElement(FOOTER, (context) => FooterElement(context));
  defineElement(HEADER, (context) => HeaderElement(context));
  defineElement(MAIN, (context) => MainElement(context));
  defineElement(NAV, (context) => NavElement(context));
  defineElement(SECTION, (context) => SectionElement(context));
  // Headings
  defineElement(H1, (context) => H1Element(context));
  defineElement(H2, (context) => H2Element(context));
  defineElement(H3, (context) => H3Element(context));
  defineElement(H4, (context) => H4Element(context));
  defineElement(H5, (context) => H5Element(context));
  defineElement(H6, (context) => H6Element(context));
  // Forms
  defineElement(LABEL, (context) => LabelElement(context));
  defineElement(BUTTON, (context) => ButtonElement(context));
  defineElement(INPUT, (context) => FlutterInputElement(context));
  defineElement(FORM, (context) => FlutterFormElement(context));
  defineElement(TEXTAREA, (context) => FlutterTextAreaElement(context));
  // Edits
  defineElement(DEL, (context) => DelElement(context));
  defineElement(INS, (context) => InsElement(context));
  // Head
  defineElement(HEAD, (context) => HeadElement(context));
  defineElement(TITLE, (context) => TitleElement(context));
  defineElement(META, (context) => MetaElement(context));
  defineElement(LINK, (context) => LinkElement(context));
  defineElement(STYLE, (context) => StyleElement(context));
  defineElement(NOSCRIPT, (context) => NoScriptElement(context));
  defineElement(SCRIPT, (context) => ScriptElement(context));
  // Others
  defineElement(HTML, (context) => HTMLElement(context));
  defineElement(BODY, (context) => BodyElement(context));
  defineElement(IMAGE, (context) => ImageElement(context));
  defineElement(CANVAS, (context) => CanvasElement(context));
  defineElement(LISTVIEW, (context) => FlutterListViewElement(context));

  svgElementsRegistry.forEach((key, value) {
    _svgRegistry[key.toUpperCase()] = value;
  });
}
