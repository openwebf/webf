/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'textarea_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadTextarea].
///
/// Exposed as `<flutter-shadcn-textarea>` in the DOM.
class FlutterShadcnTextarea extends FlutterShadcnTextareaBindings {
  FlutterShadcnTextarea(super.context);

  String _value = '';
  String? _placeholder;
  int _rows = 3;
  bool _disabled = false;
  bool _readonly = false;
  int? _maxLength;
  bool _required = false;
  bool _autofocus = false;

  @override
  String get value => _value;

  @override
  set value(value) {
    final newValue = value?.toString() ?? '';
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final newValue = value?.toString();
    if (newValue != _placeholder) {
      _placeholder = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get rows => _rows.toString();

  @override
  set rows(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 3;
    if (newValue != _rows) {
      _rows = newValue;
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
  bool get readonly => _readonly;

  @override
  set readonly(value) {
    final newValue = value == true;
    if (newValue != _readonly) {
      _readonly = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get maxlength => _maxLength?.toString();

  @override
  set maxlength(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _maxLength) {
      _maxLength = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get required => _required;

  @override
  set required(value) {
    final newValue = value == true;
    if (newValue != _required) {
      _required = newValue;
    }
  }

  @override
  bool get autofocus => _autofocus;

  @override
  set autofocus(value) {
    final newValue = value == true;
    if (newValue != _autofocus) {
      _autofocus = newValue;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTextareaState(this);
}

class FlutterShadcnTextareaState extends WebFWidgetElementState {
  FlutterShadcnTextareaState(super.widgetElement);

  late TextEditingController _controller;
  late FocusNode _focusNode;
  double? _resizedWidth;
  double? _resizedHeight;

  @override
  FlutterShadcnTextarea get widgetElement =>
      super.widgetElement as FlutterShadcnTextarea;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widgetElement.value);
    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widgetElement.dispatchEvent(Event('focus'));
    } else {
      widgetElement.dispatchEvent(Event('blur'));
      widgetElement.dispatchEvent(Event('change'));
    }
  }

  _TextareaResizeMode _effectiveResizeMode() {
    final resizeValue =
        widgetElement.style.getPropertyValue('resize').trim().toLowerCase();

    switch (resizeValue) {
      case 'none':
        return _TextareaResizeMode.none;
      case 'horizontal':
      case 'inline':
        return _TextareaResizeMode.horizontal;
      case 'vertical':
      case 'block':
        return _TextareaResizeMode.vertical;
      case 'both':
      case '':
        return _TextareaResizeMode.both;
      default:
        return _TextareaResizeMode.both;
    }
  }

  double _defaultHeightForRows() {
    return (_rowsToPixels(widgetElement._rows)).clamp(80.0, 500.0);
  }

  double _rowsToPixels(int rows) {
    return rows * 24.0 + 16.0;
  }

  double? _normalizeMax(double? value) {
    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }
    return value;
  }

  double _clampWidth(double width, BoxConstraints constraints) {
    final style = widgetElement.renderStyle;
    final minWidth =
        style.minWidth.computedValue > 0 ? style.minWidth.computedValue : 120.0;
    final maxWidth = _normalizeMax(style.maxWidth.computedValue);
    final viewportMaxWidth =
        constraints.maxWidth.isFinite ? constraints.maxWidth : width;
    final effectiveMaxWidth = maxWidth != null
        ? maxWidth.clamp(minWidth, viewportMaxWidth)
        : viewportMaxWidth;
    return width.clamp(minWidth, effectiveMaxWidth);
  }

  double _clampHeight(double height) {
    final style = widgetElement.renderStyle;
    final minHeight = style.minHeight.computedValue > 0
        ? style.minHeight.computedValue
        : _defaultHeightForRows();
    final maxHeight = _normalizeMax(style.maxHeight.computedValue) ?? 500.0;
    return height.clamp(minHeight, maxHeight);
  }

  SystemMouseCursor _cursorFor(_TextareaResizeMode mode) {
    switch (mode) {
      case _TextareaResizeMode.horizontal:
        return SystemMouseCursors.resizeLeftRight;
      case _TextareaResizeMode.vertical:
        return SystemMouseCursors.resizeUpDown;
      case _TextareaResizeMode.both:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case _TextareaResizeMode.none:
        return SystemMouseCursors.basic;
    }
  }

  void _handleResize(
    DragUpdateDetails details, {
    required _TextareaResizeMode mode,
    required BoxConstraints constraints,
    required double currentWidth,
    required double currentHeight,
  }) {
    if (mode == _TextareaResizeMode.none) return;

    _focusNode.requestFocus();

    setState(() {
      if (mode.allowsHorizontal) {
        _resizedWidth =
            _clampWidth(currentWidth + details.delta.dx, constraints);
      }
      if (mode.allowsVertical) {
        _resizedHeight = _clampHeight(currentHeight + details.delta.dy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync controller with external value changes
    if (_controller.text != widgetElement.value) {
      _controller.text = widgetElement.value;
    }

    final resizeMode = _effectiveResizeMode();

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = widgetElement.renderStyle;
        final styleWidth =
            style.width.computedValue > 0 ? style.width.computedValue : null;
        final styleHeight =
            style.height.computedValue > 0 ? style.height.computedValue : null;

        final currentWidth = _resizedWidth ??
            styleWidth ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : null);
        final currentHeight =
            _resizedHeight ?? styleHeight ?? _defaultHeightForRows();

        final textarea = ShadTextarea(
          controller: _controller,
          focusNode: _focusNode,
          placeholder: widgetElement.placeholder != null
              ? Text(widgetElement.placeholder!)
              : null,
          enabled: !widgetElement.disabled,
          readOnly: widgetElement.readonly,
          autofocus: widgetElement.autofocus,
          maxLength: widgetElement._maxLength,
          minHeight: _clampHeight(currentHeight),
          maxHeight: _clampHeight(currentHeight),
          resizable: false,
          onChanged: (value) {
            widgetElement._value = value;
            widgetElement.dispatchEvent(Event('input'));
          },
        );

        final sizedTextarea = SizedBox(
          width: currentWidth,
          child: textarea,
        );

        if (resizeMode == _TextareaResizeMode.none ||
            widgetElement.disabled ||
            currentWidth == null) {
          return sizedTextarea;
        }

        return Stack(
          children: [
            sizedTextarea,
            Positioned(
              right: 2,
              bottom: 2,
              child: MouseRegion(
                cursor: _cursorFor(resizeMode),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) => _handleResize(
                    details,
                    mode: resizeMode,
                    constraints: constraints,
                    currentWidth: currentWidth,
                    currentHeight: currentHeight,
                  ),
                  child: const ShadDefaultResizeGrip(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _TextareaResizeMode {
  none,
  horizontal,
  vertical,
  both;

  bool get allowsHorizontal =>
      this == _TextareaResizeMode.horizontal ||
      this == _TextareaResizeMode.both;

  bool get allowsVertical =>
      this == _TextareaResizeMode.vertical || this == _TextareaResizeMode.both;
}
