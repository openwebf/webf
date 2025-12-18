/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/widget.dart';

// ignore: constant_identifier_names
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
        hasEvent: true,
        child: widgetElement.childNodes.isNotEmpty ? widgetElement.childNodes.first.toWidget() : SizedBox.shrink());
  }
}
