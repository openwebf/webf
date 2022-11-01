import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/html.dart';

const TEXTAREA = 'TEXTAREA';

class FlutterTextAreaElement extends WidgetElement with BaseInputElement {
  FlutterTextAreaElement(super.context);

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return createInput(context, minLines: 3, maxLines: 5);
  }
}
