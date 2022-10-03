/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'render_object_to_flutter_element_adapter.dart';

class WebFWidgetElementToWidgetAdapter<T extends RenderObject> extends SingleChildRenderObjectWidget {
  WebFWidgetElementToWidgetAdapter({
    Widget? child,
    required this.container,
    this.debugShortDescription,
  }) : super(key: GlobalObjectKey(container), child: child);

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderObject container;

  /// A short description of this widget used by debugging aids.
  final String? debugShortDescription;

  @override
  WebFRenderObjectToWidgetElement<T> createElement() => WebFRenderObjectToWidgetElement<T>(this);

  @override
  RenderObject createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}

  @override
  String toStringShort() => debugShortDescription ?? super.toStringShort();
}
