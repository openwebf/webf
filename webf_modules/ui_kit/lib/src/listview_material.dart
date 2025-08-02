/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:webf/html.dart';
import 'package:webf/widget.dart';
import 'package:easy_refresh/easy_refresh.dart';

class CustomWebFListViewWithMeterialRefreshIndicator extends WebFListViewElement {
  CustomWebFListViewWithMeterialRefreshIndicator(super.context);

  @override
  WebFWidgetElementState createState() {
    return CustomListViewStateWithMeterialRefreshIndicator(this);
  }
}

class CustomListViewStateWithMeterialRefreshIndicator extends WebFListViewState {
  CustomListViewStateWithMeterialRefreshIndicator(super.widgetElement);

  @override
  Header? buildEasyRefreshHeader() {
    return MaterialHeader();
  }

  @override
  Footer? buildEasyRefreshFooter() {
    return MaterialFooter();
  }
}
