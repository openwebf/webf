/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'context_menu_bindings_generated.dart';

/// WebF custom element for context menus.
///
/// Exposed as `<flutter-shadcn-context-menu>` in the DOM.
class FlutterShadcnContextMenu extends FlutterShadcnContextMenuBindings {
  FlutterShadcnContextMenu(super.context);

  bool _open = false;

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
  WebFWidgetElementState createState() => FlutterShadcnContextMenuState(this);
}

class FlutterShadcnContextMenuState extends WebFWidgetElementState {
  FlutterShadcnContextMenuState(super.widgetElement);

  Offset _menuPosition = Offset.zero;

  @override
  FlutterShadcnContextMenu get widgetElement =>
      super.widgetElement as FlutterShadcnContextMenu;

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
    final trigger = _findSlot<FlutterShadcnContextMenuTrigger>();
    final content = _findSlot<FlutterShadcnContextMenuContent>();

    if (trigger == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _menuPosition = details.globalPosition;
        widgetElement.open = true;
      },
      child: Stack(
        children: [
          trigger,
          if (widgetElement.open && content != null)
            Positioned(
              left: _menuPosition.dx,
              top: _menuPosition.dy,
              child: GestureDetector(
                onTap: () {
                  widgetElement.open = false;
                },
                child: content,
              ),
            ),
        ],
      ),
    );
  }
}

/// WebF custom element for context menu trigger.
class FlutterShadcnContextMenuTrigger extends WidgetElement {
  FlutterShadcnContextMenuTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuTriggerState(this);
}

class FlutterShadcnContextMenuTriggerState extends WebFWidgetElementState {
  FlutterShadcnContextMenuTriggerState(super.widgetElement);

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

/// WebF custom element for context menu content.
class FlutterShadcnContextMenuContent extends WidgetElement {
  FlutterShadcnContextMenuContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuContentState(this);
}

class FlutterShadcnContextMenuContentState extends WebFWidgetElementState {
  FlutterShadcnContextMenuContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetElement.childNodes
            .map((node) => WebFWidgetElementChild(child: node.toWidget()))
            .toList(),
      ),
    );
  }
}

/// WebF custom element for context menu item.
class FlutterShadcnContextMenuItem extends WidgetElement {
  FlutterShadcnContextMenuItem(super.context);

  bool _disabled = false;

  bool get disabled => _disabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuItem>(element).disabled = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuItemProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuItemState(this);
}

class FlutterShadcnContextMenuItemState extends WebFWidgetElementState {
  FlutterShadcnContextMenuItemState(super.widgetElement);

  bool _isHovered = false;

  @override
  FlutterShadcnContextMenuItem get widgetElement =>
      super.widgetElement as FlutterShadcnContextMenuItem;

  void _closeMenu() {
    final menu = widgetElement.parentNode?.parentNode;
    if (menu is FlutterShadcnContextMenu) {
      menu.open = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDisabled = widgetElement.disabled;

    return MouseRegion(
      onEnter: (_) {
        if (!isDisabled) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                widgetElement.dispatchEvent(Event('select'));
                _closeMenu();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: _isHovered ? theme.colorScheme.accent : null,
          child: DefaultTextStyle(
            style: theme.textTheme.small.copyWith(
              color: isDisabled
                  ? theme.colorScheme.mutedForeground
                  : theme.colorScheme.foreground,
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
        ),
      ),
    );
  }
}

/// WebF custom element for context menu separator.
class FlutterShadcnContextMenuSeparator extends WidgetElement {
  FlutterShadcnContextMenuSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuSeparatorState(this);
}

class FlutterShadcnContextMenuSeparatorState extends WebFWidgetElementState {
  FlutterShadcnContextMenuSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.border,
    );
  }
}
