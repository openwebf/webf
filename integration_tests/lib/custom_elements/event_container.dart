import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

class EventContainer extends WidgetElement {
  EventContainer(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return GestureDetector(
      onTap: () {
        dispatchEvent(new Event('tapped'));
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
