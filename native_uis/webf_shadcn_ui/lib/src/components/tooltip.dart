/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'tooltip_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadTooltip].
///
/// Exposed as `<flutter-shadcn-tooltip>` in the DOM.
class FlutterShadcnTooltip extends FlutterShadcnTooltipBindings {
  FlutterShadcnTooltip(super.context);

  String? _content;
  int _showDelay = 200;
  int _hideDelay = 0;
  String _placement = 'top';

  @override
  String? get content => _content;

  @override
  set content(value) {
    final newValue = value?.toString();
    if (newValue != _content) {
      _content = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get showDelay => _showDelay.toString();

  @override
  set showDelay(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 200;
    if (newValue != _showDelay) {
      _showDelay = newValue;
    }
  }

  @override
  String get hideDelay => _hideDelay.toString();

  @override
  set hideDelay(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 0;
    if (newValue != _hideDelay) {
      _hideDelay = newValue;
    }
  }

  @override
  String get placement => _placement;

  @override
  set placement(value) {
    final newValue = value?.toString() ?? 'top';
    if (newValue != _placement) {
      _placement = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTooltipState(this);
}

class FlutterShadcnTooltipState extends WebFWidgetElementState {
  FlutterShadcnTooltipState(super.widgetElement);

  @override
  FlutterShadcnTooltip get widgetElement =>
      super.widgetElement as FlutterShadcnTooltip;

  @override
  Widget build(BuildContext context) {
    Widget? childWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      childWidget = WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    }

    if (widgetElement.content == null || childWidget == null) {
      return childWidget ?? const SizedBox.shrink();
    }

    return ShadTooltip(
      builder: (context) => Text(widgetElement.content!),
      waitDuration: Duration(milliseconds: widgetElement._showDelay),
      showDuration: Duration(milliseconds: widgetElement._hideDelay),
      child: childWidget,
    );
  }
}
