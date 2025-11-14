/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:collection/collection.dart';

// Element class
class FlutterCupertinoListTile extends WidgetElement {
  FlutterCupertinoListTile(super.context);

  bool _notched = false;
  bool _showChevron = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['notched'] = ElementAttributeProperty(
      getter: () => _notched.toString(),
      setter: (value) {
        _notched = value == 'true';
        state?.setState(() {});
      }
    );
    attributes['show-chevron'] = ElementAttributeProperty(
      getter: () => _showChevron.toString(),
      setter: (value) {
        _showChevron = value == 'true';
        state?.setState(() {});
      }
    );
    // Note: padding, background colors, leading size/spacing handled by Flutter defaults for now.
  }

  bool get isNotched => _notched;
  bool get shouldShowChevron => _showChevron;

  @override
  FlutterCupertinoListTileState createState() => FlutterCupertinoListTileState(this);

  @override
  FlutterCupertinoListTileState? get state => super.state as FlutterCupertinoListTileState?;
}

// State class
class FlutterCupertinoListTileState extends WebFWidgetElementState {
  FlutterCupertinoListTileState(super.widgetElement);

  @override
  FlutterCupertinoListTile get widgetElement => super.widgetElement as FlutterCupertinoListTile;

  // --- Slot Helper ---
  Widget? _getChildOfType<T>() {
    final childNode = widgetElement.childNodes.firstWhereOrNull((node) {
      return node is T;
    });
    return WebFWidgetElementChild(child: childNode?.toWidget());
  }

  // Title is the default slot (first element without specific component type)
  Widget? _getDefaultChild() {
    final defaultSlotNode = widgetElement.childNodes.firstWhereOrNull((node) {
       if (node is dom.Element) {
        // Skip specific child component types
        return !(node is FlutterCupertinoListTileLeading ||
                 node is FlutterCupertinoListTileSubtitle ||
                 node is FlutterCupertinoListTileAdditionalInfo ||
                 node is FlutterCupertinoListTileTrailing);
      }
      // Allow simple text as title
      if (node is dom.TextNode && node.data.trim().isNotEmpty) {
        return true;
      }
      return false;
    });
    // Wrap TextNode in a Text widget if found
     if (defaultSlotNode is dom.TextNode) {
       return Text(defaultSlotNode.data);
     }
    return WebFWidgetElementChild(child: defaultSlotNode?.toWidget());
  }
  // --- End Slot Helper ---

  // --- Event Handling ---

  void _handleTap() {
    // Dispatch standard 'click' event
    widgetElement.dispatchEvent(Event(EVENT_CLICK));
  }
  // --- End Event Handling ---

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = _getChildOfType<FlutterCupertinoListTileLeading>();
    Widget? titleWidget = _getDefaultChild(); // Required
    Widget? subtitleWidget = _getChildOfType<FlutterCupertinoListTileSubtitle>();
    Widget? additionalInfoWidget = _getChildOfType<FlutterCupertinoListTileAdditionalInfo>();
    Widget? trailingWidget = _getChildOfType<FlutterCupertinoListTileTrailing>();

    // Default to showing chevron if attribute is set and no trailing slot is provided
    if (trailingWidget == null && widgetElement.shouldShowChevron) {
      trailingWidget = const CupertinoListTileChevron();
    }

    // Build the actual list tile widget
    Widget listTileWidget;
    if (widgetElement.isNotched) {
      listTileWidget = CupertinoListTile.notched(
        key: ObjectKey(widgetElement),
        title: titleWidget ?? const SizedBox(),
        subtitle: subtitleWidget,
        additionalInfo: additionalInfoWidget,
        leading: leadingWidget,
        trailing: trailingWidget,
        onTap: _handleTap,
      );
    } else {
      listTileWidget = CupertinoListTile(
        key: ObjectKey(widgetElement),
        title: titleWidget ?? const SizedBox(),
        subtitle: subtitleWidget,
        additionalInfo: additionalInfoWidget,
        leading: leadingWidget,
        trailing: trailingWidget,
        onTap: _handleTap,
      );
    }

    // *** Wrap in Column with MainAxisSize.min to constrain height ***
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [listTileWidget],
    );
    // *************************************************************
  }
}

// Sub-component classes for list tile slots
class FlutterCupertinoListTileLeading extends WidgetElement {
  FlutterCupertinoListTileLeading(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListTileLeadingState(this);
  }
}

class FlutterCupertinoListTileLeadingState extends WebFWidgetElementState {
  FlutterCupertinoListTileLeadingState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}

class FlutterCupertinoListTileSubtitle extends WidgetElement {
  FlutterCupertinoListTileSubtitle(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListTileSubtitleState(this);
  }
}

class FlutterCupertinoListTileSubtitleState extends WebFWidgetElementState {
  FlutterCupertinoListTileSubtitleState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}

class FlutterCupertinoListTileAdditionalInfo extends WidgetElement {
  FlutterCupertinoListTileAdditionalInfo(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListTileAdditionalInfoState(this);
  }
}

class FlutterCupertinoListTileAdditionalInfoState extends WebFWidgetElementState {
  FlutterCupertinoListTileAdditionalInfoState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}

class FlutterCupertinoListTileTrailing extends WidgetElement {
  FlutterCupertinoListTileTrailing(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoListTileTrailingState(this);
  }
}

class FlutterCupertinoListTileTrailingState extends WebFWidgetElementState {
  FlutterCupertinoListTileTrailingState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}
