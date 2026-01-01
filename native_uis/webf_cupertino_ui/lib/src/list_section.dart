/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'list_section_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoListSection].
///
/// Exposed as `<flutter-cupertino-list-section>` in the DOM, with optional
/// `<flutter-cupertino-list-section-header>` and
/// `<flutter-cupertino-list-section-footer>` children.
class FlutterCupertinoListSection extends FlutterCupertinoListSectionBindings {
  FlutterCupertinoListSection(super.context);

  bool _insetGrouped = false;

  @override
  bool get insetGrouped => _insetGrouped;

  @override
  bool get allowsInfiniteHeight => true;

  @override
  set insetGrouped(value) {
    final bool next = value == true;
    if (next != _insetGrouped) {
      _insetGrouped = next;
      state?.requestUpdateState(() {});
    }
  }

  bool get isInsetGrouped => _insetGrouped;

  @override
  FlutterCupertinoListSectionState createState() =>
      FlutterCupertinoListSectionState(this);

  @override
  FlutterCupertinoListSectionState? get state =>
      super.state as FlutterCupertinoListSectionState?;
}

class FlutterCupertinoListSectionState extends WebFWidgetElementState {
  FlutterCupertinoListSectionState(super.widgetElement);

  @override
  FlutterCupertinoListSection get widgetElement =>
      super.widgetElement as FlutterCupertinoListSection;

  Widget? _getChildOfType<T>() {
    final dom.Node? childNode =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    return WebFWidgetElementChild(
      child: childNode?.toWidget(),
    );
  }

  List<Widget> _getChildrenWithoutSlots() {
    return widgetElement.childNodes
        .where((node) {
          if (node is dom.Element) {
            return !(node is FlutterCupertinoListSectionHeader ||
                node is FlutterCupertinoListSectionFooter);
          }
          return false;
        })
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .nonNulls
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    final EdgeInsetsGeometry styleMargin = renderStyle.margin;
    final Color? backgroundColor = renderStyle.backgroundColor?.value;
    final BoxDecoration? decoration =
        renderStyle.decoration as BoxDecoration?;
    const Clip clipBehavior = Clip.hardEdge;

    final Widget? headerWidget =
        _getChildOfType<FlutterCupertinoListSectionHeader>();
    final Widget? footerWidget =
        _getChildOfType<FlutterCupertinoListSectionFooter>();
    final List<Widget> childrenWidgets = _getChildrenWithoutSlots();

    final bool useInsetGrouped = widgetElement.isInsetGrouped;

    EdgeInsetsGeometry? margin;
    if (useInsetGrouped) {
      if (styleMargin != EdgeInsets.zero) {
        margin = styleMargin;
      } else {
        margin = null;
      }
    } else {
      if (styleMargin != EdgeInsets.zero) {
        margin = styleMargin;
      } else {
        margin = null;
      }
    }

    final Widget sectionWidget;
    if (useInsetGrouped) {
      sectionWidget = CupertinoListSection.insetGrouped(
        key: ObjectKey(widgetElement),
        header: headerWidget,
        footer: footerWidget,
        margin: margin,
        backgroundColor:
            backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        decoration: decoration,
        clipBehavior: clipBehavior,
        children: childrenWidgets,
      );
    } else {
      sectionWidget = CupertinoListSection(
        key: ObjectKey(widgetElement),
        header: headerWidget,
        footer: footerWidget,
        margin: margin ?? EdgeInsets.zero,
        backgroundColor:
            backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        decoration: decoration,
        clipBehavior: clipBehavior,
        children: childrenWidgets,
      );
    }

    return sectionWidget;
  }
}

class FlutterCupertinoListSectionHeader extends WidgetElement {
  FlutterCupertinoListSectionHeader(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListSectionHeaderState(this);
  }
}

class FlutterCupertinoListSectionHeaderState extends WebFWidgetElementState {
  FlutterCupertinoListSectionHeaderState(super.widgetElement);

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

class FlutterCupertinoListSectionFooter extends WidgetElement {
  FlutterCupertinoListSectionFooter(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListSectionFooterState(this);
  }
}

class FlutterCupertinoListSectionFooterState extends WebFWidgetElementState {
  FlutterCupertinoListSectionFooterState(super.widgetElement);

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
