/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

// Element class: Handles attributes and creates state
class FlutterCupertinoFormRow extends WidgetElement {
  FlutterCupertinoFormRow(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    // Attributes related to the core widget configuration, if any, would go here.
    // Padding is handled by style in the State's build method.
  }

  @override
  FlutterCupertinoFormRowState createState() => FlutterCupertinoFormRowState(this);

  @override
  FlutterCupertinoFormRowState? get state => super.state as FlutterCupertinoFormRowState?;
}

// State class: Handles the actual building of the Flutter widget
class FlutterCupertinoFormRowState extends WebFWidgetElementState {
  FlutterCupertinoFormRowState(super.widgetElement);

  @override
  FlutterCupertinoFormRow get widgetElement => super.widgetElement as FlutterCupertinoFormRow;

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

  Widget? _getDefaultChild() {
    final defaultSlotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.getAttribute('slotName') == null;
      }
      return false;
    });
    return defaultSlotNode?.toWidget();
  }

  @override
  Widget build(BuildContext context) {
    // Use padding from style ONLY if it's explicitly set and non-zero,
    // otherwise let CupertinoFormRow use its default by passing null.
    EdgeInsetsGeometry? padding = widgetElement.renderStyle.padding;
    if (padding == EdgeInsets.zero) { 
      // If style resolves to zero (likely default when not set), pass null
      padding = null;
    }

    Widget? prefixWidget = _getChildBySlotName('prefix');
    Widget? helperWidget = _getChildBySlotName('helper');
    Widget? errorWidget = _getChildBySlotName('error');
    Widget childWidget = _getDefaultChild() ?? const SizedBox();

    // Build the core form row
    final formRow = CupertinoFormRow(
      prefix: prefixWidget,
      padding: padding, // Pass null or the specific non-zero value from style
      helper: helperWidget,
      error: errorWidget,
      child: childWidget,
    );

    // *** Wrap in Column with MainAxisSize.min to constrain height ***
    // This allows the FormRow to determine its natural height based on content,
    // while preventing it from expanding infinitely if vertical constraints are unbounded.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [formRow],
    );
    // *************************************************************
  }
}
