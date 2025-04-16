/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Widget buildLoadMore() {
    return widgetElement.hasEventListener('loadmore')
        ? Container(
      height: 50,
      alignment: Alignment.center,
      child: isLoadingMore ? const CupertinoActivityIndicator() : const SizedBox.shrink(),
    )
        : const SizedBox.shrink();
  }

  @override
  Widget buildRefreshControl() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        if (widgetElement.hasEventListener('refresh')) {
          widgetElement.dispatchEvent(dom.Event('refresh'));
          await Future.delayed(const Duration(seconds: 2));
        }
      },
    );
  }

  @override
  Widget buildRefreshIndicator(Widget scrollView) {
    return RefreshIndicator(
      onRefresh: () async {
        if (widgetElement.hasEventListener('refresh')) {
          widgetElement.dispatchEvent(dom.Event('refresh'));
          await Future.delayed(const Duration(seconds: 2));
        }
      },
      child: scrollView,
    );
  }

  @override
  void handleScroll() {
    double scrollPixels = scrollController?.position.pixels ?? 0;
    print('scrollling.. $scrollPixels');
  }

  @override
  bool hasRefreshIndicator() {
    return true;
  }

}
