import 'package:webf/webf.dart';
import 'package:flutter/widgets.dart';

class MultipleRenderElement extends WidgetElement {
  MultipleRenderElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return MultipleRenderElementState(this);
  }
}

class MultipleRenderElementState extends WebFWidgetElementState {
  MultipleRenderElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        widgetElement.childNodes.first.toWidget(key: Key('1')),
        Text('----'),
        widgetElement.childNodes.first.toWidget(key: Key('2')),
      ],
    );
  }
}
