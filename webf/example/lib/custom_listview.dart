/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart' as dom;
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

  @override
  Widget buildLoadMoreIndicator() {
    return Image.asset('assets/logo.png');
  }

  @override
  Widget? buildRefreshIndicator() {
    return CupertinoSliverRefreshControl(
      builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
        return Container(
          height: refreshIndicatorExtent,
          alignment: Alignment.center,
          child: Image.asset('assets/logo.png'),
        );
      },
      onRefresh: () async {
        if (widgetElement.hasEventListener('refresh')) {
          widgetElement.dispatchEvent(dom.Event('refresh'));
          await Future.delayed(const Duration(seconds: 2));
        }
      },
    );
  }

  @override
  RefreshControlStyle get refreshControlStyle => RefreshControlStyle.material;
}
