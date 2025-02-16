import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoButton extends WidgetElement {
  FlutterCupertinoButton(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return CupertinoButton.filled(
      onPressed: () {
        dispatchEvent(Event('press'));
      },
      padding: renderStyle.padding == EdgeInsets.zero ? EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0) : renderStyle.padding,
      child: childNodes.isNotEmpty ? childNodes.first.toWidget() : const Text(''),
    );
  }
}
