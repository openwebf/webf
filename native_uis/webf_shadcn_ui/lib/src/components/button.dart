/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'button_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadButton].
///
/// Exposed as `<flutter-shadcn-button>` in the DOM.
class FlutterShadcnButton extends FlutterShadcnButtonBindings {
  FlutterShadcnButton(super.context);

  String _variant = 'default';
  String _size = 'default';
  bool _disabled = false;
  bool _loading = false;
  String? _icon;

  @override
  String get variant => _variant;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get size => _size;

  @override
  set size(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _size) {
      _size = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get loading => _loading;

  @override
  set loading(value) {
    final newValue = value == true;
    if (newValue != _loading) {
      _loading = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get icon => _icon;

  @override
  set icon(value) {
    final newValue = value?.toString();
    if (newValue != _icon) {
      _icon = newValue;
      state?.requestUpdateState(() {});
    }
  }

  ShadButtonVariant get buttonVariant {
    switch (_variant.toLowerCase()) {
      case 'secondary':
        return ShadButtonVariant.secondary;
      case 'destructive':
        return ShadButtonVariant.destructive;
      case 'outline':
        return ShadButtonVariant.outline;
      case 'ghost':
        return ShadButtonVariant.ghost;
      case 'link':
        return ShadButtonVariant.link;
      default:
        return ShadButtonVariant.primary;
    }
  }

  ShadButtonSize get buttonSize {
    switch (_size.toLowerCase()) {
      case 'sm':
        return ShadButtonSize.sm;
      case 'lg':
        return ShadButtonSize.lg;
      default:
        return ShadButtonSize.regular;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnButtonState(this);
}

class FlutterShadcnButtonState extends WebFWidgetElementState {
  FlutterShadcnButtonState(super.widgetElement);

  @override
  FlutterShadcnButton get widgetElement =>
      super.widgetElement as FlutterShadcnButton;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widgetElement.disabled || widgetElement.loading;

    Widget? childWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      childWidget = WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    }

    return ShadButton.raw(
      variant: widgetElement.buttonVariant,
      size: widgetElement.buttonSize,
      enabled: !isDisabled,
      onPressed: isDisabled
          ? null
          : () {
              widgetElement.dispatchEvent(Event('click'));
            },
      child: widgetElement.loading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                if (childWidget != null) ...[
                  const SizedBox(width: 8),
                  childWidget,
                ],
              ],
            )
          : childWidget ?? const SizedBox.shrink(),
    );
  }
}
