/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/src/dom/child_node_list.dart';
import 'package:webf/widget.dart';

const PORTAL = 'PORTAL';

class PortalElement extends WidgetElement {
  PortalElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return PortalElementState(this);
  }
}

class PortalElementState extends WebFWidgetElementState {
  PortalElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFEventListener(
        ownerElement: widgetElement,
        child: widgetElement.childNodes.isNotEmpty ? widgetElement.childNodes.first.toWidget() : SizedBox.shrink(),
        hasEvent: true);
  }
}
