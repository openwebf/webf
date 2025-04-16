/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull and whereNotNull

// Element class: Handles attributes and creates state
class FlutterCupertinoFormSection extends WidgetElement {
  FlutterCupertinoFormSection(super.context);

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
    // Clip behavior might be complex to map directly, using default for now.
    attributes['clip-behavior'] = ElementAttributeProperty(
      getter: () => 'none', // Defaulting, could expose if needed
      setter: (value) { /* TODO: Implement if needed */ }
    );
  }

  // Expose insetGrouped for the State class
  bool get isInsetGrouped => _insetGrouped;

  @override
  FlutterCupertinoFormSectionState createState() => FlutterCupertinoFormSectionState(this);

  @override
  FlutterCupertinoFormSectionState? get state => super.state as FlutterCupertinoFormSectionState?;
}

// State class: Handles the actual building of the Flutter widget
class FlutterCupertinoFormSectionState extends WebFWidgetElementState {
  FlutterCupertinoFormSectionState(super.widgetElement);

  @override
  FlutterCupertinoFormSection get widgetElement => super.widgetElement as FlutterCupertinoFormSection;

  // Helper methods moved to State
  Widget? _getChildBySlotName(String name) {
    final slotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.getAttribute('slotName') == name;
      }
      return false;
    });
    return slotNode?.toWidget();
  }

  List<Widget> _getChildrenWithoutSlots() {
    return widgetElement.childNodes
        .where((node) {
          // Only include Element nodes that don't have a slotName attribute
          if (node is dom.Element) {
            return node.getAttribute('slotName') == null;
          }
          return false; // Ignore non-element nodes
        })
        .map((node) => node.toWidget())
        .whereNotNull() // Ensure toWidget didn't return null
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get style properties
    EdgeInsetsGeometry? styleMargin = widgetElement.renderStyle.margin;
    Color? backgroundColor = widgetElement.renderStyle.backgroundColor?.value;
    BoxDecoration? decoration = widgetElement.renderStyle.decoration as BoxDecoration?;
    Clip clipBehavior = Clip.none; // Default

    Widget? headerWidget = _getChildBySlotName('header');
    Widget? footerWidget = _getChildBySlotName('footer');
    List<Widget> childrenWidgets = _getChildrenWithoutSlots();

    final bool useInsetGrouped = widgetElement.isInsetGrouped;

    Widget sectionWidget;
    if (useInsetGrouped) {
      // For insetGrouped, only pass margin if explicitly set to non-zero in style
      if (styleMargin != EdgeInsets.zero) {
         sectionWidget = CupertinoFormSection.insetGrouped(
          key: ObjectKey(widgetElement), 
          header: headerWidget,
          footer: footerWidget,
          margin: styleMargin, // Pass the specific non-zero margin from style
          backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: childrenWidgets,
        );
      } else {
         // Omit margin parameter to use Flutter's default inset margin
         sectionWidget = CupertinoFormSection.insetGrouped(
          key: ObjectKey(widgetElement), 
          header: headerWidget,
          footer: footerWidget,
          // margin: is omitted here
          backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: childrenWidgets,
        );
      }
    } else {
      // For standard section, default margin is zero. Pass styleMargin if set, otherwise zero.
      sectionWidget = CupertinoFormSection(
        key: ObjectKey(widgetElement), 
        header: headerWidget,
        footer: footerWidget,
        margin: (styleMargin != EdgeInsets.zero) ? styleMargin : EdgeInsets.zero,
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        decoration: decoration,
        clipBehavior: clipBehavior,
        children: childrenWidgets,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [sectionWidget],
    );
  }
}
