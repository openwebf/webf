/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'colors.dart';
import 'theme_bindings_generated.dart';

/// WebF custom element that provides shadcn_ui theming.
///
/// Exposed as `<flutter-shadcn-theme>` in the DOM.
/// Wraps child elements with [ShadApp] to provide theming context.
class FlutterShadcnTheme extends FlutterShadcnThemeBindings {
  FlutterShadcnTheme(super.context);

  String _colorScheme = 'zinc';
  String _brightness = 'system';
  double _radius = 0.5;

  @override
  String get colorScheme => _colorScheme;

  @override
  set colorScheme(value) {
    final newValue = value?.toString() ?? 'zinc';
    if (newValue != _colorScheme) {
      _colorScheme = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get brightness => _brightness;

  @override
  set brightness(value) {
    final newValue = value?.toString() ?? 'system';
    if (newValue != _brightness) {
      _brightness = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get radius => _radius.toString();

  @override
  set radius(value) {
    final newValue = double.tryParse(value?.toString() ?? '') ?? 0.5;
    if (newValue != _radius) {
      _radius = newValue;
      state?.requestUpdateState(() {});
    }
  }

  double get radiusValue => _radius;

  ThemeMode get themeMode {
    switch (_brightness.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnThemeState(this);
}

class FlutterShadcnThemeState extends WebFWidgetElementState {
  FlutterShadcnThemeState(super.widgetElement);

  @override
  FlutterShadcnTheme get widgetElement =>
      super.widgetElement as FlutterShadcnTheme;

  @override
  Widget build(BuildContext context) {
    final themeMode = widgetElement.themeMode;
    final radiusValue = widgetElement.radiusValue;
    final schemeName = widgetElement.colorScheme;

    // Determine the effective brightness
    Brightness effectiveBrightness;
    if (themeMode == ThemeMode.light) {
      effectiveBrightness = Brightness.light;
    } else if (themeMode == ThemeMode.dark) {
      effectiveBrightness = Brightness.dark;
    } else {
      effectiveBrightness = MediaQuery.platformBrightnessOf(context);
    }

    // Get color scheme for the effective brightness
    final colorScheme = getColorScheme(schemeName, effectiveBrightness);

    // Build theme data
    final theme = ShadThemeData(
      colorScheme: colorScheme,
      brightness: effectiveBrightness,
      radius: BorderRadius.circular(radiusValue * 12), // Scale to reasonable pixel values
    );

    // Wrap children with ShadTheme
    Widget content;
    if (widgetElement.childNodes.isEmpty) {
      content = const SizedBox.shrink();
    } else if (widgetElement.childNodes.length == 1) {
      content = WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetElement.childNodes
            .map((node) => WebFWidgetElementChild(child: node.toWidget()))
            .toList(),
      );
    }

    return ShadTheme(
      data: theme,
      child: content,
    );
  }
}
