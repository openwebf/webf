/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';


class FlutterCupertinoPickerItem extends WidgetElement {
  FlutterCupertinoPickerItem(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoPickerItemState(this);
  }
}

class FlutterCupertinoPickerItemState extends WebFWidgetElementState {
  FlutterCupertinoPickerItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}