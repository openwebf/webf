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
  Widget build(BuildContext context, ChildNodeList childNodes) {
    IconData? iconType = getIconType(getAttribute('type') ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      color: Colors.grey,
      size: 24.0,
      semanticLabel: 'Text to announce in accessibility modes',
    );
  }
}
