/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'canvas_context_2d.dart';
import 'canvas.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({required Listenable repaint}) : super(repaint: repaint);

  CanvasRenderingContext2D? context;

  final Paint _saveLayerPaint = Paint();
  bool _shouldRepaint = false;

  bool get _shouldPainting => context != null;

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

  final List<Picture> paintedPictures = [];

  @override
  void paint(Canvas rootCanvas, Size size) async {
    if (paintedPictures.isNotEmpty) {
      paintedPictures.forEach((picture) {
        rootCanvas.drawPicture(picture);
      });
    }

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    if (_scaleX != 1.0 || _scaleY != 1.0) {
      canvas.scale(_scaleX, _scaleY);
    }
    // This lets you create composite effects, for example making a group of drawing commands semi-transparent.
    // Without using saveLayer, each part of the group would be painted individually,
    // so where they overlap would be darker than where they do not. By using saveLayer to group them together,
    // they can be drawn with an opaque color at first,
    // and then the entire group can be made transparent using the saveLayer's paint.
    canvas.saveLayer(null, _saveLayerPaint);

    // Paint new actions
    List<CanvasAction>? actions;
    if (_shouldPainting) {
      actions = context!.performActions(canvas, size);
    }

    int actionLen = actions?.length ?? 0;

    // Must pair each call to save()/saveLayer() with a later matching call to restore().
    canvas.restore();

    // Clear actions after snapshot was created, or next frame call may empty.
    if (actions != null) {
      context!.clearActions(actions);
    }

    Picture picture = pictureRecorder.endRecording();
    if (actionLen > 0) {
      paintedPictures.add(picture);
      
      // Report FCP when canvas has content painted for the first time
      if (context != null && context!.canvas != null) {
        context!.canvas.ownerDocument.controller.reportFCP();
      }
    }

    rootCanvas.drawPicture(picture);
  }

  void _resetPaintingContext() {
    _shouldRepaint = true;
  }

  void dispose() {
    paintedPictures.clear();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
