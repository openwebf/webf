/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:webf/html.dart';
import 'package:webf/widget.dart';

class CustomWebFListView extends WebFListViewElement {
  CustomWebFListView(super.context);

  @override
  WebFWidgetElementState createState() {
    return CustomListViewState(this);
  }
}

class CustomListViewState extends WebFListViewState {
  CustomListViewState(super.widgetElement);
}
