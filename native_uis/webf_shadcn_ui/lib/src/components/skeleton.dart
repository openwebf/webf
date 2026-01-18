/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'skeleton_bindings_generated.dart';

/// WebF custom element for skeleton loading placeholders.
///
/// Exposed as `<flutter-shadcn-skeleton>` in the DOM.
class FlutterShadcnSkeleton extends FlutterShadcnSkeletonBindings {
  FlutterShadcnSkeleton(super.context);

  double? _width;
  double? _height;
  bool _circle = false;

  @override
  String? get width => _width?.toString();

  @override
  set width(value) {
    final newValue = value != null ? double.tryParse(value.toString()) : null;
    if (newValue != _width) {
      _width = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get height => _height?.toString();

  @override
  set height(value) {
    final newValue = value != null ? double.tryParse(value.toString()) : null;
    if (newValue != _height) {
      _height = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get circle => _circle;

  @override
  set circle(value) {
    final newValue = value == true;
    if (newValue != _circle) {
      _circle = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSkeletonState(this);
}

class FlutterShadcnSkeletonState extends WebFWidgetElementState {
  FlutterShadcnSkeletonState(super.widgetElement);

  @override
  FlutterShadcnSkeleton get widgetElement =>
      super.widgetElement as FlutterShadcnSkeleton;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      width: widgetElement._width,
      height: widgetElement._height,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: widgetElement.circle
            ? BorderRadius.circular(
                (widgetElement._width ?? widgetElement._height ?? 40) / 2)
            : BorderRadius.circular(4),
      ),
    );
  }
}
