/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'collapsible_bindings_generated.dart';

/// WebF custom element for collapsible sections.
///
/// Exposed as `<flutter-shadcn-collapsible>` in the DOM.
class FlutterShadcnCollapsible extends FlutterShadcnCollapsibleBindings {
  FlutterShadcnCollapsible(super.context);

  bool _open = false;
  bool _disabled = false;

  @override
  bool get open => _open;

  @override
  set open(value) {
    final newValue = value == true;
    if (newValue != _open) {
      _open = newValue;
      dispatchEvent(Event('change'));
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnCollapsibleState(this);
}

class FlutterShadcnCollapsibleState extends WebFWidgetElementState {
  FlutterShadcnCollapsibleState(super.widgetElement);

  Offset? _tapDownPosition;

  @override
  FlutterShadcnCollapsible get widgetElement =>
      super.widgetElement as FlutterShadcnCollapsible;

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
    final trigger = _findSlot<FlutterShadcnCollapsibleTrigger>();
    final content = _findSlot<FlutterShadcnCollapsibleContent>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trigger != null)
          // Use Listener instead of GestureDetector to avoid gesture arena
          // conflicts with interactive child widgets (e.g. ShadButton).
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: widgetElement.disabled
                ? null
                : (event) {
                    _tapDownPosition = event.position;
                  },
            onPointerUp: widgetElement.disabled
                ? null
                : (event) {
                    if (_tapDownPosition != null) {
                      final distance =
                          (event.position - _tapDownPosition!).distance;
                      _tapDownPosition = null;
                      if (distance < 20) {
                        widgetElement.open = !widgetElement.open;
                      }
                    }
                  },
            onPointerCancel: (_) {
              _tapDownPosition = null;
            },
            child: trigger,
          ),
        if (widgetElement.open && content != null) content,
      ],
    );
  }
}

/// WebF custom element for collapsible trigger.
class FlutterShadcnCollapsibleTrigger extends WidgetElement {
  FlutterShadcnCollapsibleTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnCollapsibleTriggerState(this);
}

class FlutterShadcnCollapsibleTriggerState extends WebFWidgetElementState {
  FlutterShadcnCollapsibleTriggerState(super.widgetElement);

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

/// WebF custom element for collapsible content.
class FlutterShadcnCollapsibleContent extends WidgetElement {
  FlutterShadcnCollapsibleContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnCollapsibleContentState(this);
}

class FlutterShadcnCollapsibleContentState extends WebFWidgetElementState {
  FlutterShadcnCollapsibleContentState(super.widgetElement);

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
