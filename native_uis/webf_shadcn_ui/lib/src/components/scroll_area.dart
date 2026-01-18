/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'scroll_area_bindings_generated.dart';

/// WebF custom element for scrollable areas.
///
/// Exposed as `<flutter-shadcn-scroll-area>` in the DOM.
class FlutterShadcnScrollArea extends FlutterShadcnScrollAreaBindings {
  FlutterShadcnScrollArea(super.context);

  String _orientation = 'vertical';

  @override
  String get orientation => _orientation;

  @override
  set orientation(value) {
    final newValue = value?.toString() ?? 'vertical';
    if (newValue != _orientation) {
      _orientation = newValue;
      state?.requestUpdateState(() {});
    }
  }

  Axis get scrollDirection {
    switch (_orientation.toLowerCase()) {
      case 'horizontal':
        return Axis.horizontal;
      default:
        return Axis.vertical;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnScrollAreaState(this);
}

class FlutterShadcnScrollAreaState extends WebFWidgetElementState {
  FlutterShadcnScrollAreaState(super.widgetElement);

  @override
  FlutterShadcnScrollArea get widgetElement =>
      super.widgetElement as FlutterShadcnScrollArea;

  @override
  Widget build(BuildContext context) {
    final children = widgetElement.childNodes
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();

    Widget content;
    if (widgetElement.scrollDirection == Axis.horizontal) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return SingleChildScrollView(
      scrollDirection: widgetElement.scrollDirection,
      child: content,
    );
  }
}
