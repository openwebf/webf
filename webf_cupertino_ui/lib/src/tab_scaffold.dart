/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BottomNavigationBarItem; // For CupertinoTabBar items
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'tab_bar.dart';
import 'icon.dart';
import 'tab_view.dart';
import 'logger.dart';

/// A WebF custom element that mimics Flutter's CupertinoTabScaffold.
///
/// Usage (DOM):
/// <flutter-cupertino-tab-scaffold current-index="0">
///   <flutter-cupertino-tab-scaffold-tab title="Home">
///     ...content of tab 0...
///   </flutter-cupertino-tab-scaffold-tab>
///   <flutter-cupertino-tab-scaffold-tab title="Settings">
///     ...content of tab 1...
///   </flutter-cupertino-tab-scaffold-tab>
/// </flutter-cupertino-tab-scaffold>
///
/// Icon support: place a <flutter-cupertino-icon> as a child of the tab to be used
/// as the tab's icon. If none is found, an empty box is used.
class FlutterCupertinoTabScaffold extends WidgetElement {
  FlutterCupertinoTabScaffold(super.context);

  int _currentIndex = 0;
  bool _resizeToAvoidBottomInset = true;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['current-index'] = ElementAttributeProperty(
      getter: () => _currentIndex.toString(),
      setter: (value) {
        final int? parsed = int.tryParse(value);
        if (parsed != null && parsed != _currentIndex) {
          _currentIndex = parsed;
          final s = state as FlutterCupertinoTabScaffoldState?;
          if (s != null) {
            // Update controller; listener will sync state and dispatch events.
            s.setIndexFromAttribute(_currentIndex);
          } else {
            // Fallback if state not ready yet
            state?.requestUpdateState(() {});
          }
        }
      },
    );
    attributes['resize-to-avoid-bottom-inset'] = ElementAttributeProperty(
      getter: () => _resizeToAvoidBottomInset.toString(),
      setter: (value) {
        final bool newVal = value == 'true' || value == '';
        if (newVal != _resizeToAvoidBottomInset) {
          _resizeToAvoidBottomInset = newVal;
          state?.requestUpdateState(() {});
        }
      },
      deleter: () {
        _resizeToAvoidBottomInset = true;
        state?.requestUpdateState(() {});
      }
    );
  }

  int get initialIndex => _currentIndex;
  bool get resizeToAvoidBottomInset => _resizeToAvoidBottomInset;

  @override
  FlutterCupertinoTabScaffoldState? get state => super.state as FlutterCupertinoTabScaffoldState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabScaffoldState(this);
  }
}

class FlutterCupertinoTabScaffoldState extends WebFWidgetElementState {
  FlutterCupertinoTabScaffoldState(super.widgetElement);

  @override
  FlutterCupertinoTabScaffold get widgetElement => super.widgetElement as FlutterCupertinoTabScaffold;

  int currentIndex = 0;
  late final CupertinoTabController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    currentIndex = widgetElement.initialIndex;
    _controller = CupertinoTabController(initialIndex: currentIndex);
    _controllerListener = () {
      if (currentIndex != _controller.index) {
        setState(() {
          currentIndex = _controller.index;
          widgetElement._currentIndex = currentIndex;
        });
        widgetElement.dispatchEvent(CustomEvent('change', detail: currentIndex));
      }
    };
    _controller.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
      _controllerListener = null;
    }
    super.dispose();
  }

  void setIndexFromAttribute(int index) {
    final int itemsLen = _lastItemsLen ?? 0;
    final int contentsLen = _lastContentsLen ?? 0;
    if (itemsLen > 0 && contentsLen > 0) {
      final int maxAllowed = (itemsLen < contentsLen ? itemsLen : contentsLen) - 1;
      _controller.index = index.clamp(0, maxAllowed);
    } else {
      _controller.index = index;
    }
  }

  int? _lastItemsLen;
  int? _lastContentsLen;

  @override
  Widget build(BuildContext context) {
    // Collect optional TabBar config element and Tab content elements
    final FlutterCupertinoTabBar? tabBarElem = widgetElement.childNodes
        .whereType<FlutterCupertinoTabBar>()
        .firstWhereOrNull((_) => true);
    final List<FlutterCupertinoTabScaffoldTab> tabs = widgetElement.childNodes
        .whereType<FlutterCupertinoTabScaffoldTab>()
        .toList(growable: false);

    // Gather tabs only; each tab builds its own content in its State
    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final hasTabView = tab.childNodes
          .whereType<dom.Element>()
          .any((e) => e is FlutterCupertinoTabView);
      // Intentionally minimal diagnostics; no verbose details
    }

    // Build items for the bottom bar
    final List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[];
    Color? backgroundColor;
    Color? activeColor;
    Color? inactiveColor;
    double? iconSize;
    Border? border;

    if (tabBarElem != null) {
      // Using nested TabBar for items/appearance. Build items from TabBar's direct children.
      for (final itemElem in tabBarElem.childNodes.whereType<FlutterCupertinoTabBarItem>()) {
        final String title = itemElem.title ?? '';
        final dom.Element? iconElem = itemElem.childNodes
            .whereType<dom.Element>()
            .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
        final Widget icon = iconElem != null
            ? WebFWidgetElementChild(child: iconElem.toWidget(key: ObjectKey(iconElem)))
            : const SizedBox(width: 24, height: 24);
        items.add(BottomNavigationBarItem(icon: icon, label: title));
      }
      backgroundColor = _parseColor(tabBarElem.backgroundColor);
      activeColor = _parseColor(tabBarElem.activeColor);
      inactiveColor = _parseColor(tabBarElem.inactiveColor);
      iconSize = tabBarElem.iconSize;
      border = tabBarElem.noTopBorder
          ? null
          : const Border(top: BorderSide(color: CupertinoColors.separator));
    } else {
      // Fallback: derive items from each TabScaffoldTab's own direct children/attributes
      // No TabBar found; deriving items from tabs
      for (final tab in tabs) {
        final String title = tab.title ?? '';
        final dom.Element? iconElem = tab.childNodes
            .whereType<dom.Element>()
            .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
        final Widget iconWidget = iconElem != null
            ? WebFWidgetElementChild(child: iconElem.toWidget(key: ObjectKey(iconElem)))
            : const SizedBox(width: 24, height: 24);
        items.add(BottomNavigationBarItem(icon: iconWidget, label: title));
      }
    }

    // Clamp index to both items and tab counts
    final int itemsLen = items.isEmpty ? 1 : items.length; // at least 1 placeholder
    final int contentsLen = tabs.isEmpty ? 1 : tabs.length; // avoid negative clamp
    _lastItemsLen = itemsLen;
    _lastContentsLen = contentsLen;
    final int maxAllowed = (itemsLen < contentsLen ? itemsLen : contentsLen) - 1;
    currentIndex = currentIndex.clamp(0, maxAllowed);
    if (itemsLen < 2) {
      logger.w('CupertinoTabBar has $itemsLen item(s). Apple\'s HIG recommends at least 2 tabs.');
    }
    if (itemsLen != contentsLen) {
      logger.w('TabScaffold items/content length mismatch: items=$itemsLen, contents=$contentsLen');
    }
    if (_controller.index != currentIndex) {
      // Keep controller in sync if external changes happened
      _controller.index = currentIndex;
    }

    // If fewer than 2 items, avoid rendering a TabBar (HIG) and show first content only
    if (itemsLen < 2) {
      logger.w('HIG: Hiding CupertinoTabBar because items < 2. Showing first content only.');
      if (tabs.isEmpty) return const SizedBox();
      final int clamped = currentIndex.clamp(0, tabs.length - 1);
      final tab = tabs[clamped];
      return WebFWidgetElementChild(child: tab.toWidget(key: ObjectKey(tab)));
    }

    return CupertinoTabScaffold(
      controller: _controller,
      resizeToAvoidBottomInset: widgetElement.resizeToAvoidBottomInset,
      tabBar: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          // Clamp with latest lengths
          final int itemsLen = items.isEmpty ? 1 : items.length;
          final int contentsLen = tabs.isEmpty ? 1 : tabs.length;
          final int maxAllowed = (itemsLen < contentsLen ? itemsLen : contentsLen) - 1;
          final int clamped = index.clamp(0, maxAllowed);
          _controller.index = clamped; // Listener will update state and dispatch event
        },
        items: items.isNotEmpty
            ? items
            : const [BottomNavigationBarItem(icon: SizedBox(width: 24, height: 24), label: '')],
        backgroundColor: backgroundColor,
        activeColor: (activeColor ?? CupertinoColors.activeBlue),
        inactiveColor: (inactiveColor ?? CupertinoColors.inactiveGray),
        iconSize: iconSize ?? 30.0,
        border: border,
      ),
      tabBuilder: (ctx, index) {
        final int itemsLen = items.isEmpty ? 1 : items.length;
        final int contentsLen = tabs.isEmpty ? 1 : tabs.length;
        final int maxAllowed = (itemsLen < contentsLen ? itemsLen : contentsLen) - 1;
        final int clamped = index.clamp(0, maxAllowed);
        if (tabs.isEmpty) return const SizedBox();
        final tab = tabs[clamped];
        return WebFWidgetElementChild(child: tab.toWidget(key: ObjectKey(tab)));
      },
    );
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
}

/// Sub-element representing a single tab in the TabScaffold.
/// Provides optional title attribute and holds content children (or a TabView).
class FlutterCupertinoTabScaffoldTab extends WidgetElement {
  FlutterCupertinoTabScaffoldTab(super.context);

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
    return _FlutterCupertinoTabScaffoldTabState(this);
  }
}

class _FlutterCupertinoTabScaffoldTabState extends WebFWidgetElementState {
  _FlutterCupertinoTabScaffoldTabState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final dom.Element? tabViewElem = widgetElement.childNodes
        .whereType<dom.Element>()
        .firstWhereOrNull((e) => e is FlutterCupertinoTabView);
    if (tabViewElem != null) {
      return WebFWidgetElementChild(child: tabViewElem.toWidget(key: ObjectKey(tabViewElem)));
    }
    // Exclude the first icon (if any) from page content to avoid duplication with tab bar
    final dom.Element? iconElem = widgetElement.childNodes
        .whereType<dom.Element>()
        .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
    return WebFHTMLElement(
      tagName: 'DIV',
      controller: widgetElement.ownerDocument.controller,
      parentElement: widgetElement,
      children: widgetElement.childNodes
          .where((n) => n != iconElem)
          .map((n) => WebFWidgetElementChild(child: n.toWidget()))
          .toList(),
    );
  }

  // Build the tab bar item (icon + label) from direct children and attributes
  BottomNavigationBarItem buildBarItem() {
    final tab = widgetElement as FlutterCupertinoTabScaffoldTab;
    final String title = tab.title ?? '';
    final dom.Element? iconElem = widgetElement.childNodes
        .whereType<dom.Element>()
        .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
    final Widget icon = iconElem != null
        ? WebFWidgetElementChild(child: iconElem.toWidget(key: ObjectKey(iconElem)))
        : const SizedBox(width: 24, height: 24);
    return BottomNavigationBarItem(icon: icon, label: title);
  }

  // Build the page content for this tab. If a TabView is present, return it.
  // Otherwise, render all children except the bar icon.
  Widget buildPageContent() {
    final dom.Element? tabViewElem = widgetElement.childNodes
        .whereType<dom.Element>()
        .firstWhereOrNull((e) => e is FlutterCupertinoTabView);
    if (tabViewElem != null) {
      return WebFWidgetElementChild(child: tabViewElem.toWidget(key: ObjectKey(tabViewElem)));
    }
    final dom.Element? iconElem = widgetElement.childNodes
        .whereType<dom.Element>()
        .firstWhereOrNull((e) => e is FlutterCupertinoIcon);
    return WebFHTMLElement(
      tagName: 'DIV',
      controller: widgetElement.ownerDocument.controller,
      parentElement: widgetElement,
      children: widgetElement.childNodes
          .where((n) => n != iconElem)
          .map((n) => WebFWidgetElementChild(child: n.toWidget()))
          .toList(),
    );
  }
}
