import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

class EventContainer extends WidgetElement {
  EventContainer(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return GestureDetector(
      onTapUp: (details) {
        MouseEvent mouseEvent = MouseEvent.fromTapUp(this, details);
        dispatchEvent(mouseEvent);
      },
      child: Column(
        children: [
          Text('Flutter Text'),
          ...childNodes.toWidgetList()
        ],
      ),
    );
  }
}
