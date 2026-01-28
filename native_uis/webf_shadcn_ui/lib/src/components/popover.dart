/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'popover_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadPopover].
///
/// Exposed as `<flutter-shadcn-popover>` in the DOM.
class FlutterShadcnPopover extends FlutterShadcnPopoverBindings {
  FlutterShadcnPopover(super.context);

  bool _open = false;
  String _placement = 'bottom';
  bool _closeOnOutsideClick = true;

  @override
  bool get open => _open;

  @override
  set open(value) {
    final bool v = value == true;
    if (v != _open) {
      _open = v;
      if (_open) {
        dispatchEvent(Event('open'));
      } else {
        dispatchEvent(Event('close'));
      }
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get placement => _placement;

  @override
  set placement(value) {
    final String newValue = value?.toString() ?? 'bottom';
    if (newValue != _placement) {
      _placement = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get closeOnOutsideClick => _closeOnOutsideClick;

  @override
  set closeOnOutsideClick(value) {
    final bool v = value == true;
    if (v != _closeOnOutsideClick) {
      _closeOnOutsideClick = v;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnPopoverState(this);
}

class FlutterShadcnPopoverState extends WebFWidgetElementState {
  FlutterShadcnPopoverState(super.widgetElement);

  final _popoverController = ShadPopoverController();

  @override
  FlutterShadcnPopover get widgetElement =>
      super.widgetElement as FlutterShadcnPopover;

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

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
    final trigger = _findSlot<FlutterShadcnPopoverTrigger>();
    final content = _findSlot<FlutterShadcnPopoverContent>();

    if (trigger == null) {
      return const SizedBox.shrink();
    }

    // Sync controller with open state
    if (widgetElement.open && !_popoverController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popoverController.show();
      });
    } else if (!widgetElement.open && _popoverController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popoverController.hide();
      });
    }

    return ShadPopover(
      controller: _popoverController,
      popover: (context) => content ?? const SizedBox.shrink(),
      child: GestureDetector(
        onTap: () {
          widgetElement.open = !widgetElement.open;
        },
        child: trigger,
      ),
    );
  }
}

/// WebF custom element for popover trigger.
class FlutterShadcnPopoverTrigger extends WidgetElement {
  FlutterShadcnPopoverTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnPopoverTriggerState(this);
}

class FlutterShadcnPopoverTriggerState extends WebFWidgetElementState {
  FlutterShadcnPopoverTriggerState(super.widgetElement);

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

/// WebF custom element for popover content.
class FlutterShadcnPopoverContent extends WidgetElement {
  FlutterShadcnPopoverContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnPopoverContentState(this);
}

class FlutterShadcnPopoverContentState extends WebFWidgetElementState {
  FlutterShadcnPopoverContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}
