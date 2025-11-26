/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import 'icon.dart';
import 'context_menu_bindings_generated.dart';
import 'logger.dart';

/// WebF custom element that wraps Flutter's [CupertinoContextMenu].
///
/// Exposed as `<flutter-cupertino-context-menu>` in the DOM.
class FlutterCupertinoContextMenu extends FlutterCupertinoContextMenuBindings {
  FlutterCupertinoContextMenu(super.context) {
    _actions = <Map<String, dynamic>>[];
  }

  bool _enableHapticFeedback = false;
  List<Map<String, dynamic>> _actions = <Map<String, dynamic>>[];

  @override
  bool get enableHapticFeedback => _enableHapticFeedback;

  @override
  set enableHapticFeedback(value) {
    final bool next = value == true;
    if (next != _enableHapticFeedback) {
      _enableHapticFeedback = next;
      state?.requestUpdateState(() {});
    }
  }

  static StaticDefinedSyncBindingObjectMethodMap contextMenuMethods = {
    'setActions': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final menu = castToType<FlutterCupertinoContextMenu>(element);

        if (args.isNotEmpty) {
          final actionsData = args[0];

          if (actionsData is List) {
            final List<Map<String, dynamic>> newActions = <Map<String, dynamic>>[];
            for (final item in actionsData) {
              if (item is Map) {
                newActions.add(
                  Map<String, dynamic>.from(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                );
              } else {
                logger.w('Skipping non-map item in actions list: $item');
              }
            }
            menu._actions = newActions;
          } else {
            menu._actions = <Map<String, dynamic>>[];
          }
          menu.state?.requestUpdateState(() {});
        } else {
          menu._actions = <Map<String, dynamic>>[];
          menu.state?.requestUpdateState(() {});
        }
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        contextMenuMethods,
      ];

  IconData? _getIconData(String iconName) {
    final IconData? icon = FlutterCupertinoIcon.getIconType(iconName);
    if (icon == null) {
      logger.w('Icon not found for name: $iconName');
    }
    return icon;
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

  Widget? _findPreviewChild() {
    for (final child in widgetElement.childNodes) {
      if (child is dom.Element) {
        final Widget childWidget = WebFWidgetElementChild(child: child.toWidget());
        return Container(child: childWidget);
      }
    }
    return null;
  }

  List<Widget> _buildActions() {
    final List<Widget> builtActions = <Widget>[];

    for (int i = 0; i < widgetElement._actions.length; i++) {
      final Map<String, dynamic> action = widgetElement._actions[i];
      final bool isDestructive = action['destructive'] == true;
      final bool isDefault = action['default'] == true;
      final String text = action['text'] as String? ?? '';
      final String? iconName = action['icon'] as String?;
      final String eventName = action['event'] as String? ?? 'press';

      builtActions.add(
        CupertinoContextMenuAction(
          isDestructiveAction: isDestructive,
          isDefaultAction: isDefault,
          onPressed: () {
            final Map<String, dynamic> detail = <String, dynamic>{
              'index': i,
              'text': text,
              'event': eventName,
              'destructive': isDestructive,
              'default': isDefault,
            };

            widgetElement.dispatchEvent(CustomEvent('select', detail: detail));

            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e, stacktrace) {
              logger.e('Error closing menu', error: e, stackTrace: stacktrace);
            }
          },
          trailingIcon: iconName != null ? widgetElement._getIconData(iconName) : null,
          child: Text(text),
        ),
      );
    }

    if (builtActions.isEmpty) {
      logger.w(
        "_buildActions called but resulted in empty list. This shouldn't happen if build logic is correct",
      );
      return <Widget>[
        CupertinoContextMenuAction(
          child: const Text('Error'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ];
    }

    return builtActions;
  }

  @override
  Widget build(BuildContext context) {
    final Widget? previewChild = _findPreviewChild();

    if (previewChild == null) {
      return const SizedBox.shrink();
    }

    if (widgetElement._actions.isEmpty) {
      return previewChild;
    }

    final List<Widget> builtActions = _buildActions();

    return CupertinoContextMenu(
      actions: builtActions,
      enableHapticFeedback: widgetElement._enableHapticFeedback,
      child: previewChild,
    );
  }
}
