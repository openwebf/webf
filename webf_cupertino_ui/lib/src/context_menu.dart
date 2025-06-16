/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'logger.dart';

class FlutterCupertinoContextMenu extends WidgetElement {
  FlutterCupertinoContextMenu(super.context) {
    // Actions are initially empty, set via setActions method or remain empty
    _actions = [];
  }

  bool _enableHapticFeedback = false;
  List<Map<String, dynamic>> _actions = [];

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Enable haptic feedback
    attributes['enable-haptic-feedback'] = ElementAttributeProperty(
        getter: () => _enableHapticFeedback.toString(),
        setter: (val) {
          _enableHapticFeedback = val != 'false';
          // No need to call setState for this attribute change
          // The build method will read the latest value when needed
        });
  }

  // Define setActions method
  static StaticDefinedSyncBindingObjectMethodMap contextMenuMethods = {
    'setActions': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final menu = castToType<FlutterCupertinoContextMenu>(element);

        if (args.isNotEmpty) {
          var actionsData = args[0];

          if (actionsData is List) {
            final List<Map<String, dynamic>> newActions = [];
            for (var item in actionsData) {
              if (item is Map) {
                // Ensure keys are strings and values are dynamic
                newActions.add(Map<String, dynamic>.from(item.map((key, value) => MapEntry(key.toString(), value))));
              } else {
                logger.w('Skipping non-map item in actions list: $item');
              }
            }
            menu._actions = newActions;
          } else {
            menu._actions = []; // Clear actions if data is not a list
          }
          menu.state?.requestUpdateState(() {}); // Update the UI after actions change
        } else {
          menu._actions = []; // Clear actions if args is empty
          menu.state?.requestUpdateState(() {});
        }
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        contextMenuMethods,
      ];

  // Get icon data
  IconData? _getIconData(String iconName) {
    switch (iconName) {
      case 'share':
        return CupertinoIcons.share;
      case 'heart':
        return CupertinoIcons.heart;
      case 'delete':
        return CupertinoIcons.delete;
      case 'doc':
        return CupertinoIcons.doc;
      case 'doc_text':
        return CupertinoIcons.doc_text;
      case 'phone':
        return CupertinoIcons.phone;
      case 'chat_bubble':
        return CupertinoIcons.chat_bubble;
      case 'mail':
        return CupertinoIcons.mail;
      case 'photo':
        return CupertinoIcons.photo;
      case 'add':
        return CupertinoIcons.add;
      case 'edit':
        return CupertinoIcons.pencil;
      case 'pencil':
        return CupertinoIcons.pencil;
      case 'person_circle':
        return CupertinoIcons.person_circle;
      case 'folder':
        return CupertinoIcons.folder;
      case 'star':
        return CupertinoIcons.star;
      case 'xmark_circle':
        return CupertinoIcons.xmark_circle;
      default:
        logger.w('Icon not found for name: $iconName');
        return null; // Return null for unknown icons
    }
  }

  @override
  FlutterCupertinoContextMenuState? get state => super.state as FlutterCupertinoContextMenuState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoContextMenuState(this);
  }
}

class FlutterCupertinoContextMenuState extends WebFWidgetElementState {
  FlutterCupertinoContextMenuState(super.widgetElement);

  @override
  FlutterCupertinoContextMenu get widgetElement => super.widgetElement as FlutterCupertinoContextMenu;

  // Find the first direct child Element and return its widget
  Widget? _findPreviewChild() {
    for (final child in widgetElement.childNodes) {
      // Find the first node that is an Element
      if (child is dom.Element) {
        // Return the widget representation of this element
        Widget? childWidget = child.toWidget();
        if (childWidget != null) {
          // Wrap in a Container to ensure gestures are captured correctly,
          // especially if the child itself doesn't handle gestures well.
          // Add some default styling like rounded corners if desired.
          return Container(
              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)), // Optional: Add decoration if needed
              // clipBehavior: Clip.antiAlias, // Optional: Clip content
              child: childWidget);
        } else {
          logger.w('First element child ${child.tagName} failed to render to a widget');
        }
        // Only consider the first element found
        break;
      }
    }
    return null; // Return null if no element child is found
  }

  // Build menu actions
  List<Widget> _buildActions() {
    final builtActions = <Widget>[];

    for (final action in widgetElement._actions) {
      final isDestructive = action['destructive'] == true;
      final isDefault = action['default'] == true;
      final text = action['text'] as String? ?? '';
      final iconName = action['icon'] as String?;
      final eventName = action['event'] as String? ?? 'press'; // Default event name

      builtActions.add(CupertinoContextMenuAction(
        isDestructiveAction: isDestructive,
        isDefaultAction: isDefault,
        onPressed: () {
          widgetElement.dispatchEvent(CustomEvent(eventName)); // Dispatch event with the name from config

          // Attempt to close the menu
          try {
            // Use root navigator to ensure context is valid
            Navigator.of(context, rootNavigator: true).pop();
          } catch (e, stacktrace) {
            logger.e('Error closing menu', error: e, stackTrace: stacktrace);
          }
        },
        trailingIcon: iconName != null ? widgetElement._getIconData(iconName) : null,
        child: Text(text),
      ));
    }

    // CupertinoContextMenu requires at least one action.
    // This check is now handled in the build method.
    // If buildActions is called, it means _actions was not empty.
    if (builtActions.isEmpty) {
      logger.w("_buildActions called but resulted in empty list. This shouldn't happen if build logic is correct");
      // Return a dummy action to prevent crashes, though ideally build method prevents this call.
      return [
        CupertinoContextMenuAction(
            child: const Text('Error'), onPressed: () => Navigator.of(context, rootNavigator: true).pop())
      ];
    }

    return builtActions;
  }

  @override
  Widget build(BuildContext context) {
    // Get the preview child (first direct element child's widget)
    final previewChild = _findPreviewChild();

    if (previewChild == null) {
      // Return an empty SizedBox if no preview content is available
      return const SizedBox.shrink();
    }

    // If actions are empty, just return the preview child directly without context menu functionality.
    if (widgetElement._actions.isEmpty) {
      return previewChild;
    }

    // If actions are present, build the context menu.
    // Call _buildActions only if needed and actions are not empty.
    final builtActions = _buildActions();

    return CupertinoContextMenu(
      actions: builtActions,
      enableHapticFeedback: widgetElement._enableHapticFeedback,
      // The child of CupertinoContextMenu is the widget that triggers the menu on long press.
      child: previewChild,
    );
  }
}
