import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

class EventContainer extends WidgetElement {
  EventContainer(super.context);

  @override
  WebFWidgetElementState createState() {
    return EventContainerState(this);
  }
}

class EventContainerState extends WebFWidgetElementState {
  EventContainerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        MouseEvent mouseEvent = MouseEvent.fromTapUp(widgetElement, details);
        widgetElement.dispatchEvent(mouseEvent);
      },
      child: Column(
        children: [
          Text('Flutter Text'),
          ...widgetElement.childNodes.toWidgetList()
        ],
      ),
    );
  }

}
