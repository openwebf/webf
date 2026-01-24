/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'dialog_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadDialog].
///
/// Exposed as `<flutter-shadcn-dialog>` in the DOM.
class FlutterShadcnDialog extends FlutterShadcnDialogBindings {
  FlutterShadcnDialog(super.context);

  bool _open = false;
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
  bool get closeOnOutsideClick => _closeOnOutsideClick;

  @override
  set closeOnOutsideClick(value) {
    final bool v = value == true;
    if (v != _closeOnOutsideClick) {
      _closeOnOutsideClick = v;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnDialogState(this);
}

class FlutterShadcnDialogState extends WebFWidgetElementState {
  FlutterShadcnDialogState(super.widgetElement);

  bool _wasOpen = false;
  bool _isShowingDialog = false;

  @override
  FlutterShadcnDialog get widgetElement =>
      super.widgetElement as FlutterShadcnDialog;

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

  Future<void> _showDialog(BuildContext context) async {
    if (_isShowingDialog) return;
    _isShowingDialog = true;

    // Extract title and description text
    String? titleText;
    String? descriptionText;

    final headerNode = widgetElement.childNodes
        .firstWhereOrNull((n) => n is FlutterShadcnDialogHeader);
    if (headerNode != null) {
      final titleNode = headerNode.childNodes
          .firstWhereOrNull((n) => n is FlutterShadcnDialogTitle);
      final descNode = headerNode.childNodes
          .firstWhereOrNull((n) => n is FlutterShadcnDialogDescription);

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
        .firstWhereOrNull((n) => n is FlutterShadcnDialogFooter);
    if (footerNode != null) {
      for (final child in footerNode.childNodes) {
        footerActions.add(WebFWidgetElementChild(child: child.toWidget()));
      }
    }

    // Build content
    final contentSlot = _findSlot<FlutterShadcnDialogContent>();

    await showShadDialog(
      context: context,
      barrierDismissible: widgetElement.closeOnOutsideClick,
      builder: (dialogContext) => ShadDialog(
        title: titleText != null ? Text(titleText) : null,
        description: descriptionText != null ? Text(descriptionText) : null,
        actions: footerActions,
        child: contentSlot,
      ),
    );

    // Dialog was closed (either by user action or programmatically)
    _isShowingDialog = false;
    if (mounted && widgetElement.open) {
      widgetElement._open = false;
      widgetElement.dispatchEvent(Event('close'));
    }
  }

  void _closeDialog(BuildContext context) {
    if (_isShowingDialog) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle open state changes
    if (widgetElement.open && !_wasOpen) {
      // Opening dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widgetElement.open) {
          _showDialog(context);
        }
      });
    } else if (!widgetElement.open && _wasOpen) {
      // Closing dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _closeDialog(context);
        }
      });
    }
    _wasOpen = widgetElement.open;

    // Return an empty placeholder - the dialog is shown via showShadDialog
    return const SizedBox.shrink();
  }
}

/// WebF custom element for dialog header.
///
/// Exposed as `<flutter-shadcn-dialog-header>` in the DOM.
class FlutterShadcnDialogHeader extends WidgetElement {
  FlutterShadcnDialogHeader(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnDialogHeaderState(this);
}

class FlutterShadcnDialogHeaderState extends WebFWidgetElementState {
  FlutterShadcnDialogHeaderState(super.widgetElement);

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
    final title = _findSlot<FlutterShadcnDialogTitle>();
    final description = _findSlot<FlutterShadcnDialogDescription>();

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

/// WebF custom element for dialog title.
///
/// Exposed as `<flutter-shadcn-dialog-title>` in the DOM.
class FlutterShadcnDialogTitle extends WidgetElement {
  FlutterShadcnDialogTitle(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnDialogTitleState(this);
}

class FlutterShadcnDialogTitleState extends WebFWidgetElementState {
  FlutterShadcnDialogTitleState(super.widgetElement);

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

/// WebF custom element for dialog description.
///
/// Exposed as `<flutter-shadcn-dialog-description>` in the DOM.
class FlutterShadcnDialogDescription extends WidgetElement {
  FlutterShadcnDialogDescription(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnDialogDescriptionState(this);
}

class FlutterShadcnDialogDescriptionState extends WebFWidgetElementState {
  FlutterShadcnDialogDescriptionState(super.widgetElement);

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

/// WebF custom element for dialog content.
///
/// Exposed as `<flutter-shadcn-dialog-content>` in the DOM.
class FlutterShadcnDialogContent extends WidgetElement {
  FlutterShadcnDialogContent(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnDialogContentState(this);
}

class FlutterShadcnDialogContentState extends WebFWidgetElementState {
  FlutterShadcnDialogContentState(super.widgetElement);

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

/// WebF custom element for dialog footer.
///
/// Exposed as `<flutter-shadcn-dialog-footer>` in the DOM.
class FlutterShadcnDialogFooter extends WidgetElement {
  FlutterShadcnDialogFooter(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnDialogFooterState(this);
}

class FlutterShadcnDialogFooterState extends WebFWidgetElementState {
  FlutterShadcnDialogFooterState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widgetElement.childNodes
          .map((node) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: WebFWidgetElementChild(child: node.toWidget()),
              ))
          .toList(),
    );
  }
}
