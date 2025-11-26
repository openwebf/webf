/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

import 'logger.dart';

/// WebF custom element that wraps Flutter's [CupertinoActionSheet].
///
/// Exposed as `<flutter-cupertino-action-sheet>` in the DOM.
class FlutterCupertinoActionSheet extends WidgetElement {
  FlutterCupertinoActionSheet(super.context);

  /// Imperative show() entry point from JavaScript.
  ///
  /// This is a synchronous binding that delegates to an async implementation
  /// on the [WebFWidgetElementState].
  void _showSync(List<dynamic> args) {
    state?._showActionSheetImpl(args);
  }

  static StaticDefinedSyncBindingObjectMethodMap actionSheetMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final actionSheetElement = castToType<FlutterCupertinoActionSheet>(element);
        actionSheetElement._showSync(args);
        return null;
      },
    )
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        actionSheetMethods,
      ];

  @override
  FlutterCupertinoActionSheetState? get state =>
      super.state as FlutterCupertinoActionSheetState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoActionSheetState(this);
  }
}

class FlutterCupertinoActionSheetState extends WebFWidgetElementState {
  FlutterCupertinoActionSheetState(super.widgetElement);

  @override
  FlutterCupertinoActionSheet get widgetElement =>
      super.widgetElement as FlutterCupertinoActionSheet;

  @override
  Widget build(BuildContext context) {
    // Host element itself doesn't render anything; the sheet is shown modally.
    return const SizedBox.shrink();
  }

  Future<void> _showActionSheetImpl(List<dynamic> args) async {
    if (args.isEmpty) {
      logger.e('show ActionSheet requires configuration argument');
      return;
    }

    Map<String, dynamic> config = {};
    if (args[0] is Map) {
      config = Map<String, dynamic>.from(args[0]);
    } else if (args[0] is String) {
      try {
        config = jsonDecode(args[0]);
      } catch (e) {
        logger.e('Error parsing ActionSheet config JSON', error: e);
        return;
      }
    } else {
      logger.e('ActionSheet config must be an object or JSON string');
      return;
    }

    final BuildContext? buildContext = context;
    if (buildContext == null) {
      logger.e('Element BuildContext is null. Cannot show ActionSheet');
      return;
    }
    if (!buildContext.mounted) {
      logger.e('BuildContext is not mounted. Cannot show ActionSheet');
      return;
    }

    final String? title = config['title'] as String?;
    final String? message = config['message'] as String?;
    final List<dynamic> actionsRaw =
        config['actions'] is List ? config['actions'] : const [];
    final Map<String, dynamic>? cancelButtonRaw =
        config['cancelButton'] is Map
            ? Map<String, dynamic>.from(config['cancelButton'])
            : null;

    final List<Map<String, dynamic>> actionConfigs = actionsRaw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final Map<String, dynamic>? cancelActionConfig = cancelButtonRaw;

    if (actionConfigs.isEmpty && cancelActionConfig == null) {
      logger.w('ActionSheet shown with no actions or cancel button');
    }

    try {
      await showCupertinoModalPopup<void>(
        context: buildContext,
        useRootNavigator: true,
        builder: (BuildContext dialogContext) {
          final List<Widget> dialogActions = <Widget>[];
          for (int i = 0; i < actionConfigs.length; i++) {
            final cfg = Map<String, dynamic>.from(actionConfigs[i]);
            cfg['index'] = i;
            dialogActions.add(_buildAction(cfg, dialogContext));
          }
          final Widget? dialogCancelButton = cancelActionConfig != null
              ? _buildAction(cancelActionConfig, dialogContext)
              : null;

          return CupertinoActionSheet(
            title: title != null ? Text(title) : null,
            message: message != null ? Text(message) : null,
            actions: dialogActions.isNotEmpty ? dialogActions : null,
            cancelButton: dialogCancelButton,
          );
        },
      );
    } catch (e, stacktrace) {
      logger.e('Error showing CupertinoActionSheet',
          error: e, stackTrace: stacktrace);
    }
  }

  CupertinoActionSheetAction _buildAction(
    Map<String, dynamic> actionConfig,
    BuildContext dialogContext,
  ) {
    final String text = actionConfig['text'] as String? ?? 'Action';
    final bool isDefault = actionConfig['isDefault'] == true;
    final bool isDestructive = actionConfig['isDestructive'] == true;
    final String eventName =
        actionConfig['event'] as String? ?? text.toLowerCase().replaceAll(' ', '_');
    final int? index = actionConfig['index'] as int?;

    return CupertinoActionSheetAction(
      onPressed: () {
        final Map<String, dynamic> detail = <String, dynamic>{
          'text': text,
          'event': eventName,
          'isDefault': isDefault,
          'isDestructive': isDestructive,
        };
        if (index != null) {
          detail['index'] = index;
        }

        widgetElement.dispatchEvent(CustomEvent('select', detail: detail));
        Navigator.pop(dialogContext);
      },
      isDefaultAction: isDefault,
      isDestructiveAction: isDestructive,
      child: Text(text),
    );
  }
}
