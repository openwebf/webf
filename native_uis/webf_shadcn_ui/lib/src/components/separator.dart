/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'separator_bindings_generated.dart';

/// WebF custom element that provides a visual separator.
///
/// Exposed as `<flutter-shadcn-separator>` in the DOM.
class FlutterShadcnSeparator extends FlutterShadcnSeparatorBindings {
  FlutterShadcnSeparator(super.context);

  String _orientation = 'horizontal';

  @override
  String? get orientation => _orientation;

  @override
  set orientation(value) {
    final newValue = value?.toString() ?? 'horizontal';
    if (newValue != _orientation) {
      _orientation = newValue;
      state?.requestUpdateState(() {});
    }
  }

  bool get isVertical => _orientation.toLowerCase() == 'vertical';

  @override
  WebFWidgetElementState createState() => FlutterShadcnSeparatorState(this);
}

class FlutterShadcnSeparatorState extends WebFWidgetElementState {
  FlutterShadcnSeparatorState(super.widgetElement);

  @override
  FlutterShadcnSeparator get widgetElement =>
      super.widgetElement as FlutterShadcnSeparator;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (widgetElement.isVertical) {
      return Container(
        width: 1,
        color: theme.colorScheme.border,
      );
    }

    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.border,
    );
  }
}
