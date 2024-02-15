/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/rendering.dart';

/// Collect performance details of core components in WebF.

// Represent a layout step from a layout operation.
class _OpSteps {
  Stopwatch startClock;
  late Duration duration;
  String label;

  _OpSteps(this.startClock, this.label);

  List<_OpSteps> childSteps = [];

  void addChildSteps(String label, _OpSteps step) {
    childSteps.add(step);
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'duration': '${duration.inMicroseconds} us', //  Time elapsed for this paint step.
      'label': label,
      'childSteps': childSteps
    };
  }
}

class LayoutOrPaintOp {
  Stopwatch selfClock;
  String renderBox;
  String ownerElement;

  final Map<String, _OpSteps> _stepMap = {};

  List<String> stepStack = [];
  List<_OpSteps> steps = [];

  _OpSteps? get currentStep => _stepMap[stepStack.last];

  late Duration duration;
  late Duration selfPaintDuration;

  LayoutOrPaintOp(this.selfClock, this.renderBox, this.ownerElement);

  void recordStep(String label, _OpSteps step) {
    bool isChildStep = false;
    if (stepStack.isNotEmpty) {
      isChildStep = true;
    }

    if (isChildStep) {
      currentStep!.addChildSteps(label, step);
    } else {
      steps.add(step);
    }

    stepStack.add(label);
    _stepMap[label] = step;
  }

  void finishStep() {
    currentStep!.startClock.stop();
    currentStep!.duration = currentStep!.startClock.elapsed;
    stepStack.removeLast();
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
  final List<LayoutOrPaintOp> paintOp = [];
  final List<LayoutOrPaintOp> _paintStack = [];
  final List<LayoutOrPaintOp> layoutOp = [];
  final List<LayoutOrPaintOp> _layoutStack = [];

  LayoutOrPaintOp get currentPaintOp => _paintStack.last;

  LayoutOrPaintOp get currentLayoutOp => _layoutStack.last;

  _PaintPipeLine();

  Set<String> paintRenderObjects = {};
  Set<String> layoutRenderObjects = {};
  int paintCount = 0;
  int layoutCount = 0;

  void recordPaintOp(LayoutOrPaintOp op) {
    paintOp.add(op);

    paintRenderObjects.add(describeIdentity(op.renderBox));

    paintCount++;

    _paintStack.add(op);
  }

  void recordLayoutOp(LayoutOrPaintOp op) {
    layoutOp.add(op);

    layoutRenderObjects.add(describeIdentity(op.renderBox));

    layoutCount++;

    _layoutStack.add(op);
  }

  bool finishPaintOp() {
    LayoutOrPaintOp targetOp = _paintStack.last;
    targetOp.selfClock.stop();
    targetOp.duration = targetOp.selfClock.elapsed;

    _paintStack.removeLast();

    return _paintStack.isEmpty;
  }

  bool finishLayoutOp() {
    LayoutOrPaintOp targetOp = _layoutStack.last;
    targetOp.selfClock.stop();
    targetOp.duration = targetOp.selfClock.elapsed;

    _layoutStack.removeLast();

    return _layoutStack.isEmpty;
  }

  Duration get paintDurations {
    Duration duration = Duration.zero;

    for (int i = 0; i < paintOp.length; i++) {
      duration += paintOp[i].duration;
    }

    return duration;
  }

  Duration get layoutDurations {
    Duration duration = Duration.zero;

    for (int i = 0; i < layoutOp.length; i++) {
      duration += layoutOp[i].duration;
    }

    return duration;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'layoutDuration': '${layoutDurations.inMicroseconds} us',
      'layouts': layoutOp,
      'layoutCount': layoutCount,
      'layoutRenderObjects': layoutRenderObjects.length,
      'paintDuration': '${paintDurations.inMicroseconds} us', // Time elapsed for this paint
      'paintCount': paintCount, // Count for paint operations
      'paints': paintOp,
      'paintedRenderObjects': paintRenderObjects.length, // Active renderObjects which was painted in this paint.
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
      'WebF Paint ${targetRenderObject.runtimeType}',
      arguments: {
        'ownerElement': targetRenderObject.renderStyle.target.toString(),
        'isRepaintBoundary': targetRenderObject.isRepaintBoundary,
        'isScrollingContentBox': targetRenderObject.isScrollingContentBox
      },
    );

    LayoutOrPaintOp op = LayoutOrPaintOp(
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
    LayoutOrPaintOp activeOp = currentPipeline.currentPaintOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackPaintStep() {
    Timeline.finishSync();
    LayoutOrPaintOp activeOp = currentPipeline.currentPaintOp;
    activeOp.finishStep();
  }

  Map<String, dynamic> frameReport() {
    return {
      'totalFrames': _paintPipeLines.length, // Collected frame counts
      'frameDetails': _paintPipeLines
    };
  }

  void startLayout(RenderBox targetRenderBox) {
    String ownerElement = targetRenderBox is RenderBoxModel ? targetRenderBox.renderStyle.target.toString() : '<Root>';
    Timeline.startSync(
      'WebF Layout ${targetRenderBox.runtimeType}',
      arguments: {
        'ownerElement': ownerElement,
        'isRepaintBoundary': targetRenderBox.isRepaintBoundary,
        'isScrollingContentBox': targetRenderBox is RenderBoxModel ? targetRenderBox.isScrollingContentBox : false
      },
    );

    LayoutOrPaintOp op = LayoutOrPaintOp(Stopwatch()..start(), describeIdentity(targetRenderBox), ownerElement);

    currentPipeline.recordLayoutOp(op);
  }

  void finishLayout(RenderBox renderBox) {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    currentActivePipeline.finishLayoutOp();
  }

  void startTrackLayoutStep(String label, [Map<String, dynamic>? arguments]) {
    Timeline.startSync(label, arguments: arguments);
    LayoutOrPaintOp activeOp = currentPipeline.currentLayoutOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackLayoutStep() {
    Timeline.finishSync();
    LayoutOrPaintOp activeOp = currentPipeline.currentLayoutOp;
    activeOp.finishStep();
  }

  void pauseCurrentLayoutOp() {
    currentPipeline.currentLayoutOp.selfClock.stop();
    currentPipeline.currentLayoutOp._stepMap.forEach((key, step) {
      step.startClock.stop();
    });
  }

  void pauseCurrentPaintOp() {
    currentPipeline.currentPaintOp.selfClock.stop();
    currentPipeline.currentPaintOp._stepMap.forEach((key, step) {
      step.startClock.stop();
    });
  }

  void resumeCurrentLayoutOp() {
    currentPipeline.currentLayoutOp.selfClock.start();
    currentPipeline.currentLayoutOp._stepMap.forEach((key, step) {
      step.startClock.start();
    });
  }

  void resumeCurrentPaintOp() {
    currentPipeline.currentPaintOp.selfClock.start();
    currentPipeline.currentPaintOp._stepMap.forEach((key, step) {
      step.startClock.start();
    });
  }

  Map<String, dynamic> report() {
    return {'frames': frameReport()};
  }
}
