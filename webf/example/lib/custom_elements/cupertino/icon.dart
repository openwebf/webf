import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoIcon extends WidgetElement {
  FlutterCupertinoIcon(super.context);

  static IconData? getIconType(String type) {
    switch (type) {
      case 'eye':
        return CupertinoIcons.eye;
      case 'hand_thumbsup':
        return CupertinoIcons.hand_thumbsup;
      case 'hand_thumbsdown':
        return CupertinoIcons.hand_thumbsdown;
      case 'bookmark':
        return CupertinoIcons.bookmark;
      case 'ellipsis_circle':
        return CupertinoIcons.ellipsis_circle;        
    }

    return null;
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    IconData? iconType = getIconType(getAttribute('type') ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      // TODO: support color and size
      color: Colors.grey,
      size: 24.0,
      semanticLabel: 'Text to announce in accessibility modes',
    );
  }
}
