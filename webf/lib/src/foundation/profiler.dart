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
import 'package:webf/bridge.dart';

/// Collect performance details of core components in WebF.
bool enableWebFProfileTracking = false;

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
  binding,
}

class OpItem {
  Stopwatch selfClock;
  String? renderBox;
  String? ownerElement;
  String? url;

  final Map<String, _OpSteps> _stepMap = {};

  List<String> stepStack = [];
  List<_OpSteps> steps = [];

  _OpSteps? get currentStep => _stepMap[stepStack.last];

  late Duration duration;

  OpItem(this.selfClock, { this.renderBox, this.ownerElement, this.url });

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
    if (url != null) {
      map['url'] = url;
    }
    return map;
  }
}

class NetworkOpItem extends OpItem {
  NetworkOpItem(super.selfClock, { super.url });

  bool pending = false;

  @override
  Map toJson() {
    Map map = {
      'pending': pending,
      'duration': '${pending ? 'NaN' : duration.inMicroseconds} us', // Time elapsed for this paint operation.
      'steps': steps
    };
    if (url != null) {
      map['url'] = url;
    }
    return map;
  }
}

class EvaluateOpItem extends OpItem {
  EvaluateOpItem(super.selfClock, this.label);

  String label;

  List<dynamic> nativeSteps = [];

  @override
  Map toJson() {
    Map map = {
      'label': label,
      'duration': '${duration.inMicroseconds} us', // Time elapsed for this paint operation.
      'steps': nativeSteps
    };
    return map;
  }
}

class BindingOpItem extends OpItem {
  BindingOpItem(super.selfClock, this.profileId);

  int profileId;

  @override
  Map toJson() {
    Map map = super.toJson();
    map['profileId'] = profileId;
    return map;
  }
}

class _NetworkOpSteps extends _OpSteps {
  bool pending = false;

  _NetworkOpSteps(super.startClock, super.label);

  @override
  Map toJson() {
    return {
      'duration': '${pending ? 'NaN' : duration.inMicroseconds} us', //  Time elapsed for this paint step.
      'label': label,
      'childSteps': childSteps
    };
  }
}

// Represent a series of paints in a single frame.
class _PaintPipeLine {
  final List<OpItem> paintOp = [];
  final List<OpItem> layoutOp = [];
  final List<OpItem> uiCommandOp = [];
  final List<OpItem> bindingOp = [];

  final List<OpItem> _stack = [];

  bool containsActiveUICommand() {
    return _stack.isNotEmpty;
  }

  List<OpItem> _getOp(OpItemType type) {
    switch(type) {
      case OpItemType.paint:
        return paintOp;
      case OpItemType.uiCommand:
        return uiCommandOp;
      case OpItemType.layout:
        return layoutOp;
      case OpItemType.binding:
        return bindingOp;
    }
  }

  List<OpItem> _getOpStack(OpItemType type) {
    return _stack;
  }

  OpItem get currentPaintOp => _stack.last;
  OpItem get currentLayoutOp => _stack.last;
  OpItem get currentUICommandOp => _stack.last;
  OpItem get currentBindingOp => _stack.last;

  _PaintPipeLine();

  Set<String> paintRenderObjects = {};
  Set<String> layoutRenderObjects = {};
  int paintCount = 0;
  int layoutCount = 0;
  int uiCommandCount = 0;

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
  final Map<String, NetworkOpItem> _networkOpMap = {};
  final List<NetworkOpItem> _networkOp = [];

  final Map<int, EvaluateOpItem> _evaluateOpMap = {};
  final List<EvaluateOpItem> _evaluateOp = [];

  final Map<String, BindingOpItem> _bindingOpMap = {};

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
    if (_paintPipeLines.isNotEmpty && currentPipeline.paintCount == 0 && currentPipeline.uiCommandCount == 0 && currentPipeline.layoutCount == 0) {
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

  void startTrackLayout(RenderObject targetRenderObject) {
    String ownerElement = targetRenderObject is RenderBoxModel ? targetRenderObject.renderStyle.target.toString() : '<Root>';
    Timeline.startSync(
      'WebF Layout ${targetRenderObject.runtimeType}',
      arguments: {
        'ownerElement': ownerElement,
        'isRepaintBoundary': targetRenderObject.isRepaintBoundary,
        'isScrollingContentBox': targetRenderObject is RenderBoxModel ? targetRenderObject.isScrollingContentBox : false
      },
    );

    OpItem op = OpItem(Stopwatch()..start(), ownerElement: ownerElement, renderBox: describeIdentity(targetRenderObject));

    currentPipeline.recordOp(OpItemType.layout, op);
  }

  void finishTrackLayout(RenderObject renderObject) {
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
    if (currentPipeline._stack.isEmpty) return;

    Timeline.startSync(label, arguments: arguments);
    OpItem activeOp = currentPipeline.currentUICommandOp;
    _OpSteps step;
    step = _OpSteps(Stopwatch()..start(), label);
    activeOp.recordStep(label, step);
  }

  void finishTrackUICommandStep() {
    if (currentPipeline._stack.isEmpty) return;
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

  NetworkOpItem startTrackNetwork(String url) {

    NetworkOpItem op = NetworkOpItem(Stopwatch()..start(), url: url);
    _networkOp.add(op);
    op.pending = true;

    _networkOpMap[url] = op;

    return op;
  }

  NetworkOpItem? getCurrentOpFromUrl(String url) {
    return _networkOpMap[url];
  }

  void startTrackNetworkStep(NetworkOpItem activeOp, String label, [Map<String, dynamic>? arguments]) {
    _NetworkOpSteps step =  _NetworkOpSteps(Stopwatch()..start(), label);
    step.pending = true;
    activeOp.recordStep(label, step);
  }

  void finishTrackNetworkStep(NetworkOpItem activeOp) {
    (activeOp.currentStep as _NetworkOpSteps).pending = false;
    activeOp.finishStep();
  }

  void finishTrackNetwork(NetworkOpItem targetOp) {
    targetOp.selfClock.stop();
    targetOp.duration = targetOp.selfClock.elapsed;
    targetOp.pending = false;
    _networkOpMap.remove(targetOp.url);
  }

  EvaluateOpItem startTrackEvaluate(String label) {
    EvaluateOpItem op = EvaluateOpItem(Stopwatch()..start(), label);
    _evaluateOp.add(op);

    _evaluateOpMap[op.hashCode] = op;

    return op;
  }

  void finishTrackEvaluate(EvaluateOpItem targetOp) {
    targetOp.selfClock.stop();
    targetOp.duration = targetOp.selfClock.elapsed;
  }

  BindingOpItem startTrackBinding(int profileId) {
    if (_paintPipeLines.isEmpty) {
      _paintBeginInFrame();
    }

    BindingOpItem op = BindingOpItem(Stopwatch()..start(), profileId);
    _bindingOpMap[profileId.toString()] = op;
    currentPipeline.recordOp(OpItemType.binding, op);
    return op;
  }

  void startTrackBindingSteps(BindingOpItem targetOp, String label) {
    _OpSteps step = _OpSteps(Stopwatch()..start(), label);
    targetOp.recordStep(label, step);
  }

  void finishTrackBindingSteps(BindingOpItem targetOp) {
    targetOp.finishStep();
  }

  void finishTrackBinding(int profileId) {
    assert(_paintPipeLines.isNotEmpty);
    _PaintPipeLine currentActivePipeline = currentPipeline;
    currentActivePipeline.finishOp(OpItemType.uiCommand);
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

  void _mergeEvaluateProfileData(Map<String, dynamic> nativeData) {
    nativeData.forEach((key, value) {
      EvaluateOpItem? opItem = _evaluateOpMap[int.parse(key)];

      var matches = RegExp(r'\d+').firstMatch(value['duration']);
      opItem!.duration = Duration(microseconds: int.parse(matches!.group(0)!));
      opItem.nativeSteps = value['steps'];
    });
  }

  void _mergeBindingProfileData(Map<String, dynamic> source, Map<String, dynamic> linkData) {
    linkData.forEach((key, pathString) {
      List<String> paths = (pathString as String).split('/');

      dynamic profileItem = source[paths[0]]['steps'];

      dynamic target = profileItem;
      for(int i = 1; i < paths.length - 1; i ++) {
        Map stepMap = target[int.parse(paths[i])];
        target = stepMap['childSteps'];
      }

      int targetProfileId = target[0]['profileId'];
      target[0]['childSteps'].add(_bindingOpMap[targetProfileId.toString()]!.toJson());
    });
  }

  Map<String, dynamic> report() {
    String nativeProfileData = collectNativeProfileData();
    Map<String, dynamic> profileData = jsonDecode(nativeProfileData);

    _mergeBindingProfileData(profileData['evaluate'], profileData['link']);
    _mergeEvaluateProfileData(profileData['evaluate']);

    return {
      'networks': _networkOp,
      'native_initialize': profileData['initialize'],
      'evaluate': _evaluateOp,
      'async_evaluate': profileData['async_evaluate'],
      'frames': frameReport(),
    };
  }

  void clear() {
    clearNativeProfileData();
    _networkOpMap.clear();
    _networkOp.clear();
    _evaluateOp.clear();
    _evaluateOpMap.clear();
    _bindingOpMap.clear();
    _paintPipeLines.clear();
  }
}
