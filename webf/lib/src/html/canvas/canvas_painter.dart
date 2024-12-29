/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'canvas_context_2d.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({required Listenable repaint}) : super(repaint: repaint);

  CanvasRenderingContext2D? context;

  final Paint _snapshotPaint = Paint();

  // Cache the last paint image.
  Image? _snapshot;
  Image? get snapshot => _snapshot;

  bool _shouldRepaint = false;
  // Indicate that snapshot is not generated yet, should not to perform next frame now.
  bool _updatingSnapshot = false;

  bool get _shouldPainting => context != null && context!.actionCount > 0;
  bool get _hasSnapshot => context != null && _snapshot != null;

  // Notice: Canvas is stateless, change scaleX or scaleY will case dropping drawn content.
  /// https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
  double _scaleX = 1.0;
  double get scaleX => _scaleX;
  set scaleX(double? value) {
    if (value != null && value != _scaleX) {
      _scaleX = value;
      _resetPaintingContext();
    }
  }

  double _scaleY = 1.0;
  double get scaleY => _scaleY;
  set scaleY(double? value) {
    if (value != null && value != _scaleY) {
      _scaleY = value;
      _resetPaintingContext();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_scaleX != 1.0 || _scaleY != 1.0) {
      canvas.scale(_scaleX, _scaleY);
    }

    // Paint new actions
    List<CanvasAction>? actions;
    if (_shouldPainting) {
      actions = context!.performActions(canvas, size);
    }

    // Clear actions after snapshot was created, or next frame call may empty.
    if (actions != null) {
      context!.clearActions(actions);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    if (_shouldRepaint) {
      _shouldRepaint = false;
      return true;
    }
    return !_updatingSnapshot;
  }

  void _resetPaintingContext() {
    _disposeSnapshot();
    _shouldRepaint = true;
  }

  void _disposeSnapshot() {
    _snapshot?.dispose();
    _snapshot = null;
  }

  void dispose() {
    _disposeSnapshot();
  }
}
