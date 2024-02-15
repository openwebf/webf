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

// Represent a layout step from a layout operation.
class _LayoutSteps {
  Stopwatch startClock;
  late Duration duration;
  String label;
  _LayoutSteps(this.startClock, this.label);

  List<_LayoutSteps> childSteps = [];

  void addChildSteps(String label, _LayoutSteps step) {
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

class LayoutOP {
  Stopwatch selfLayoutClock;
  String renderBox;
  String ownerElement;

  final Map<String, _LayoutSteps> _stepMap = {};

  List<String> stepStack = [];
  List<_LayoutSteps> steps = [];
  _LayoutSteps? get currentStep => _stepMap[stepStack.last];

  late Duration duration;
  late Duration selfPaintDuration;

  final List<LayoutOP> childrenLayoutOp = [];

  LayoutOP(this.selfLayoutClock, this.renderBox, this.ownerElement);

  void recordLayoutStep(String label, _LayoutSteps step) {
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

  void finishLayoutStep() {
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
  final List<PaintOP> paintOp = [];
  final List<PaintOP> _paintStack = [];
  final List<LayoutOP> layoutOp = [];
  final List<LayoutOP> _layoutStack = [];

  DateTime startTime;

  PaintOP get currentPaintOp => _paintStack.last;
  LayoutOP get currentLayoutOp => _layoutStack.last;

  _PaintPipeLine() : startTime = DateTime.now();

  Set<String> paintRenderObjects = {};
  Set<String> layoutRenderObjects = {};
  int paintCount = 0;
  int layoutCount = 0;

  void recordPaintOp(PaintOP op) {
    paintOp.add(op);

    paintRenderObjects.add(describeIdentity(op.renderBox));

    paintCount++;

    if (_paintStack.isNotEmpty) {
      _paintStack.last.childrenPaintOp.add(op);
    }

    _paintStack.add(op);
  }

  void recordLayoutOp(LayoutOP op) {
    layoutOp.add(op);

    layoutRenderObjects.add(describeIdentity(op.renderBox));

    layoutCount++;

    if (_layoutStack.isNotEmpty) {
      _layoutStack.last.childrenLayoutOp.add(op);
    }

    _layoutStack.add(op);
  }

  bool finishPaintOp() {
    PaintOP targetOp = _paintStack.last;
    targetOp.selfPaintClock.stop();
    targetOp.duration = targetOp.selfPaintClock.elapsed;
    _paintStack.removeLast();

    return _paintStack.isEmpty;
  }

  bool finishLayoutOp() {
    LayoutOP targetOp = _layoutStack.last;
    targetOp.selfLayoutClock.stop();
    targetOp.duration = targetOp.selfLayoutClock.elapsed;

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
    PaintOP activeOp = currentPipeline.currentPaintOp;
    _PaintSteps step;
    step = _PaintSteps(DateTime.now(), label);
    activeOp.recordPaintStep(step);
  }

  void finishTrackPaintStep() {
    Timeline.finishSync();
    PaintOP activeOp = currentPipeline.currentPaintOp;
    activeOp.finishPaintStep();
  }

  Map<String, dynamic> frameReport() {
    return {
      'totalFrames': _paintPipeLines.length, // Collected frame counts
      'frameDetails': _paintPipeLines
    };
  }

  void startLayout(RenderBox targetRenderBox) {
    print('$targetRenderBox start layout');
    String ownerElement = targetRenderBox is RenderBoxModel ? targetRenderBox.renderStyle.target.toString() : '<Root>';
    Timeline.startSync(
      'WebF Layout ${targetRenderBox.runtimeType}',
      arguments: {
        'ownerElement': ownerElement,
        'isRepaintBoundary': targetRenderBox.isRepaintBoundary,
        'isScrollingContentBox': targetRenderBox is RenderBoxModel ? targetRenderBox.isScrollingContentBox : false
      },
    );

    LayoutOP op = LayoutOP(
        Stopwatch()..start(), describeIdentity(targetRenderBox), ownerElement);

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
    LayoutOP activeOp = currentPipeline.currentLayoutOp;
    _LayoutSteps step;
    step = _LayoutSteps(Stopwatch()..start(), label);
    activeOp.recordLayoutStep(label, step);
  }

  void finishTrackLayoutStep() {
    Timeline.finishSync();
    LayoutOP activeOp = currentPipeline.currentLayoutOp;
    activeOp.finishLayoutStep();
  }

  void pauseCurrentLayoutOp() {
    currentPipeline.currentLayoutOp.selfLayoutClock.stop();
    currentPipeline.currentLayoutOp._stepMap.forEach((key, step) {
      step.startClock.stop();
    });
  }

  void resumeCurrentLayoutOp() {
    currentPipeline.currentLayoutOp.selfLayoutClock.start();
    currentPipeline.currentLayoutOp._stepMap.forEach((key, step) {
      step.startClock.start();
    });
  }

  Map<String, dynamic> report() {
    return {'frames': frameReport()};
  }
}
