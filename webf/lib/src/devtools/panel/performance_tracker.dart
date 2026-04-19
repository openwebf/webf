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
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

/// Represents a single performance span in the rendering pipeline.
///
/// Primary timestamps are `startOffsetUs` / `endOffsetUs` — microseconds
/// from the [PerformanceTracker] session start, captured from a monotonic
/// stopwatch. `startTime`/`endTime` remain as derived `DateTime` values for
/// API compatibility with existing consumers. The wall-clock anchor is
/// captured once at session start; wall-clock drift during the session
/// (e.g. NTP adjustment) is not reflected in the derived DateTime values.
class PerformanceSpan {
  final String subType;
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
    required this.subType,
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
        'subType': subType,
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
      subType: json['subType'] as String,
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

/// Handle returned by [PerformanceTracker.beginEntry] to end an entry root.
///
/// Ending an entry pops it from the entry stack and clears (or restores)
/// the C++ profiler's current_entry_id. Child spans opened between
/// beginEntry/end auto-attribute to the entry via the existing _currentSpan
/// stack.
class EntryHandle {
  final PerformanceSpan _root;
  final PerformanceTracker _tracker;
  final int _entryId;
  final int _previousEntryId;

  EntryHandle._(this._root, this._tracker, this._entryId, this._previousEntryId);

  void end({Map<String, dynamic>? metadata}) {
    _root.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _root.metadata = (_root.metadata ?? {})..addAll(metadata);
    }
    _tracker._popEntry(_root, _previousEntryId);
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

  /// When true, [beginSpan] called outside any entry triggers an assertion.
  /// Default false because the spec allows uninstrumented call sites
  /// (Flutter framework callbacks like Future.then, Ticker, FutureBuilder
  /// rebuilds) to fall through to an `unattributed` root in production.
  /// Tests that want to verify dev-mode contract enforcement must opt in.
  bool assertOnUnattributedSpan = false;

  /// Top-level spans (not children of any other span).
  final List<PerformanceSpan> rootSpans = [];

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

  /// Stack of currently-open entry root spans. Mirrors the depth that the
  /// C++ profiler is aware of via current_entry_id_.
  final List<PerformanceSpan> _entryStack = [];

  /// Map from entry id → root span. Entries are added on push and stay
  /// until session reset (popping does NOT remove), so JS spans drained
  /// after the entry has closed still graft correctly.
  final Map<int, PerformanceSpan> _entryIdToSpan = {};

  /// Monotonic entry-id allocator. Reset to 1 on session start (0 reserved
  /// for "no entry active").
  int _nextEntryId = 1;

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
    _currentSpan = null;
    _totalSpanCount = 0;
    enabled = true;
    _entryStack.clear();
    _entryIdToSpan.clear();
    _entryIdMap.clear();
    _nextEntryId = 1;
    to_native.setJSProfilerCurrentEntryId(0);

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
    // Drain any remaining JS spans before tearing down state
    drainJSThreadSpans();
    // Disable C++ JS thread profiling
    to_native.setJSThreadProfilingEnabled(false);
    to_native.setJSProfilerCurrentEntryId(0);
    // Close any unclosed spans using the monotonic clock.
    final nowUs = nowOffsetUs();
    while (_currentSpan != null) {
      _currentSpan!.endOffsetUs ??= nowUs;
      _currentSpan = _currentSpan!.parent;
    }
    _entryStack.clear();
    _entryIdMap.clear();
  }

  /// Drain JS thread profiling spans from the C++ ring buffer and graft
  /// each into the unified span tree.
  ///
  /// For each drained native span:
  /// - Look up `entry_id` in [_entryIdToSpan]. Match → the JS span is added
  ///   as a child of the entry's deepest leaf descendant whose interval
  ///   contains the span's start time.
  /// - No match (`entry_id == 0` or unknown) → synthesize a new root span
  ///   with `subType` derived from the C++ category enum
  ///   (kJsCategorySubTypes[category]).
  void drainJSThreadSpans() {
    if (!enabled && _stopwatch == null) return;
    final offsetUs = _cppToDartOffsetUs ?? 0;
    final anchor = sessionStart;
    if (anchor == null) return;

    const maxDrain = 4096;
    final buffer = calloc<NativeJSThreadSpan>(maxDrain);
    try {
      final count = to_native.drainJSThreadProfilingSpans(buffer, maxDrain);
      if (count <= 0) return;

      final atomNameCache = <int, String>{};

      for (int i = 0; i < count; i++) {
        final native = buffer[i];
        final startOffsetUs = native.startUs + offsetUs;
        final endOffsetUs = native.endUs + offsetUs;

        final atom = native.funcNameAtom;
        String funcName = '';
        if (atom != 0) {
          funcName = atomNameCache[atom] ??= to_native.getJSProfilerAtomName(atom);
        }

        final categoryIdx = native.category;
        final subType = (categoryIdx >= 0 && categoryIdx < kJsCategorySubTypes.length)
            ? kJsCategorySubTypes[categoryIdx]
            : 'jsUnknown';

        _attachJSSpan(
          entryId: native.entryId,
          subType: subType,
          name: funcName,
          startOffsetUs: startOffsetUs,
          endOffsetUs: endOffsetUs,
          anchor: anchor,
        );
      }
    } finally {
      calloc.free(buffer);
    }
  }

  /// Attach a drained (or test-injected) JS span to the entry-rooted tree.
  /// If [entryId] resolves to a live entry root, graft as a child of the
  /// deepest leaf whose interval contains [startOffsetUs]; otherwise the
  /// span becomes a new root for JS-originated work with no Dart parent.
  void _attachJSSpan({
    required int entryId,
    required String subType,
    required String name,
    required int startOffsetUs,
    required int endOffsetUs,
    required DateTime anchor,
  }) {
    final root = entryId != 0 ? _entryIdToSpan[entryId] : null;
    if (root != null) {
      final parent = _findInsertionParent(root, startOffsetUs);
      final span = PerformanceSpan(
        subType: subType,
        name: name,
        startOffsetUs: startOffsetUs,
        depth: parent.depth + 1,
        sessionAnchor: anchor,
        parent: parent,
      );
      span.endOffsetUs = endOffsetUs;
      parent.children.add(span);
    } else {
      final span = PerformanceSpan(
        subType: subType,
        name: name,
        startOffsetUs: startOffsetUs,
        depth: 0,
        sessionAnchor: anchor,
      );
      span.endOffsetUs = endOffsetUs;
      rootSpans.add(span);
    }
    _totalSpanCount++;
  }

  /// Walks down [root] to find the deepest descendant whose interval
  /// contains [startOffsetUs]. Used to graft drained JS spans at the
  /// correct depth in the tree. Open-ended children (endOffsetUs == null)
  /// are treated as still ongoing — i.e. the interval extends to +∞ — so
  /// a mid-session drain can attribute a JS span to an open Dart entry.
  PerformanceSpan _findInsertionParent(PerformanceSpan root, int startOffsetUs) {
    PerformanceSpan candidate = root;
    while (true) {
      PerformanceSpan? next;
      for (final child in candidate.children) {
        if (child.startOffsetUs > startOffsetUs) continue;
        final endUs = child.endOffsetUs;
        if (endUs == null || startOffsetUs <= endUs) {
          next = child;
          break;
        }
      }
      if (next == null) return candidate;
      candidate = next;
    }
  }

  /// Test-only: inject a JS span as if it had just been drained from C++.
  /// `startUs` and `endUs` are C++ offsets (from C++ session_start_); this
  /// helper applies [_cppToDartOffsetUs] the same way [drainJSThreadSpans]
  /// would, so tests exercise the real correction math.
  @visibleForTesting
  void debugInjectJSSpan({
    required String subType,
    required int startUs,
    required int endUs,
    int entryId = 0,
    int funcNameAtom = 0,
    String funcName = '',
    int depth = 0,
  }) {
    final offsetUs = _cppToDartOffsetUs ?? 0;
    _attachJSSpan(
      entryId: entryId,
      subType: subType,
      name: funcName,
      startOffsetUs: startUs + offsetUs,
      endOffsetUs: endUs + offsetUs,
      anchor: sessionStart ?? DateTime.now(),
    );
  }

  /// Begin a new performance span.
  ///
  /// If another span is currently active, the new span becomes its child.
  /// Returns a [PerformanceSpanHandle] to end the span, or null if tracking
  /// is disabled or the span limit has been reached.
  ///
  /// [category] identifies the pipeline stage: 'cssParse', 'styleFlush',
  /// 'styleRecalc', 'styleApply', 'layout', 'paint'. Stored as
  /// [PerformanceSpan.subType].
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

    // Dev-mode contract: every span should live under an entry. In
    // production we silently promote to root with subType `unattributed`
    // and the original subType moved into the name field, so the panel
    // stays useful while we iterate. In dev (assertions enabled) we
    // surface the missing instrumentation immediately.
    String effectiveSubType = category;
    String effectiveName = name;
    if (_entryStack.isEmpty) {
      assert(!assertOnUnattributedSpan,
          'beginSpan called outside any entry: $category/$name. '
          'Wrap the call site in tracker.beginEntry(...) or use the '
          'unattributed subType explicitly.');
      effectiveSubType = 'unattributed';
      effectiveName = '$category/$name';
    }

    final span = PerformanceSpan(
      subType: effectiveSubType,
      name: effectiveName,
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

  /// Begin a new entry root.
  ///
  /// Pushes a fresh root span onto [rootSpans], registers an entry id with
  /// the C++ profiler so JS-thread spans drained later can be grafted under
  /// this root, and sets the entry as the active call-stack head.
  ///
  /// Entries can nest — eg. flushUICommand inside drawFrame's build phase.
  /// The inner becomes a child span of the outer (not a sibling root) so
  /// that "what work did this drawFrame trigger" attribution is preserved.
  ///
  /// Returns null when tracking is disabled or the span limit is reached.
  EntryHandle? beginEntry(String subType, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final root = PerformanceSpan(
      subType: subType,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: (_currentSpan != null) ? _currentSpan!.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: _currentSpan,
      metadata: metadata,
    );

    if (_currentSpan != null) {
      _currentSpan!.children.add(root);
    } else {
      rootSpans.add(root);
    }

    final entryId = _nextEntryId++;
    final previousEntryId = _entryStack.isEmpty
        ? 0
        : _entryIdMap[_entryStack.last] ?? 0;
    _entryIdToSpan[entryId] = root;
    _entryIdMap[root] = entryId;
    _entryStack.add(root);
    _currentSpan = root;
    _totalSpanCount++;

    to_native.setJSProfilerCurrentEntryId(entryId);

    return EntryHandle._(root, this, entryId, previousEntryId);
  }

  /// Reverse-lookup map: span → entry id. Used by [_popEntry] to find the
  /// id corresponding to the parent entry being restored.
  final Map<PerformanceSpan, int> _entryIdMap = {};

  void _popEntry(PerformanceSpan root, int previousEntryId) {
    if (_entryStack.isNotEmpty && identical(_entryStack.last, root)) {
      _entryStack.removeLast();
    } else {
      // Out-of-order pop (defensive — shouldn't happen with sane handle usage).
      _entryStack.remove(root);
    }
    _currentSpan = root.parent;
    to_native.setJSProfilerCurrentEntryId(previousEntryId);
    // Note: do NOT remove from _entryIdToSpan — JS spans drained later may
    // still need to graft under this completed root.
  }

  /// Total number of spans recorded in this session.
  int get totalSpanCount => _totalSpanCount;

  /// Whether the span limit has been reached.
  bool get isAtCapacity => _totalSpanCount >= maxSpans;

  /// Get all root spans of a specific subType.
  List<PerformanceSpan> rootSpansForSubType(String subType) {
    return rootSpans.where((s) => s.subType == subType).toList();
  }

  /// Clear all recorded spans without changing the enabled state.
  void clear() {
    rootSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    _entryStack.clear();
    _entryIdToSpan.clear();
    _entryIdMap.clear();
    _nextEntryId = 1;
    // Only reset C++ entry id when a session is active. When no session
    // is running, C++ profiling is disabled and the FFI sync would force
    // libwebf load in environments (e.g. unit tests) that never opted in.
    if (enabled) {
      to_native.setJSProfilerCurrentEntryId(0);
    }
  }

  /// Export the current session data as a JSON string.
  ///
  /// If [phases] is provided, they are included so that lifecycle milestones
  /// (FP, FCP, LCP, Attach) can be reconstructed on import.
  ///
  /// JS-thread spans are intentionally not exported in v5: under the
  /// entry-rooted model they are grafted into [rootSpans] at drain time
  /// (see Task 3.3), so the export is already complete via [rootSpans].
  String exportToJson({List<ExportablePhase>? phases}) {
    int countSpans(List<PerformanceSpan> spans) {
      int count = 0;
      for (final s in spans) {
        count += 1 + countSpans(s.children);
      }
      return count;
    }

    final data = <String, dynamic>{
      'version': 5,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessionStart': sessionStart?.microsecondsSinceEpoch,
      'totalSpanCount': countSpans(rootSpans),
      'rootSpans': rootSpans.map((s) => s.toJson()).toList(),
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

    // Hard-reject any version other than v5. Earlier formats encoded
    // categories as a flat enum and JS-thread spans as a parallel list,
    // both incompatible with the entry-rooted tree.
    final version = data['version'] as int?;
    if (version != 5) {
      throw FormatException(
        'Unsupported profile version: ${version ?? "missing"}. '
        'Expected version 5 (this build of WebF DevTools).',
      );
    }

    rootSpans.clear();
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
