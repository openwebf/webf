import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

class EventContainerUnpoped extends WidgetElement {
  EventContainerUnpoped(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return GestureDetector(
      onTapUp: (details) {
        // Normal event are not propagated.
        dispatchEvent(Event('tapped'));
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
