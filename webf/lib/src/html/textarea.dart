/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';

const TEXTAREA = 'TEXTAREA';

const Map<String, dynamic> _textAreaDefaultStyle = {
  BORDER: '1px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
  WIDTH: '334.5px',
};

class FlutterTextAreaElement extends WidgetElement with BaseInputElement {
  FlutterTextAreaElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => _textAreaDefaultStyle;

  // The concatenation of the data of all the Text node descendants of node.
  // https://dom.spec.whatwg.org/#concept-descendant-text-content
  String get textContent {
    String str = '';
    // Set data of all text node children as value of textarea.
    for (Node child in childNodes) {
      if (child is TextNode) {
        str += child.data;
      }
    }
    return str;
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    defaultValue = textContent;
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return createInput(context, minLines: 3, maxLines: 5);
  }
}
