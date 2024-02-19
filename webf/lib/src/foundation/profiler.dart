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

enum OpItemType {
  uiCommand,
  layout,
  paint,
  network
}

class OpItem {
  Stopwatch selfClock;
  String? renderBox;
  String? ownerElement;

  final Map<String, _OpSteps> _stepMap = {};

  List<String> stepStack = [];
  List<_OpSteps> steps = [];

  _OpSteps? get currentStep => _stepMap[stepStack.last];

  late Duration duration;

  OpItem(this.selfClock, { this.renderBox, this.ownerElement });

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
    assert(!_stepMap.containsKey(label), 'exiting label = $label found');
    _stepMap[label] = step;
  }

  void finishStep() {
    currentStep!.startClock.stop();
    currentStep!.duration = currentStep!.startClock.elapsed;
    _stepMap.remove(currentStep!.label);
    stepStack.removeLast();
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    Map map = {
      'duration': '${duration.inMicroseconds} us', // Time elapsed for this paint operation.
      'steps': steps
    };
    if (renderBox != null) {
      map['renderObject'] = renderBox;
    }
    if (ownerElement != null) {
      map['ownerElement'] = ownerElement;
    }
    return map;
  }
}

// Represent a series of paints in a single frame.
class _PaintPipeLine {
  final List<OpItem> paintOp = [];
  final List<OpItem> _paintStack = [];
  final List<OpItem> layoutOp = [];
  final List<OpItem> _layoutStack = [];
  final List<OpItem> uiCommandOp = [];
  final List<OpItem> _uiCommandStack = [];
  final List<OpItem> networkOp = [];
  final List<OpItem> _networkStack = [];

  bool containsActiveUICommand() {
    return _uiCommandStack.isNotEmpty;
  }

  List<OpItem> _getOp(OpItemType type) {
    switch(type) {
      case OpItemType.paint:
        return paintOp;
      case OpItemType.uiCommand:
        return uiCommandOp;
      case OpItemType.layout:
        return layoutOp;
      case OpItemType.network:
        return networkOp;
    }
  }

  List<OpItem> _getOpStack(OpItemType type) {
    switch(type) {
      case OpItemType.uiCommand:
        return _uiCommandStack;
      case OpItemType.layout:
        return _layoutStack;
      case OpItemType.paint:
        return _paintStack;
      case OpItemType.network:
        return _networkStack;
    }
  }

  OpItem get currentPaintOp => _paintStack.last;
  OpItem get currentLayoutOp => _layoutStack.last;
  OpItem get currentUICommandOp => _uiCommandStack.last;
  OpItem get currentNetworkOp => _networkStack.last;

  _PaintPipeLine();

  Set<String> paintRenderObjects = {};
  Set<String> layoutRenderObjects = {};
  int paintCount = 0;
  int layoutCount = 0;
  int uiCommandCount = 0;
  int networkCount = 0;

  void recordOp(OpItemType type, OpItem op) {
    _getOp(type).add(op);

    if (type == OpItemType.paint) {
      paintRenderObjects.add(describeIdentity(op.renderBox));
      paintCount++;
    } else if (type == OpItemType.layout) {
      layoutRenderObjects.add(describeIdentity(op.renderBox));
      layoutCount++;
    } else if (type == OpItemType.uiCommand) {
      uiCommandCount++;
    } else if (type == OpItemType.network) {
      networkCount++;
    }

    _getOpStack(type).add(op);
  }

  bool finishOp(OpItemType type) {
    List<OpItem> opStack = _getOpStack(type);
    OpItem targetOp = opStack.last;
    targetOp.selfClock.stop();
    targetOp.duration = targetOp.selfClock.elapsed;

    opStack.removeLast();

    return opStack.isEmpty;
  }

  Duration totalOpDuration(List<OpItem> opList) {
    Duration duration = Duration.zero;

    for (int i = 0; i < opList.length; i++) {
      duration += opList[i].duration;
    }

    return duration;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Map toJson() {
    return {
      'totalDuration': '${totalOpDuration(uiCommandOp).inMicroseconds + totalOpDuration(layoutOp).inMicroseconds + totalOpDuration(paintOp).inMicroseconds} us',
      'uiCommandDuration': '${totalOpDuration(uiCommandOp).inMicroseconds} us',
      'uiCommands': uiCommandOp,
      'uiCommandCount': uiCommandCount,
      'layoutDuration': '${totalOpDuration(layoutOp).inMicroseconds} us',
      'layouts': layoutOp,
      'layoutCount': layoutCount,
      'layoutRenderObjects': layoutRenderObjects.length,
      'paintDuration': '${totalOpDuration(paintOp).inMicroseconds} us', // Time elapsed for this paint
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
    if (currentPipeline.paintCount == 0 && currentPipeline.uiCommandCount == 0) {
      _paintPipeLines.removeLast();
    }
  }

  void startTrackPaint(RenderBox renderBox) {
    String ownerElement = renderBox is RenderBoxModel ? renderBox.renderStyle.target.toString() : '';
    Timeline.startSync(
      'WebF Paint ${renderBox.runtimeType}',
      arguments: {
        'ownerElement': ownerElement,
        'isRepaintBoundary': renderBox.isRepaintBoundary,
        'isScrollingContentBox': renderBox is RenderBoxModel ? renderBox.isScrollingContentBox : false
      },
    );

    OpItem op = OpItem(
        Stopwatch()..start(), ownerElement: ownerElement, renderBox: describeIdentity(renderBox));

    currentPipeline.recordOp(OpItemType.paint, op);
  }

  void finishTrackPaint(RenderBox renderBox) {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    bool isPipeLineFinished = currentActivePipeline.finishOp(OpItemType.paint);

    if (isPipeLineFinished) {
      _paintBeginInFrame();
    }
  }

  void startTrackPaintStep(String label, [Map<String, dynamic>? arguments]) {
    Timeline.startSync(label, arguments: arguments);
    OpItem activeOp = currentPipeline.currentPaintOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackPaintStep() {
    Timeline.finishSync();
    OpItem activeOp = currentPipeline.currentPaintOp;
    activeOp.finishStep();
  }

  Map<String, dynamic> frameReport() {
    return {
      'totalFrames': _paintPipeLines.length, // Collected frame counts
      'frameDetails': _paintPipeLines
    };
  }

  void startTrackLayout(RenderBox targetRenderBox) {
    String ownerElement = targetRenderBox is RenderBoxModel ? targetRenderBox.renderStyle.target.toString() : '<Root>';
    Timeline.startSync(
      'WebF Layout ${targetRenderBox.runtimeType}',
      arguments: {
        'ownerElement': ownerElement,
        'isRepaintBoundary': targetRenderBox.isRepaintBoundary,
        'isScrollingContentBox': targetRenderBox is RenderBoxModel ? targetRenderBox.isScrollingContentBox : false
      },
    );

    OpItem op = OpItem(Stopwatch()..start(), ownerElement: ownerElement, renderBox: describeIdentity(targetRenderBox));

    currentPipeline.recordOp(OpItemType.layout, op);
  }

  void finishTrackLayout(RenderBox renderBox) {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    currentActivePipeline.finishOp(OpItemType.layout);
  }

  void startTrackLayoutStep(String label, [Map<String, dynamic>? arguments]) {
    Timeline.startSync(label, arguments: arguments);
    OpItem activeOp = currentPipeline.currentLayoutOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackLayoutStep() {
    Timeline.finishSync();
    OpItem activeOp = currentPipeline.currentLayoutOp;
    activeOp.finishStep();
  }

  void startTrackUICommand() {
    Timeline.startSync(
      'WebF FlushUICommand'
    );

    if (_paintPipeLines.isEmpty) {
      _paintBeginInFrame();
    }

    OpItem op = OpItem(Stopwatch()..start());

    currentPipeline.recordOp(OpItemType.uiCommand, op);
  }

  void startTrackUICommandStep(String label, [Map<String, dynamic>? arguments]) {
    Timeline.startSync(label, arguments: arguments);
    OpItem activeOp = currentPipeline.currentUICommandOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackUICommandStep() {
    Timeline.finishSync();
    OpItem activeOp = currentPipeline.currentUICommandOp;
    activeOp.finishStep();
  }

  void finishTrackUICommand() {
    Timeline.finishSync();

    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    currentActivePipeline.finishOp(OpItemType.uiCommand);
  }

  void startTrackNetwork() {
    Timeline.startSync(
        'WebF Networking'
    );

    if (_paintPipeLines.isEmpty) {
      _paintBeginInFrame();
    }

    OpItem op = OpItem(Stopwatch()..start());

    currentPipeline.recordOp(OpItemType.network, op);
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
