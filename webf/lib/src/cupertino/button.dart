import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';

class FlutterCupertinoButton extends WidgetElement {
  FlutterCupertinoButton(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Button variant: filled | tinted | plain
    attributes['variant'] = ElementAttributeProperty(
      getter: () => _variant,
      setter: (value) {
        _variant = value;
        setState(() {});
      }
    );

    // Button size: small | large
    attributes['size'] = ElementAttributeProperty(
      getter: () => _sizeStyle,
      setter: (value) {
        _sizeStyle = value;
        setState(() {});
      }
    );

    // Whether the button is disabled
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
        setState(() {});
      }
    );

    // The opacity when the button is pressed
    attributes['pressed-opacity'] = ElementAttributeProperty(
      getter: () => _pressedOpacity.toString(),
      setter: (value) {
        _pressedOpacity = double.tryParse(value) ?? 0.4;
        setState(() {});
      }
    );
  }

  String _variant = 'plain';  // plain | filled | tinted
  String _sizeStyle = 'small';   // small | large
  bool _disabled = false;
  double _pressedOpacity = 0.4;

  EdgeInsetsGeometry getDefaultPadding() {
    return _sizeStyle == 'small'
      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
      : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  double getDefaultMinSize() {
    return _sizeStyle == 'small' ? 32.0 : 44.0;
  }

  Color? _parseCSSColor(CSSColor? color) {
    if (color == null) return null;
    return color.value;
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get renderStyle
    final style = renderStyle;
    final hasWidth = style?.width?.computedValue != 0.0;
    final hasHeight = style?.height?.computedValue != 0.0;
    final hasPadding = style?.padding != null && style!.padding != EdgeInsets.zero;
    final hasBorderRadius = style?.borderRadius != null;
    final hasMinHeight = style?.minHeight?.computedValue != 0.0;
    final textAlign = style?.textAlign ?? TextAlign.center;
    final backgroundColor = _parseCSSColor(style?.backgroundColor);

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
      switch (_variant) {
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
      if (_disabled) {
        return isDark
          ? CupertinoColors.systemGrey.darkColor
          : CupertinoColors.systemGrey;
      }

      switch (_variant) {
        case 'filled':
          return CupertinoColors.white;
        case 'tinted':
          return theme.primaryColor;
        default:
          return theme.primaryColor;
      }
    }

    Widget buttonChild = Container(
      width: hasWidth ? style.width.computedValue : null,
      height: hasHeight ? style.height.computedValue : null,
      alignment: alignment,
      child: DefaultTextStyle(
        style: TextStyle(
          color: getTextColor(),
          fontSize: _sizeStyle == 'small' ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        child: childNodes.isEmpty
          ? const SizedBox()
          : childNodes.first.toWidget(),
      ),
    );

    Widget button;
    switch (_variant) {
      case 'filled':
        button = CupertinoButton.filled(
          onPressed: _disabled ? null : () {
            dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? style!.padding! : getDefaultPadding()),
          disabledColor: getDisabledColor(),
          pressedOpacity: _pressedOpacity,
          borderRadius: hasBorderRadius
            ? BorderRadius.circular(style!.borderRadius!.first.x)
            : BorderRadius.circular(8),
          minSize: hasMinHeight ? style!.minHeight!.value : getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
        break;
      case 'tinted':
        button = CupertinoButton.tinted(
          onPressed: _disabled ? null : () {
            dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? style!.padding! : getDefaultPadding()),
          color: backgroundColor,
          disabledColor: getDisabledColor(),
          pressedOpacity: _pressedOpacity,
          borderRadius: hasBorderRadius
            ? BorderRadius.circular(style!.borderRadius!.first.x)
            : BorderRadius.circular(8),
          minSize: hasMinHeight ? style!.minHeight!.value : getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
        break;
      default:
        button = CupertinoButton(
          onPressed: _disabled ? null : () {
            dispatchEvent(Event('click'));
          },
          padding: hasWidth ? EdgeInsets.zero : (hasPadding ? style!.padding! : getDefaultPadding()),
          color: backgroundColor,
          disabledColor: getDisabledColor(),
          pressedOpacity: _pressedOpacity,
          borderRadius: hasBorderRadius
            ? BorderRadius.circular(style!.borderRadius!.first.x)
            : BorderRadius.circular(8),
          minSize: hasMinHeight ? style!.minHeight!.value : getDefaultMinSize(),
          alignment: alignment,
          child: buttonChild,
        );
    }

    return UnconstrainedBox(
      child: button,
    );
  }
}
