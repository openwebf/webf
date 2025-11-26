/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BottomNavigationBarItem;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:collection/collection.dart';
import 'icon.dart';

class FlutterCupertinoTabBar extends WidgetElement {
  FlutterCupertinoTabBar(super.context);

  int _currentIndex = 0;
  String? _backgroundColor;
  String? _activeColor;
  String? _inactiveColor;
  double? _iconSize;
  bool _noTopBorder = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['current-index'] = ElementAttributeProperty(
      getter: () => _currentIndex.toString(),
      setter: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed != _currentIndex) {
          _currentIndex = parsed;
          state?.setState(() {
            final s = state as FlutterCupertinoTabBarState?;
            if (s != null) s.currentIndex = _currentIndex;
          });
        }
      },
    );
    attributes['background-color'] = ElementAttributeProperty(
      getter: () => _backgroundColor,
      setter: (value) {
        _backgroundColor = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _backgroundColor = null;
        state?.requestUpdateState(() {});
      },
    );
    attributes['active-color'] = ElementAttributeProperty(
      getter: () => _activeColor,
      setter: (value) {
        _activeColor = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _activeColor = null;
        state?.requestUpdateState(() {});
      },
    );
    attributes['inactive-color'] = ElementAttributeProperty(
      getter: () => _inactiveColor,
      setter: (value) {
        _inactiveColor = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _inactiveColor = null;
        state?.requestUpdateState(() {});
      },
    );
    attributes['icon-size'] = ElementAttributeProperty(
      getter: () => _iconSize?.toString(),
      setter: (value) {
        _iconSize = double.tryParse(value);
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _iconSize = null;
        state?.requestUpdateState(() {});
      },
    );
    attributes['no-top-border'] = ElementAttributeProperty(
      getter: () => _noTopBorder.toString(),
      setter: (value) {
        _noTopBorder = value == 'true' || value == '';
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _noTopBorder = false;
        state?.requestUpdateState(() {});
      },
    );
  }

  int get initialIndex => _currentIndex;
  String? get backgroundColor => _backgroundColor;
  String? get activeColor => _activeColor;
  String? get inactiveColor => _inactiveColor;
  double? get iconSize => _iconSize;
  bool get noTopBorder => _noTopBorder;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabBarState(this);
  }

  @override
  FlutterCupertinoTabBarState? get state => super.state as FlutterCupertinoTabBarState?;
}

class FlutterCupertinoTabBarState extends WebFWidgetElementState {
  FlutterCupertinoTabBarState(super.widgetElement);

  @override
  FlutterCupertinoTabBar get widgetElement => super.widgetElement as FlutterCupertinoTabBar;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widgetElement.initialIndex;
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    if (colorString.startsWith('#')) {
      String hex = colorString.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) {
        try {
          return Color(int.parse(hex, radix: 16));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Build items from child <flutter-cupertino-tab-bar-item>
    final items = buildItems();

    // Clamp index
    if (items.isEmpty) {
      currentIndex = 0;
    } else {
      currentIndex = currentIndex.clamp(0, items.length - 1);
    }

    final Color? background = _parseColor(widgetElement.backgroundColor);
    final Color? active = _parseColor(widgetElement.activeColor);
    final Color? inactive = _parseColor(widgetElement.inactiveColor);
    final double iconSize = widgetElement.iconSize ?? 30.0;
    final Border? border = widgetElement.noTopBorder ? null : const Border(top: BorderSide(color: CupertinoColors.separator));

    return CupertinoTabBar(
      items: items.isNotEmpty
          ? items
          : const [BottomNavigationBarItem(icon: SizedBox(width: 24, height: 24), label: '')],
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
          widgetElement._currentIndex = index;
        });
        widgetElement.dispatchEvent(CustomEvent('change', detail: index));
      },
      backgroundColor: background,
      activeColor: active ?? CupertinoColors.activeBlue,
      inactiveColor: inactive ?? CupertinoColors.inactiveGray,
      iconSize: iconSize,
      border: border,
    );
  }

  // Expose building of items for parent TabScaffold to consume without peeking grandchildren.
  List<BottomNavigationBarItem> buildItems() {
    final items = <BottomNavigationBarItem>[];
    for (final itemElem in widgetElement.childNodes.whereType<FlutterCupertinoTabBarItem>()) {
      final String title = itemElem.title ?? '';
      final dom.Element? iconElem = itemElem.childNodes
          .whereType<dom.Element>()
          .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
      final Widget icon = iconElem != null
          ? WebFWidgetElementChild(child: iconElem.toWidget(key: ObjectKey(iconElem)))
          : const SizedBox(width: 24, height: 24);
      items.add(BottomNavigationBarItem(icon: icon, label: title));
    }
    return items;
  }
}

class FlutterCupertinoTabBarItem extends WidgetElement {
  FlutterCupertinoTabBarItem(super.context);

  String? _title;
  String? get title => _title;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['title'] = ElementAttributeProperty(
      getter: () => _title,
      setter: (value) {
        _title = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _title = null;
        state?.requestUpdateState(() {});
      },
    );
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabBarItemState(this);
  }
}

class FlutterCupertinoTabBarItemState extends WebFWidgetElementState {
  FlutterCupertinoTabBarItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This element acts as a data/slot container; real rendering done by parent
    return const SizedBox.shrink();
  }
}
