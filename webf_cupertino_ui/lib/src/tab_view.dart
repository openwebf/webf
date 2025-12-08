/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

/// WebF wrapper for Flutter's CupertinoTabView.
///
/// Renders its children as the root of a per-tab Navigator.
class FlutterCupertinoTabView extends WidgetElement {
  FlutterCupertinoTabView(super.context);

  String? _defaultTitle;
  String? _restorationScopeId;

  String? get defaultTitle => _defaultTitle;
  String? get restorationScopeId => _restorationScopeId;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['default-title'] = ElementAttributeProperty(
      getter: () => _defaultTitle,
      setter: (value) {
        _defaultTitle = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _defaultTitle = null;
        state?.requestUpdateState(() {});
      },
    );
    attributes['restoration-scope-id'] = ElementAttributeProperty(
      getter: () => _restorationScopeId,
      setter: (value) {
        _restorationScopeId = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _restorationScopeId = null;
        state?.requestUpdateState(() {});
      },
    );
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabViewState(this);
  }
}

class FlutterCupertinoTabViewState extends WebFWidgetElementState {
  FlutterCupertinoTabViewState(super.widgetElement);

  @override
  FlutterCupertinoTabView get widgetElement => super.widgetElement as FlutterCupertinoTabView;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      defaultTitle: widgetElement.defaultTitle,
      restorationScopeId: widgetElement.restorationScopeId,
      builder: (ctx) {
        return WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        );
      },
    );
  }
}
