/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:webf/html.dart';
import 'package:webf/widget.dart';
import 'package:easy_refresh/easy_refresh.dart';

class CustomWebFListViewWithCupertinoRefreshIndicator extends WebFListViewElement {
  CustomWebFListViewWithCupertinoRefreshIndicator(super.context);

  @override
  WebFWidgetElementState createState() {
    return CustomListViewStateWithCupertinoRefreshIndicator(this);
  }
}

class CustomListViewStateWithCupertinoRefreshIndicator extends WebFListViewState {
  CustomListViewStateWithCupertinoRefreshIndicator(super.widgetElement);

  @override
  Header? buildEasyRefreshHeader() {
    return CupertinoHeader();
  }

  @override
  Footer? buildEasyRefreshFooter() {
    return CupertinoFooter();
  }
}
