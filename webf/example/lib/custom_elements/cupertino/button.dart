import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoButton extends WidgetElement {
  FlutterCupertinoButton(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    // Get props from attributes
    final String type = attributes['type'] ?? 'default'; // default | primary | success | warning | danger
    final String size = attributes['size'] ?? 'middle'; // large | middle | small | mini
    final bool block = attributes['block'] != null && attributes['block'] != 'false';
    final bool disabled = attributes['disabled'] != null && attributes['disabled'] != 'false';
    final bool loading = attributes['loading'] != null && attributes['loading'] != 'false';
    final String shape = attributes['shape'] ?? 'default'; // default | rounded | rectangular
    final bool fill = attributes['fill'] != 'outline'; // true for solid, false for outline

    // Define colors based on type
    final Map<String, Color> typeColors = {
      'default': CupertinoColors.systemGrey,
      'primary': CupertinoColors.activeBlue,
      'success': CupertinoColors.systemGreen,
      'warning': CupertinoColors.systemOrange,
      'danger': CupertinoColors.systemRed,
    };

    // Define sizes
    final Map<String, double> buttonHeights = {
      'large': 44.0,
      'middle': 40.0,
      'small': 32.0,
      'mini': 24.0,
    };

    final Map<String, double> buttonFontSizes = {
      'large': 18.0,
      'middle': 16.0,
      'small': 14.0,
      'mini': 12.0,
    };

    // Define border radius based on shape
    final Map<String, double> shapeRadius = {
      'default': 8.0,
      'rounded': 24.0,
      'rectangular': 0.0,
    };

    // Build button style
    final Color buttonColor = typeColors[type] ?? typeColors['default']!;
    final double height = buttonHeights[size] ?? buttonHeights['middle']!;
    final double fontSize = buttonFontSizes[size] ?? buttonFontSizes['middle']!;
    final double borderRadius = shapeRadius[shape] ?? shapeRadius['default']!;

    Widget buttonChild = childNodes.isNotEmpty 
        ? childNodes.first.toWidget() 
        : const Text('');

    // Add loading spinner if loading
    if (loading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(
            radius: fontSize / 2,
          ),
          SizedBox(width: 8),
          buttonChild,
        ],
      );
    }

    return CupertinoButton(
      onPressed: disabled || loading ? null : () {
        dispatchEvent(Event('click'));
      },
      padding: renderStyle.padding == EdgeInsets.zero 
          ? EdgeInsets.symmetric(horizontal: height / 2) 
          : renderStyle.padding,
      color: fill ? buttonColor : null,
      disabledColor: CupertinoColors.systemGrey4,
      child: Container(
        height: height,
        width: block ? double.infinity : null,
        decoration: !fill ? BoxDecoration(
          border: Border.all(
            color: disabled ? CupertinoColors.systemGrey4 : buttonColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ) : null,
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: fontSize,
              color: fill 
                  ? CupertinoColors.white 
                  : disabled 
                      ? CupertinoColors.systemGrey4 
                      : buttonColor,
            ),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}