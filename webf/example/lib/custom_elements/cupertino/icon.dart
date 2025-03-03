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
      case 'share':
        return CupertinoIcons.share;
      case 'chat_bubble':
        return CupertinoIcons.chat_bubble;
      case 'question_circle':
        return CupertinoIcons.question_circle;
      case 'search':
        return CupertinoIcons.search;
      case 'pencil':
        return CupertinoIcons.pencil;
      case 'gear':
        return CupertinoIcons.gear;
      case 'doc_text':
        return CupertinoIcons.doc_text;
      case 'heart':
        return CupertinoIcons.heart;
      case 'heart_fill':
        return CupertinoIcons.heart_fill;
      case 'bookmark':
        return CupertinoIcons.bookmark;
    }

    return null;
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    IconData? iconType = getIconType(getAttribute('type') ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      color: renderStyle.color.value,
      size: renderStyle.fontSize.value,
      semanticLabel: 'Text to announce in accessibility modes',
    );
  }
}
