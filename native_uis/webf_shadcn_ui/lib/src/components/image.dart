/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'image_bindings_generated.dart';

/// WebF custom element for images.
///
/// Exposed as `<flutter-shadcn-image>` in the DOM.
class FlutterShadcnImage extends FlutterShadcnImageBindings {
  FlutterShadcnImage(super.context);

  String? _src;
  String? _alt;
  double? _width;
  double? _height;
  String _fit = 'cover';

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
  String? get width => _width?.toString();

  @override
  set width(value) {
    final strValue = value?.toString();
    final newValue = strValue != null ? double.tryParse(strValue) : null;
    if (newValue != _width) {
      _width = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get height => _height?.toString();

  @override
  set height(value) {
    final strValue = value?.toString();
    final newValue = strValue != null ? double.tryParse(strValue) : null;
    if (newValue != _height) {
      _height = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get fit => _fit;

  @override
  set fit(value) {
    final newValue = value?.toString() ?? 'cover';
    if (newValue != _fit) {
      _fit = newValue;
      state?.requestUpdateState(() {});
    }
  }

  BoxFit get boxFit {
    switch (_fit.toLowerCase()) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'none':
        return BoxFit.none;
      case 'scaledown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnImageState(this);
}

class FlutterShadcnImageState extends WebFWidgetElementState {
  FlutterShadcnImageState(super.widgetElement);

  @override
  FlutterShadcnImage get widgetElement =>
      super.widgetElement as FlutterShadcnImage;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (widgetElement.src == null || widgetElement.src!.isEmpty) {
      return Container(
        width: widgetElement._width,
        height: widgetElement._height,
        color: theme.colorScheme.muted,
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      widgetElement.src!,
      width: widgetElement._width,
      height: widgetElement._height,
      fit: widgetElement.boxFit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widgetElement._width,
          height: widgetElement._height,
          color: theme.colorScheme.muted,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widgetElement._width,
          height: widgetElement._height,
          color: theme.colorScheme.muted,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
