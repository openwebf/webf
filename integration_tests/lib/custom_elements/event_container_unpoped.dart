import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

class EventContainerUnpoped extends WidgetElement {
  EventContainerUnpoped(super.context);


  @override
  WebFWidgetElementState createState() {
    return EventContainerUnpopedState(this);
  }
}

class EventContainerUnpopedState extends WebFWidgetElementState {
  EventContainerUnpopedState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        // Normal event are not propagated.
        widgetElement.dispatchEvent(Event('tapped'));
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
