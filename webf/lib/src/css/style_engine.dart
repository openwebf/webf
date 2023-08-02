/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/css.dart';

// The StyleEngine class manages style-related state for the document. There is
// a 1-1 relationship of Document to StyleEngine. The document calls the
// StyleEngine when the document is updated in a way that impacts styles.
class StyleEngine {
  Document document;
  StyleNodeManager get styleNodeManager => _styleNodeManager;
  late StyleNodeManager _styleNodeManager;

  Set<Element> styleDirtyElements = {};

  StyleEngine(this.document) {
    _styleNodeManager = StyleNodeManager(document);
  }

  void childrenRemoved(ContainerNode parent) {
    if (!parent.isConnected) {
      return;
    }
    if (parent == parent.ownerDocument) {
      parent.ownerDocument.styleEngine.markElementNeedsStyleUpdate(parent.ownerDocument.documentElement!);
    } else {
      parent.ownerDocument.styleEngine.markElementNeedsStyleUpdate(parent as Element);
    }
  }

  void flushStyleSheetsStyleIfNeeded() {
    if (!styleNodeManager.hasPendingStyleSheet && !styleNodeManager.isStyleSheetCandidateNodeChanged) {
      return;
    }
    if (document.styleSheets.isEmpty && styleNodeManager.hasPendingStyleSheet) {
      flushStyleSheetStyle(rebuild: true);
      return;
    }
    flushStyleSheetStyle();
  }

  void markElementNeedsStyleUpdate(Element element) {
    styleDirtyElements.add(element);
    document.scheduleStyleNeedsUpdate();
  }

  void flushStyleSheetStyle({bool rebuild = false}) {
    if (styleDirtyElements.isEmpty) {
      return;
    }
    if (!styleNodeManager.updateActiveStyleSheets(rebuild: rebuild)) {
      styleDirtyElements.clear();
      return;
    }
    recalcStyle();
  }

  void recalcStyle({bool rebuild = false}) {
    if (styleDirtyElements.any((element) {
      return element is HeadElement || element is HTMLElement;
    }) ||
        rebuild) {
      document.documentElement?.recalculateStyle(rebuildNested: true);
    } else {
      List<Element> removedElements = [];
      for (Element element in styleDirtyElements) {
        bool success = element.recalculateStyle();
        if (success) {
          removedElements.add(element);
        }
      }
      styleDirtyElements.removeAll(removedElements);
    }
  }

}
