/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import 'icon.dart';
import 'menu_bindings_generated.dart';
import 'logger.dart';

/// WebF custom element that provides a tap-triggered popup menu
/// with Cupertino styling.
///
/// Exposed as `<flutter-cupertino-menu>` in the DOM.
class FlutterCupertinoMenu extends FlutterCupertinoMenuBindings {
  FlutterCupertinoMenu(super.context) {
    _actions = <Map<String, dynamic>>[];
  }

  bool _disabled = false;
  List<Map<String, dynamic>> _actions = <Map<String, dynamic>>[];

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool next = value == true;
    if (next != _disabled) {
      _disabled = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get allowsInfiniteHeight => true;

  @override
  bool get allowsInfiniteWidth => true;

  static StaticDefinedSyncBindingObjectMethodMap menuMethods = {
    'setActions': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final menu = castToType<FlutterCupertinoMenu>(element);

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
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        menuMethods,
      ];

  IconData? _getIconData(String iconName) {
    final IconData? icon = FlutterCupertinoIcon.getIconType(iconName);
    if (icon == null) {
      logger.w('Icon not found for name: $iconName');
    }
    return icon;
  }

  @override
  FlutterCupertinoMenuState? get state =>
      super.state as FlutterCupertinoMenuState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoMenuState(this);
  }
}

class FlutterCupertinoMenuState extends WebFWidgetElementState {
  FlutterCupertinoMenuState(super.widgetElement);

  @override
  FlutterCupertinoMenu get widgetElement =>
      super.widgetElement as FlutterCupertinoMenu;

  Widget? _findChild() {
    for (final child in widgetElement.childNodes) {
      if (child is dom.Element) {
        return WebFWidgetElementChild(child: child.toWidget());
      }
    }
    return null;
  }

  Future<void> _showMenu() async {
    if (widgetElement._disabled || widgetElement._actions.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final List<PopupMenuEntry<int>> items = <PopupMenuEntry<int>>[];
    for (int i = 0; i < widgetElement._actions.length; i++) {
      final Map<String, dynamic> action = widgetElement._actions[i];
      final bool isDestructive = action['destructive'] == true;
      final String text = action['text'] as String? ?? '';
      final String? iconName = action['icon'] as String?;

      items.add(
        PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDestructive ? CupertinoColors.destructiveRed : null,
                    fontSize: 17,
                  ),
                ),
              ),
              if (iconName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    widgetElement._getIconData(iconName),
                    size: 20,
                    color: isDestructive ? CupertinoColors.destructiveRed : null,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final int? selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      items: items,
    );

    if (selected != null && selected < widgetElement._actions.length) {
      final Map<String, dynamic> action = widgetElement._actions[selected];
      final String text = action['text'] as String? ?? '';
      final bool isDestructive = action['destructive'] == true;
      final String eventName = action['event'] as String? ??
          text.toLowerCase().replaceAll(' ', '_');

      final Map<String, dynamic> detail = <String, dynamic>{
        'index': selected,
        'text': text,
        'event': eventName,
        'destructive': isDestructive,
      };

      widgetElement.dispatchEvent(CustomEvent('select', detail: detail));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget? child = _findChild();

    if (child == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widgetElement._disabled ? null : _showMenu,
      child: child,
    );
  }
}
