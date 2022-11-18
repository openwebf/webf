import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

const Map<String, dynamic> _flutterContainerDefaultStyle = {
  'display': 'block',
  'width': '200px',
  'height': '200px',
  'border': '5px solid red'
};

class FlutterContainerElement extends WidgetElement {
  FlutterContainerElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _flutterContainerDefaultStyle;

  @override
  Widget build(BuildContext context, List<Widget> children) {
    double? topWidth = renderStyle.borderTopWidth?.value;
    double? rightWidth = renderStyle.borderRightWidth?.value;
    double? bottomWidth = renderStyle.borderBottomWidth?.value;
    double? leftWidth = renderStyle.borderLeftWidth?.value;

    return Container(
      width: renderStyle.width.value,
      height: renderStyle.height.value,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(width: topWidth ?? 0.0, color: renderStyle.borderTopColor),
            bottom: BorderSide(width: bottomWidth ?? 0.0, color: renderStyle.borderBottomColor),
            left: BorderSide(width: leftWidth ?? 0.0, color: renderStyle.borderLeftColor),
            right: BorderSide(width: rightWidth ?? 0.0, color: renderStyle.borderRightColor)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
