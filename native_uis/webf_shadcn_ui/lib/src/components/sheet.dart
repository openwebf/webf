/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'sheet_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadSheet].
///
/// Exposed as `<flutter-shadcn-sheet>` in the DOM.
class FlutterShadcnSheet extends FlutterShadcnSheetBindings {
  FlutterShadcnSheet(super.context);

  bool _open = false;
  String _side = 'right';
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
  String get side => _side;

  @override
  set side(value) {
    final String newValue = value?.toString() ?? 'right';
    if (newValue != _side) {
      _side = newValue;
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

  ShadSheetSide get sheetSide {
    switch (_side.toLowerCase()) {
      case 'top':
        return ShadSheetSide.top;
      case 'bottom':
        return ShadSheetSide.bottom;
      case 'left':
        return ShadSheetSide.left;
      default:
        return ShadSheetSide.right;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSheetState(this);
}

class FlutterShadcnSheetState extends WebFWidgetElementState {
  FlutterShadcnSheetState(super.widgetElement);

  @override
  FlutterShadcnSheet get widgetElement =>
      super.widgetElement as FlutterShadcnSheet;

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
    if (!widgetElement.open) {
      return const SizedBox.shrink();
    }

    final header = _findSlot<FlutterShadcnSheetHeader>();
    final content = _findSlot<FlutterShadcnSheetContent>();
    final footer = _findSlot<FlutterShadcnSheetFooter>();

    final theme = ShadTheme.of(context);
    final side = widgetElement.sheetSide;

    final isHorizontal =
        side == ShadSheetSide.left || side == ShadSheetSide.right;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: widgetElement.closeOnOutsideClick
              ? () {
                  widgetElement.open = false;
                }
              : null,
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Sheet
        Positioned(
          top: side == ShadSheetSide.bottom ? null : 0,
          bottom: side == ShadSheetSide.top ? null : 0,
          left: side == ShadSheetSide.right ? null : 0,
          right: side == ShadSheetSide.left ? null : 0,
          child: Container(
            width: isHorizontal ? 320 : double.infinity,
            height: !isHorizontal ? 320 : double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  header,
                  const SizedBox(height: 16),
                ],
                if (content != null) Expanded(child: content),
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  footer,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// WebF custom element for sheet header.
class FlutterShadcnSheetHeader extends WidgetElement {
  FlutterShadcnSheetHeader(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnSheetHeaderState(this);
}

class FlutterShadcnSheetHeaderState extends WebFWidgetElementState {
  FlutterShadcnSheetHeaderState(super.widgetElement);

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
    final title = _findSlot<FlutterShadcnSheetTitle>();
    final description = _findSlot<FlutterShadcnSheetDescription>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title,
        if (description != null) ...[
          const SizedBox(height: 4),
          description,
        ],
      ],
    );
  }
}

/// WebF custom element for sheet title.
class FlutterShadcnSheetTitle extends WidgetElement {
  FlutterShadcnSheetTitle(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnSheetTitleState(this);
}

class FlutterShadcnSheetTitleState extends WebFWidgetElementState {
  FlutterShadcnSheetTitleState(super.widgetElement);

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

/// WebF custom element for sheet description.
class FlutterShadcnSheetDescription extends WidgetElement {
  FlutterShadcnSheetDescription(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnSheetDescriptionState(this);
}

class FlutterShadcnSheetDescriptionState extends WebFWidgetElementState {
  FlutterShadcnSheetDescriptionState(super.widgetElement);

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

/// WebF custom element for sheet content.
class FlutterShadcnSheetContent extends WidgetElement {
  FlutterShadcnSheetContent(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnSheetContentState(this);
}

class FlutterShadcnSheetContentState extends WebFWidgetElementState {
  FlutterShadcnSheetContentState(super.widgetElement);

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

/// WebF custom element for sheet footer.
class FlutterShadcnSheetFooter extends WidgetElement {
  FlutterShadcnSheetFooter(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnSheetFooterState(this);
}

class FlutterShadcnSheetFooterState extends WebFWidgetElementState {
  FlutterShadcnSheetFooterState(super.widgetElement);

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
