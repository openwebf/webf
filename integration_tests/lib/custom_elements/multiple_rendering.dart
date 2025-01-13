import 'package:webf/webf.dart';
import 'package:flutter/widgets.dart';

class MultipleRenderElement extends WidgetElement {
  MultipleRenderElement(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Flex(
      direction: Axis.vertical,
      children: [
        childNodes.first.toWidget(key: Key('1')),
        Text('----'),
        childNodes.first.toWidget(key: Key('2')),
      ],
    );
  }
}
