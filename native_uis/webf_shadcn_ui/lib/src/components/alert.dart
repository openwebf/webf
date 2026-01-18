/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'alert_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadAlert].
///
/// Exposed as `<flutter-shadcn-alert>` in the DOM.
class FlutterShadcnAlert extends FlutterShadcnAlertBindings {
  FlutterShadcnAlert(super.context);

  String _variant = 'default';
  String? _icon;

  @override
  String get variant => _variant;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get icon => _icon;

  @override
  set icon(value) {
    final newValue = value?.toString();
    if (newValue != _icon) {
      _icon = newValue;
      state?.requestUpdateState(() {});
    }
  }

  ShadAlertVariant get alertVariant {
    switch (_variant.toLowerCase()) {
      case 'destructive':
        return ShadAlertVariant.destructive;
      default:
        return ShadAlertVariant.primary;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnAlertState(this);
}

class FlutterShadcnAlertState extends WebFWidgetElementState {
  FlutterShadcnAlertState(super.widgetElement);

  @override
  FlutterShadcnAlert get widgetElement =>
      super.widgetElement as FlutterShadcnAlert;

  Widget? _findSlot<T>() {
    final node =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return WebFWidgetElementChild(child: node.toWidget());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _findSlot<FlutterShadcnAlertTitle>();
    final description = _findSlot<FlutterShadcnAlertDescription>();

    // Use named constructors based on variant
    if (widgetElement.alertVariant == ShadAlertVariant.destructive) {
      return ShadAlert.destructive(
        title: title,
        description: description,
      );
    }

    return ShadAlert(
      title: title,
      description: description,
    );
  }
}

/// WebF custom element for alert title.
///
/// Exposed as `<flutter-shadcn-alert-title>` in the DOM.
class FlutterShadcnAlertTitle extends WidgetElement {
  FlutterShadcnAlertTitle(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnAlertTitleState(this);
}

class FlutterShadcnAlertTitleState extends WebFWidgetElementState {
  FlutterShadcnAlertTitleState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'SPAN',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}

/// WebF custom element for alert description.
///
/// Exposed as `<flutter-shadcn-alert-description>` in the DOM.
class FlutterShadcnAlertDescription extends WidgetElement {
  FlutterShadcnAlertDescription(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnAlertDescriptionState(this);
}

class FlutterShadcnAlertDescriptionState extends WebFWidgetElementState {
  FlutterShadcnAlertDescriptionState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'SPAN',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}
