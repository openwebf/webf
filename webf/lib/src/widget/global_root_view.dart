/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

/// A widget that renders the content of `<webf-global-root>` element.
///
/// Place this in a [Stack] above your route content so that global overlays
/// (modals, toasts, etc.) are always visible regardless of the current route.
///
/// This widget listens for globalRoot changes and rebuilds automatically.
class WebFGlobalRootView extends StatefulWidget {
  final WebFController controller;

  const WebFGlobalRootView({super.key, required this.controller});

  @override
  State<WebFGlobalRootView> createState() => _WebFGlobalRootViewState();
}

class _WebFGlobalRootViewState extends State<WebFGlobalRootView> {
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) setState(() {});
    };
    widget.controller.view.addGlobalRootListener(_listener!);
  }

  @override
  void didUpdateWidget(covariant WebFGlobalRootView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.view.removeGlobalRootListener(_listener!);
      widget.controller.view.addGlobalRootListener(_listener!);
    }
  }

  @override
  void dispose() {
    if (_listener != null) {
      widget.controller.view.removeGlobalRootListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalRoot = widget.controller.view.globalRoot;
    if (globalRoot == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: false,
      child: WebFContext(
        controller: widget.controller,
        child: WebFRouterViewport(
          controller: widget.controller,
          key: globalRoot.key,
          children: [globalRoot.toWidget()],
        ),
      ),
    );
  }
}
