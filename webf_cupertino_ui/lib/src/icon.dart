/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'cupertino_icons_map_generated.dart';
import 'icon_bindings_generated.dart';

class FlutterCupertinoIcon extends FlutterCupertinoIconBindings {
  FlutterCupertinoIcon(super.context);

  String? _type;
  String? _label;

  @override
  String get type => _type ?? '';

  @override
  set type(dynamic value) {
    _type = value?.toString();
  }

  @override
  String? get label => _label;

  @override
  set label(dynamic value) {
    _label = value?.toString();
  }

  // Generated icon lookup map (see lib/src/cupertino_icons_map_generated.dart)
  static final Map<String, IconData> _iconMap = kCupertinoIconMap;

  static IconData? getIconType(String type) {
    return _iconMap[type];
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoIconState(this);
  }
}

class FlutterCupertinoIconState extends WebFWidgetElementState {
  FlutterCupertinoIconState(super.widgetElement);

  @override
  FlutterCupertinoIcon get widgetElement => super.widgetElement as FlutterCupertinoIcon;

  @override
  Widget build(BuildContext context) {
    IconData? iconType = FlutterCupertinoIcon.getIconType(widgetElement.type ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      color: widgetElement.renderStyle.color.value,
      size: widgetElement.renderStyle.fontSize.computedValue,
      semanticLabel: widgetElement.label ?? 'Text to announce in accessibility modes',
    );
  }
}
