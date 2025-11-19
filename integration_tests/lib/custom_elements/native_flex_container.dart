import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class NativeFlexContainer extends WidgetElement {
  NativeFlexContainer(super.context);

  @override
  WebFWidgetElementState createState() {
    return NativeFlexContainerState(this);
  }
}

class NativeFlexContainerState extends WebFWidgetElementState {
  NativeFlexContainerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(child: const Text('456')),
        WebFWidgetElementChild(
          child: widgetElement.childNodes.firstOrNull?.toWidget(),
        ),
      ],
    );
  }
}

