/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/devtools.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';

class InspectOverlayModule extends UIInspectorModule {
  @override
  String get name => 'Overlay';

  // Prefer context API (new architecture). Keep legacy controller fallback.
  DebuggingContext? get dbgContext => devtoolsService.context;

  Document? get document => dbgContext?.document ?? devtoolsService.controller?.view.document;

  InspectOverlayModule(super.devtoolsService);

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'highlightNode':
        onHighlightNode(id, params!);
        break;
      case 'highlightRect':
        onHighlightRect(id, params ?? const {});
        break;
      case 'hideHighlight':
        onHideHighlight(id);
        break;
    }
  }

  Element? _highlightElement;

  /// https://chromedevtools.github.io/devtools-protocol/tot/Overlay/#method-highlightNode
  void onHighlightNode(int? id, Map<String, dynamic> params) {
    _highlightElement?.debugHideHighlight();

    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Element? element;
    if (targetId != null) {
      element = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Element?;
    }

    if (element != null) {
      element.debugHighlight();
      _highlightElement = element;
    }
    sendToFrontend(id, null);
  }

  void onHideHighlight(int? id) {
    _highlightElement?.debugHideHighlight();
    _highlightElement = null;
    sendToFrontend(id, null);
  }

  /// Approximate Overlay.highlightRect behavior by hit-testing the rect center
  /// and applying element highlight. This keeps implementation minimal and
  /// non-invasive to the render pipeline.
  void onHighlightRect(int? id, Map<String, dynamic> params) {
    _highlightElement?.debugHideHighlight();

    final ctx = dbgContext;
    if (ctx == null || document == null) {
      sendToFrontend(id, null);
      return;
    }

    // Accept either int or double values
    double toDouble(dynamic v) {
      if (v is int) return v.toDouble();
      if (v is double) return v;
      return 0.0;
    }

    final double x = toDouble(params['x'] ?? params['left']);
    final double y = toDouble(params['y'] ?? params['top']);
    final double w = toDouble(params['width']);
    final double h = toDouble(params['height']);

    final double cx = x + (w > 0 ? w / 2 : 0);
    final double cy = y + (h > 0 ? h / 2 : 0);

    try {
      final rootRenderObject = document!.viewport!;
      final result = BoxHitTestResult();
      rootRenderObject.hitTest(result, position: Offset(cx, cy));
      var hitPath = result.path;
      if (hitPath.isNotEmpty) {
        // Skip non-element render targets
        final firstTarget = hitPath.first.target;
        if (firstTarget is WebFRenderImage ||
            (firstTarget is RenderBoxModel && firstTarget.renderStyle.target.pointer == null)) {
          hitPath = hitPath.skip(1);
        }

        if (hitPath.isNotEmpty && hitPath.first.target is RenderBoxModel) {
          final ro = hitPath.first.target as RenderBoxModel;
          final element = ro.renderStyle.target;
          element.debugHighlight();
          _highlightElement = element;
        }
      }
    } catch (_) {}

    sendToFrontend(id, null);
  }
}
