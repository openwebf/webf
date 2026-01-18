/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'avatar_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadAvatar].
///
/// Exposed as `<flutter-shadcn-avatar>` in the DOM.
class FlutterShadcnAvatar extends FlutterShadcnAvatarBindings {
  FlutterShadcnAvatar(super.context);

  String? _src;
  String? _alt;
  String? _fallback;
  double _size = 40;

  @override
  String? get src => _src;

  @override
  set src(value) {
    final newValue = value?.toString();
    if (newValue != _src) {
      _src = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get alt => _alt;

  @override
  set alt(value) {
    final newValue = value?.toString();
    if (newValue != _alt) {
      _alt = newValue;
    }
  }

  @override
  String? get fallback => _fallback;

  @override
  set fallback(value) {
    final newValue = value?.toString();
    if (newValue != _fallback) {
      _fallback = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get size => _size.toString();

  @override
  set size(value) {
    final newValue = double.tryParse(value?.toString() ?? '') ?? 40;
    if (newValue != _size) {
      _size = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnAvatarState(this);
}

class FlutterShadcnAvatarState extends WebFWidgetElementState {
  FlutterShadcnAvatarState(super.widgetElement);

  @override
  FlutterShadcnAvatar get widgetElement =>
      super.widgetElement as FlutterShadcnAvatar;

  @override
  Widget build(BuildContext context) {
    return ShadAvatar(
      widgetElement.src ?? '',
      size: Size.square(widgetElement._size),
      placeholder: widgetElement.fallback != null
          ? Text(widgetElement.fallback!)
          : null,
    );
  }
}
