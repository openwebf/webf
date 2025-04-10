import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterButton extends WidgetElement {
  FlutterButton(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    Widget button = ElevatedButton(onPressed: () {
      dispatchEvent(Event('press'));
    }, child: childNodes.isNotEmpty ? childNodes.first.toWidget() : Text(''));

    return (renderStyle.width.isNotAuto || renderStyle.height.isNotAuto) ? Container(
      width: renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null,
      height: renderStyle.height.isNotAuto ? renderStyle.height.computedValue : null,
      child: button,
    ) : button;
  }
}
