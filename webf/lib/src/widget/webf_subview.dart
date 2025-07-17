/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/devtools.dart';
import 'package:webf/html.dart';
import 'package:webf/launcher.dart';
import 'package:webf/widget.dart';

typedef OnAppBarCreated = AppBar Function(String title, RouterLinkElement routeLinkElement);

class WebFSubView extends StatefulWidget {
  const WebFSubView({super.key, required this.path, required this.controller, this.onAppBarCreated, this.errorBuilder});

  final WebFController controller;
  final String path;
  final OnAppBarCreated? onAppBarCreated;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  @override
  State<StatefulWidget> createState() {
    return WebFSubViewState();
  }
}

class WebFSubViewState extends State<WebFSubView> {
  @override
  Widget build(BuildContext context) {
    WebFController controller = widget.controller;
    RouterLinkElement? routerLinkElement = controller.view.getHybridRouterView(widget.path);

    if (routerLinkElement == null) {
      return widget.errorBuilder != null
          ? widget.errorBuilder!(context, FlutterError('Route page[${widget.path}] not found'))
          : Text('Route page[${widget.path}] not found');
    }

    return Scaffold(
      appBar: widget.onAppBarCreated != null
          ? widget.onAppBarCreated!(routerLinkElement.getAttribute('title') ?? '', routerLinkElement)
          : null,
      body: Stack(
        children: [
          WebFRouterView(controller: controller, path: widget.path),
          if (kDebugMode) WebFInspectorFloatingPanel(),
        ],
      ),
    );
  }
}
