/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'button_bindings_generated.dart';

class FlutterCupertinoButton extends FlutterCupertinoButtonBindings {
  FlutterCupertinoButton(super.context);

  String _variant = 'plain'; // plain | filled | tinted
  String _sizeStyle = 'small'; // small | large
  bool _disabled = false;
  double _pressedOpacity = 0.4;
  String? _disabledColor; // Hex color string like #RRGGBB or #AARRGGBB

  @override
  String get variant => _variant;

  @override
  set variant(value) {
    _variant = value;
  }

  @override
  String get size => _sizeStyle;

  @override
  set size(value) {
    _sizeStyle = value;
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    _disabled = value;
  }

  @override
  String get pressedOpacity => _pressedOpacity.toString();

  @override
  set pressedOpacity(value) {
    _pressedOpacity = double.tryParse(value) ?? 0.4;
  }

  @override
  String? get disabledColor => _disabledColor;

  @override
  set disabledColor(value) {
    _disabledColor = value;
  }

  double getDefaultMinSize() {
    return _sizeStyle == 'small' ? 32.0 : 44.0;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoButtonState(this);
  }
}

class FlutterCupertinoButtonState extends WebFWidgetElementState {
  FlutterCupertinoButtonState(super.widgetElement);

  @override
  FlutterCupertinoButton get widgetElement => super.widgetElement as FlutterCupertinoButton;

  Color? _parseCSSColor(CSSColor? color) {
    if (color == null) return null;
    return color.value;
  }

  Color? _parseAttrColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    var v = colorString.trim();
    if (v.startsWith('#')) {
      var hex = v.substring(1);
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return null;
  }

  EdgeInsetsGeometry getDefaultPadding() {
    return widgetElement._sizeStyle == 'small'
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get renderStyle
    final renderStyle = widgetElement.renderStyle;
    final hasWidth = renderStyle.width.computedValue != 0.0;
    final hasHeight = renderStyle.height.computedValue != 0.0;
    final hasPadding = renderStyle.padding != EdgeInsets.zero;
    final hasBorderRadius = renderStyle.borderRadius != null;
    final hasMinHeight = renderStyle.minHeight.computedValue != 0.0;
    final textAlign = renderStyle.textAlign;
    final backgroundColor = _parseCSSColor(renderStyle.backgroundColor);

    // Determine the alignment based on textAlign
    AlignmentGeometry alignment;
    switch (textAlign) {
      case TextAlign.left:
        alignment = Alignment.centerLeft;
        break;
      case TextAlign.right:
        alignment = Alignment.centerRight;
        break;
      default:
        alignment = Alignment.center;
    }

    // Get the color of the disabled state
    Color getDisabledColor() {
      // Attr override
      final override = _parseAttrColor(widgetElement.disabledColor);
      if (override != null) return override;
      switch (widgetElement._variant) {
        case 'filled':
          return isDark
              ? CupertinoColors.systemGrey4.darkColor
              : CupertinoColors.systemGrey4;
        case 'tinted':
          return isDark
              ? CupertinoColors.systemGrey5.darkColor
              : CupertinoColors.systemGrey5;
        default:
          return Colors.transparent;
      }
    }


    Widget buttonChild = WebFWidgetElementChild(child: widgetElement.childNodes.isEmpty
        ? const SizedBox()
        : widgetElement.childNodes.first.toWidget());

    Widget button;
    switch (widgetElement._variant) {
      case 'filled':
        button = CupertinoButton.filled(
          onPressed: widgetElement._disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          // Unify padding behavior: when width is fixed, remove internal padding
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? renderStyle.padding : getDefaultPadding()),
          disabledColor: getDisabledColor(),
          pressedOpacity: widgetElement._pressedOpacity,
          borderRadius: renderStyle.borderRadius != null
              ? BorderRadius.only(
                  topLeft: renderStyle.borderRadius![0],
                  topRight: renderStyle.borderRadius![1],
                  bottomRight: renderStyle.borderRadius![2],
                  bottomLeft: renderStyle.borderRadius![3],
                )
              : BorderRadius.zero,
          minSize: hasMinHeight ? renderStyle.minHeight.value : widgetElement.getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
        break;
      case 'tinted':
        button = CupertinoButton.tinted(
          onPressed: widgetElement._disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? renderStyle.padding : getDefaultPadding()),
          color: backgroundColor,
          disabledColor: getDisabledColor(),
          // Support asymmetric border radii
          borderRadius: hasBorderRadius
              ? BorderRadius.only(
                  topLeft: renderStyle.borderRadius![0],
                  topRight: renderStyle.borderRadius![1],
                  bottomRight: renderStyle.borderRadius![2],
                  bottomLeft: renderStyle.borderRadius![3],
                )
              : BorderRadius.circular(8),
          pressedOpacity: widgetElement._pressedOpacity,
          minSize: hasMinHeight ? renderStyle.minHeight.value : widgetElement.getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
        break;
      default:
        button = CupertinoButton(
          onPressed: widgetElement._disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? renderStyle.padding : getDefaultPadding()),
          color: backgroundColor,
          disabledColor: getDisabledColor(),
          // Support asymmetric border radii
          borderRadius: hasBorderRadius
              ? BorderRadius.only(
                  topLeft: renderStyle.borderRadius![0],
                  topRight: renderStyle.borderRadius![1],
                  bottomRight: renderStyle.borderRadius![2],
                  bottomLeft: renderStyle.borderRadius![3],
                )
              : BorderRadius.circular(8),
          pressedOpacity: widgetElement._pressedOpacity,
          minSize: hasMinHeight ? renderStyle.minHeight.value : widgetElement.getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
    }

    return button;
  }
}
