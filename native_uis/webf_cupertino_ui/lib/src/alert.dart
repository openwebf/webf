/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

import 'alert_bindings_generated.dart';
import 'logger.dart';

mixin FlutterCupertinoAlertMixin on WidgetElement {
  static StaticDefinedSyncBindingObjectMethodMap alertSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        if (alert.state == null) return;

        if (args.isNotEmpty) {
          final Map<String, dynamic> options = args[0];
          alert._tempTitle = options['title']?.toString();
          alert._tempMessage = options['message']?.toString();
        }

        alert._isVisible = true;
        alert.showDialog();
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        alert._tempTitle = null;
        alert._tempMessage = null;
        alert._isVisible = false;

        if (alert.state == null) return;

        Navigator.of(alert.state!.context, rootNavigator: true).pop();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        alertSyncMethods,
      ];
}

/// WebF custom element that wraps Flutter's [CupertinoAlertDialog].
///
/// Exposed as `<flutter-cupertino-alert>` in the DOM.
class FlutterCupertinoAlert extends FlutterCupertinoAlertBindings
    with FlutterCupertinoAlertMixin {
  FlutterCupertinoAlert(super.context);

  // Attribute-backed fields (JS-visible state).
  String? _title;
  String? _message;
  String? _cancelText;
  bool _cancelDestructive = false;
  bool _cancelDefault = false;
  String? _cancelTextStyle;
  String? _confirmText;
  bool _confirmDefault = true;
  bool _confirmDestructive = false;
  String? _confirmTextStyle;

  // Per-show overrides coming from JS options.
  String? _tempTitle;
  String? _tempMessage;

  bool _isVisible = false;

  @override
  String? get title => _title;

  @override
  set title(value) {
    _title = value?.toString();
  }

  @override
  String? get message => _message;

  @override
  set message(value) {
    _message = value?.toString();
  }

  @override
  String? get cancelText => _cancelText;

  @override
  set cancelText(value) {
    _cancelText = value?.toString();
  }

  @override
  bool get cancelDestructive => _cancelDestructive;

  @override
  set cancelDestructive(value) {
    _cancelDestructive = value == true;
  }

  @override
  bool get cancelDefault => _cancelDefault;

  @override
  set cancelDefault(value) {
    _cancelDefault = value == true;
  }

  @override
  String? get cancelTextStyle => _cancelTextStyle;

  @override
  set cancelTextStyle(value) {
    _cancelTextStyle = value?.toString();
  }

  @override
  String? get confirmText => _confirmText;

  @override
  set confirmText(value) {
    _confirmText = value?.toString();
  }

  @override
  bool get confirmDefault => _confirmDefault;

  @override
  set confirmDefault(value) {
    _confirmDefault = value == true;
  }

  @override
  bool get confirmDestructive => _confirmDestructive;

  @override
  set confirmDestructive(value) {
    _confirmDestructive = value == true;
  }

  @override
  String? get confirmTextStyle => _confirmTextStyle;

  @override
  set confirmTextStyle(value) {
    _confirmTextStyle = value?.toString();
  }

  bool get isVisible => _isVisible;

  void showDialog() {
    if (!_isVisible) return;
    if (state == null) return;

    showCupertinoDialog(
      context: state!.context,
      builder: (BuildContext context) => FlutterCupertinoDialog(this),
    ).then((_) {
      _isVisible = false;
      _tempTitle = null;
      _tempMessage = null;
    });
  }

  @override
  FlutterCupertinoAlertState? get state =>
      super.state as FlutterCupertinoAlertState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoAlertState(this);
  }
}

class FlutterCupertinoDialog extends StatelessWidget {
  final FlutterCupertinoAlert widgetElement;

  const FlutterCupertinoDialog(this.widgetElement, {super.key});

  TextStyle? _parseTextStyle(String? styleStr) {
    if (styleStr == null) return null;

    try {
      final Map<String, dynamic> styleMap =
          Map<String, dynamic>.from(const JsonDecoder().convert(styleStr));

      return TextStyle(
        color: styleMap['color'] != null ? parseColor(styleMap['color']) : null,
        fontSize: styleMap['fontSize'] != null
            ? (styleMap['fontSize'] as num).toDouble()
            : null,
        fontWeight: styleMap['fontWeight'] == 'bold'
            ? FontWeight.bold
            : FontWeight.normal,
      );
    } catch (e) {
      logger.e('Error parsing text style: $e');
      return null;
    }
  }

  Color? parseColor(String? value) {
    if (value == null) return null;
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      final int? color = int.tryParse(hex, radix: 16);
      if (color != null) {
        return Color(color | 0xFF000000);
      }
    }
    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Cancel button, optional.
    final cancelText = widgetElement.cancelText;
    if (cancelText != null && cancelText.isNotEmpty) {
      actions.add(
        CupertinoDialogAction(
          isDestructiveAction: widgetElement.cancelDestructive,
          isDefaultAction: widgetElement.cancelDefault,
          textStyle: _parseTextStyle(widgetElement.cancelTextStyle),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            widgetElement.dispatchEvent(CustomEvent('cancel'));
          },
          child: Text(cancelText),
        ),
      );
    }

    // Confirm button.
    final confirmText = widgetElement.confirmText ?? 'OK';
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: widgetElement.confirmDefault,
        isDestructiveAction: widgetElement.confirmDestructive,
        textStyle: _parseTextStyle(widgetElement.confirmTextStyle),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          widgetElement.dispatchEvent(CustomEvent('confirm'));
        },
        child: Text(confirmText),
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    if (!widgetElement.isVisible) {
      return const SizedBox.shrink();
    }

    final titleText =
        widgetElement._tempTitle ?? widgetElement.title ?? '';
    final messageText =
        widgetElement._tempMessage ?? widgetElement.message ?? '';

    return CupertinoAlertDialog(
      title: Text(
        titleText,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        messageText,
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.black,
        ),
      ),
      actions: _buildActions(context),
    );
  }
}

class FlutterCupertinoAlertState extends WebFWidgetElementState {
  FlutterCupertinoAlertState(super.widgetElement);

  @override
  FlutterCupertinoAlert get widgetElement =>
      super.widgetElement as FlutterCupertinoAlert;

  @override
  Widget build(BuildContext context) {
    // Host element itself does not render anything; dialog is shown via showCupertinoDialog.
    return const SizedBox.shrink();
  }
}
