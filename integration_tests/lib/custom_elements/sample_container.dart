
import 'package:flutter/cupertino.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class SampleContainer extends WidgetElement {
  SampleContainer(super.context);

  @override
  WebFWidgetElementState createState() {
    return SampleElementWidgetState(this);
  }

}

class SampleElementWidgetState extends WebFWidgetElementState {
  SampleElementWidgetState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: BoxConstraints(maxWidth: 28, maxHeight: 28), child: WebFWidgetElementChild(
      child: widgetElement.childNodes.firstOrNull?.toWidget(),
    ));
  }
}
