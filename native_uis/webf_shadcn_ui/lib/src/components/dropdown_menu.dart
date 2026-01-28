/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'dropdown_menu_bindings_generated.dart';

/// WebF custom element that provides a dropdown menu.
///
/// Exposed as `<flutter-shadcn-dropdown-menu>` in the DOM.
class FlutterShadcnDropdownMenu extends FlutterShadcnDropdownMenuBindings {
  FlutterShadcnDropdownMenu(super.context);

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
  WebFWidgetElementState createState() => FlutterShadcnDropdownMenuState(this);
}

class FlutterShadcnDropdownMenuState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuState(super.widgetElement);

  final _popoverController = ShadPopoverController();

  @override
  FlutterShadcnDropdownMenu get widgetElement =>
      super.widgetElement as FlutterShadcnDropdownMenu;

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
    final trigger = _findSlot<FlutterShadcnDropdownMenuTrigger>();
    final content = _findSlot<FlutterShadcnDropdownMenuContent>();

    if (trigger == null) {
      return const SizedBox.shrink();
    }

    // Sync controller
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

/// WebF custom element for dropdown menu trigger.
class FlutterShadcnDropdownMenuTrigger extends WidgetElement {
  FlutterShadcnDropdownMenuTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDropdownMenuTriggerState(this);
}

class FlutterShadcnDropdownMenuTriggerState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuTriggerState(super.widgetElement);

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

/// WebF custom element for dropdown menu content.
class FlutterShadcnDropdownMenuContent extends WidgetElement {
  FlutterShadcnDropdownMenuContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDropdownMenuContentState(this);
}

class FlutterShadcnDropdownMenuContentState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuContentState(super.widgetElement);

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

/// WebF custom element for dropdown menu item.
class FlutterShadcnDropdownMenuItem extends WidgetElement {
  FlutterShadcnDropdownMenuItem(super.context);

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

  static StaticDefinedBindingPropertyMap flutterShadcnDropdownMenuItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnDropdownMenuItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnDropdownMenuItem>(element).disabled = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnDropdownMenuItemProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDropdownMenuItemState(this);
}

class FlutterShadcnDropdownMenuItemState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuItemState(super.widgetElement);

  bool _isHovered = false;

  @override
  FlutterShadcnDropdownMenuItem get widgetElement =>
      super.widgetElement as FlutterShadcnDropdownMenuItem;

  void _closeMenu() {
    final menu = widgetElement.parentNode?.parentNode;
    if (menu is FlutterShadcnDropdownMenu) {
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

/// WebF custom element for dropdown menu separator.
class FlutterShadcnDropdownMenuSeparator extends WidgetElement {
  FlutterShadcnDropdownMenuSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDropdownMenuSeparatorState(this);
}

class FlutterShadcnDropdownMenuSeparatorState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuSeparatorState(super.widgetElement);

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

/// WebF custom element for dropdown menu label.
class FlutterShadcnDropdownMenuLabel extends WidgetElement {
  FlutterShadcnDropdownMenuLabel(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDropdownMenuLabelState(this);
}

class FlutterShadcnDropdownMenuLabelState extends WebFWidgetElementState {
  FlutterShadcnDropdownMenuLabelState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DefaultTextStyle(
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.foreground,
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
