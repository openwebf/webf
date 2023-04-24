/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'widget_element.dart';
import 'render_object_to_flutter_element_adapter.dart';

class WebFWidgetElementToWidgetAdapter<T extends RenderObject> extends SingleChildRenderObjectWidget {
  WebFWidgetElementToWidgetAdapter({
    Widget? child,
    required this.container,
    required this.widgetElement,
    this.debugShortDescription,
  }) : super(key: GlobalObjectKey(container), child: child);

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderObject container;

  final WidgetElement widgetElement;

  /// A short description of this widget used by debugging aids.
  final String? debugShortDescription;

  @override
  WebFRenderObjectToWidgetElement<T> createElement() => WebFRenderObjectToWidgetElement<T>(this);

  @override
  RenderObject createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    // WidgetElement can be remounted to the DOM tree and trigger widget adapter updates.
    // We need to check if the widgetElement is actually disconnected before unmounting the renderWidget.
    if (!widgetElement.isConnected) {
      widgetElement.unmountRenderObject();
    }
  }

  @override
  String toStringShort() => debugShortDescription ?? super.toStringShort();
}
