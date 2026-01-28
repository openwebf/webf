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

  bool _wasOpen = false;
  bool _isShowingSheet = false;

  @override
  FlutterShadcnSheet get widgetElement =>
      super.widgetElement as FlutterShadcnSheet;

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

  Widget? _findSlot<T>() {
    final node =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return WebFWidgetElementChild(child: node.toWidget());
    }
    return null;
  }

  Future<void> _showSheet(BuildContext context) async {
    if (_isShowingSheet) return;
    _isShowingSheet = true;

    // Extract title and description text
    String? titleText;
    String? descriptionText;

    final headerNode = widgetElement.childNodes
        .firstWhereOrNull((n) => n is FlutterShadcnSheetHeader);
    if (headerNode != null) {
      final titleNode = headerNode.childNodes
          .firstWhereOrNull((n) => n is FlutterShadcnSheetTitle);
      final descNode = headerNode.childNodes
          .firstWhereOrNull((n) => n is FlutterShadcnSheetDescription);

      if (titleNode != null) {
        titleText = _extractTextContent(titleNode.childNodes);
      }
      if (descNode != null) {
        descriptionText = _extractTextContent(descNode.childNodes);
      }
    }

    // Build actions from footer
    final footerActions = <Widget>[];
    final footerNode = widgetElement.childNodes
        .firstWhereOrNull((n) => n is FlutterShadcnSheetFooter);
    if (footerNode != null) {
      for (final child in footerNode.childNodes) {
        footerActions.add(WebFWidgetElementChild(child: child.toWidget()));
      }
    }

    // Build content
    final contentSlot = _findSlot<FlutterShadcnSheetContent>();

    await showShadSheet(
      context: context,
      side: widgetElement.sheetSide,
      isDismissible: widgetElement.closeOnOutsideClick,
      builder: (sheetContext) => ShadSheet(
        title: titleText != null ? Text(titleText) : null,
        description: descriptionText != null ? Text(descriptionText) : null,
        actions: footerActions,
        child: contentSlot,
      ),
    );

    // Sheet was closed (either by user action or programmatically)
    _isShowingSheet = false;
    if (mounted && widgetElement.open) {
      widgetElement._open = false;
      widgetElement.dispatchEvent(Event('close'));
    }
  }

  void _closeSheet(BuildContext context) {
    if (_isShowingSheet) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle open state changes
    if (widgetElement.open && !_wasOpen) {
      // Opening sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widgetElement.open) {
          _showSheet(context);
        }
      });
    } else if (!widgetElement.open && _wasOpen) {
      // Closing sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _closeSheet(context);
        }
      });
    }
    _wasOpen = widgetElement.open;

    // Return an empty placeholder - the sheet is shown via showShadSheet
    return const SizedBox.shrink();
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
