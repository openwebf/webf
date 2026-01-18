/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

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
  get disableBoxModelPaint => true;

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

  /// Get the foreground color for the button based on its variant.
  /// This retrieves the appropriate color from the ShadTheme.
  Color? _getForegroundColor(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ShadButtonTheme buttonTheme;

    switch (widgetElement.buttonVariant) {
      case ShadButtonVariant.primary:
        buttonTheme = theme.primaryButtonTheme;
        break;
      case ShadButtonVariant.secondary:
        buttonTheme = theme.secondaryButtonTheme;
        break;
      case ShadButtonVariant.destructive:
        buttonTheme = theme.destructiveButtonTheme;
        break;
      case ShadButtonVariant.outline:
        buttonTheme = theme.outlineButtonTheme;
        break;
      case ShadButtonVariant.ghost:
        buttonTheme = theme.ghostButtonTheme;
        break;
      case ShadButtonVariant.link:
        buttonTheme = theme.linkButtonTheme;
        break;
    }

    return buttonTheme.foregroundColor;
  }

  /// Extract text content from a list of nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  /// Extract CSS text styles from the first element child (if any).
  /// Returns a TextStyle with CSS properties like font-size, font-weight, etc.
  TextStyle? _extractCssTextStyle() {
    // Find the first element child to extract CSS from
    dom.Element? styledElement;
    for (final node in widgetElement.childNodes) {
      if (node is dom.Element) {
        styledElement = node;
        break;
      }
    }

    if (styledElement == null) return null;

    final style = styledElement.renderStyle;

    // Extract CSS properties and convert to Flutter TextStyle
    double? fontSize;
    FontWeight? fontWeight;
    FontStyle? fontStyle;
    double? letterSpacing;
    double? wordSpacing;
    TextDecoration? decoration;

    // Font size
    final cssFontSize = style.fontSize;
    if (cssFontSize.computedValue > 0) {
      fontSize = cssFontSize.computedValue;
    }

    // Font weight
    final cssFontWeight = style.fontWeight;
    if (cssFontWeight != FontWeight.normal) {
      fontWeight = cssFontWeight;
    }

    // Font style (italic)
    final cssFontStyle = style.fontStyle;
    if (cssFontStyle != FontStyle.normal) {
      fontStyle = cssFontStyle;
    }

    // Letter spacing
    final cssLetterSpacing = style.letterSpacing;
    if (cssLetterSpacing != null && cssLetterSpacing.computedValue != 0) {
      letterSpacing = cssLetterSpacing.computedValue;
    }

    // Word spacing
    final cssWordSpacing = style.wordSpacing;
    if (cssWordSpacing != null && cssWordSpacing.computedValue != 0) {
      wordSpacing = cssWordSpacing.computedValue;
    }

    // Text decoration (textDecorationLine returns Flutter's TextDecoration)
    final cssTextDecoration = style.textDecorationLine;
    if (cssTextDecoration != TextDecoration.none) {
      decoration = cssTextDecoration;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widgetElement.loading;
    final isDisabled = widgetElement.disabled;
    final isClickable = !isDisabled && !isLoading;

    // Get the foreground color from the button theme
    final foregroundColor = _getForegroundColor(context);

    // Get gradient from CSS background-image: linear-gradient(...)
    final cssGradient = widgetElement.renderStyle.backgroundImage?.gradient;

    // Get shadows from CSS box-shadow
    final cssShadows = widgetElement.renderStyle.shadows;

    // Build child widget from DOM children
    Widget? childWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      final textContent = _extractTextContent(widgetElement.childNodes);
      if (textContent.isNotEmpty) {
        // Extract CSS styles from child elements
        final cssTextStyle = _extractCssTextStyle();

        // Create TextStyle with foreground color and merged CSS styles
        final textStyle = TextStyle(
          color: foregroundColor,
          fontSize: cssTextStyle?.fontSize,
          fontWeight: cssTextStyle?.fontWeight,
          fontStyle: cssTextStyle?.fontStyle,
          letterSpacing: cssTextStyle?.letterSpacing,
          wordSpacing: cssTextStyle?.wordSpacing,
          decoration: cssTextStyle?.decoration,
        );

        childWidget = Text(textContent, style: textStyle);
      }
    }

    return ShadButton.raw(
      variant: widgetElement.buttonVariant,
      size: widgetElement.buttonSize,
      // Only show disabled styling when actually disabled, not when loading
      enabled: !isDisabled,
      // Apply CSS gradient if specified
      gradient: cssGradient,
      // Apply CSS box-shadow if specified
      shadows: cssShadows,
      onPressed: isClickable
          ? () {
              widgetElement.dispatchEvent(Event('click'));
            }
          : null,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ?? Colors.white,
                    ),
                  ),
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
