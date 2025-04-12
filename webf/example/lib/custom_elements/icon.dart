import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterIcon extends WidgetElement {
  FlutterIcon(super.context);

  static IconData? getIconType(String type) {
    switch (type) {
      case 'article':
        return Icons.article;
    }

    return null;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterIconState(this);
  }
}

class FlutterIconState extends WebFWidgetElementState {
  FlutterIconState(super.widgetElement);

  @override
  WidgetElement get widgetElement => super.widgetElement as FlutterIcon;

  @override
  Widget build(BuildContext context) {
    IconData? iconType = FlutterIcon.getIconType(widgetElement.getAttribute('type') ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      color: Colors.grey,
      size: 24.0,
      semanticLabel: 'Text to announce in accessibility modes',
    );
  }
}
