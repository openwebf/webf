/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:collection/collection.dart';

// Element class: Handles attributes and creates state
class FlutterCupertinoListSection extends WidgetElement {
  FlutterCupertinoListSection(super.context);

  bool _insetGrouped = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['inset-grouped'] = ElementAttributeProperty(
      getter: () => _insetGrouped.toString(),
      setter: (value) {
        _insetGrouped = value == 'true';
        // Rebuild the state when this attribute changes
        state?.setState(() {}); 
      }
    );
    // Note: margin, background-color, decoration, etc., handled via style in State
    // More specific attributes like divider margins, separator color could be added here if needed.
  }

  // Expose insetGrouped for the State class
  bool get isInsetGrouped => _insetGrouped;

  @override
  FlutterCupertinoListSectionState createState() => FlutterCupertinoListSectionState(this);

  @override
  FlutterCupertinoListSectionState? get state => super.state as FlutterCupertinoListSectionState?;
}

// State class: Handles the actual building of the Flutter widget
class FlutterCupertinoListSectionState extends WebFWidgetElementState {
  FlutterCupertinoListSectionState(super.widgetElement);

  @override
  FlutterCupertinoListSection get widgetElement => super.widgetElement as FlutterCupertinoListSection;

  // Helper methods moved to State
  Widget? _getChildOfType<T>() {
    final childNode = widgetElement.childNodes.firstWhereOrNull((node) {
      return node is T;
    });
    return WebFWidgetElementChild(child: childNode?.toWidget());
  }

  List<Widget> _getChildrenWithoutSlots() {
    return widgetElement.childNodes
        .where((node) {
          if (node is dom.Element) {
            // Skip specific child component types
            return !(node is FlutterCupertinoListSectionHeader ||
                     node is FlutterCupertinoListSectionFooter);
          }
          return false; // Ignore non-element nodes for children list
        })
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .nonNulls
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get style properties
    EdgeInsetsGeometry? styleMargin = widgetElement.renderStyle.margin;
    Color? backgroundColor = widgetElement.renderStyle.backgroundColor?.value;
    BoxDecoration? decoration = widgetElement.renderStyle.decoration as BoxDecoration?;
    Clip clipBehavior = Clip.hardEdge; // Default for insetGrouped, reasonable default otherwise

    Widget? headerWidget = _getChildOfType<FlutterCupertinoListSectionHeader>();
    Widget? footerWidget = _getChildOfType<FlutterCupertinoListSectionFooter>();
    List<Widget> childrenWidgets = _getChildrenWithoutSlots();

    final bool useInsetGrouped = widgetElement.isInsetGrouped;

    // Determine margin based on insetGrouped and style
    EdgeInsetsGeometry? margin;
    if (useInsetGrouped) {
       // Only use style margin if explicitly non-zero for inset grouped
       if (styleMargin != EdgeInsets.zero) {
         margin = styleMargin;
       } else {
         margin = null; // Let Flutter use default inset margin
       }
    } else {
       // Use style margin if set and non-zero, otherwise default to Flutter's default (which might be zero or specific)
       if (styleMargin != EdgeInsets.zero) {
         margin = styleMargin;
       } else {
         margin = null; // Let Flutter use its default margin
       }
    }


    Widget sectionWidget;
    if (useInsetGrouped) {
      sectionWidget = CupertinoListSection.insetGrouped(
        key: ObjectKey(widgetElement), 
        header: headerWidget,
        footer: footerWidget,
        margin: margin, // Pass null to use default, or specific value
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        decoration: decoration,
        clipBehavior: clipBehavior,
        children: childrenWidgets,
        // dividerMargin, additionalDividerMargin, separatorColor etc. omitted for simplicity
      );
    } else {
      sectionWidget = CupertinoListSection(
        key: ObjectKey(widgetElement), 
        header: headerWidget,
        footer: footerWidget,
        margin: margin ?? const EdgeInsets.all(0), // Standard section expects non-null margin, default is EdgeInsets.zero
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        decoration: decoration,
        clipBehavior: clipBehavior,
        children: childrenWidgets,
         // dividerMargin, additionalDividerMargin, separatorColor etc. omitted for simplicity
      );
    }

    // Wrap in Column to constrain height
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [sectionWidget],
    );
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
            children: widgetElement.childNodes.toWidgetList()));
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
            children: widgetElement.childNodes.toWidgetList()));
  }
}