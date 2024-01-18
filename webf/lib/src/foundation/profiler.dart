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

// Represent a operation to get the arguments from a paint step
class _PaintSubStep {
  late dynamic value;
  String? label;
  DateTime startTime;
  Duration duration = Duration.zero;

  _PaintSubStep({this.label, value}) : startTime = DateTime.now() {
    if (value != null) {
      this.value = value;
    }
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    if (label == null) {
      return value;
    }
    return {
      label: {'value': value, 'duration': '${duration.inMicroseconds} us'}
    };
  }
}

// Represent a paint step from a paint operation.
class _PaintSteps {
  DateTime startTime;
  late Duration duration;
  String label;
  final List<_PaintSubStep> subSteps = [];

  _PaintSteps(this.startTime, this.label);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'duration': '${duration.inMicroseconds} us', //  Time elapsed for this paint step.
      'label': label,
      'subSteps': subSteps
    };
  }
}

// Represent a single paint operation in a single frame
class _PaintOP {
  DateTime startTime;
  late Duration duration;
  String renderBox;
  String ownerElement;
  final List<_PaintSteps> steps = [];
  final List<_PaintOP> childrenPaintOp = [];

  _PaintOP(this.startTime, this.renderBox, this.ownerElement);

  void recordPaintStep(_PaintSteps step) {
    steps.add(step);
  }

  void finishPaintStep() {
    DateTime currentTime = DateTime.now();

    _PaintSteps targetStep = steps.last;

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
  final List<_PaintOP> paintOp = [];
  final List<_PaintOP> _paintStack = [];
  DateTime startTime;

  _PaintPipeLine() : startTime = DateTime.now();

  Set<String> renderObjects = {};
  int paintCount = 0;

  void recordPaintOp(_PaintOP op) {
    paintOp.add(op);

    renderObjects.add(describeIdentity(op.renderBox));

    paintCount++;

    if (_paintStack.isNotEmpty) {
      _paintStack.last.childrenPaintOp.add(op);
    }

    _paintStack.add(op);
  }

  bool finishPaintOp() {
    _PaintOP targetOp = _paintStack.last;
    DateTime currentTime = DateTime.now();

    Duration totalDuration = currentTime.difference(targetOp.startTime);

    for (int i = 0; i < targetOp.childrenPaintOp.length; i++) {
      totalDuration -= targetOp.childrenPaintOp[i].duration;
    }

    targetOp.duration = totalDuration;
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
      'ops': paintOp,
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
    if (_paintPipeLines.last.paintCount == 0) {
      _paintPipeLines.removeLast();
    }
  }

  void startPaint(RenderBoxModel targetRenderObject) {
    Timeline.startSync(
      '$targetRenderObject PAINT',
      arguments: {
        'ownerElement': targetRenderObject.renderStyle.target.toString(),
        'isRepaintBoundary': targetRenderObject.isRepaintBoundary,
        'isScrollingContentBox': targetRenderObject.isScrollingContentBox
      },
    );

    _PaintOP op = _PaintOP(
        DateTime.now(), describeIdentity(targetRenderObject), targetRenderObject.renderStyle.target.toString());
    _paintPipeLines.last.recordPaintOp(op);
  }

  void finishPaint() {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);

    _PaintPipeLine currentActivePipeline = _paintPipeLines.last;
    bool isPipeLineFinished = currentActivePipeline.finishPaintOp();

    if (isPipeLineFinished) {
      _paintBeginInFrame();
    }
  }

  void startTrackPaintStep(String label, [Map<String, dynamic>? arguments]) {
    _PaintOP activeOp = _paintPipeLines.last.paintOp.last;
    _PaintSteps step;
    if (arguments != null) {
      step = _PaintSteps(DateTime.now(), label);
      arguments.forEach((key, value) {
        var argument = _PaintSubStep(label: key, value: value);
        step.subSteps.add(argument);
      });
    } else {
      step = _PaintSteps(DateTime.now(), label);
    }
    activeOp.recordPaintStep(step);
  }

  void finishTrackPaintStep() {
    _PaintOP activeOp = _paintPipeLines.last.paintOp.last;
    activeOp.finishPaintStep();
  }

  void startTrackPaintSubStep(String label) {
    _PaintSteps activeStep = _paintPipeLines.last.paintOp.last.steps.last;
    activeStep.subSteps.add(_PaintSubStep(label: label));
  }

  void finishTrackPaintSubStep(value) {
    _PaintSteps activeStep = _paintPipeLines.last.paintOp.last.steps.last;
    activeStep.subSteps.last.value = value;
    activeStep.subSteps.last.duration = DateTime.now().difference(activeStep.subSteps.last.startTime);
  }

  Map<String, dynamic> paintReport() {
    return {
      'totalFrames': _paintPipeLines.length, // Collected frame counts
      'paintDetails': _paintPipeLines
    };
  }

  Map<String, dynamic> report() {
    return {'paint': paintReport()};
  }
}
