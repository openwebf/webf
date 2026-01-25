/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';
import 'lucide_icons_map_generated.dart';
import 'icon_bindings_generated.dart';

class FlutterLucideIcon extends FlutterLucideIconBindings {
  FlutterLucideIcon(super.context);

  String? _name;
  String? _label;
  double? _strokeWidth;

  @override
  String get name => _name ?? '';

  @override
  set name(dynamic value) {
    _name = value?.toString();
  }

  @override
  String? get label => _label;

  @override
  set label(dynamic value) {
    _label = value?.toString();
  }

  @override
  double? get strokeWidth => _strokeWidth;

  @override
  set strokeWidth(dynamic value) {
    if (value == null) {
      _strokeWidth = null;
    } else if (value is num) {
      _strokeWidth = value.toDouble();
    } else {
      _strokeWidth = double.tryParse(value.toString());
    }
  }

  /// Get the stroke width as an integer variant (100-600) if valid
  int? get strokeWidthVariant {
    if (_strokeWidth == null) return null;
    final variant = _strokeWidth!.toInt();
    if ([100, 200, 300, 400, 500, 600].contains(variant)) {
      return variant;
    }
    return null;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterLucideIconState(this);
  }
}

class FlutterLucideIconState extends WebFWidgetElementState {
  FlutterLucideIconState(super.widgetElement);

  @override
  FlutterLucideIcon get widgetElement => super.widgetElement as FlutterLucideIcon;

  @override
  Widget build(BuildContext context) {
    final IconData? iconData = getLucideIcon(
      widgetElement.name,
      widgetElement.strokeWidthVariant,
    );
    if (iconData == null) return SizedBox.shrink();

    return Icon(
      iconData,
      color: widgetElement.renderStyle.color.value,
      size: widgetElement.renderStyle.fontSize.computedValue,
      semanticLabel: widgetElement.label ?? 'Lucide icon',
    );
  }
}
