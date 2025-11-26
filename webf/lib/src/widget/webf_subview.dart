/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/devtools.dart';
import 'package:webf/html.dart';
import 'package:webf/launcher.dart';
import 'package:webf/widget.dart';

/// Signature for creating an [AppBar] for a WebF subview page.
///
/// The [title] is typically sourced from the current [RouterLinkElement]'s
/// `title` attribute. The [routeLinkElement] provides access to other
/// attributes on the route node.
typedef OnAppBarCreated = PreferredSizeWidget Function(String title, RouterLinkElement routeLinkElement);

class WebFSubView extends StatefulWidget {
  /// Subview container that renders a WebF route by [path].
  const WebFSubView(
      {super.key,
      required this.path,
      required this.controller,
      this.onAppBarCreated,
      this.errorBuilder,
      this.showDevTools = false});

  /// WebF controller hosting the hybrid router and DOM.
  final WebFController controller;
  /// Hybrid router path to render.
  final String path;
  /// Whether to force show DevTools inspector panel in non-debug builds.
  final bool showDevTools;
  /// Optional callback to build the page AppBar.
  final OnAppBarCreated? onAppBarCreated;
  /// Optional error builder when the route for [path] is not found.
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

    // Build content for the route body.
    Widget content = Stack(
      children: [
        WebFRouterView(controller: controller, path: widget.path),
        if (kDebugMode || widget.showDevTools)
          WebFInspectorFloatingPanel(
            visible: kDebugMode || widget.showDevTools,
          ),
      ],
    );

    return Scaffold(
      appBar: widget.onAppBarCreated != null
          ? widget.onAppBarCreated!(routerLinkElement.getAttribute('title') ?? '', routerLinkElement)
          : null,
      body: content,
    );
  }
}
