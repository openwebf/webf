/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

/// WebF custom element that provides breadcrumb navigation.
///
/// Exposed as `<flutter-shadcn-breadcrumb>` in the DOM.
class FlutterShadcnBreadcrumb extends WidgetElement {
  FlutterShadcnBreadcrumb(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnBreadcrumbState(this);
}

class FlutterShadcnBreadcrumbState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'NAV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}

/// WebF custom element for breadcrumb list.
class FlutterShadcnBreadcrumbList extends WidgetElement {
  FlutterShadcnBreadcrumbList(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbListState(this);
}

class FlutterShadcnBreadcrumbListState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbListState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgetElement.childNodes
          .map((node) => WebFWidgetElementChild(child: node.toWidget()))
          .toList(),
    );
  }
}

/// WebF custom element for breadcrumb item.
class FlutterShadcnBreadcrumbItem extends WidgetElement {
  FlutterShadcnBreadcrumbItem(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbItemState(this);
}

class FlutterShadcnBreadcrumbItemState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgetElement.childNodes
          .map((node) => WebFWidgetElementChild(child: node.toWidget()))
          .toList(),
    );
  }
}

/// WebF custom element for breadcrumb link.
class FlutterShadcnBreadcrumbLink extends WidgetElement {
  FlutterShadcnBreadcrumbLink(super.context);

  String? _href;

  String? get href => _href;

  set href(value) {
    final newValue = value?.toString();
    if (newValue != _href) {
      _href = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['href'] = ElementAttributeProperty(
      getter: () => href,
      setter: (v) => href = v,
      deleter: () => href = null,
    );
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbLinkState(this);
}

class FlutterShadcnBreadcrumbLinkState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbLinkState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumbLink get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumbLink;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: () {
        widgetElement.dispatchEvent(Event('click'));
      },
      child: DefaultTextStyle(
        style: theme.textTheme.small.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
        child: WebFWidgetElementChild(
          child: WebFHTMLElement(
            tagName: 'SPAN',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList(),
          ),
        ),
      ),
    );
  }
}

/// WebF custom element for current breadcrumb page.
class FlutterShadcnBreadcrumbPage extends WidgetElement {
  FlutterShadcnBreadcrumbPage(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbPageState(this);
}

class FlutterShadcnBreadcrumbPageState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbPageState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.small.copyWith(
        color: theme.colorScheme.foreground,
        fontWeight: FontWeight.w500,
      ),
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

/// WebF custom element for breadcrumb separator.
class FlutterShadcnBreadcrumbSeparator extends WidgetElement {
  FlutterShadcnBreadcrumbSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbSeparatorState(this);
}

class FlutterShadcnBreadcrumbSeparatorState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
