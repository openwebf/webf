/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'logger.dart';
// import 'package:webf/launcher.dart'; // Not needed if using context directly

class FlutterCupertinoActionSheet extends WidgetElement {
  // Constructor - removed isIntrinsicBox
  FlutterCupertinoActionSheet(super.context);

  // Synchronous wrapper method to be bound
  void _showSync(List<dynamic> args) {
    state?._showActionSheetImpl(args); // Fire-and-forget async task
  }

  // Method Binding using StaticDefinedSyncBindingObjectMethodMap
  static StaticDefinedSyncBindingObjectMethodMap actionSheetMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final actionSheetElement = castToType<FlutterCupertinoActionSheet>(element);
        actionSheetElement._showSync(args);
        return null; // Sync method returns null
      },
    )
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        actionSheetMethods,
      ];

  @override
  FlutterCupertinoActionSheetState? get state => super.state as FlutterCupertinoActionSheetState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoActionSheetState(this);
  }
}

class FlutterCupertinoActionSheetState extends WebFWidgetElementState {
  FlutterCupertinoActionSheetState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This element itself doesn't render anything visible
    return const SizedBox();
  }

  // Async implementation detail
  Future<void> _showActionSheetImpl(List<dynamic> args) async {
    // --- Argument Parsing ---
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

    // --- Get BuildContext ---
    // Access BuildContext directly from the element's context property
    final BuildContext? buildContext = this.context;
    if (buildContext == null) {
      logger.e('Element BuildContext is null. Cannot show ActionSheet');
      return;
    }
    // Ensure the context is still mounted
    if (!buildContext.mounted) {
      logger.e('BuildContext is not mounted. Cannot show ActionSheet');
      return;
    }

    // --- Extract Config ---
    String? title = config['title'] as String?;
    String? message = config['message'] as String?;
    List<dynamic> actionsRaw = config['actions'] is List ? config['actions'] : [];
    Map<String, dynamic>? cancelButtonRaw =
        config['cancelButton'] is Map ? Map<String, dynamic>.from(config['cancelButton']) : null;

    // --- Prepare Configs (no context needed yet) ---
    List<Map<String, dynamic>> actionConfigs = actionsRaw
        .whereType<Map>() // Filters out non-map items safely
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    Map<String, dynamic>? cancelActionConfig = cancelButtonRaw;

    if (actionConfigs.isEmpty && cancelActionConfig == null) {
      logger.w('ActionSheet shown with no actions or cancel button');
    }

    // --- Show Popup ---
    try {
      // Use rootNavigator: true to ensure it pops correctly, especially in nested Navigators
      await showCupertinoModalPopup<void>(
          context: buildContext,
          useRootNavigator: true,
          builder: (BuildContext dialogContext) {
            // Build actions *inside* the builder using the dialogContext
            List<Widget> dialogActions = actionConfigs.map((cfg) => _buildAction(cfg, dialogContext)).toList();
            Widget? dialogCancelButton =
                cancelActionConfig != null ? _buildAction(cancelActionConfig, dialogContext) : null;

            return CupertinoActionSheet(
              title: title != null ? Text(title) : null,
              message: message != null ? Text(message) : null,
              actions: dialogActions.isNotEmpty ? dialogActions : null,
              cancelButton: dialogCancelButton,
            );
          });
    } catch (e, stacktrace) {
      logger.e('Error showing CupertinoActionSheet', error: e, stackTrace: stacktrace);
    }
  }

  // Helper to parse action config and build CupertinoActionSheetAction
  // Use the dialogContext provided by the builder for Navigator.pop
  CupertinoActionSheetAction _buildAction(Map<String, dynamic> actionConfig, BuildContext dialogContext) {
    String text = actionConfig['text'] as String? ?? 'Action';
    bool isDefault = actionConfig['isDefault'] == true;
    bool isDestructive = actionConfig['isDestructive'] == true;
    String eventName = actionConfig['event'] as String? ?? text.toLowerCase().replaceAll(' ', '_');

    return CupertinoActionSheetAction(
      onPressed: () {
        widgetElement.dispatchEvent(CustomEvent(eventName, detail: text));
        Navigator.pop(dialogContext); // Pop using the builder's context
      },
      isDefaultAction: isDefault,
      isDestructiveAction: isDestructive,
      child: Text(text),
    );
  }
}
