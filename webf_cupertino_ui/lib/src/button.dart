/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'button_bindings_generated.dart';

class FlutterCupertinoButton extends FlutterCupertinoButtonBindings {
  FlutterCupertinoButton(super.context);

  String _variant = 'plain';  // plain | filled | tinted
  String _sizeStyle = 'small';   // small | large
  bool _disabled = false;
  double _pressedOpacity = 0.4;

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
    _disabled = value != 'false';
  }

  @override
  String get pressedOpacity => _pressedOpacity.toString();
  @override
  set pressedOpacity(value) {
    _pressedOpacity = double.tryParse(value) ?? 0.4;
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
    final textAlign = renderStyle.textAlign ?? TextAlign.center;
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

    // Get the text color
    Color getTextColor() {
      if (widgetElement._disabled) {
        return isDark
            ? CupertinoColors.systemGrey.darkColor
            : CupertinoColors.systemGrey;
      }

      switch (widgetElement._variant) {
        case 'filled':
          return CupertinoColors.white;
        case 'tinted':
          return theme.primaryColor;
        default:
          return theme.primaryColor;
      }
    }

    Widget buttonChild = Container(
      width: hasWidth ? renderStyle.width.computedValue : null,
      height: hasHeight ? renderStyle.height.computedValue : null,
      alignment: alignment,
      child: DefaultTextStyle(
        style: TextStyle(
          color: getTextColor(),
          fontSize: widgetElement._sizeStyle == 'small' ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        child: widgetElement.childNodes.isEmpty
            ? const SizedBox()
            : widgetElement.childNodes.first.toWidget(),
      ),
    );

    Widget button;
    switch (widgetElement._variant) {
      case 'filled':
        button = CupertinoButton.filled(
          onPressed: widgetElement._disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? renderStyle.padding : getDefaultPadding()),
          disabledColor: getDisabledColor(),
          pressedOpacity: widgetElement._pressedOpacity,
          borderRadius: hasBorderRadius
              ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
              : BorderRadius.circular(8),
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
          pressedOpacity: widgetElement._pressedOpacity,
          borderRadius: hasBorderRadius
              ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
              : BorderRadius.circular(8),
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
          pressedOpacity: widgetElement._pressedOpacity,
          borderRadius: hasBorderRadius
              ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
              : BorderRadius.circular(8),
          minSize: hasMinHeight ? renderStyle.minHeight.value : widgetElement.getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
    }

    return UnconstrainedBox(
      child: button,
    );
  }
}
