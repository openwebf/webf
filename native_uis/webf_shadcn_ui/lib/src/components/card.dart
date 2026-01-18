/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

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

  Widget? _findSlot<T>() {
    final node =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return WebFWidgetElementChild(child: node.toWidget());
    }
    return null;
  }

  List<Widget> _getContentChildren() {
    return widgetElement.childNodes
        .where((node) =>
            node is! FlutterShadcnCardHeader &&
            node is! FlutterShadcnCardContent &&
            node is! FlutterShadcnCardFooter)
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final header = _findSlot<FlutterShadcnCardHeader>();
    final content = _findSlot<FlutterShadcnCardContent>();
    final footer = _findSlot<FlutterShadcnCardFooter>();
    final otherChildren = _getContentChildren();

    Widget? effectiveContent = content;
    if (content == null && otherChildren.isNotEmpty) {
      effectiveContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: otherChildren,
      );
    }

    return ShadCard(
      title: header,
      child: effectiveContent,
      footer: footer,
    );
  }
}

/// WebF custom element for card header.
///
/// Exposed as `<flutter-shadcn-card-header>` in the DOM.
class FlutterShadcnCardHeader extends WidgetElement {
  FlutterShadcnCardHeader(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardHeaderState(this);
}

class FlutterShadcnCardHeaderState extends WebFWidgetElementState {
  FlutterShadcnCardHeaderState(super.widgetElement);

  Widget? _findSlot<T>() {
    final node =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return WebFWidgetElementChild(child: node.toWidget());
    }
    return null;
  }

  List<Widget> _getOtherChildren() {
    return widgetElement.childNodes
        .where((node) =>
            node is! FlutterShadcnCardTitle &&
            node is! FlutterShadcnCardDescription)
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _findSlot<FlutterShadcnCardTitle>();
    final description = _findSlot<FlutterShadcnCardDescription>();
    final others = _getOtherChildren();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title,
        if (description != null) ...[
          const SizedBox(height: 4),
          description,
        ],
        ...others,
      ],
    );
  }
}

/// WebF custom element for card title.
///
/// Exposed as `<flutter-shadcn-card-title>` in the DOM.
class FlutterShadcnCardTitle extends WidgetElement {
  FlutterShadcnCardTitle(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnCardTitleState(this);
}

class FlutterShadcnCardTitleState extends WebFWidgetElementState {
  FlutterShadcnCardTitleState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.h4,
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}

/// WebF custom element for card description.
///
/// Exposed as `<flutter-shadcn-card-description>` in the DOM.
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
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.muted,
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
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
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
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
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}
