import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoButton extends WidgetElement {
  FlutterCupertinoButton(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['type'] = ElementAttributeProperty(
      getter: () => _type,
      setter: (value) {
        _type = value;
        setState(() {});
      }
    );

    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value == 'true';
        setState(() {});
      }
    );
  }

  String _type = 'primary';
  bool _disabled = false;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getButtonColor() {
      if (_disabled) {
        return isDark 
          ? CupertinoColors.systemGrey3.darkColor 
          : CupertinoColors.systemGrey3;
      }
      
      switch (_type) {
        case 'primary':
          return isDark 
            ? CupertinoColors.systemBlue.darkColor 
            : CupertinoColors.systemBlue;
        case 'secondary':
          return isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6;
        default:
          return isDark 
            ? CupertinoColors.systemBlue.darkColor 
            : CupertinoColors.systemBlue;
      }
    }

    Color getTextColor() {
      if (_disabled) {
        return isDark 
          ? CupertinoColors.systemGrey.darkColor 
          : CupertinoColors.systemGrey;
      }

      switch (_type) {
        case 'primary':
          return CupertinoColors.white;
        case 'secondary':
          return isDark 
            ? CupertinoColors.white 
            : CupertinoColors.black;
        default:
          return CupertinoColors.white;
      }
    }

    return CupertinoButton(
      onPressed: _disabled ? null : () {
        dispatchEvent(Event('click'));
      },
      padding: EdgeInsets.zero,
      color: getButtonColor(),
      disabledColor: getButtonColor(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: TextStyle(
            color: getTextColor(),
            fontSize: renderStyle.fontSize.value ?? 16,
            fontWeight: renderStyle.fontWeight,
          ),
          child: childNodes.isEmpty 
            ? const SizedBox() 
            : childNodes.first.toWidget(),
        ),
      ),
    );
  }
}