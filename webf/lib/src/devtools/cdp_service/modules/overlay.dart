/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'package:webf/dom.dart';
import 'package:webf/devtools.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';
import 'package:webf/foundation.dart';

class InspectOverlayModule extends UIInspectorModule {
  @override
  String get name => 'Overlay';

  // Prefer context API (new architecture). Keep legacy controller fallback.
  DebuggingContext? get dbgContext => devtoolsService.context;

  Document? get document => dbgContext?.document ?? devtoolsService.controller?.view.document;

  InspectOverlayModule(DevToolsService devtoolsService) : super(devtoolsService);

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'highlightNode':
        onHighlightNode(id, params!);
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
}
