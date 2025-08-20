/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';

typedef ResizeChangeCallback = void Function(ResizeObserverEntry info);
mixin ResizeObserverMixin on RenderBox {
  /// A list of event handlers
  List<ResizeChangeCallback>? _listeners;

  Size? preContentSize;
  Size? preBorderSize;

  void disposeIntersectionObserverLayer() {}

  void addResizeListener(ResizeChangeCallback callback) {
    // Init things
    _listeners ??= List.empty(growable: true);
    // Avoid same listener added twice.
    if (!_listeners!.contains(callback)) {
      _listeners!.add(callback);
    }
  }

  void removeResizeListener(ResizeChangeCallback callback) {
    if (_listeners != null && _listeners!.contains(callback)) {
      _listeners!.remove(callback);
    }
  }

  bool needResizeNotify(Size newContentSize, Size newBorderSize) {
    return _listeners != null &&
        _listeners!.isNotEmpty &&
        !(newContentSize == preContentSize && newBorderSize == preBorderSize);
  }

  void dispatchResize(
    Size newContentSize,
    Size newBorderSize,
  ) {
    if (!needResizeNotify(newContentSize, newBorderSize)) {
      return;
    }
    preContentSize = newContentSize;
    preBorderSize = newBorderSize;

    _dispatchResizeChange(ResizeObserverEntry(
        borderBoxSize: newBorderSize,
        contentBoxSize: newContentSize,
        devicePixelContentBoxSize: newContentSize,
        contentRect: newBorderSize));
  }

  void _dispatchResizeChange(ResizeObserverEntry info) {
    // Not use for-in, and not cache length, due to callback call stack may
    // clear [_listeners], which case concurrent exception.
    for (int i = 0; i < (_listeners == null ? 0 : _listeners!.length); i++) {
      _listeners![i](info);
    }
  }
}

class ResizeObserverEntry {
  ResizeObserverEntry({Size? borderBoxSize, Size? contentBoxSize, Size? devicePixelContentBoxSize, Size? contentRect})
      : borderBoxSize = borderBoxSize ?? Size.zero,
        contentBoxSize = contentBoxSize ?? Size.zero,
        devicePixelContentBoxSize = devicePixelContentBoxSize ?? Size.zero,
        contentRect = contentRect ?? Size.zero;
  final Size borderBoxSize;
  final Size contentBoxSize;
  final Size devicePixelContentBoxSize;
  final Size contentRect;
  late EventTarget target;

  String toJson() {
    return jsonEncode({
      'borderBoxSize': {'blockSize': borderBoxSize.height, 'inlineSize': borderBoxSize.width},
      'contentBoxSize': {'blockSize': contentBoxSize.height, 'inlineSize': contentBoxSize.width},
      'contentRect': {'x': 0, 'y': 0, 'width': contentRect.width, 'height': contentRect.height},
    });
  }
}
