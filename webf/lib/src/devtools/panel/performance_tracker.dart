/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// A lightweight hierarchical performance span tracker for WebF's rendering pipeline.
///
/// Records start/end timing for CSS parse, style recalc, layout, and paint stages.
/// Uses a call-stack model: when [beginSpan] is called during a recursive operation
/// (e.g., nested layout), the new span automatically becomes a child of the active span.
///
/// Zero-cost when [enabled] is false (single boolean check per call).
library;

import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:webf/bridge.dart';
import 'package:webf/src/bridge/to_native.dart' as to_native;

/// Represents a single performance span in the rendering pipeline.
///
/// Primary timestamps are `startOffsetUs` / `endOffsetUs` — microseconds
/// from the [PerformanceTracker] session start, captured from a monotonic
/// stopwatch. `startTime`/`endTime` remain as derived `DateTime` values for
/// API compatibility with existing consumers. The wall-clock anchor is
/// captured once at session start; wall-clock drift during the session
/// (e.g. NTP adjustment) is not reflected in the derived DateTime values.
class PerformanceSpan {
  final String category;
  final String name;

  /// Monotonic offset from session start, in microseconds.
  final int startOffsetUs;

  /// Monotonic offset at span end. Null while the span is still open.
  int? endOffsetUs;

  final int depth;
  final PerformanceSpan? parent;
  final List<PerformanceSpan> children = [];
  Map<String, dynamic>? metadata;

  /// Wall-clock anchor used to derive [startTime] / [endTime]. Captured at
  /// [PerformanceTracker.sessionStart].
  final DateTime _sessionAnchor;

  PerformanceSpan({
    required this.category,
    required this.name,
    required this.startOffsetUs,
    required this.depth,
    required DateTime sessionAnchor,
    this.parent,
    this.metadata,
  }) : _sessionAnchor = sessionAnchor;

  /// Derived wall-clock start time (anchor + offset).
  DateTime get startTime =>
      _sessionAnchor.add(Duration(microseconds: startOffsetUs));

  /// Derived wall-clock end time, or null if span still open.
  DateTime? get endTime => endOffsetUs == null
      ? null
      : _sessionAnchor.add(Duration(microseconds: endOffsetUs!));

  Duration get duration => endOffsetUs != null
      ? Duration(microseconds: endOffsetUs! - startOffsetUs)
      : Duration.zero;

  /// Time spent in this span excluding children.
  Duration get selfDuration {
    final childTotal =
        children.fold<Duration>(Duration.zero, (sum, c) => sum + c.duration);
    final d = duration - childTotal;
    return d.isNegative ? Duration.zero : d;
  }

  bool get isComplete => endOffsetUs != null;

  /// Total number of spans in this subtree (including self).
  int get subtreeCount {
    int count = 1;
    for (final child in children) {
      count += child.subtreeCount;
    }
    return count;
  }

  /// Maximum depth in this subtree.
  int get maxDepth {
    int max = depth;
    for (final child in children) {
      final childMax = child.maxDepth;
      if (childMax > max) max = childMax;
    }
    return max;
  }

  /// Collect all spans at a given depth level (breadth-first).
  List<PerformanceSpan> spansAtDepth(int targetDepth) {
    final result = <PerformanceSpan>[];
    _collectAtDepth(targetDepth, result);
    return result;
  }

  void _collectAtDepth(int targetDepth, List<PerformanceSpan> result) {
    if (depth == targetDepth) {
      result.add(this);
      return;
    }
    for (final child in children) {
      child._collectAtDepth(targetDepth, result);
    }
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'name': name,
        'startOffsetUs': startOffsetUs,
        'endOffsetUs': endOffsetUs,
        'depth': depth,
        if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };

  static PerformanceSpan fromJson(Map<String, dynamic> json,
      {PerformanceSpan? parent, required DateTime sessionAnchor}) {
    final span = PerformanceSpan(
      category: json['category'] as String,
      name: json['name'] as String,
      startOffsetUs: json['startOffsetUs'] as int,
      depth: json['depth'] as int,
      sessionAnchor: sessionAnchor,
      parent: parent,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
    span.endOffsetUs = json['endOffsetUs'] as int?;
    if (json['children'] != null) {
      for (final childJson in json['children'] as List) {
        span.children.add(PerformanceSpan.fromJson(
          childJson as Map<String, dynamic>,
          parent: span,
          sessionAnchor: sessionAnchor,
        ));
      }
    }
    return span;
  }
}

/// Handle returned by [PerformanceTracker.beginSpan] to end a span.
class PerformanceSpanHandle {
  final PerformanceSpan _span;
  final PerformanceTracker _tracker;

  PerformanceSpanHandle._(this._span, this._tracker);

  /// End this span and pop back to the parent span.
  void end({Map<String, dynamic>? metadata}) {
    _span.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
    _tracker._currentSpan = _span.parent;
  }
}

/// Handle for async spans that don't participate in the call-stack model.
///
/// Unlike [PerformanceSpanHandle], ending this span does NOT modify
/// [PerformanceTracker._currentSpan], so synchronous spans that run
/// during the async gap are recorded independently as root spans.
class AsyncPerformanceSpanHandle {
  final PerformanceSpan _span;

  AsyncPerformanceSpanHandle._(this._span);

  void end({Map<String, dynamic>? metadata}) {
    _span.endOffsetUs = PerformanceTracker.instance.nowOffsetUs();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
  }
}

/// Singleton performance tracker that records hierarchical spans.
///
/// The tracker uses a [_currentSpan] pointer as a call stack. When [beginSpan]
/// is called during a recursive operation (e.g., flex layout calling child layout),
/// the new span automatically becomes a child of the active span:
///
/// ```
/// flexLayout [0-50ms]              // beginSpan → _currentSpan = flex
///   ├── flowLayout [2-15ms]        // beginSpan → _currentSpan = flow (child of flex)
///   │     └── flexLayout [5-10ms]  // beginSpan → _currentSpan = nestedFlex (child of flow)
///   └── gridLayout [20-40ms]       // beginSpan → _currentSpan = grid (child of flex)
/// ```
class PerformanceTracker {
  PerformanceTracker._();

  static final PerformanceTracker instance = PerformanceTracker._();

  /// Whether span recording is active. When false, [beginSpan] returns null immediately.
  bool enabled = false;

  /// Top-level spans (not children of any other span).
  final List<PerformanceSpan> rootSpans = [];

  /// JS thread spans collected from the C++ profiler.
  final List<JSThreadSpan> jsThreadSpans = [];

  /// Monotonic clock source. A fresh instance is created on every
  /// [startSession] call and used for all timing within that session.
  Stopwatch? _stopwatch;

  /// Absolute C++ steady_clock microseconds captured at the instant the Dart
  /// stopwatch was started. Derived from `getSteadyClockNowUs()` and the
  /// stopwatch's elapsed at that instant. Constant for the session.
  /// Note: there is a sub-ms skew equal to any OS/GC pause between the
  /// `getSteadyClockNowUs()` FFI call and the `elapsedMicroseconds` read.
  /// Accepted — well below visible waterfall resolution.
  int? _stopwatchStartAbsUs;

  /// Absolute C++ steady_clock microseconds of the C++ profiler's
  /// `session_start_`. Read via `getJSProfilerSessionStartUs()`.
  int? _cppSessionStartAbsUs;

  /// Delta to add to C++-reported JS span offsets (which are relative to
  /// `_cppSessionStartAbsUs`) to convert them into offsets relative to
  /// `_stopwatchStartAbsUs`. Constant for the session.
  int? _cppToDartOffsetUs;

  /// Currently active span (acts as call stack via parent pointer).
  PerformanceSpan? _currentSpan;

  /// When the current recording session started.
  DateTime? sessionStart;

  int _totalSpanCount = 0;

  /// Maximum number of spans to record per session to prevent memory issues.
  static const int maxSpans = 10000;

  /// Current monotonic offset from session start, in microseconds.
  /// Returns 0 if session has not started.
  int nowOffsetUs() => _stopwatch?.elapsedMicroseconds ?? 0;

  /// Offset to apply when converting a C++ JS span offset into a
  /// Dart-timeline offset. Visible for testing.
  @visibleForTesting
  int? get cppToDartOffsetUsForTest => _cppToDartOffsetUs;

  /// Start a new recording session. Clears all previous spans.
  void startSession() {
    sessionStart = DateTime.now();
    rootSpans.clear();
    jsThreadSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    enabled = true;

    // Step A: start Dart stopwatch, read C++ steady_clock, compute
    // `_stopwatchStartAbsUs` as the absolute steady_clock microseconds at
    // which the stopwatch started.
    final sw = Stopwatch()..start();
    final syncAbsUs = to_native.getSteadyClockNowUs();
    final syncElapsedUs = sw.elapsedMicroseconds;
    _stopwatch = sw;
    _stopwatchStartAbsUs = syncAbsUs - syncElapsedUs;

    // Step B: enable C++ profiling (this captures C++ session_start_).
    to_native.setJSThreadProfilingEnabled(true);
    final cppSessionStartAbsUs = to_native.getJSProfilerSessionStartUs();
    _cppSessionStartAbsUs = cppSessionStartAbsUs;
    _cppToDartOffsetUs = cppSessionStartAbsUs - _stopwatchStartAbsUs!;
  }

  /// End the current recording session. Spans are preserved for reading.
  void endSession() {
    enabled = false;
    // Drain any remaining JS spans
    drainJSThreadSpans();
    // Disable C++ JS thread profiling
    to_native.setJSThreadProfilingEnabled(false);
    // Close any unclosed spans using the monotonic clock.
    final nowUs = nowOffsetUs();
    while (_currentSpan != null) {
      _currentSpan!.endOffsetUs ??= nowUs;
      _currentSpan = _currentSpan!.parent;
    }
  }

  /// Drain JS thread profiling spans from the C++ ring buffer.
  /// Called during flushUICommand and at session end.
  ///
  /// C++ spans arrive as microsecond offsets from the C++ profiler's
  /// `session_start_`. We shift them by [_cppToDartOffsetUs] so they land on
  /// the shared Dart timeline (rooted at the stopwatch start).
  void drainJSThreadSpans() {
    if (!enabled && jsThreadSpans.isEmpty && _stopwatch == null) return;
    final offsetUs = _cppToDartOffsetUs ?? 0;

    const maxDrain = 4096;
    final buffer = calloc<NativeJSThreadSpan>(maxDrain);
    try {
      final count = to_native.drainJSThreadProfilingSpans(buffer, maxDrain);
      if (count <= 0) return;

      // Cache resolved atom names to avoid repeated FFI calls
      final atomNameCache = <int, String>{};

      for (int i = 0; i < count; i++) {
        final native = buffer[i];
        // Shift C++ offsets onto the Dart monotonic timeline.
        final startOffsetUs = native.startUs + offsetUs;
        final endOffsetUs = native.endUs + offsetUs;

        // Resolve function name from atom
        final atom = native.funcNameAtom;
        String funcName = '';
        if (atom != 0) {
          funcName = atomNameCache[atom] ??= to_native.getJSProfilerAtomName(atom);
        }

        jsThreadSpans.add(JSThreadSpan(
          category: JSThreadSpan.categoryFromIndex(native.category),
          startOffset: Duration(microseconds: startOffsetUs),
          endOffset: Duration(microseconds: endOffsetUs),
          funcNameAtom: atom,
          funcName: funcName,
          depth: native.depth,
        ));
      }
    } finally {
      calloc.free(buffer);
    }
  }

  /// Test-only: inject a JS span as if it had just been drained from C++.
  /// `startUs` and `endUs` are C++ offsets (from C++ session_start_); this
  /// helper applies [_cppToDartOffsetUs] the same way [drainJSThreadSpans]
  /// would, so tests exercise the real correction math.
  @visibleForTesting
  void debugInjectJSSpan({
    required String category,
    required int startUs,
    required int endUs,
    int funcNameAtom = 0,
    String funcName = '',
    int depth = 0,
  }) {
    final offsetUs = _cppToDartOffsetUs ?? 0;
    jsThreadSpans.add(JSThreadSpan(
      category: category,
      startOffset: Duration(microseconds: startUs + offsetUs),
      endOffset: Duration(microseconds: endUs + offsetUs),
      funcNameAtom: funcNameAtom,
      funcName: funcName,
      depth: depth,
    ));
  }

  /// Begin a new performance span.
  ///
  /// If another span is currently active, the new span becomes its child.
  /// Returns a [PerformanceSpanHandle] to end the span, or null if tracking
  /// is disabled or the span limit has been reached.
  ///
  /// [category] identifies the pipeline stage: 'cssParse', 'styleFlush',
  /// 'styleRecalc', 'styleApply', 'layout', 'paint'.
  ///
  /// [name] identifies the specific operation: 'parseStylesheet', 'flushStyle',
  /// 'recalculateStyle', 'flexLayout', 'paint', etc.
  ///
  /// Returns null when tracking is disabled, the span limit is reached, or
  /// no session has been started.
  PerformanceSpanHandle? beginSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final span = PerformanceSpan(
      category: category,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: (_currentSpan != null) ? _currentSpan!.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: _currentSpan,
      metadata: metadata,
    );

    if (_currentSpan != null) {
      _currentSpan!.children.add(span);
    } else {
      rootSpans.add(span);
    }

    _currentSpan = span;
    _totalSpanCount++;
    return PerformanceSpanHandle._(span, this);
  }

  /// Begin an async performance span that does NOT participate in the call stack.
  ///
  /// Use this for operations that cross `await` boundaries (JS evaluation,
  /// network fetches, HTML parsing). The span is always added as a root span
  /// and does not affect [_currentSpan], so synchronous spans that run during
  /// the async gap are recorded independently.
  ///
  /// Returns null when tracking is disabled, the span limit is reached, or
  /// no session has been started.
  AsyncPerformanceSpanHandle? beginAsyncSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final span = PerformanceSpan(
      category: category,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: 0,
      sessionAnchor: anchor,
      parent: null,
      metadata: metadata,
    );

    rootSpans.add(span);
    _totalSpanCount++;
    return AsyncPerformanceSpanHandle._(span);
  }

  /// Total number of spans recorded in this session.
  int get totalSpanCount => _totalSpanCount;

  /// Whether the span limit has been reached.
  bool get isAtCapacity => _totalSpanCount >= maxSpans;

  /// Get all root spans of a specific category.
  List<PerformanceSpan> rootSpansForCategory(String category) {
    return rootSpans.where((s) => s.category == category).toList();
  }

  /// Clear all recorded spans without changing the enabled state.
  void clear() {
    rootSpans.clear();
    jsThreadSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
  }

  /// Export the current session data as a JSON string.
  ///
  /// If [phases] is provided, they are included so that lifecycle milestones
  /// (FP, FCP, LCP, Attach) can be reconstructed on import.
  String exportToJson({List<ExportablePhase>? phases}) {
    int countSpans(List<PerformanceSpan> spans) {
      int count = 0;
      for (final s in spans) {
        count += 1 + countSpans(s.children);
      }
      return count;
    }

    final data = <String, dynamic>{
      'version': 4,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessionStart': sessionStart?.microsecondsSinceEpoch,
      'totalSpanCount': countSpans(rootSpans),
      'rootSpans': rootSpans.map((s) => s.toJson()).toList(),
      if (jsThreadSpans.isNotEmpty)
        'jsThreadSpans': jsThreadSpans.map((s) => s.toJson()).toList(),
    };
    if (phases != null && phases.isNotEmpty) {
      data['phases'] = phases.map((p) => p.toJson()).toList();
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Import session data from a JSON string, replacing current data.
  ///
  /// Returns imported [ExportablePhase] list if present in the data.
  List<ExportablePhase> importFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Version check BEFORE mutating state so a bad input doesn't wipe the
    // current session. v3 and older exports used 'startTime' instead of
    // 'offsetUs' and will cause a TypeError on deserialization if imported.
    final version = data['version'] as int?;
    if (version != 4) {
      throw FormatException(
        'Unsupported profile version: ${version ?? "missing"}. '
        'Expected version 4 (this build of WebF DevTools).',
      );
    }

    rootSpans.clear();
    jsThreadSpans.clear();
    _currentSpan = null;
    enabled = false;

    if (data['sessionStart'] != null) {
      sessionStart =
          DateTime.fromMicrosecondsSinceEpoch(data['sessionStart'] as int);
    }

    final anchor = sessionStart ?? DateTime.now();
    final spans = data['rootSpans'] as List;
    for (final spanJson in spans) {
      rootSpans.add(PerformanceSpan.fromJson(
        spanJson as Map<String, dynamic>,
        sessionAnchor: anchor,
      ));
    }
    _totalSpanCount = data['totalSpanCount'] as int? ?? rootSpans.length;

    // Restore JS thread spans if present
    final jsSpansJson = data['jsThreadSpans'] as List?;
    if (jsSpansJson != null) {
      for (final jsJson in jsSpansJson) {
        jsThreadSpans.add(JSThreadSpan.fromJson(jsJson as Map<String, dynamic>));
      }
    }

    // Restore phases if present
    final phasesJson = data['phases'] as List?;
    if (phasesJson != null) {
      return phasesJson
          .map((p) => ExportablePhase.fromJson(
                p as Map<String, dynamic>,
                sessionAnchor: anchor,
              ))
          .toList();
    }
    return [];
  }
}

/// Represents a single JS thread profiling span collected from QuickJS.
class JSThreadSpan {
  static const List<String> categoryNames = [
    'jsFunction',      // 0: kJSFunction
    'jsCFunction',     // 1: kJSCFunction
    'jsScriptEval',    // 2: kJSScriptEval
    'jsTimer',         // 3: kJSTimer
    'jsEvent',         // 4: kJSEvent
    'jsRAF',           // 5: kJSRAF
    'jsIdle',          // 6: kJSIdle
    'jsMicrotask',     // 7: kJSMicrotask
    'jsMutationObserver', // 8: kJSMutationObserver
    'jsFlushUICommand',   // 9: kJSFlushUICommand
    'jsBindingSyncCall',  // 10: kJSBindingSyncCall
  ];

  final String category;
  final Duration startOffset;  // from Dart session start
  final Duration endOffset;
  final int funcNameAtom;
  final String funcName;
  final int depth;

  JSThreadSpan({
    required this.category,
    required this.startOffset,
    required this.endOffset,
    required this.funcNameAtom,
    this.funcName = '',
    required this.depth,
  });

  Duration get duration => endOffset - startOffset;

  static String categoryFromIndex(int index) {
    if (index >= 0 && index < categoryNames.length) return categoryNames[index];
    return 'jsUnknown';
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'startOffsetUs': startOffset.inMicroseconds,
    'endOffsetUs': endOffset.inMicroseconds,
    'funcNameAtom': funcNameAtom,
    if (funcName.isNotEmpty) 'funcName': funcName,
    'depth': depth,
  };

  static JSThreadSpan fromJson(Map<String, dynamic> json) {
    return JSThreadSpan(
      category: json['category'] as String,
      startOffset: Duration(microseconds: json['startOffsetUs'] as int),
      endOffset: Duration(microseconds: json['endOffsetUs'] as int),
      funcNameAtom: json['funcNameAtom'] as int? ?? 0,
      funcName: json['funcName'] as String? ?? '',
      depth: json['depth'] as int,
    );
  }
}

/// Lightweight phase representation for export/import.
///
/// Captures name, wall-clock timestamp, and monotonic offset so that
/// lifecycle milestones (FP, FCP, LCP, Attach) survive round-tripping and
/// the waterfall can render them on the monotonic timeline.
class ExportablePhase {
  final String name;
  final DateTime timestamp;

  /// Monotonic offset from session start, in microseconds.
  final int offsetUs;

  ExportablePhase({
    required this.name,
    required this.timestamp,
    required this.offsetUs,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'offsetUs': offsetUs,
      };

  static ExportablePhase fromJson(Map<String, dynamic> json,
      {required DateTime sessionAnchor}) {
    final offsetUs = json['offsetUs'] as int;
    return ExportablePhase(
      name: json['name'] as String,
      timestamp: sessionAnchor.add(Duration(microseconds: offsetUs)),
      offsetUs: offsetUs,
    );
  }
}
