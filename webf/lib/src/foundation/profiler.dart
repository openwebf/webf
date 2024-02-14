/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/rendering.dart';

/// Collect performance details of core components in WebF.

// Represent a paint step from a paint operation.
class _PaintSteps {
  DateTime startTime;
  late Duration duration;
  String label;
  _PaintSteps(this.startTime, this.label);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'duration': '${duration.inMicroseconds} us', //  Time elapsed for this paint step.
      'label': label,
    };
  }
}

// Represent a single paint operation in a single frame
class PaintOP {
  Stopwatch selfPaintClock;
  late Duration duration;
  late Duration selfPaintDuration;
  String renderBox;
  String ownerElement;
  final List<_PaintSteps> steps = [];
  final List<PaintOP> childrenPaintOp = [];

  _PaintSteps get currentStep => steps.last;

  PaintOP(this.selfPaintClock, this.renderBox, this.ownerElement);

  void recordPaintStep(_PaintSteps step) {
    steps.add(step);
  }

  void finishPaintStep() {
    DateTime currentTime = DateTime.now();

    _PaintSteps targetStep = currentStep;

    targetStep.duration = currentTime.difference(targetStep.startTime);
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'duration': '${duration.inMicroseconds} us', // Time elapsed for this paint operation.
      'renderObject': renderBox, // Target renderBox
      'ownerElement': ownerElement,
      'steps': steps
    };
  }
}

// Represent a series of paints in a single frame.
class _PaintPipeLine {
  final List<PaintOP> paintOp = [];
  final List<PaintOP> _paintStack = [];
  DateTime startTime;

  PaintOP get currentOp => paintOp.last;

  _PaintPipeLine() : startTime = DateTime.now();

  Set<String> renderObjects = {};
  int paintCount = 0;

  void recordPaintOp(PaintOP op) {
    paintOp.add(op);

    renderObjects.add(describeIdentity(op.renderBox));

    paintCount++;

    if (_paintStack.isNotEmpty) {
      _paintStack.last.childrenPaintOp.add(op);
    }

    _paintStack.add(op);
  }

  bool finishPaintOp() {
    PaintOP targetOp = _paintStack.last;
    targetOp.selfPaintClock.stop();
    targetOp.duration = targetOp.selfPaintClock.elapsed;
    _paintStack.removeLast();

    return _paintStack.isEmpty;
  }

  Duration get frameDuration {
    Duration duration = Duration.zero;

    for (int i = 0; i < paintOp.length; i++) {
      duration += paintOp[i].duration;
    }

    return duration;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'frameDuration': '${frameDuration.inMicroseconds} us', // Time elapsed for this paint
      'paintCount': paintCount, // Count for paint operations
      'paints': paintOp,
      'paintedRenderObjects': renderObjects.length, // Active renderObjects which was painted in this paint.
    };
  }
}

class WebFProfiler {
  static void initialize() {
    _instance ??= WebFProfiler();
    _instance!._recordForFrameCallback();
  }

  static WebFProfiler? _instance;

  static WebFProfiler get instance => _instance!;

  final List<_PaintPipeLine> _paintPipeLines = [];
  _PaintPipeLine get currentPipeline => _paintPipeLines.last;

  void _recordForFrameCallback() {
    scheduleMicrotask(() {
      _paintBeginInFrame();
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _paintEndInFrame();
      _recordForFrameCallback();
    });
  }

  void _paintBeginInFrame() {
    _paintPipeLines.add(_PaintPipeLine());
  }

  void _paintEndInFrame() {
    if (currentPipeline.paintCount == 0) {
      _paintPipeLines.removeLast();
    }
  }

  void startPaint(RenderBoxModel targetRenderObject) {
    Timeline.startSync(
      'WebF Paint Steps ${targetRenderObject.runtimeType}',
      arguments: {
        'ownerElement': targetRenderObject.renderStyle.target.toString(),
        'isRepaintBoundary': targetRenderObject.isRepaintBoundary,
        'isScrollingContentBox': targetRenderObject.isScrollingContentBox
      },
    );

    PaintOP op = PaintOP(
        Stopwatch()..start(), describeIdentity(targetRenderObject), targetRenderObject.renderStyle.target.toString());

    currentPipeline.recordPaintOp(op);
  }

  void finishPaint(RenderBoxModel targetRenderObject) {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    bool isPipeLineFinished = currentActivePipeline.finishPaintOp();

    if (isPipeLineFinished) {
      _paintBeginInFrame();
    }
  }

  void startTrackPaintStep(String label, [Map<String, dynamic>? arguments]) {
    Timeline.startSync(label, arguments: arguments);
    PaintOP activeOp = currentPipeline.currentOp;
    _PaintSteps step;
    step = _PaintSteps(DateTime.now(), label);
    activeOp.recordPaintStep(step);
  }

  void finishTrackPaintStep() {
    Timeline.finishSync();
    PaintOP activeOp = currentPipeline.currentOp;
    activeOp.finishPaintStep();
  }

  Map<String, dynamic> paintReport() {
    return {
      'totalFrames': _paintPipeLines.length, // Collected frame counts
      'frameDetails': _paintPipeLines
    };
  }

  Map<String, dynamic> report() {
    return {'paint': paintReport()};
  }
}
