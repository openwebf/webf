/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

/// Helper to extract text content from nodes recursively.
String _extractTextContent(Iterable<Node> nodes) {
  final buffer = StringBuffer();
  for (final node in nodes) {
    if (node is TextNode) {
      buffer.write(node.data);
    } else if (node.childNodes.isNotEmpty) {
      buffer.write(_extractTextContent(node.childNodes));
    }
  }
  return buffer.toString().trim();
}

/// WebF custom element that wraps shadcn_ui [ShadCard].
///
/// Exposed as `<flutter-shadcn-card>` in the DOM.
class FlutterShadcnCard extends WidgetElement {
  FlutterShadcnCard(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardState(this);
}

class FlutterShadcnCardState extends WebFWidgetElementState {
  FlutterShadcnCardState(super.widgetElement);

  @override
  FlutterShadcnCard get widgetElement =>
      super.widgetElement as FlutterShadcnCard;

  T? _findSlot<T>() {
    // First check direct children
    final directNode =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (directNode != null) {
      return directNode as T;
    }
    return null;
  }

  T? _findSlotInHeader<T>(FlutterShadcnCardHeader header) {
    final node = header.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return node as T;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final header = _findSlot<FlutterShadcnCardHeader>();
    final content = _findSlot<FlutterShadcnCardContent>();
    final footer = _findSlot<FlutterShadcnCardFooter>();

    // Extract title and description from header
    Widget? titleWidget;
    Widget? descriptionWidget;

    if (header != null) {
      final titleElement = _findSlotInHeader<FlutterShadcnCardTitle>(header);
      final descElement = _findSlotInHeader<FlutterShadcnCardDescription>(header);

      if (titleElement != null) {
        final titleText = _extractTextContent(titleElement.childNodes);
        if (titleText.isNotEmpty) {
          titleWidget = Text(titleText);
        }
      }

      if (descElement != null) {
        final descText = _extractTextContent(descElement.childNodes);
        if (descText.isNotEmpty) {
          descriptionWidget = Text(descText);
        }
      }
    }

    // Build content widget with vertical padding like the official examples
    Widget? contentWidget;
    if (content != null) {
      contentWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: WebFWidgetElementChild(
          child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: content,
            children: content.childNodes.toWidgetList(),
          ),
        ),
      );
    }

    // Build footer widget
    Widget? footerWidget;
    if (footer != null) {
      footerWidget = WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: footer,
          children: footer.childNodes.toWidgetList(),
        ),
      );
    }

    return ShadCard(
      title: titleWidget,
      description: descriptionWidget,
      child: contentWidget,
      footer: footerWidget,
      // Stretch children to full width so footer layout works correctly
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }
}

/// WebF custom element for card header.
///
/// Exposed as `<flutter-shadcn-card-header>` in the DOM.
/// This is a structural element - its children (title, description) are
/// extracted by the parent Card.
class FlutterShadcnCardHeader extends WidgetElement {
  FlutterShadcnCardHeader(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardHeaderState(this);
}

class FlutterShadcnCardHeaderState extends WebFWidgetElementState {
  FlutterShadcnCardHeaderState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is not rendered directly - it's processed by the parent Card
    // Return an empty container as a placeholder
    return const SizedBox.shrink();
  }
}

/// WebF custom element for card title.
///
/// Exposed as `<flutter-shadcn-card-title>` in the DOM.
/// The text content is extracted by the parent Card and styled properly.
class FlutterShadcnCardTitle extends WidgetElement {
  FlutterShadcnCardTitle(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardTitleState(this);
}

class FlutterShadcnCardTitleState extends WebFWidgetElementState {
  FlutterShadcnCardTitleState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is not rendered directly - it's processed by the parent Card
    return const SizedBox.shrink();
  }
}

/// WebF custom element for card description.
///
/// Exposed as `<flutter-shadcn-card-description>` in the DOM.
/// The text content is extracted by the parent Card and styled properly.
class FlutterShadcnCardDescription extends WidgetElement {
  FlutterShadcnCardDescription(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnCardDescriptionState(this);
}

class FlutterShadcnCardDescriptionState extends WebFWidgetElementState {
  FlutterShadcnCardDescriptionState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is not rendered directly - it's processed by the parent Card
    return const SizedBox.shrink();
  }
}

/// WebF custom element for card content.
///
/// Exposed as `<flutter-shadcn-card-content>` in the DOM.
class FlutterShadcnCardContent extends WidgetElement {
  FlutterShadcnCardContent(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardContentState(this);
}

class FlutterShadcnCardContentState extends WebFWidgetElementState {
  FlutterShadcnCardContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is not rendered directly - it's processed by the parent Card
    return const SizedBox.shrink();
  }
}

/// WebF custom element for card footer.
///
/// Exposed as `<flutter-shadcn-card-footer>` in the DOM.
class FlutterShadcnCardFooter extends WidgetElement {
  FlutterShadcnCardFooter(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardFooterState(this);
}

class FlutterShadcnCardFooterState extends WebFWidgetElementState {
  FlutterShadcnCardFooterState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is not rendered directly - it's processed by the parent Card
    return const SizedBox.shrink();
  }
}
